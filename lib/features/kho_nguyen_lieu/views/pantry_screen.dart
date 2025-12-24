import 'package:beptroly/features/kho_nguyen_lieu/views/widgets/add_ingredient_sheet.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_enums.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../thongbao/services/notification_service.dart';
import '../models/ingredient_model.dart';
import '../view_models/pantry_view_model.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final PantryViewModel _pantryviewModel = PantryViewModel();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: const [
            Icon(Icons.kitchen, color: Color(0xFF1A1D26)),
            SizedBox(width: 8),
            Text(
              'My Pantry',
              style: TextStyle(
                color: Color(0xFF1A1D26),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),

      // Nút mở sheet Add
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2BEE79),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () async {
          final IngredientModel? result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const AddIngredientSheet(),
          );

          //Nếu người dùng bấm Save và có dữ liệu trả về
          if (result != null) {
            int notificationId = result.name.hashCode;
            _notificationService.scheduleExpiryNotification(
              id: notificationId,
              title: 'Sắp hết hạn! ⚠️',
              body: 'Món ${result.name} của bạn sẽ hết hạn hôm nay. Hãy dùng ngay nhé!',
              expiryDate: result.expiryDate!,
            );

            _pantryviewModel.addNewIngredient(result);
            
            await _pantryviewModel.logNotification(
                notificationId,
                'Sắp hết hạn! ⚠️',
                'Món ${result.name} của bạn sắp hết hạn.',
                result.expiryDate!
            );
            AppToast.show(context,ActionType.add,result.name);
          }
        },
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _pantryviewModel.pantryDataStream, // Lắng nghe luồng dữ liệu
        builder: (context, snapshot) {
          // 1. Trạng thái đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Trạng thái lỗi
          if (snapshot.hasError) {
            return Center(child: Text("Đã xảy ra lỗi: ${snapshot.error}"));
          }

          // 3. Lấy dữ liệu
          final pantryData = snapshot.data ?? [];

          final int itemCount = pantryData.isEmpty ? 2 : pantryData.length + 1;

          final bool isSearching = _pantryviewModel.searchQuery.isNotEmpty;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            itemCount: itemCount,
            itemBuilder: (context, index) {

              if (index == 0) {
                return Column(
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                  ],
                );
              }
              if (pantryData.isEmpty) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                          isSearching
                              ? "Không tìm thấy món nào khớp với\n\"${_pantryviewModel.searchQuery}\""
                              : "Tủ lạnh đang trống trơn!",
                      style: const TextStyle(color: Colors.grey, fontSize: 16)
                      ),
                    ],
                  ),
                );
              }
              final categoryData = pantryData[index - 1];
              return _buildCategorySection(categoryData);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(Map<String, dynamic> data) {
    final List<dynamic> items = data['items'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: EdgeInsets.zero,
          title: Row(
            children: [
              Text(
                data['category'],
                style: const TextStyle(
                  color: Color(0xFF1A1D26),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  data['count'].toString(),
                  style: const TextStyle(
                    color: Color(0xFF9FA2B4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          children: items.map<Widget>((item) => _buildPantryItem(item)).toList(),
        ),
      ),
    );
  }

  Widget _buildPantryItem(Map<String, dynamic> item) {
    // 1. Lấy dữ liệu gốc ra (nhờ bước sửa ViewModel ở trên)
    final IngredientModel model = item['model'];

    // 2. Bọc ngoài cùng bằng Dismissible để Vuốt Xóa
    return Dismissible(
      key: Key(model.id), // ID định danh để biết xóa dòng nào
      direction: DismissDirection.endToStart, // Chỉ cho vuốt từ Phải sang Trái

      // Giao diện màu đỏ hiện ra khi vuốt
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 14), // Margin khớp với Container chính
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.red, size: 28),
      ),

      // Hành động khi vuốt xong
      onDismissed: (direction) {
        _pantryviewModel.deleteIngredient(model);

        AppToast.show(context,ActionType.delete,model.name);
      },

      // 3. Bọc tiếp bằng GestureDetector để Bắt sự kiện chạm (Sửa)
      child: GestureDetector(
        onTap: () async {
          // Mở Sheet Sửa (truyền model hiện tại vào)
          final IngredientModel? updatedItem = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => AddIngredientSheet(ingredientToEdit: model),
          );

          // Nếu có dữ liệu trả về thì cập nhật
          if (updatedItem != null) {
            await _pantryviewModel.updateIngredient(model, updatedItem);

            if (mounted) {
              AppToast.show(context,ActionType.edit,updatedItem.name);
            }
          }
        },

        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Thanh màu trạng thái bên trái
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: item['color'],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),

                // Icon nền mờ
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon'],
                    color: item['color'],
                    size: 20,
                  ),
                ),

                const SizedBox(width: 14),

                // Tên và số lượng
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          color: Color(0xFF1A1D26),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['quantity'],
                        style: const TextStyle(
                          color: Color(0xFF9FA2B4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Trạng thái (Expires in...)
                Text(
                  item['status'],
                  style: TextStyle(
                    color: item['color'] == const Color(0xFF9FA2B4)
                        ? const Color(0xFF9FA2B4)
                        : item['color'],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        // --- KẾT THÚC CONTAINER CŨ ---
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField( // Bỏ const nếu có
        // --- THÊM DÒNG NÀY ---
        onChanged: (value) {
          // Gọi hàm search trong ViewModel mỗi khi gõ
          _pantryviewModel.search(value);
        },
        // ---------------------
        decoration: const InputDecoration( // Thêm const nếu cần
          hintText: 'Search ingredients...',
          hintStyle: TextStyle(color: Color(0xFF6B7280)),
          prefixIcon: Icon(Icons.search, color: Color(0xFF9FA2B4)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
          suffixIcon: null,
        ),
      ),
    );
  }
}