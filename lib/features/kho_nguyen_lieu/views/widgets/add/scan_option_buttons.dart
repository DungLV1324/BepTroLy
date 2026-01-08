import 'package:flutter/material.dart';

class ScanOptionButtons extends StatelessWidget {
  final VoidCallback onScanBarcode;
  final VoidCallback onScanReceipt;

  const ScanOptionButtons({
    super.key,
    required this.onScanBarcode,
    required this.onScanReceipt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildScanButton(
            icon: Icons.qr_code_scanner,
            label: "Scan Barcode",
            color: const Color(0xFFFFE0B2),
            textColor: Colors.orange[900]!,
            onTap: onScanBarcode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildScanButton(
            icon: Icons.receipt_long,
            label: "Scan Receipt",
            color: const Color(0xFFFFEBEE),
            textColor: Colors.red[900]!,
            onTap: onScanReceipt,
          ),
        ),
      ],
    );
  }

  Widget _buildScanButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}