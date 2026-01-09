import 'package:flutter/material.dart';

enum ActionType { add, edit, delete }

class AppToast {
  static void show(BuildContext context, ActionType action, String itemName) {

    // Cấu hình màu sắc
    late Color bgColor;
    late Color borderColor;
    late Color primaryColor;
    late IconData icon;
    late String message;

    switch (action) {
      case ActionType.add:
        bgColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF4CAF50);
        primaryColor = const Color(0xFF2E7D32);
        icon = Icons.check_circle;
        message = 'Added successfully $itemName!';
        break;

      case ActionType.edit:
        bgColor = const Color(0xFFE3F2FD);
        borderColor = const Color(0xFF2196F3);
        primaryColor = const Color(0xFF1565C0);
        icon = Icons.edit;
        message = 'Updated successfully $itemName!';
        break;

      case ActionType.delete:
        bgColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFEF5350);
        primaryColor = const Color(0xFFC62828);
        icon = Icons.delete_outline;
        message = 'Deleted successfully $itemName!';
        break;
    }

    ScaffoldMessenger.of(context).clearSnackBars();

    final height = MediaQuery.of(context).size.height;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bgColor,
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1),
        ),
        margin: EdgeInsets.only(
          bottom: height * 0.70,
          left: 40,
          right: 40,
        ),
        duration: const Duration(seconds: 2),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primaryColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
