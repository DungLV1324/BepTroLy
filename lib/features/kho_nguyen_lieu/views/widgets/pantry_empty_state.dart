import 'package:flutter/material.dart';

class PantryEmptyState extends StatelessWidget {
  final bool isSearching;
  final String searchQuery;

  const PantryEmptyState({
    super.key,
    required this.isSearching,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.kitchen_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            isSearching
                ? "No items match\n\"$searchQuery\""
                : "Your fridge is empty!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          if (!isSearching) ...[
            const SizedBox(height: 8),
            Text("Tap the (+) button to add new items", style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          ]
        ],
      ),
    );
  }
}