import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/shopping_list_view_model.dart';
import '../models/shopping_item_model.dart';
import '../../../core/constants/app_enums.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const _CustomHeader(),
          Expanded(child: _ShoppingListBody()),
        ],
      ),
      // Floating Action Button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72), // Đẩy lên trên Bottom Nav Bar
        child: FloatingActionButton(
          onPressed: () {
            // Mở dialog/screen thêm item nếu cần
          },
          backgroundColor: const Color(0xFF2BEE79),
          shape: const CircleBorder(),
          elevation: 5,
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// === WIDGETS CON ===

class _CustomHeader extends StatelessWidget {
  const _CustomHeader();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ShoppingListViewModel>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon Back (Dùng Icon chuẩn thay cho Font Awesome)
          const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1D26), size: 18),

          // Tiêu đề
          const Text(
            'Shopping List',
            style: TextStyle(
              color: Color(0xFF1A1D26),
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),

          // Nút Clear
          GestureDetector(
            onTap: viewModel.clearList,
            child: const Text(
              'Clear',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF34C759),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddItemField extends StatefulWidget {
  const _AddItemField();

  @override
  State<_AddItemField> createState() => _AddItemFieldState();
}

class _AddItemFieldState extends State<_AddItemField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addNewItem(ShoppingListViewModel viewModel) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Logic parse đơn giản: Tách số, tên và unit (cần cải tiến thêm)
    // Ví dụ đơn giản: "2 large tomatoes" -> 2, "tomatoes", piece/large
    final regex = RegExp(r'(\d+)\s*(.*?)(?:\s*(g|kg|ml|l|bunch|clove|cup|spoon))?\s*$', caseSensitive: false);
    final match = regex.firstMatch(text);

    double quantity = 1;
    String name = text;
    MeasureUnit unit = MeasureUnit.piece;

    if (match != null) {
      quantity = double.tryParse(match.group(1)!) ?? 1;
      name = match.group(2)!.trim();

      final unitStr = match.group(3)?.toLowerCase() ?? '';

      // Map đơn vị (sử dụng logic trong model hoặc đơn giản hơn ở đây)
      if (unitStr == 'g') unit = MeasureUnit.g;
      else if (unitStr == 'kg') unit = MeasureUnit.kg;
      else if (unitStr == 'ml') unit = MeasureUnit.ml;
      else if (unitStr == 'l') unit = MeasureUnit.l;
      else if (unitStr == 'bunch') unit = MeasureUnit.bunch;
      else if (unitStr == 'clove') unit = MeasureUnit.clove;
      else if (unitStr.contains('cup')) unit = MeasureUnit.cup;
      else if (unitStr.contains('spoon')) unit = MeasureUnit.spoon;

    } else {
      // Nếu không có số lượng, coi như 1 item
      quantity = 1;
      name = text;
    }

    // Gán category tạm thời, bạn có thể thêm logic phân loại dựa vào tên.
    String category = 'Produce'; // Mặc định cho demo

    viewModel.addItem(name, quantity, unit, category: category);
    _controller.clear();
    _focusNode.unfocus();
  }


  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ShoppingListViewModel>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add an item',
          style: TextStyle(
            color: Color(0xFF1A1D26),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: const Color(0xFFD1D5DB)),
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'e.g., 2 large tomatoes',
                    hintStyle: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _addNewItem(viewModel),
                ),
              ),
              GestureDetector(
                onTap: () => _addNewItem(viewModel),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.add_circle,
                    color: Color(0xFF34C759),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShoppingListBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Consumer lắng nghe mọi thay đổi trong ViewModel
    return Consumer<ShoppingListViewModel>(
      builder: (context, viewModel, child) {
        final groupedItems = viewModel.groupedItems;
        final categories = groupedItems.keys.toList();

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          children: [
            const _AddItemField(),
            const SizedBox(height: 16),

            // Render từng Category Section
            ...categories.map((category) {
              final items = groupedItems[category] ?? [];
              return _CategorySection(
                category: category,
                items: items,
                viewModel: viewModel,
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<ShoppingItemModel> items;
  final ShoppingListViewModel viewModel;

  const _CategorySection({
    required this.category,
    required this.items,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = viewModel.isSectionExpanded(category);
    final unboughtCount = viewModel.getUnboughtCount(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Category (Có thể tương tác để mở/đóng)
        GestureDetector(
          onTap: () => viewModel.toggleSectionExpanded(category),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFFEE2E2), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$category ($unboughtCount)',
                  style: const TextStyle(
                    color: Color(0xFF1A1D26),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF1A1D26),
                  size: 18,
                ),
              ],
            ),
          ),
        ),

        // Item List (Chỉ hiển thị khi Expanded)
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: items
                  .map((item) => _ShoppingListItem(
                item: item,
                onToggle: () => viewModel.toggleBoughtStatus(item.id),
              ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _ShoppingListItem extends StatelessWidget {
  final ShoppingItemModel item;
  final VoidCallback onToggle;

  const _ShoppingListItem({required this.item, required this.onToggle});

  // Chuyển đổi MeasureUnit thành chuỗi hiển thị
  String _getUnitDisplay(MeasureUnit unit, double quantity) {
    switch (unit) {
      case MeasureUnit.piece:
        return quantity > 1 ? '' : ''; // (2 large) hoặc (1)
      case MeasureUnit.g:
        return 'g';
      case MeasureUnit.kg:
        return 'kg';
      case MeasureUnit.ml:
        return 'ml';
      case MeasureUnit.l:
        return 'l';
      case MeasureUnit.spoon:
        return 'spoon';
      case MeasureUnit.cup:
        return 'cup';
      case MeasureUnit.bunch:
        return 'bunch';
      case MeasureUnit.clove:
        return 'cloves';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    String unitDisplay = _getUnitDisplay(item.unit, item.quantity);

    // Tạo chuỗi hiển thị: "Tomatoes (2 large)"
    String itemDisplay = '${item.name} (${item.quantity.toInt()} ${unitDisplay})';

    // Nếu đơn vị là piece hoặc unitDisplay rỗng, chỉ hiển thị số lượng
    if (item.unit == MeasureUnit.piece && unitDisplay.isEmpty) {
      itemDisplay = '${item.name} (${item.quantity.toInt()})';
    }


    return GestureDetector(
      onTap: onToggle, // Bắt sự kiện click để đổi trạng thái
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Checkbox
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: item.isBought,
                onChanged: (bool? newValue) => onToggle(),
                activeColor: const Color(0xFF34C759),
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Text Item
            Expanded(
              child: Text(
                itemDisplay,
                style: TextStyle(
                  color: item.isBought ? const Color(0xFF8A8E9B) : const Color(0xFF1A1D26),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  decoration: item.isBought ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Chiều cao phù hợp hơn
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFFEE2E2), width: 1)),
      ),
      child: const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(icon: Icons.home_outlined, label: 'Home', isActive: false),
            _NavBarItem(icon: Icons.kitchen_outlined, label: 'Pantry', isActive: false),
            _NavBarItem(icon: Icons.calendar_today_outlined, label: 'Planner', isActive: false),
            _NavBarItem(icon: Icons.shopping_bag, label: 'Shopping', isActive: true),
          ],
        ),
      ),
    );
  }

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFFFF8460) : const Color(0xFF8A8E9B);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}