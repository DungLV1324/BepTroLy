import 'package:flutter/material.dart';

class IngredientItemTile extends StatelessWidget {
  final String name;
  final double quantity;
  final String unit;
  final bool isHave;

  const IngredientItemTile({
    super.key,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.isHave,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color greenColor = Color(0xFF4CAF50);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isHave
            ? greenColor.withOpacity(0.15)
            : (isDark ? const Color(0xFF2C2C2C) : Colors.grey[50]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: isHave
                ? greenColor
                : (isDark ? Colors.grey[700] : Colors.grey[300]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "${quantity.toStringAsFixed(1)} $unit $name",
              style: TextStyle(
                fontSize: 15,
                fontWeight: isHave ? FontWeight.bold : FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
