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

  final List<String> _timeOptions = [
    'All',
    '< 15 mins',
    '< 30 mins',
    '< 60 mins',
  ];
  final List<String> _difficultyOptions = ['All', 'Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    if (widget.currentFilters != null) {
      setState(() {
        _selectedTime = widget.currentFilters!['maxReadyTime'] ?? 'All';
        _selectedDifficulty = widget.currentFilters!['difficulty'] ?? 'All';
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedTime = 'All';
      _selectedDifficulty = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // THANH KÉO (HANDLE)
          Center(
            child: Container(
              width: 45,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Recipes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              TextButton(
                onPressed: _resetFilters,
                style: TextButton.styleFrom(foregroundColor: Colors.orange),
                child: const Text(
                  'Reset All',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(
            color: isDark ? Colors.grey[850] : Colors.grey[200],
            thickness: 1,
          ),

          // NỘI DUNG LỌC
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 16),

                // PHẦN 1: THỜI GIAN
                _buildSectionTitle('Cooking Time', isDark),
                _buildChipGroup(
                  options: _timeOptions,
                  currentValue: _selectedTime,
                  onSelect: (val) => setState(() => _selectedTime = val),
                  activeColor: Colors.orange,
                  isDark: isDark,
                ),

                const SizedBox(height: 32),

                // PHẦN 2: ĐỘ KHÓ
                _buildSectionTitle('Difficulty Level', isDark),
                _buildChipGroup(
                  options: _difficultyOptions,
                  currentValue: _selectedDifficulty,
                  onSelect: (val) => setState(() => _selectedDifficulty = val),
                  activeColor: Colors.blueAccent,
                  isDark: isDark,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // NÚT ÁP DỤNG (APPLY)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, {
                      'maxReadyTime': _selectedTime,
                      'difficulty': _selectedDifficulty,
                    });
                  },
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildChipGroup({
    required List<String> options,
    required String currentValue,
    required Function(String) onSelect,
    required Color activeColor,
    required bool isDark,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final bool isSelected = currentValue == option;

        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (bool selected) {
            if (selected) onSelect(option);
          },
          selectedColor: activeColor,
          backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
          labelStyle: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
          showCheckmark: false,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? activeColor
                  : (isDark ? Colors.grey[800]! : Colors.transparent),
              width: 1,
            ),
          ),
        );
      }).toList(),
    );
  }
}
