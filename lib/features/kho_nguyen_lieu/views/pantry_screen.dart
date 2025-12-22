import 'package:beptroly/features/kho_nguyen_lieu/views/widgets/add_ingredient_sheet.dart';
import 'package:flutter/material.dart';

import '../../thongbao/services/notification_service.dart';
import '../models/ingredient_model.dart';
import '../view_models/pantry_view_model.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final PantryViewModel _viewModel = PantryViewModel();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      _notificationService.showInstantNotification();
    });
    NotificationService().requestPermissions();
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2BEE79),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () async {
          // 1. Hiện BottomSheet và chờ kết quả trả về
          final IngredientModel? result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Để sheet có thể full chiều cao khi hiện phím
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const AddIngredientSheet(),
          );

          // 2. Nếu người dùng bấm Save và có dữ liệu trả về
          if (result != null) {
            int notificationId = result.name.hashCode;

            NotificationService().scheduleExpiryNotification(
              id: notificationId,
              title: 'Sắp hết hạn! ⚠️',
              body: 'Món ${result.name} của bạn sẽ hết hạn hôm nay. Hãy dùng ngay nhé!',
              expiryDate: result.expiryDate!,
            );

            _viewModel.addNewIngredient(result);
            
            await _viewModel.logNotification(
                'Sắp hết hạn! ⚠️',
                'Món ${result.name} của bạn sắp hết hạn.',
                result.expiryDate!
            );

            // Feedback nhẹ
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã thêm ${result.name} vào tủ bếp!')),
            );
          }
        },
      ),
      // --- BODY (STREAM BUILDER + LISTVIEW) ---
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _viewModel.pantryDataStream, // Lắng nghe luồng dữ liệu
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

          // 4. Xử lý khi kho trống
          if (pantryData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.kitchen_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text("Tủ lạnh trống trơn!", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _viewModel.addTestItem(),
                    child: const Text("Thêm món mẫu"),
                  )
                ],
              ),
            );
          }

          // 5. HIỂN THỊ DANH SÁCH (Tương đương RecyclerView)
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            // +1 để dành chỗ cho thanh tìm kiếm ở đầu tiên
            itemCount: pantryData.length + 1,
            itemBuilder: (context, index) {

              if (index == 0) {
                return Column(
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                  ],
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search ingredients...',
          hintStyle: TextStyle(color: Color(0xFF6B7280)),
          prefixIcon: Icon(Icons.search, color: Color(0xFF9FA2B4)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
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
    return Container(
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
                color: (item['color'] as Color).withOpacity(0.1),
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
    );
  }
}