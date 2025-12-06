import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthState { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  AuthState _state = AuthState.idle;
  AuthState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Kiểm tra user đã login chưa khi mở app
  void checkLoginStatus() {
    _currentUser = _authService.currentUser;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setState(AuthState.loading);
    try {
      _currentUser = await _authService.signIn(email, password);
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _setState(AuthState.loading);
    try {
      _currentUser = await _authService.signUp(email, password, name);
      _setState(AuthState.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }
}