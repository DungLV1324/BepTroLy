import 'package:flutter/material.dart';

class RecipeFilterSheet extends StatefulWidget {
  final Map<String, dynamic>? currentFilters;
  const RecipeFilterSheet({super.key, this.currentFilters});

  @override
  State<RecipeFilterSheet> createState() => _RecipeFilterSheetState();
}

class _RecipeFilterSheetState extends State<RecipeFilterSheet> {
  String _selectedTime = 'All';
  String _selectedDifficulty = 'All';
  String _selectedDiet = 'None';

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
    if (widget.currentFilters != null) {
      _selectedTime = widget.currentFilters!['maxReadyTime'] ?? 'All';
      _selectedDifficulty = widget.currentFilters!['difficulty'] ?? 'All';
      _selectedDiet = widget.currentFilters!['diet'] ?? 'None';
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedTime = 'All';
      _selectedDifficulty = 'All';
      _selectedDiet = 'None';
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Xác định chế độ tối/sáng
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        // Đã bỏ const
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // THANH KÉO TRÊN CÙNG
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Advanced Filters',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black, // Màu tiêu đề
                ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: Text(
                  'Reset',
                  style: TextStyle(color: isDark ? Colors.orange : Colors.red),
                ),
              ),
            ],
          ),
          Divider(color: isDark ? Colors.grey[800] : Colors.grey[300]),

          // NỘI DUNG LỌC
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 10),
                _buildSectionTitle('Cooking Time', isDark),
                _buildChipGroup(
                  _timeOptions,
                  _selectedTime,
                  (val) => setState(() => _selectedTime = val),
                  Colors.orange,
                  isDark,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Difficulty', isDark),
                _buildChipGroup(
                  _difficultyOptions,
                  _selectedDifficulty,
                  (val) => setState(() => _selectedDifficulty = val),
                  Colors.blue,
                  isDark,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Dietary Preference', isDark),
                _buildChipGroup(
                  _dietOptions,
                  _selectedDiet,
                  (val) => setState(() => _selectedDiet = val),
                  Colors.green,
                  isDark,
                ),
              ],
            ),
          ),
          // NÚT ÁP DỤNG
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, {
                  'maxReadyTime': _selectedTime,
                  'difficulty': _selectedDifficulty,
                  'diet': _selectedDiet,
                });
              },
              child: const Text(
                'Apply Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          // Đã bỏ const
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildChipGroup(
    List<String> options,
    String selected,
    Function(String) onSelect,
    Color color,
    bool isDark, // Đã thêm tham số
  ) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selected == option;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          selectedColor: color,
          // Màu nền khi chưa chọn
          backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
          // Màu chữ
          labelStyle: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
          ),
          // Sửa viền
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected
                  ? color
                  : (isDark ? Colors.grey[800]! : Colors.transparent),
            ),
          ),
          onSelected: (bool s) {
            if (s) onSelect(option);
          },
        );
      }).toList(),
    );
  }
}
