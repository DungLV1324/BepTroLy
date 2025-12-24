import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_enums.dart';
import '../../models/ingredient_model.dart';
import '../../services/spoonacular_service.dart';

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
      _qtyController.text = item.quantity.toString(); // Bỏ chữ .0 nếu cần
      _selectedUnit = item.unit;
      _expiryDate = item.expiryDate;
      _imageUrl = item.imageUrl;
      _aisle = item.aisle;

      if (_expiryDate != null) {
        _dateController.text = DateFormat('dd/MM/yyyy').format(_expiryDate!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Thêm nguyên liệu mới", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),

            const Text("Tên nguyên liệu", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
          TypeAheadField<IngredientModel>(
            builder: (context, controller, focusNode) {
              controller.text = _nameController.text;

              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: _inputDecoration("Nhập tên tiếng Anh để có gợi ý tốt nhất (ví dụ: Rice (gạo))"),
                onChanged: (value) {
                  _nameController.text = value;
                },
              );
            },

            suggestionsCallback: (search) async {
              return await _apiService.searchIngredients(search);
            },

            itemBuilder: (context, suggestion) {
              return ListTile(
                leading: suggestion.imageUrl != null
                    ? Image.network(
                  suggestion.imageUrl!,
                  width: 30,
                  errorBuilder: (_, _, _) =>
                  const Icon(Icons.image),
                )
                    : const Icon(Icons.food_bank),
                title: Text(suggestion.name),
                subtitle: Text(suggestion.aisle ?? 'Unknown aisle'),
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
              child: Text('Không tìm thấy món này'),
            ),
          ),

          const SizedBox(height: 16),

            // 2. SỐ LƯỢNG & ĐƠN VỊ (Row)
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Số lượng", style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration("e.g., 500"),
                        validator: (value) => value!.isEmpty ? "Nhập số" : null,
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
                      const Text("Đơn vị", style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<MeasureUnit>(
                        value: _selectedUnit,
                        decoration: _inputDecoration(""),
                        items: MeasureUnit.values.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit.name), // Hiển thị 'kg', 'g', 'piece'
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedUnit = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 3. NGÀY HẾT HẠN (DatePicker)
            const Text("Ngày hết hạn", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _dateController,
              readOnly: true, // Không cho nhập tay
              decoration: _inputDecoration("dd/mm/yyyy").copyWith(
                suffixIcon: const Icon(Icons.calendar_today, size: 20),
              ),
              onTap: _pickDate,
              validator: (value) => value!.isEmpty ? "Chọn ngày" : null,
            ),

            const SizedBox(height: 24),

            // 4. BUTTON SAVE
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Màu xanh lá
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveIngredient,
                child: const Text("Save Ingredient", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),

            // Padding bottom để tránh bàn phím che (nếu cần)
            Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)),
          ],
        ),
      ),
    );
  }

  // Helper: Style cho các ô nhập
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.grey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }

  // Logic chọn ngày
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

  void _saveIngredient() {
    if (_formKey.currentState!.validate()) {
      final newItem = IngredientModel(
        // QUAN TRỌNG: Nếu đang sửa thì phải giữ nguyên ID cũ
        id: widget.ingredientToEdit?.id ?? '',
        name: _nameController.text,
        quantity: double.tryParse(_qtyController.text) ?? 1,
        unit: _selectedUnit,
        expiryDate: _expiryDate,
        addedDate: widget.ingredientToEdit?.addedDate ?? DateTime.now(), // Giữ ngày thêm cũ
        imageUrl: _imageUrl,
        aisle: _aisle ?? 'Pantry',
      );

      Navigator.pop(context, newItem);
    }
  }
}