import 'package:beptroly/features/kho_nguyen_lieu/services/pantry_service.dart';

import '../../kho_nguyen_lieu/models/ingredient_model.dart';

class HomeService {
  final PantryService _pantryService = PantryService();

  // Hàm lấy danh sách các món sắp hết hạn (<= 3 ngày)
  Future<List<IngredientModel>> getExpiringIngredients() async {
    try {
      // 1. Lấy toàn bộ dữ liệu từ DatabaseService
      // (Lưu ý: getIngredientsStream trả về Stream, ta lấy snapshot đầu tiên để hiện lên Home)
      final allItems = await _pantryService.getIngredientsStream().first;

      // 2. Lọc logic: Chỉ lấy món còn hạn và sắp hết hạn (<= 3 ngày)
      final expiringItems = allItems.where((item) {
        if (item.expiryDate == null) return false;
        return item.daysRemaining <= 3;
      }).toList();

      // 3. Sắp xếp: Món nào hết hạn trước thì đưa lên đầu
      expiringItems.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));

      return expiringItems;
    } catch (e) {
      print("Lỗi HomeService: $e");
      return [];
    }
  }
}