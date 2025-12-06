import 'package:flutter/material.dart';
import '../../../core/constants/app_enums.dart';
import '../../goi_y_mon_an/models/recipe_model.dart';
import '../../kho_nguyen_lieu/models/ingredient_model.dart';

class HomeViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<IngredientModel> _expiringIngredients = [];
  List<RecipeModel> _recommendedRecipes = [];

  bool get isLoading => _isLoading;
  List<IngredientModel> get expiringIngredients => _expiringIngredients;
  List<RecipeModel> get recommendedRecipes => _recommendedRecipes;

  Future<void> loadHomeData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    _expiringIngredients = [
      IngredientModel(
        id: '1',
        name: 'Cà chua',
        quantity: 2,
        unit: MeasureUnit.piece,
        expiryDate: now.add(const Duration(days: 2)),
        imageUrl: 'tomato.png',
        addedDate: now.subtract(const Duration(days: 5)),
      ),
      IngredientModel(
        id: '2',
        name: 'Xà lách',
        quantity: 300,
        unit: MeasureUnit.g,
        expiryDate: now.add(const Duration(days: 3)),
        imageUrl: 'lettuce.png',
        addedDate: now.subtract(const Duration(days: 2)),
      ),
      IngredientModel(
        id: '3',
        name: 'Sữa tươi',
        quantity: 1,
        unit: MeasureUnit.l,
        expiryDate: now.add(const Duration(days: 4)),
        imageUrl: 'milk.png',
        addedDate: now.subtract(const Duration(days: 10)),
      ),
    ];

    _recommendedRecipes = [
      RecipeModel(
        id: '101',
        name: 'Phở Bò Hà Nội',
        description: 'Món ăn truyền thống...',
        cookingTimeMinutes: 45,
        instructions: ['Hầm xương', 'Thái thịt', 'Chan nước dùng'],
        ingredients: [],
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/5/53/Pho_Bo_-_Beef_Noodle_Soup.jpg',
        missedIngredientCount: 1,
        usedIngredientCount: 5,
      ),
      RecipeModel(
        id: '102',
        name: 'Bánh Xèo',
        description: 'Bánh xèo miền Tây...',
        cookingTimeMinutes: 30,
        instructions: ['Pha bột', 'Đổ bánh', 'Cuốn rau'],
        ingredients: [],
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Banh_xeo_2011.jpg/1200px-Banh_xeo_2011.jpg',
        missedIngredientCount: 0,
        usedIngredientCount: 8,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }
}