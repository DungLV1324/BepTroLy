// lib/features/setting/views/setting_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/setting_view_model.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng ChangeNotifierProvider để cấp ViewModel cho màn hình này
    return ChangeNotifierProvider(
      create: (_) => SettingViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // Màu nền xám nhẹ
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'Cài đặt',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: Consumer<SettingViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 1. User Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _boxDecoration(),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=5',
                          ), // Ảnh mẫu
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'User Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'user.email@example.com',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Settings Group Card
                  Container(
                    decoration: _boxDecoration(),
                    child: Column(
                      children: [
                        // Toggle: Cảnh báo hết hạn
                        SwitchListTile(
                          activeColor: Colors.white,
                          activeTrackColor:
                              Colors.green, // Màu xanh giống thiết kế
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.grey[300],
                          secondary: const Icon(
                            Icons.notifications_none_outlined,
                            color: Colors.black,
                          ),
                          title: const Text(
                            'Cảnh báo hết hạn',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          value: viewModel.isExpiryAlertOn,
                          onChanged: (val) => viewModel.toggleExpiryAlert(val),
                        ),

                        Divider(
                          height: 1,
                          color: Colors.grey[200],
                          indent: 16,
                          endIndent: 16,
                        ),

                        // Toggle: Chế độ tối
                        SwitchListTile(
                          activeColor: Colors.white,
                          activeTrackColor: Colors.green,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.grey[300],
                          secondary: const Icon(
                            Icons.nightlight_round_outlined,
                            color: Colors.black,
                          ),
                          title: const Text(
                            'Chế độ tối',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          value: viewModel.isDarkModeOn,
                          onChanged: (val) => viewModel.toggleDarkMode(val),
                        ),

                        Divider(
                          height: 1,
                          color: Colors.grey[200],
                          indent: 16,
                          endIndent: 16,
                        ),

                        // Item: Edit Profile
                        ListTile(
                          leading: const Icon(
                            Icons.person_outline,
                            color: Colors.black,
                          ),
                          title: const Text(
                            'Edit Profile',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            // TODO: Navigate to Edit Profile
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Logout Card
                  GestureDetector(
                    onTap: () => viewModel.logout(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      decoration: _boxDecoration(),
                      child: Row(
                        children: const [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 16),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Hàm tạo Style đổ bóng chung cho các Card
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
