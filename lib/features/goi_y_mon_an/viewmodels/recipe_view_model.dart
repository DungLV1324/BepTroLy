// File: lib/features/goi_y_mon_an/viewmodels/recipe_view_model.dart

import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/recipe_services.dart';

enum RecipeViewState { idle, loading, success, error }

class RecipeViewModel extends ChangeNotifier {
  final RecipeServices _dataSource = RecipeServices();

  List<RecipeModel> _recipes = [];
  List<RecipeModel> get recipes => _recipes;

  RecipeViewState _state = RecipeViewState.idle;
  RecipeViewState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // 1. Hàm tìm gợi ý theo nguyên liệu (Dùng cho nút "Have Ingredients")
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
      _errorMessage = e.toString();
      _setState(RecipeViewState.error);
    }
  }

  // --- ĐÂY LÀ ĐOẠN BẠN ĐANG THIẾU ---
  // 2. Hàm Lọc & Tìm kiếm (Đã sửa tên thành fetchRecipesWithFilter để khớp với View)
  Future<void> fetchRecipesWithFilter({
    String? query,
    String? time, // Nhận chuỗi '< 20 mins' từ View
  }) async {
    _setState(RecipeViewState.loading);
    try {
      List<RecipeModel> result = [];

      // Xử lý tham số thời gian (Convert từ String sang int)
      int? maxReadyTime;
      if (time != null && time.contains('20')) {
        maxReadyTime = 20;
      }

      // Logic:
      // - Nếu có time -> Lọc theo time
      // - Nếu không có time & không có query -> Mặc định là Trending (sort popularity)
      // - Nếu có query -> Tìm theo từ khóa

      String? sortParam;
      if (maxReadyTime == null && (query == null || query.isEmpty)) {
        sortParam = 'popularity'; // Logic cho Trending
      }

      // Gọi API Complex Search trong Service
      result = await _dataSource.searchRecipes(
        query: query,
        maxReadyTime: maxReadyTime,
        sort: sortParam,
      );

      _recipes = result;
      _setState(RecipeViewState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(RecipeViewState.error);
    }
  }
  // ----------------------------------

  void _setState(RecipeViewState state) {
    _state = state;
    notifyListeners();
  }
}
