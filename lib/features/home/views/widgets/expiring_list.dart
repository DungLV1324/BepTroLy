import 'package:flutter/material.dart';
import '../../../kho_nguyen_lieu/models/ingredient_model.dart';

class ExpiringList extends StatelessWidget {
  final List<IngredientModel> ingredients;

  const ExpiringList({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
        child: const Text(
          "Your pantry is safe! No items expiring soon.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
        ),
      );
    }

    return SizedBox(
      height: 165,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ingredients.length,
        separatorBuilder: (_, _) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final item = ingredients[index];
          final isUrgent = item.daysRemaining <= 1;

          return Container(
            width: 120,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImage(item),
                const SizedBox(height: 12),
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.daysRemaining == 0
                      ? 'Expires today'
                      : '${item.daysRemaining} days left',
                  style: TextStyle(
                    color: isUrgent ? Colors.red : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(IngredientModel item) {
    return Container(
      height: 60,
      width: 60,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFFF0E0),
      ),
      child: ClipOval(
        child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
            ? Image.network(
          item.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildFallbackIcon(),
        )
            : _buildFallbackIcon(),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Icon(Icons.kitchen, color: Colors.orange[800], size: 30);
  }
}