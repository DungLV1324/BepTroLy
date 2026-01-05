import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../goi_y_mon_an/models/recipe_model.dart';
import '../../kho_nguyen_lieu/models/ingredient_model.dart';
import '../../kho_nguyen_lieu/services/pantry_service.dart';
import '../services/home_service.dart';

class HomeViewModel extends ChangeNotifier {

  bool _isLoading = false;
  late List<IngredientModel> _expiringIngredients = [];
  final List<RecipeModel> _recommendedRecipes = [];
  final List<IngredientModel> _expiringList = [];

  String _userName = 'My friend';
  String? _photoUrl;

  // Getters
  List<IngredientModel> get expiringIngredients => _expiringIngredients;
  List<RecipeModel> get recommendedRecipes => _recommendedRecipes;
  List<IngredientModel> get expiringList => _expiringList;
  bool get isLoading => _isLoading;
  String get userName => _userName;
  String? get photoUrl => _photoUrl;

  final PantryService _pantryService = PantryService();

  final HomeService _homeService = HomeService();

  StreamSubscription? _pantrySubscription;

  void loadHomeData() {
    _isLoading = true;
    notifyListeners();

    _pantrySubscription?.cancel();

    // Bắt đầu lắng nghe Stream
    _pantrySubscription = _pantryService.getIngredientsStream().listen((allIngredients) {
      allIngredients.sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));
      var limitedList = allIngredients.take(10).toList();

      // Cập nhật dữ liệu
      _expiringIngredients = limitedList;
      _isLoading = false;
      notifyListeners();

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

  Future<void> _loadUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userName = user.displayName ?? 'My friend';
      _photoUrl = user.photoURL;

      if (_userName == 'My friend') {
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists) {
            Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
            // Thay 'fullName' hoặc 'name' tùy theo cách bạn lưu trong DB
            if (data.containsKey('fullName')) {
              _userName = data['fullName'];
            } else if (data.containsKey('name')) {
              _userName = data['name'];
            }

            // Lấy thêm ảnh nếu có lưu trong Firestore
            if (data.containsKey('avatarUrl')) {
              _photoUrl = data['avatarUrl'];
            }
          }
        } catch (e) {
          print("Lỗi lấy info từ Firestore: $e");
        }
      }
    }
  }
}