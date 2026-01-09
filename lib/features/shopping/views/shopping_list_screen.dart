import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/shopping_list_view_model.dart';
import '../models/shopping_item_model.dart';
import '../../../core/constants/app_enums.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  void _onCompletePressed(BuildContext context) async {
    final viewModel = Provider.of<ShoppingListViewModel>(
      context,
      listen: false,
    );
    final unboughtItems = viewModel.items
        .where((item) => !item.isBought)
        .toList();

    bool? shouldProceed = true;

    if (unboughtItems.isNotEmpty) {
      shouldProceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('I haven\'t finished buying everything yet?'),
          content: Text(
            'You still have ${unboughtItems.length} items not marked as purchased. Do you want to finalize and save your selected items?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Back to Shopping List'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Still complete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (shouldProceed == true) {
      await viewModel.completeShoppingAndSaveHistory();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved shopping history!')),
        );
      }
    }
  }

  void _showAddItemsForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddItemsFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.history,
            color: isDark ? Colors.white : const Color(0xFF1A1D26),
          ),
          onPressed: () {
            context.go('/shopping/history');
          },
        ),
        title: Text(
          'Shopping List',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1D26),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
            child: ElevatedButton(
              onPressed: () => _onCompletePressed(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2BEE79),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'COMPLETE',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _ShoppingListBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemsForm(context),
        backgroundColor: const Color(0xFF2BEE79),
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text(
          'Add Items ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ShoppingListBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<ShoppingListViewModel>(
      builder: (context, viewModel, child) {
        final allItems = viewModel.items;

        if (allItems.isEmpty) {
          return Center(
            child: Text(
              'The list is empty. Please add items to buy!',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'THINGS TO BUY',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.grey[400] : Colors.blueGrey,
                ),
              ),
            ),
            Divider(
              height: 1,
              color: isDark ? Colors.grey[800] : Colors.grey.shade200,
            ),
            ...allItems.map(
              (item) => _ShoppingListItem(
                item: item,
                onToggle: () =>
                    viewModel.toggleBoughtStatus(item.id, item.isBought),
              ),
            ),
            const SizedBox(height: 120),
          ],
        );
      },
    );
  }
}

class _ShoppingListItem extends StatelessWidget {
  final ShoppingItemModel item;
  final VoidCallback onToggle;

  const _ShoppingListItem({required this.item, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey.shade100,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onToggle,
        leading: Icon(
          item.isBought ? Icons.check_box : Icons.check_box_outline_blank,
          color: item.isBought
              ? const Color(0xFF34C759)
              : (isDark ? Colors.grey[600] : Colors.grey),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: item.isBought ? TextDecoration.lineThrough : null,
            color: item.isBought
                ? Colors.grey
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
        trailing: Text(
          "${item.quantity} ${item.unit.name}",
          style: TextStyle(
            color: item.isBought
                ? Colors.grey
                : (isDark ? Colors.grey[400] : Colors.blueGrey),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AddItemsFormSheet extends StatefulWidget {
  const _AddItemsFormSheet();
  @override
  State<_AddItemsFormSheet> createState() => _AddItemsFormSheetState();
}

class _AddItemsFormSheetState extends State<_AddItemsFormSheet> {
  final List<_DraftItem> _draftItems = [_DraftItem()];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ShoppingListViewModel>(
      context,
      listen: false,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'New Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _draftItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _ItemInputRow(
                  item: _draftItems[index],
                  onRemove: () {
                    if (_draftItems.length > 1) {
                      setState(() => _draftItems.removeAt(index));
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => setState(() => _draftItems.add(_DraftItem())),
            icon: const Icon(Icons.add, color: Color(0xFF2BEE79)),
            label: const Text(
              'New Line',
              style: TextStyle(color: Color(0xFF2BEE79)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2BEE79),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                for (var draft in _draftItems) {
                  if (draft.nameController.text.isNotEmpty) {
                    viewModel.addItem(
                      draft.nameController.text.trim(),
                      double.tryParse(draft.qtyController.text) ?? 1.0,
                      draft.selectedUnit,
                      category: 'Shopping List',
                    );
                  }
                }
                Navigator.pop(context);
              },
              child: const Text(
                'SAVE TO LIST',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemInputRow extends StatefulWidget {
  final _DraftItem item;
  final VoidCallback onRemove;
  const _ItemInputRow({required this.item, required this.onRemove});

  @override
  State<_ItemInputRow> createState() => _ItemInputRowState();
}

class _ItemInputRowState extends State<_ItemInputRow> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: widget.item.nameController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'Name Item',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey.shade400,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 1,
          child: TextField(
            controller: widget.item.qtyController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'SL',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey.shade400,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey.shade400,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<MeasureUnit>(
                value: widget.item.selectedUnit,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => widget.item.selectedUnit = val);
                  }
                },
                items: MeasureUnit.values.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(
                      unit.name,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: widget.onRemove,
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        ),
      ],
    );
  }
}

class _DraftItem {
  final nameController = TextEditingController();
  final qtyController = TextEditingController(text: "1");
  MeasureUnit selectedUnit = MeasureUnit.piece;
}
