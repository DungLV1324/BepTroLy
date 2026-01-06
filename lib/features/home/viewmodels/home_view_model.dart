import 'dart:async';
import 'package:flutter/material.dart';
import '../../kho_nguyen_lieu/models/ingredient_model.dart';
import '../services/home_service.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeService _homeService = HomeService();

  // State
  bool _isLoading = false;
  List<IngredientModel> _expiringIngredients = [];
  String _userName = 'My friend';
  String? _photoUrl;

  // Quản lý Stream
  StreamSubscription? _pantrySubscription;

  // Getters
  bool get isLoading => _isLoading;
  List<IngredientModel> get expiringIngredients => _expiringIngredients;
  String get userName => _userName;
  String? get photoUrl => _photoUrl;

  // Hàm khởi tạo dữ liệu
  void loadHomeData() {
    _isLoading = true;
    notifyListeners();

    _loadUserInfo();

    _listenToExpiringItems();
  }

  void _listenToExpiringItems() {
    _pantrySubscription?.cancel(); // Hủy đăng ký cũ nếu có

    // Gọi Stream đã được xử lý từ Service
    _pantrySubscription = _homeService.getExpiringIngredientsStream().listen(
          (processedList) {
        _expiringIngredients = processedList;
        _isLoading = false;
        notifyListeners(); // Cập nhật UI ngay khi có thay đổi
      },
      onError: (error) {
        print("Lỗi ViewModel: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> _loadUserInfo() async {
    final userProfile = await _homeService.getUserProfile();

    _userName = userProfile['name'] ?? 'My friend';
    _photoUrl = userProfile['photoUrl'];
    notifyListeners();
  }

  @override
  void dispose() {
    _pantrySubscription?.cancel();
    super.dispose();
  }
}