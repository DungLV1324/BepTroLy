import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/setting_view_model.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingViewModel>(
      builder: (context, viewModel, child) {
        final theme = Theme.of(context);
        final isDark = viewModel.isDarkModeOn;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.appBarTheme.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: theme.iconTheme.color,
                size: 20,
              ),
              onPressed: () => context.pop(),
            ),
            centerTitle: true,
            title: Text(
              'Settings',
              style: TextStyle(
                color: theme.textTheme.titleLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _boxDecoration(context),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=5',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              viewModel.email,
                              style: TextStyle(
                                color: theme.hintColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Settings Group
                Container(
                  decoration: _boxDecoration(context),
                  child: Column(
                    children: [
                      // Toggle: Expiry Alerts
                      SwitchListTile(
                        activeColor: Colors.white,
                        activeTrackColor: Colors.green,
                        secondary: Icon(
                          Icons.notifications_none_outlined,
                          color: theme.iconTheme.color,
                        ),
                        title: Text(
                          'Expiry Alerts',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        value: viewModel.isExpiryAlertOn,
                        onChanged: (val) => viewModel.updateToggleSetting(
                          field: 'isExpiryAlert',
                          value: val,
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: theme.dividerColor,
                        indent: 16,
                        endIndent: 16,
                      ),

                      // Toggle: Dark Mode
                      SwitchListTile(
                        activeColor: Colors.white,
                        activeTrackColor: Colors.green,
                        secondary: Icon(
                          Icons.nightlight_round_outlined,
                          color: theme.iconTheme.color,
                        ),
                        title: Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        value: viewModel.isDarkModeOn,
                        onChanged: (val) => viewModel.updateToggleSetting(
                          field: 'isDarkMode',
                          value: val,
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: theme.dividerColor,
                        indent: 16,
                        endIndent: 16,
                      ),

                      // Item: Edit Profile
                      ListTile(
                        leading: Icon(
                          Icons.person_outline,
                          color: theme.iconTheme.color,
                        ),
                        title: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          context.push('/edit_profile');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 3. Logout Button
                GestureDetector(
                  onTap: () => _showLogoutConfirm(context, viewModel),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.red.withOpacity(0.1)
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Log Out',
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
          ),
        );
      },
    );
  }

  BoxDecoration _boxDecoration(BuildContext context) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(
            theme.brightness == Brightness.dark ? 0.3 : 0.05,
          ),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Hàm hiển thị BottomSheet xác nhận đăng xuất
  void _showLogoutConfirm(BuildContext context, SettingViewModel viewModel) {
    final theme = Theme.of(context);
    final isDark = viewModel.isDarkModeOn;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to log out of your account?",
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.hintColor, fontSize: 15),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        viewModel.logout(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5252),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Confirm",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
