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
  final StreamController<List<Map<String, dynamic>>> _uiStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  //State
  List<IngredientModel> _allItems = [];
  String _searchQuery = "";
  final Set<String> _selectedItemIds = {};
  List<IngredientModel> get ingredients => _allItems;
  bool hasIngredient(String ingredientName) {
    return _allItems.any(
      (pantryItem) =>
          ingredientName.toLowerCase().contains(
            pantryItem.name.toLowerCase(),
          ) ||
          pantryItem.name.toLowerCase().contains(ingredientName.toLowerCase()),
    );
  }

  // 2. Hàm kiểm tra tổng quát cho cả Recipe
  bool isRecipeReady(List<String> recipeIngredients) {
    if (recipeIngredients.isEmpty) return false;
    // Nếu có bất kỳ nguyên liệu nào TRONG danh sách món ăn mà KHÔNG có trong kho -> Trả về false
    return recipeIngredients.every((name) => hasIngredient(name));
  }

  // Getters
  Set<String> get selectedItemIds => _selectedItemIds;
  Stream<List<Map<String, dynamic>>> get pantryDataStream =>
      _uiStreamController.stream;
  String get searchQuery => _searchQuery;

  // --- CONSTRUCTOR ---
  PantryViewModel() {
    _initData();
  }

  void _initData() {
    _pantryService.getIngredientsStream().listen((items) {
      _allItems = items;
      _applyFilterAndEmit();
      notifyListeners();
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
        return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    final grouped = _groupItemsByCategory(filteredList);
    _uiStreamController.add(grouped);
  }

  List<Map<String, dynamic>> _groupItemsByCategory(
    List<IngredientModel> items,
  ) {
    if (items.isEmpty) return [];

    Map<String, List<IngredientModel>> grouped = {};
    for (var item in items) {
      String category = item.aisle ?? "Other Items";
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(item);
    }

    List<Map<String, dynamic>> result = [];
    grouped.forEach((category, listItems) {
      result.add({
        "category": category,
        "count": listItems.length,
        "items": listItems
            .map((item) => _mapModelToUi(item, category))
            .toList(),
      });
    });
    return result;
  }

  Map<String, dynamic> _mapModelToUi(IngredientModel item, String category) {
    return {
      "model": item,
      "id": item.id,
      "name": item.name,
      "quantity": "${_formatQuantity(item.quantity)} ${item.unit.name}",
      "daysLeft": item.daysRemaining,
      "icon": _getIconForCategory(category),
      "color": _getColorStatus(item.status),
      "status": _getStatusText(item.daysRemaining),
    };
  }

  Color _getColorStatus(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.expired:
        return const Color(0xFFFF4D4D); // Đỏ
      case ExpiryStatus.expiringSoon:
        return const Color(0xFFFFC107); // Vàng
      default:
        return const Color(0xFF4CAF50); // Xanh
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
    if (catLower.contains("dairy") || catLower.contains("egg")) {
      return Icons.egg_alt;
    }
    if (catLower.contains("fruit") || catLower.contains("vegetable")) {
      return Icons.eco;
    }
    if (catLower.contains("meat") || catLower.contains("fish")) {
      return Icons.set_meal;
    }
    if (catLower.contains("beverage") || catLower.contains("drink")) {
      return Icons.local_drink;
    }
    if (catLower.contains("grain") || catLower.contains("bread")) {
      return Icons.breakfast_dining;
    }
    return Icons.kitchen;
  }

  String _formatQuantity(double qty) {
    // Nếu là số nguyên (5.0) thì hiện 5, ngược lại hiện 5.5
    return qty % 1 == 0 ? qty.toInt().toString() : qty.toString();
  }

  Future<void> addNewIngredient(IngredientModel item) async {
    await _pantryService.addIngredient(item);
  }

  Future<void> logNotification(
    int notificationId,
    String title,
    String body,
    DateTime date,
  ) async {
    await _notificationService.addNotificationLog(
      notificationId: notificationId,
      title: title,
      body: body,
      scheduledTime: date,
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
  Future<void> updateIngredient(
    IngredientModel oldItem,
    IngredientModel newItem,
  ) async {
    // A. Cập nhật Firestore
    await _pantryService.updateIngredient(newItem);

    await _notificationService.cancelNotification(oldItem.name.hashCode);

    if (newItem.expiryDate != null) {
      _notificationService.scheduleExpiryNotification(
        id: newItem.name.hashCode,
        title: 'Expiring soon! ⚠️',
        body: 'Dish ${newItem.name} it is about to expire.',
        expiryDate: newItem.expiryDate!,
      );
    }
  }

  Future<int> addBatchIngredients(List<String> itemNames) async {
    int successCount = 0;
    final DateTime defaultExpiry = DateTime.now().add(const Duration(days: 7));
    final DateTime now = DateTime.now();

    try {
      for (String name in itemNames) {
        String newId = "${now.millisecondsSinceEpoch}_${name.hashCode}";

        final newItem = IngredientModel(
          id: newId,
          name: name,
          quantity: 1.0,
          unit: MeasureUnit.values.first,
          expiryDate: defaultExpiry,
          addedDate: now,
          imageUrl: "",
          aisle: "Other Items",
        );

        await _pantryService.addIngredient(newItem);

        // Đặt lịch thông báo
        await _notificationService.scheduleExpiryNotification(
          id: name.hashCode,
          title: 'Expiring soon ⚠️',
          body: 'Dish $name it is about to expire.',
          expiryDate: defaultExpiry,
        );
        successCount++;
      }

      notifyListeners();

    } catch (e) {
      print("ViewModel Error when adding batch: $e");
    }

    return successCount;
  }}
