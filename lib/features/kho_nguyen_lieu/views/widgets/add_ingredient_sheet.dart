import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../../models/ingredient_model.dart';
import '../../services/spoonacular_service.dart';
import 'barcode_scanner_page.dart';

class AddIngredientSheet extends StatefulWidget {
  final IngredientModel? ingredientToEdit;
  const AddIngredientSheet({super.key, this.ingredientToEdit});

  @override
  State<AddIngredientSheet> createState() => _AddIngredientSheetState();
}

class _AddIngredientSheetState extends State<AddIngredientSheet> {
  final SpoonacularService _apiService = SpoonacularService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // State
  MeasureUnit _selectedUnit = MeasureUnit.g;
  DateTime? _expiryDate;
  String? _imageUrl;
  String? _aisle;

  @override
  void initState() {
    super.initState();
    if (widget.ingredientToEdit != null) {
      final item = widget.ingredientToEdit!;
      _nameController.text = item.name;
      _qtyController.text = item.quantity.toString();
      _selectedUnit = item.unit;
      _expiryDate = item.expiryDate;
      _imageUrl = item.imageUrl;
      _aisle = item.aisle;
    } else {
      _expiryDate = DateTime.now();
    }

    if (_expiryDate != null) {
      _dateController.text = DateFormat('dd/MM/yyyy').format(_expiryDate!);
    }
  }

  //QUÉT BARCODE
  Future<void> _onScanBarcode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
    );

    if (result != null && result is String) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Looking for product information..."),
          duration: Duration(seconds: 1),
        ),
      );

      try {
        // Gọi API tìm sản phẩm
        final product = await _apiService.findProductByBarcode(result);

        if (!mounted) return;

        if (product != null) {
          setState(() {
            _nameController.text = product.name;
            _imageUrl = product.imageUrl;
            _aisle = product.aisle;
          });
          DialogHelper.showScanResultDialog(
            context: context,
            title: "Product Found!",
            content: "Successfully added: ${product.name}",
            isSuccess: true,
          );
        } else {
          DialogHelper.showScanResultDialog(
            context: context,
            title: "Not Found",
            content: "Cannot find product with barcode: $result",
            isSuccess: false,
          );
        }
      } catch (e) {
        print("Lỗi khi tìm sản phẩm: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Network connection error!")),
          );
        }
      }
    }
  }

  //QUÉT HÓA ĐƠN
  void _onScanReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("The receipt scanning feature is under development!"),
      ),
    );
  }

  void _saveIngredient() {
    if (_formKey.currentState!.validate()) {
      final newItem = IngredientModel(
        id: widget.ingredientToEdit?.id ?? '',
        name: _nameController.text,
        quantity: double.tryParse(_qtyController.text) ?? 1,
        unit: _selectedUnit,
        expiryDate: _expiryDate,
        addedDate: widget.ingredientToEdit?.addedDate ?? DateTime.now(),
        imageUrl: _imageUrl,
        aisle: _aisle ?? 'Pantry',
      );

      Navigator.pop(context, newItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.ingredientToEdit != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(
              isEditing ? "Update ingredient" : "Add new ingredient",
            ),
            const SizedBox(height: 20),

            // Nút Scan (Chỉ hiện khi thêm mới)
            if (!isEditing) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildScanButton(
                      icon: Icons.qr_code_scanner,
                      label: "Scan Barcode",
                      color: const Color(0xFFFFE0B2),
                      textColor: Colors.orange[900]!,
                      onTap: _onScanBarcode,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildScanButton(
                      icon: Icons.receipt_long,
                      label: "Scan Receipt",
                      color: const Color(0xFFFFEBEE),
                      textColor: Colors.red[900]!,
                      onTap: _onScanReceipt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Input Tên (TypeAhead + Validator)
            _buildNameInputSection(),
            const SizedBox(height: 16),

            // Số lượng & Đơn vị
            _buildQuantityAndUnitSection(),
            const SizedBox(height: 16),

            // Ngày hết hạn
            _buildDateInputSection(),
            const SizedBox(height: 24),

            // Nút Lưu
            _buildSaveButton(isEditing ? "Save changes" : "Add to pantry"),

            // Padding bàn phím
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      helperText: ' ',
      helperStyle: const TextStyle(height: 0.7),
      errorStyle: const TextStyle(height: 0.7, color: Colors.red),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[800]! : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
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

  Widget _buildNameInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ingredient name",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        TypeAheadField<IngredientModel>(
          controller: _nameController,

          builder: (context, controller, focusNode) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: _inputDecoration("Rice, Gạo..."),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? "Please enter ingredient name"
                  : null,
            );
          },
          suggestionsCallback: (search) async {
            if (search.isEmpty) return [];
            return await _apiService.searchIngredients(search);
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              leading: suggestion.imageUrl != null
                  ? Image.network(
                      suggestion.imageUrl!,
                      width: 30,
                      errorBuilder: (_, _, _) => const Icon(Icons.image),
                    )
                  : const Icon(Icons.food_bank),
              title: Text(suggestion.name),
              subtitle: Text(suggestion.aisle ?? 'Unknown'),
            );
          },
          onSelected: (suggestion) {
            _nameController.text = suggestion.name;
            setState(() {
              _imageUrl = suggestion.imageUrl;
              _aisle = suggestion.aisle;
            });
          },
          emptyBuilder: (context) => const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Item not found'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityAndUnitSection() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Quantity",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _qtyController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDecoration("e.g., 500"),
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
                value: _selectedUnit,
                decoration: _inputDecoration(""),
                items: MeasureUnit.values.map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit.name));
                }).toList(),
                onChanged: (val) => setState(() => _selectedUnit = val!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Expiration date",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          decoration: _inputDecoration(
            "dd/mm/yyyy",
          ).copyWith(suffixIcon: const Icon(Icons.calendar_today, size: 20)),
          onTap: _pickDate,
          validator: (value) => value!.isEmpty ? "Select date" : null,
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Widget _buildSaveButton(String label) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _saveIngredient,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
