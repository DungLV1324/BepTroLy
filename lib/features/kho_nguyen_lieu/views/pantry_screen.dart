import 'package:beptroly/features/kho_nguyen_lieu/views/widgets/add_ingredient_sheet.dart';
import 'package:beptroly/features/kho_nguyen_lieu/views/widgets/pantry_empty_state.dart';
import 'package:beptroly/features/kho_nguyen_lieu/views/widgets/pantry_item_card.dart';
import 'package:flutter/material.dart';
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
  final PantryViewModel _pantryViewModel = PantryViewModel();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _pantryViewModel.addListener(() {
      if (mounted) setState(() {});

    });_notificationService.requestPermissions();
  }

  void _handleAddNew() async {
    final IngredientModel? result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const AddIngredientSheet(),
    );

    if (result != null) {
      int notifId = result.name.hashCode;

      // Setup Notification & Data
      _notificationService.scheduleExpiryNotification(
          id: notifId,
          title: 'Sắp hết hạn! ⚠️',
          body: 'Món ${result.name} sắp hết hạn.',
          expiryDate: result.expiryDate!
      );
      _pantryViewModel.addNewIngredient(result);
      await _pantryViewModel.logNotification(notifId, 'Sắp hết hạn! ⚠️', 'Món ${result.name} sắp hết hạn.', result.expiryDate!);

      if (mounted) AppToast.show(context, ActionType.add, result.name);
    }
  }

  // 2. Logic Sửa
  void _handleEdit(IngredientModel model) async {
    final IngredientModel? updatedItem = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => AddIngredientSheet(ingredientToEdit: model),
    );

    if (updatedItem != null) {
      await _pantryViewModel.updateIngredient(model, updatedItem);
      if (mounted) AppToast.show(context, ActionType.edit, updatedItem.name);
    }
  }

  // 3. Logic Xóa
  void _handleDelete(IngredientModel model) {
    _pantryViewModel.deleteIngredient(model);
    if (mounted) AppToast.show(context, ActionType.delete, model.name);
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
        onPressed: _handleAddNew,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _pantryViewModel.pantryDataStream,
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
                return PantryEmptyState(
                  isSearching: _pantryViewModel.searchQuery.isNotEmpty,
                  searchQuery: _pantryViewModel.searchQuery,
                );
              }
              final categoryData = pantryData[index - 1];
              return _buildCategorySection(categoryData);
            }
          );
        },
      ),
    );
  }

// Có thể tách widget SearchBar ra file riêng luôn cho sạch, nhưng để đây cũng tạm ổn
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        onChanged: (val) => _pantryViewModel.search(val),
        decoration: const InputDecoration(
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: EdgeInsets.zero,
          title: Row(
            children: [
              Text(data['category'], style: const TextStyle(
                  color: Color(0xFF1A1D26),
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(data['count'].toString(), style: const TextStyle(
                    color: Color(0xFF9FA2B4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          // Sử dụng Widget con PantryItemCard
          children: (data['items'] as List).map<Widget>((itemMap) {
            return PantryItemCard(
              itemMap: itemMap,
              onDelete: _handleDelete, // Truyền hàm xử lý
              onEdit: _handleEdit, // Truyền hàm xử lý
            );
          }).toList(),
        ),
      ),
    );
  }
}