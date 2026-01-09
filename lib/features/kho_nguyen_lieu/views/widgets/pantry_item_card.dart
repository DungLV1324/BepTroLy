import 'package:flutter/material.dart';
import '../../models/ingredient_model.dart';
import '../../../../core/utils/dialog_helper.dart';

class PantryItemCard extends StatelessWidget {
  final Map<String, dynamic> itemMap;
  final Function(IngredientModel) onDelete;
  final Function(IngredientModel) onEdit;

  const PantryItemCard({
    super.key,
    required this.itemMap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final IngredientModel model = itemMap['model'];
    bool hasImage = model.imageUrl != null && model.imageUrl!.isNotEmpty;
    return Dismissible(
      key: Key(model.id),
      direction: DismissDirection.endToStart,

      // Nền khi vuốt
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.red.withOpacity(0.2) : Colors.red[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
      ),

      //Xác nhận xóa
      confirmDismiss: (direction) async {
        return await DialogHelper.showDeleteConfirmation(context, model.name);
      },

      onDismissed: (_) => onDelete(model),

      // UI Thẻ món ăn
      child: GestureDetector(
        onTap: () => onEdit(model),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
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
                const SizedBox(width: 8),

                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    // Nếu có ảnh thì để nền trong suốt, không có ảnh thì để nền màu nhạt
                    color: hasImage
                        ? Colors.transparent
                        : (itemMap['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12), // Bo góc cho ảnh
                    child: hasImage
                        ? Image.network(
                            model.imageUrl!,
                            fit: BoxFit.cover,
                            // Xử lý khi ảnh loading
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: itemMap['color'],
                                ),
                              );
                            },

                            // Xử lý khi ảnh bị lỗi
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: (itemMap['color'] as Color).withOpacity(
                                  0.1,
                                ),
                                child: Icon(
                                  itemMap['icon'],
                                  color: itemMap['color'],
                                  size: 20,
                                ),
                              );
                            },
                          )
                        // Nếu không có link ảnh ngay từ đầu -> Hiện Icon
                        : Icon(
                            itemMap['icon'],
                            color: itemMap['color'],
                            size: 20,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // Tên & Số lượng
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        itemMap['name'],
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1D26),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        itemMap['quantity'],
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey[400]
                              : const Color(0xFF9FA2B4),
                          fontSize: 12,
                        ),
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
