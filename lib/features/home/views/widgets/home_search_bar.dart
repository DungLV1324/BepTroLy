import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.03,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            context.push('/recipes', extra: value);
            // Log kiểm tra
            print("Đang tìm kiếm: $value");
          }
        },

        decoration: const InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Find food...',
          hintStyle: TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
