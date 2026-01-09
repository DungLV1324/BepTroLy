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
    });
    _notificationService.requestPermissions();
  }

  void _handleAddNew() async {
    final IngredientModel? result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddIngredientSheet(),
    );

    if (result != null) {
      int notifId = result.name.hashCode;

      //Notification
      _notificationService.scheduleExpiryNotification(
        id: notifId,
        title: 'Expiring soon! ⚠️',
        body: 'The item ${result.name} is about to expire.',
        expiryDate: result.expiryDate!,
      );
      _pantryViewModel.addNewIngredient(result);
      await _pantryViewModel.logNotification(
        notifId,
        'Expiring soon! ⚠️',
        'The item ${result.name} is about to expire.',
        result.expiryDate!,
      );

      if (mounted) AppToast.show(context, ActionType.add, result.name);
    }
  }

  //Sửa
  void _handleEdit(IngredientModel model) async {
    final IngredientModel? updatedItem = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddIngredientSheet(ingredientToEdit: model),
    );

    if (updatedItem != null) {
      await _pantryViewModel.updateIngredient(model, updatedItem);
      if (mounted) AppToast.show(context, ActionType.edit, updatedItem.name);
    }
  }

  //Xóa
  void _handleDelete(IngredientModel model) {
    _pantryViewModel.deleteIngredient(model);
    if (mounted) AppToast.show(context, ActionType.delete, model.name);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF121212)
            : const Color(0xFFF9FAFB),
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Icon(
              Icons.kitchen,
              color: isDark ? Colors.white : const Color(0xFF1A1D26),
            ),
            SizedBox(width: 8),
            Text(
              'My Pantry',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1D26),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),

      //Add
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
            return Center(child: Text("An error occurred: ${snapshot.error}"));
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
                  children: [_buildSearchBar(), const SizedBox(height: 24)],
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
            },
          );
        },
      ),
    );
  }

  // SearchBar
  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (val) => _pantryViewModel.search(val),
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: 'Search ingredients...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.white : const Color(0xFF9FA2B4),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategorySection(Map<String, dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1D26),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2C2C2C)
                      : const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  data['count'].toString(),
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : const Color(0xFF9FA2B4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          //PantryItemCard
          children: (data['items'] as List).map<Widget>((itemMap) {
            return PantryItemCard(
              itemMap: itemMap,
              onDelete: _handleDelete,
              onEdit: _handleEdit,
            );
          }).toList(),
        ),
      ),
    );
  }
}
