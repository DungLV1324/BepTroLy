import 'package:flutter/material.dart';
import '../../models/ingredient_model.dart';
import '../../../../core/utils/dialog_helper.dart'; // Import dialog

class PantryItemCard extends StatelessWidget {
  final Map<String, dynamic> itemMap; // Dữ liệu UI (màu, icon...)
  final Function(IngredientModel) onDelete; // Callback khi xóa
  final Function(IngredientModel) onEdit;   // Callback khi sửa

  const PantryItemCard({
    super.key,
    required this.itemMap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final IngredientModel model = itemMap['model'];

    return Dismissible(
      key: Key(model.id),
      direction: DismissDirection.endToStart,

      // Nền khi vuốt
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
      ),

      // Logic xác nhận xóa
      confirmDismiss: (direction) async {
        return await DialogHelper.showDeleteConfirmation(context, model.name);
      },

      // Logic khi đã xác nhận xóa
      onDismissed: (_) => onDelete(model),

      // UI Thẻ món ăn
      child: GestureDetector(
        onTap: () => onEdit(model),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Thanh màu
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: itemMap['color'],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),

                // Icon nền
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (itemMap['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(itemMap['icon'], color: itemMap['color'], size: 20),
                ),
                const SizedBox(width: 14),

                // Tên & Số lượng
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        itemMap['name'],
                        style: const TextStyle(
                          color: Color(0xFF1A1D26),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        itemMap['quantity'],
                        style: const TextStyle(color: Color(0xFF9FA2B4), fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Trạng thái hạn dùng
                Text(
                  itemMap['status'],
                  style: TextStyle(
                    color: itemMap['color'] == const Color(0xFF9FA2B4)
                        ? const Color(0xFF9FA2B4)
                        : itemMap['color'],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}