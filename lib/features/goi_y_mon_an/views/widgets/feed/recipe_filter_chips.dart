import 'package:flutter/material.dart';

class RecipeFilterChips extends StatelessWidget {
  final List<Map<String, dynamic>> filters;
  final int selectedIndex;
  final Function(int) onSelected;

  const RecipeFilterChips({
    super.key,
    required this.filters,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              showCheckmark: false,
              avatar: Icon(
                filter['icon'],
                size: 18,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              label: Text(filter['label']),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[300] : Colors.grey[700]),
                fontWeight: FontWeight.w500,
              ),
              selected: isSelected,
              selectedColor: Colors.orange,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Colors.orange
                      : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                ),
              ),
              onSelected: (_) => onSelected(index),
            ),
          );
        },
      ),
    );
  }
}
