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
    } else {
      _expiryDate = DateTime.now();
    }

    if (_expiryDate != null) {
      _dateController.text = DateFormat('dd/MM/yyyy').format(_expiryDate!);
    }
  }
  @override
  Widget build(BuildContext context) {
    // Tiêu đề thay đổi tùy theo việc Thêm hay Sửa
    final isEditing = widget.ingredientToEdit != null;

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
            // 1. Header (Tiêu đề + Nút đóng)
            _buildHeader(isEditing ? "Cập nhật nguyên liệu" : "Thêm nguyên liệu mới"),
            const SizedBox(height: 20),

            // 2. Input Tên (Tìm kiếm gợi ý)
            _buildNameInputSection(),
            const SizedBox(height: 16),

            // 3. Hàng Số lượng & Đơn vị
            _buildQuantityAndUnitSection(),
            const SizedBox(height: 16),

            // 4. Input Ngày hết hạn
            _buildDateInputSection(),
            const SizedBox(height: 24),

            // 5. Nút Lưu
            _buildSaveButton(isEditing ? "Lưu thay đổi" : "Thêm vào tủ"),

            // Xử lý bàn phím che
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

  Widget _buildHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildNameInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tên nguyên liệu", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TypeAheadField<IngredientModel>(
          builder: (context, controller, focusNode) {
            // Đồng bộ text controller nếu cần thiết
            if (controller.text != _nameController.text) {
              controller.text = _nameController.text;
            }
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: _inputDecoration("Nhập tên tiếng Anh (ví dụ: Rice)"),
              // Lưu ý: Cập nhật controller chính khi gõ
              onChanged: (val) => _nameController.text = val,
            );
          },
          suggestionsCallback: (search) async {
            if (search.isEmpty) return [];
            return await _apiService.searchIngredients(search);
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              leading: suggestion.imageUrl != null
                  ? Image.network(suggestion.imageUrl!, width: 30, errorBuilder: (_, __, ___) => const Icon(Icons.image))
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
      ],
    );
  }

  Widget _buildQuantityAndUnitSection() {
    return Row(
      children: [
        // Cột Số lượng
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Số lượng", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _qtyController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration("e.g., 500"),
                validator: (value) => value!.isEmpty ? "Nhập số" : null,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Cột Đơn vị
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
                    child: Text(unit.name),
                  );
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
        const Text("Ngày hết hạn", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          decoration: _inputDecoration("dd/mm/yyyy").copyWith(
            suffixIcon: const Icon(Icons.calendar_today, size: 20),
          ),
          onTap: _pickDate,
          validator: (value) => value!.isEmpty ? "Chọn ngày" : null,
        ),
      ],
    );
  }

  Widget _buildSaveButton(String label) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _saveIngredient,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}