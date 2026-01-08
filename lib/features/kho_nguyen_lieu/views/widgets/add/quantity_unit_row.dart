import 'package:flutter/material.dart';
import '../../../../../core/constants/app_enums.dart';

class QuantityUnitRow extends StatelessWidget {
  final TextEditingController qtyController;
  final MeasureUnit selectedUnit;
  final Function(MeasureUnit?) onUnitChanged;

  const QuantityUnitRow({
    super.key,
    required this.qtyController,
    required this.selectedUnit,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Quantity", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: qtyController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _commonInputDecoration(context, "e.g., 500"),
                validator: (value) => value!.isEmpty ? "Enter quantity" : null,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Unit", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<MeasureUnit>(
                value: selectedUnit,
                decoration: _commonInputDecoration(context, ""),
                items: MeasureUnit.values.map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit.name));
                }).toList(),
                onChanged: onUnitChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Bạn có thể đưa hàm này ra 1 file utils chung để dùng lại
  InputDecoration _commonInputDecoration(BuildContext context, String hint) {
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