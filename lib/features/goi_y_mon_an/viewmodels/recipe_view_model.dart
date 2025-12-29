import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/recipe_services.dart';

// Các trạng thái của màn hình
enum RecipeViewState { idle, loading, success, error }

class RecipeViewModel extends ChangeNotifier {
  final RecipeServices _dataSource = RecipeServices();

  List<RecipeModel> _recipes = [];
  List<RecipeModel> get recipes => _recipes;

  RecipeViewState _state = RecipeViewState.idle;
  RecipeViewState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // 1. Hàm gợi ý theo nguyên liệu (Dành cho filter "Have Ingredients")
  Future<void> fetchSuggestedRecipes(List<String> ingredients) async {
    _setState(RecipeViewState.loading);
    try {
      if (ingredients.isEmpty) {
        _recipes = [];
        _setState(RecipeViewState.idle);
        return;
      }
      final result = await _dataSource.findRecipesByIngredients(ingredients);
      _recipes = result;
      _setState(RecipeViewState.success);
    } catch (e) {
      debugPrint("Error in fetchSuggestedRecipes: $e");
      _errorMessage = e.toString();
      _setState(RecipeViewState.error);
    }
  }

  // 2. Hàm Lọc & Tìm kiếm nâng cao (Đã thêm tham số DIET)
  Future<void> fetchRecipesWithFilter({
    String? query,
    String? time,
    String? diet,
  }) async {
    _setState(RecipeViewState.loading);
    try {
      // --- XỬ LÝ THÔNG SỐ THỜI GIAN ---
      int? maxReadyTime;
      if (time != null && time != 'All') {
        final digits = time.replaceAll(RegExp(r'[^0-9]'), '');
        maxReadyTime = int.tryParse(digits);
      }

      // --- XỬ LÝ LOGIC SORT ---
      String? sortParam;
      if (maxReadyTime == null && (query == null || query.isEmpty)) {
        sortParam = 'popularity';
      }

      // --- GỌI SERVICE ---
      _recipes = await _dataSource.searchRecipes(
        query: query ?? '',
        maxReadyTime: maxReadyTime,
        diet: (diet == 'None' || diet == null) ? null : diet,
        sort: sortParam,
      );

      _setState(RecipeViewState.success);
    } catch (e) {
      debugPrint("Error in fetchRecipesWithFilter: $e");
      _errorMessage = e.toString();
      _setState(RecipeViewState.error);
    }
  }

  // Hàm cập nhật trạng thái và báo cho giao diện vẽ lại
  void _setState(RecipeViewState state) {
    _state = state;
    notifyListeners();
  }
}
