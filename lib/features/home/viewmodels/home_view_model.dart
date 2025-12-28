import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/constants/app_enums.dart';
import '../../goi_y_mon_an/models/recipe_model.dart';
import '../../kho_nguyen_lieu/models/ingredient_model.dart';
import '../../kho_nguyen_lieu/services/pantry_service.dart';
import '../services/home_service.dart';

class HomeViewModel extends ChangeNotifier {

  bool _isLoading = false;
  late List<IngredientModel> _expiringIngredients = [];
  final List<RecipeModel> _recommendedRecipes = [];
  List<IngredientModel> _expiringList = [];

  // Getters
  List<IngredientModel> get expiringIngredients => _expiringIngredients;
  List<RecipeModel> get recommendedRecipes => _recommendedRecipes;
  List<IngredientModel> get expiringList => _expiringList;
  bool get isLoading => _isLoading;
  final PantryService _pantryService = PantryService();

  final HomeService _homeService = HomeService();
  StreamSubscription? _pantrySubscription; // Biến để quản lý việc lắng nghe

  void loadHomeData() {
    _isLoading = true;
    notifyListeners();

    // --- PHẦN QUAN TRỌNG: TÁI SỬ DỤNG STREAM CỦA BẠN ---

    // Hủy đăng ký cũ nếu có (tránh nghe 2 lần)
    _pantrySubscription?.cancel();

    // Bắt đầu lắng nghe Stream
    _pantrySubscription = _pantryService.getIngredientsStream().listen((allIngredients) {

      // 1. Lọc & Sắp xếp logic cho trang chủ
      // Chỉ lấy những món còn hạn (hoặc hết hạn tùy bạn) và sắp xếp ngày gần nhất

      // Sắp xếp: Ngày hết hạn tăng dần (gần nhất lên đầu)
      allIngredients.sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));

      // Lọc: (Ví dụ) Chỉ lấy 10 món đầu tiên để hiện ở Home
      // và tính toán logic ngày hết hạn
      var limitedList = allIngredients.take(10).toList();

      // Cập nhật dữ liệu
      _expiringIngredients = limitedList;
      _isLoading = false;
      notifyListeners(); // Báo UI vẽ lại ngay lập tức

    }, onError: (error) {
      print("Lỗi stream home: $error");
      _isLoading = false;
      notifyListeners();
    });
  }

  // Rất quan trọng: Phải hủy lắng nghe khi thoát app hoặc widget bị hủy
  @override
  void dispose() {
    _pantrySubscription?.cancel();
    super.dispose();
  }

  // Rất quan trọng: Phải hủy lắng nghe khi thoát app hoặc widget bị hủy


  // Future<void> loadHomeData() async {
  //   _isLoading = true;
  //   notifyListeners();
  //
  //   await Future.delayed(const Duration(milliseconds: 500));
  //
  //   final now = DateTime.now();
  //   _expiringIngredients = [
  //     IngredientModel(
  //       id: '1',
  //       name: 'Cà chua',
  //       quantity: 2,
  //       unit: MeasureUnit.piece,
  //       expiryDate: now.add(const Duration(days: 2)),
  //       imageUrl: 'assets/images/bruschetta.jpg',
  //       addedDate: now.subtract(const Duration(days: 5)),
  //     ),
  //     IngredientModel(
  //       id: '2',
  //       name: 'Xà lách',
  //       quantity: 300,
  //       unit: MeasureUnit.g,
  //       expiryDate: now.add(const Duration(days: 3)),
  //       imageUrl: 'assets/images/bruschetta.jpg',
  //       addedDate: now.subtract(const Duration(days: 2)),
  //     ),
  //     IngredientModel(
  //       id: '3',
  //       name: 'Sữa tươi',
  //       quantity: 1,
  //       unit: MeasureUnit.l,
  //       expiryDate: now.add(const Duration(days: 4)),
  //       imageUrl: 'assets/images/bruschetta.jpg',
  //       addedDate: now.subtract(const Duration(days: 10)),
  //     ),
  //   ];
  //
  //   _recommendedRecipes = [
  //     RecipeModel(
  //       id: '101',
  //       name: 'Phở Bò Hà Nội',
  //       description: 'Món ăn truyền thống...',
  //       cookingTimeMinutes: 45,
  //       instructions: ['Hầm xương', 'Thái thịt', 'Chan nước dùng'],
  //       ingredients: [],
  //       imageUrl: 'assets/images/bruschetta.jpg',
  //       missedIngredientCount: 1,
  //       usedIngredientCount: 5,
  //     ),
  //     RecipeModel(
  //       id: '102',
  //       name: 'Bánh Xèo',
  //       description: 'Bánh xèo miền Tây...',
  //       cookingTimeMinutes: 30,
  //       instructions: ['Pha bột', 'Đổ bánh', 'Cuốn rau'],
  //       ingredients: [],
  //       imageUrl: 'assets/images/bruschetta.jpg',
  //       missedIngredientCount: 0,
  //       usedIngredientCount: 8,
  //     ),
  //   ];
  //
  //   _isLoading = false;
  //   notifyListeners();
  // }
}