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

  // 2. Hàm gọi API
  Future<void> fetchSuggestedRecipes(List<String> ingredients) async {
    _state = RecipeViewState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      if (ingredients.isEmpty) {
        _recipes = [];
        _state = RecipeViewState.idle;
        notifyListeners();
        return;
      }

      final result = await _dataSource.findRecipesByIngredients(ingredients);

      _recipes = result;
      _state = RecipeViewState.success;

    } catch (e) {
      _errorMessage = e.toString();
      _state = RecipeViewState.error;
    } finally {
      notifyListeners();
    }
  }
}