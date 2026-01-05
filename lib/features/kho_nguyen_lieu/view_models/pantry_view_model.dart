import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/constants/app_enums.dart';
import '../../thongbao/services/notification_service.dart';
import '../models/ingredient_model.dart';
import '../services/pantry_service.dart';

class PantryViewModel extends ChangeNotifier {
  //Service
  final PantryService _pantryService = PantryService();
  final NotificationService _notificationService = NotificationService();

  // Stream Controller
  final StreamController<List<Map<String, dynamic>>> _uiStreamController = StreamController<List<Map<String, dynamic>>>.broadcast();

  //State
  List<IngredientModel> _allItems = [];
  String _searchQuery = "";
  final Set<String> _selectedItemIds = {};

  // Getters
  Set<String> get selectedItemIds => _selectedItemIds;
  Stream<List<Map<String, dynamic>>> get pantryDataStream => _uiStreamController.stream;
  String get searchQuery => _searchQuery;

  // --- CONSTRUCTOR ---
  PantryViewModel() {
    _initData();
  }

  void _initData() {
    _pantryService.getIngredientsStream().listen((items) {
      _allItems = items;
      _applyFilterAndEmit(); // Mỗi khi data gốc đổi -> Lọc lại -> Đẩy ra UI
    });
  }

  @override
  void dispose() {
    _uiStreamController.close();
    super.dispose();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilterAndEmit();
  }

  void _applyFilterAndEmit() {
    List<IngredientModel> filteredList = _allItems;

    if (_searchQuery.isNotEmpty) {
      filteredList = _allItems.where((item) {
        return item.name
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    final grouped = _groupItemsByCategory(filteredList);
    _uiStreamController.add(grouped);
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
        "items": listItems.map((item) => _mapModelToUi(item, category)).toList(),
      });
    });
    return result;
  }

  Map<String, dynamic> _mapModelToUi(IngredientModel item, String category) {
    return {
      "model": item, // Giữ model gốc để truyền vào các hàm sửa/xóa
      "id": item.id,
      "name": item.name,
      "quantity": "${_formatQuantity(item.quantity)} ${item.unit.name}",
      "daysLeft": item.daysRemaining,
      "icon": _getIconForCategory(category),
      "color": _getColorStatus(item.status),
      "status": _getStatusText(item.daysRemaining),
    };
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

  IconData _getIconForCategory(String category) {
    final catLower = category.toLowerCase();
    if (catLower.contains("dairy") || catLower.contains("egg")) return Icons.egg_alt;
    if (catLower.contains("fruit") || catLower.contains("vegetable")) return Icons.eco;
    if (catLower.contains("meat") || catLower.contains("fish")) return Icons.set_meal;
    if (catLower.contains("beverage") || catLower.contains("drink")) return Icons.local_drink;
    if (catLower.contains("grain") || catLower.contains("bread")) return Icons.breakfast_dining;
    return Icons.kitchen; // Icon mặc định
  }

  String _formatQuantity(double qty) {
    // Nếu là số nguyên (5.0) thì hiện 5, ngược lại hiện 5.5
    return qty % 1 == 0 ? qty.toInt().toString() : qty.toString();
  }

  Future<void> addNewIngredient(IngredientModel item) async {
    await _pantryService.addIngredient(item);
  }

  Future<void> logNotification(int notificationId,String title, String body, DateTime date) async {
    await _notificationService.addNotificationLog(
        notificationId: notificationId,
        title: title,
        body: body,
        scheduledTime: date
    );
  }

  Future<void> deleteIngredient(IngredientModel item) async {
    int notificationId = item.name.hashCode;
    // A. Xóa trong Firestore
    await _pantryService.deleteIngredient(item.id);

    // B. Hủy thông báo nhắc nhở (Dùng hashCode tên làm ID như lúc tạo)
    await _notificationService.cancelNotification(notificationId);
    await _notificationService.deleteNotificationLog(notificationId);
  }

// 2. Cập nhật món ăn
  Future<void> updateIngredient(IngredientModel oldItem, IngredientModel newItem) async {
    // A. Cập nhật Firestore
    await _pantryService.updateIngredient(newItem);

    await _notificationService.cancelNotification(oldItem.name.hashCode);

    if (newItem.expiryDate != null) {
      _notificationService.scheduleExpiryNotification(
        id: newItem.name.hashCode, // Lưu ý: Nếu user đổi tên, ID này sẽ đổi
        title: 'Sắp hết hạn! ⚠️',
        body: 'Món ${newItem.name} sắp hết hạn.',
        expiryDate: newItem.expiryDate!,
      );
    }
  }
}