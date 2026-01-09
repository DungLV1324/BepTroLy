import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String time;
  final String difficulty;
  final bool hasAllIngredients;
  final VoidCallback? onBuyIngredients;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.time,
    required this.difficulty,
    this.hasAllIngredients = false,
    this.onBuyIngredients,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = hasAllIngredients
        ? 'Ingredients ready!'
        : 'Needs ingredients';
    final statusColor = hasAllIngredients
        ? Colors.green[700]!
        : Colors.orange[700]!;
    final statusBg = hasAllIngredients ? Colors.green[50]! : Colors.orange[50]!;
    final statusIcon = hasAllIngredients
        ? Icons.check_circle
        : Icons.shopping_basket;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey[200], height: 200),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            _buildInfoRow(),
            const SizedBox(height: 12),
            _buildStatusRow(statusBg, statusIcon, statusColor, statusText),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        const SizedBox(width: 12),
        Icon(Icons.bar_chart, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          difficulty,
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildStatusRow(Color bg, IconData icon, Color color, String text) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _buildCartButton(),
      ],
    );
  }

  Widget _buildCartButton() {
    return InkWell(
      onTap: onBuyIngredients,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5722),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.shopping_cart_outlined,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
