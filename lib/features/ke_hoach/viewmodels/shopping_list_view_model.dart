// lib/viewmodels/shopping_list_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/shopping_item_model.dart';
import '../../../core/constants/app_enums.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final Uuid _uuid = const Uuid();

  // Trạng thái của các section (mô phỏng Produce đang mở, Dairy & Eggs, Pantry Staples đang đóng)
  final Map<String, bool> _sectionExpandedStatus = {
    'Produce': true,
    'Dairy & Eggs': false,
    'Pantry Staples': false,
  };

  bool isSectionExpanded(String category) => _sectionExpandedStatus[category] ?? false;

  void toggleSectionExpanded(String category) {
    if (_sectionExpandedStatus.containsKey(category)) {
      _sectionExpandedStatus[category] = !_sectionExpandedStatus[category]!;
      notifyListeners();
    }
  }

  // Dữ liệu mẫu (theo hình ảnh)
  List<ShoppingItemModel> _items = [
    ShoppingItemModel(
        id: const Uuid().v4(),
        name: 'Tomatoes',
        quantity: 2,
        unit: MeasureUnit.piece,
        category: 'Produce'),
    ShoppingItemModel(
        id: const Uuid().v4(),
        name: 'Onion',
        quantity: 1,
        unit: MeasureUnit.piece,
        isBought: true,
        category: 'Produce'),
    ShoppingItemModel(
        id: const Uuid().v4(),
        name: 'Garlic',
        quantity: 3,
        unit: MeasureUnit.clove,
        category: 'Produce'),
    ShoppingItemModel(
        id: const Uuid().v4(),
        name: 'Avocado',
        quantity: 2,
        unit: MeasureUnit.piece,
        category: 'Produce'),
    ShoppingItemModel(
        id: const Uuid().v4(),
        name: 'Cilantro',
        quantity: 1,
        unit: MeasureUnit.bunch,
        category: 'Produce'),
    // Thêm các items cho các category đóng
    ShoppingItemModel(
        id: const Uuid().v4(),
        name: 'Milk',
        quantity: 1,
        unit: MeasureUnit.l,
        category: 'Dairy & Eggs'),
    ShoppingItemModel(
        id: const Uuid().v4(),
        name: 'Eggs',
        quantity: 12,
        unit: MeasureUnit.piece,
        category: 'Dairy & Eggs'),
    ShoppingItemModel(
        id: const Uuid().v4(),
        name: 'Flour',
        quantity: 1,
        unit: MeasureUnit.kg,
        category: 'Pantry Staples'),
    ShoppingItemModel(
        id: const Uuid().v4(),
        name: 'Salt',
        quantity: 1,
        unit: MeasureUnit.kg,
        category: 'Pantry Staples'),
  ];

  List<ShoppingItemModel> get items => _items;

  // Lấy danh sách items đã được nhóm theo category
  Map<String, List<ShoppingItemModel>> get groupedItems {
    final Map<String, List<ShoppingItemModel>> grouped = {};
    for (var item in _items) {
      if (!grouped.containsKey(item.category)) {
        grouped[item.category] = [];
      }
      grouped[item.category]!.add(item);
    }
    // Đảm bảo các category có trong status vẫn hiển thị dù rỗng
    for (var category in _sectionExpandedStatus.keys) {
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
    }
    return grouped;
  }

  // Chức năng thêm item
  void addItem(String name, double quantity, MeasureUnit unit, {String category = 'Khác'}) {
    final newItem = ShoppingItemModel(
      id: _uuid.v4(),
      name: name,
      quantity: quantity,
      unit: unit,
      category: category,
    );
    // Logic merge item nếu đã tồn tại và chưa mua
    int index = _items.indexWhere((item) =>
    item.name.toLowerCase().trim() == newItem.name.toLowerCase().trim() &&
        !item.isBought &&
        item.unit == newItem.unit);

    if (index != -1) {
      // Merge số lượng
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity + newItem.quantity);
    } else {
      // Thêm item mới
      _items.insert(0, newItem);
      // Đảm bảo category mới có trạng thái mở mặc định
      if(!_sectionExpandedStatus.containsKey(category)) {
        _sectionExpandedStatus[category] = true;
      }
    }
    notifyListeners();
  }

  // Chức năng chuyển đổi trạng thái đã mua/chưa mua
  void toggleBoughtStatus(String itemId) {
    int index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final currentItem = _items[index];
      _items[index] = currentItem.copyWith(isBought: !currentItem.isBought);
      notifyListeners();
    }
  }

  // Chức năng xóa tất cả items
  void clearList() {
    _items.clear();
    notifyListeners();
  }

  // Tính số lượng item chưa mua trong một category
  int getUnboughtCount(String category) {
    return (_items.where((item) => item.category == category && !item.isBought)).length;
  }
}