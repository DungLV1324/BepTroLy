import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../../models/ingredient_model.dart';
import '../../../services/spoonacular_service.dart';

class IngredientNameField extends StatelessWidget {
  final TextEditingController controller;
  final SpoonacularService apiService;
  final Function(IngredientModel) onSuggestionSelected;

  const IngredientNameField({
    super.key,
    required this.controller,
    required this.apiService,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ingredient name", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TypeAheadField<IngredientModel>(
          controller: controller,
          builder: (context, controller, focusNode) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: _inputDecoration(context, "Rice,..."),
              validator: (value) => (value == null || value.trim().isEmpty) ? "Please enter ingredient name" : null,
            );
          },
          suggestionsCallback: (search) async {
            if (search.isEmpty) return [];
            return await apiService.searchIngredients(search);
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              leading: suggestion.imageUrl != null
                  ? Image.network(suggestion.imageUrl!, width: 30, errorBuilder: (_, _, _) => const Icon(Icons.image))
                  : const Icon(Icons.food_bank),
              title: Text(suggestion.name),
              subtitle: Text(suggestion.aisle ?? 'Unknown'),
            );
          },
          onSelected: onSuggestionSelected,
          emptyBuilder: (context) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Item not found'),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey.shade300),
      ),
    );
  }
}