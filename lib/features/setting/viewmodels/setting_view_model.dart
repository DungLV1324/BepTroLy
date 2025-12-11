// lib/features/setting/viewmodels/setting_view_model.dart

import 'package:flutter/material.dart';

class SettingViewModel extends ChangeNotifier {
  // Trạng thái giả lập
  bool _isExpiryAlertOn = true;
  bool _isDarkModeOn = false;

  bool get isExpiryAlertOn => _isExpiryAlertOn;
  bool get isDarkModeOn => _isDarkModeOn;

  // Toggle Cảnh báo hết hạn
  void toggleExpiryAlert(bool value) {
    _isExpiryAlertOn = value;
    notifyListeners();
    // TODO: Lưu vào SharedPreferences hoặc gọi API
  }

  // Toggle Chế độ tối
  void toggleDarkMode(bool value) {
    _isDarkModeOn = value;
    notifyListeners();
    // TODO: Gọi ThemeService để đổi theme toàn app
  }

  // Xử lý đăng xuất
  void logout(BuildContext context) {
    // TODO: Xử lý logic đăng xuất (Clear token, firebase auth signOut...)
    print("Đăng xuất thành công");

    // Ví dụ: Quay về màn hình Login (cần cấu hình route login trước)
    // context.go('/login');
  }
}
