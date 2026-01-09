import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class LoginViewModel with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;

  // --- Hàm đăng nhập bằng Email và Password ---
  Future<bool> loginWithEmail(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final loggedInUser = await _authService.signIn(email, password);
      _user = loggedInUser;
      _setLoading(false);
      return loggedInUser != null;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // --- Hàm đăng nhập với Google ---
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      // Gọi hàm đã thêm vào AuthService ở bước trước
      final loggedInUser = await _authService.signInWithGoogle();
      _user = loggedInUser;
      _setLoading(false);

      return loggedInUser != null;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // --- Hàm đăng xuất ---
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  // Helper để cập nhật trạng thái loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Xóa thông báo lỗi khi người dùng bắt đầu nhập lại
  void clearErrorMessage() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}