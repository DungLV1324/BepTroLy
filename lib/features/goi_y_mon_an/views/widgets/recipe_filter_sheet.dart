import 'package:flutter/material.dart';

class RecipeFilterSheet extends StatefulWidget {
  // Nhận vào các giá trị lọc hiện tại (để hiển thị đúng trạng thái cũ)
  final Map<String, dynamic>? currentFilters;

  const RecipeFilterSheet({super.key, this.currentFilters});

  @override
  State<RecipeFilterSheet> createState() => _RecipeFilterSheetState();
}

class _RecipeFilterSheetState extends State<RecipeFilterSheet> {
  // Khởi tạo giá trị mặc định
  String _selectedTime = 'All';
  String _selectedDifficulty = 'All';
  String _selectedDiet = 'None';

  // Dữ liệu mẫu cho các bộ lọc
  final List<String> _timeOptions = [
    'All',
    '< 15 mins',
    '< 30 mins',
    '< 60 mins',
  ];
  final List<String> _difficultyOptions = ['All', 'Easy', 'Medium', 'Hard'];
  final List<String> _dietOptions = [
    'None',
    'Vegetarian',
    'Vegan',
    'Gluten Free',
    'Ketogenic',
  ];

  @override
  void initState() {
    super.initState();
    // Nếu có dữ liệu cũ truyền vào thì cập nhật state
    if (widget.currentFilters != null) {
      _selectedTime = widget.currentFilters!['maxReadyTime'] ?? 'All';
      _selectedDifficulty =
          widget.currentFilters!['difficulty'] ??
          'All'; // Lưu ý: API Spoonacular free ko support filter difficulty trực tiếp, đây là giả lập UI
      _selectedDiet = widget.currentFilters!['diet'] ?? 'None';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // Chiếm 75% màn hình
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER (Thanh nắm kéo + Tiêu đề) ---
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lọc nâng cao',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: const Text(
                  'Đặt lại',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          const Divider(),

          // --- BODY (Nội dung cuộn) ---
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 10),

                // 1. Thời gian nấu
                _buildSectionTitle('Thời gian nấu'),
                _buildChipGroup(
                  options: _timeOptions,
                  selectedOption: _selectedTime,
                  onSelect: (val) => setState(() => _selectedTime = val),
                  color: Colors.orange,
                ),
                const SizedBox(height: 24),

                // 2. Độ khó
                _buildSectionTitle('Độ khó'),
                _buildChipGroup(
                  options: _difficultyOptions,
                  selectedOption: _selectedDifficulty,
                  onSelect: (val) => setState(() => _selectedDifficulty = val),
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),

                // 3. Chế độ ăn (Diet)
                _buildSectionTitle('Chế độ ăn'),
                _buildChipGroup(
                  options: _dietOptions,
                  selectedOption: _selectedDiet,
                  onSelect: (val) => setState(() => _selectedDiet = val),
                  color: Colors.green,
                ),
              ],
            ),
          ),

          // --- FOOTER (Nút Áp dụng) ---
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Màu chủ đạo của App
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                // Đóng sheet và trả về dữ liệu lọc
                Navigator.pop(context, {
                  'maxReadyTime': _selectedTime,
                  'difficulty': _selectedDifficulty,
                  'diet': _selectedDiet,
                });
              },
              child: const Text(
                'Áp dụng bộ lọc',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20), // Bottom safe area padding
        ],
      ),
    );
  }

  // Widget tiêu đề section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Widget hiển thị danh sách Chips
  Widget _buildChipGroup({
    required List<String> options,
    required String selectedOption,
    required Function(String) onSelect,
    required Color color,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selectedOption == option;
        return ChoiceChip(
          label: Text(option),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          selected: isSelected,
          selectedColor: color,
          backgroundColor: Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: isSelected ? color : Colors.transparent),
          ),
          onSelected: (bool selected) {
            if (selected) {
              onSelect(option);
            }
          },
        );
      }).toList(),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedTime = 'All';
      _selectedDifficulty = 'All';
      _selectedDiet = 'None';
    });
  }
}
