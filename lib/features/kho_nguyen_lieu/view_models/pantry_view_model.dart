import 'package:flutter/material.dart';
import '../../../core/constants/app_enums.dart';
import '../../thongbao/services/notification_service.dart';
import '../models/ingredient_model.dart';
import '../services/pantry_service.dart';

class PantryViewModel extends ChangeNotifier {
  final PantryService _pantryService = PantryService();
  final NotificationService _notificationService = NotificationService();

  Stream<List<Map<String, dynamic>>> get pantryDataStream {
    return _pantryService.getIngredientsStream().map((items) {
      return _groupItemsByCategory(items);
    });
  }

  // Hàm logic: Gom nhóm các món ăn theo 'aisle' (ngành hàng)
  List<Map<String, dynamic>> _groupItemsByCategory(List<IngredientModel> items) {
    if (items.isEmpty) return [];

    // 1. Tạo Map tạm để gom nhóm
    Map<String, List<IngredientModel>> grouped = {};

    for (var item in items) {
      // Nếu không có aisle, xếp vào nhóm "Khác"
      String category = item.aisle ?? "Other Items";
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(item);
    }

    // 2. Chuyển đổi sang cấu trúc List<Map> cho UI
    List<Map<String, dynamic>> result = [];

    grouped.forEach((category, listItems) {
      result.add({
        "category": category,
        "count": listItems.length,
        "items": listItems.map((item) {
          // Mapping từ Model sang Map UI hiển thị
          return {
            "id": item.id, // Giữ ID để xóa/sửa
            "name": item.name,
            "quantity": "${item.quantity} ${item.unit.name}", // Format số lượng
            "daysLeft": item.daysRemaining,
            "icon": _getIconForCategory(category), // Hàm helper chọn icon
            "color": _getColorStatus(item.status), // Màu dựa trên hạn sử dụng
            "status": _getStatusText(item.daysRemaining),
          };
        }).toList(),
      });
    });

    return result;
  }

  // Helper: Chọn màu dựa trên ExpiryStatus (Dùng getter trong model của bạn)
  Color _getColorStatus(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.expired: return const Color(0xFFFF4D4D); // Đỏ
      case ExpiryStatus.expiringSoon: return const Color(0xFFFFC107); // Vàng
      default: return const Color(0xFF4CAF50); // Xanh
    }
  }

  // Helper: Text hiển thị
  String _getStatusText(int days) {
    if (days < 0) return "Expired ${days.abs()} days ago";
    if (days == 0) return "Expires today";
    return "Expires in $days days";
  }

  // Helper: Icon giả lập (vì model chưa lưu icon, sau này lưu icon string thì map sau)
  IconData _getIconForCategory(String category) {
    if (category.contains("Dairy")) return Icons.egg_alt;
    if (category.contains("Vegetable")) return Icons.grass;
    if (category.contains("Meat")) return Icons.set_meal;
    return Icons.kitchen;
  }
  Future<void> addNewIngredient(IngredientModel item) async {
    await _pantryService.addIngredient(item);
  }

  // Hàm test thêm dữ liệu giả
  Future<void> addTestItem() async {
    final newItem = IngredientModel(
      id: '', // Firestore tự sinh
      name: 'Test Milk ${DateTime.now().second}',
      quantity: 1,
      unit: MeasureUnit.l,
      aisle: 'Dairy & Eggs',
      expiryDate: DateTime.now().add(const Duration(days: 3)),
      addedDate: DateTime.now(),
    );
    await _pantryService.addIngredient(newItem);
  }

  Future<void> logNotification(String title, String body, DateTime date) async {
    await _notificationService.addNotificationLog(
        title: title,
        body: body,
        scheduledTime: date
    );
  }
}