import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:beptroly/features/goi_y_mon_an/viewmodels/recipe_view_model.dart';
import 'package:beptroly/features/goi_y_mon_an/models/recipe_model.dart';

class RecipeFeedScreen extends StatefulWidget {
  const RecipeFeedScreen({super.key});

  @override
  State<RecipeFeedScreen> createState() => _RecipeFeedScreenState();
}

class _RecipeFeedScreenState extends State<RecipeFeedScreen> {
  // 1. TỦ LẠNH GIẢ LẬP
  final List<String> _myPantryIngredients = [
    'chicken',
    'egg',
    'tomato',
    'onion',
    'rice',
    'bananas',
    'oatmeal',
    'peanut butter',
    'sundried tomatoes',
    'parsley',
    'olive oil',
    'basil',
    'eggs',
  ];

  int _selectedFilterIndex = 0;
  Timer? _debounce;

  final List<Map<String, dynamic>> _filters = [
    {'label': 'Trending', 'icon': Icons.whatshot, 'type': 'trending'},
    {'label': 'Under 20 mins', 'icon': Icons.timer_outlined, 'type': 'time'},
    {
      'label': 'Have Ingredients',
      'icon': Icons.check_circle_outline,
      'type': 'pantry',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataForFilter(0);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _loadDataForFilter(int index) {
    final viewModel = context.read<RecipeViewModel>();
    final type = _filters[index]['type'];
    if (type == 'pantry') {
      viewModel.fetchSuggestedRecipes(_myPantryIngredients);
    } else if (type == 'time') {
      viewModel.fetchRecipesWithFilter(query: '', time: '< 20 mins');
    } else {
      viewModel.fetchRecipesWithFilter(query: '');
    }
  }

  bool _checkInPantry(String name) {
    return _myPantryIngredients.any(
      (item) =>
          name.toLowerCase().contains(item.toLowerCase()) ||
          item.toLowerCase().contains(name.toLowerCase()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecipeViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Gợi ý món ăn",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER & SEARCH BAR
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hôm nay bạn muốn\nnấu món gì? 🍳',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 1000), () {
                        context.read<RecipeViewModel>().fetchRecipesWithFilter(
                          query: value,
                        );
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm công thức...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final isSelected = _selectedFilterIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: FilterChip(
                            showCheckmark: false,
                            avatar: filter['icon'] != null
                                ? Icon(
                                    filter['icon'],
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                                  )
                                : null,
                            label: Text(filter['label']),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            selected: isSelected,
                            selectedColor: Colors.orange,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            onSelected: (bool selected) {
                              if (selected) {
                                setState(() {
                                  _selectedFilterIndex = index;
                                });
                                _loadDataForFilter(index);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // RECIPE LIST
            Expanded(
              child: Builder(
                builder: (context) {
                  if (viewModel.state == RecipeViewState.loading)
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    );
                  if (viewModel.state == RecipeViewState.error)
                    return Center(
                      child: Text('Lỗi: ${viewModel.errorMessage}'),
                    );
                  if (viewModel.recipes.isEmpty)
                    return const Center(child: Text("Không tìm thấy món nào!"));

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = viewModel.recipes[index];

                      // Logic tính toán thiếu/đủ nguyên liệu
                      List<String> actualMissed = [];
                      if (recipe.ingredients.isNotEmpty) {
                        actualMissed = recipe.ingredients
                            .where((ing) => !_checkInPantry(ing.name))
                            .map((ing) => ing.name)
                            .toList();
                      } else if (recipe.missedIngredients.isNotEmpty) {
                        actualMissed = recipe.missedIngredients
                            .where((name) => !_checkInPantry(name))
                            .toList();
                      }

                      bool isFull =
                          actualMissed.isEmpty &&
                          (recipe.ingredients.isNotEmpty ||
                              recipe.usedIngredientCount > 0);

                      return GestureDetector(
                        onTap: () =>
                            context.push('/recipe_detail', extra: recipe),
                        child: _RecipeCard(
                          title: recipe.name,
                          imageUrl: recipe.imageUrl,
                          time: recipe.cookingTimeMinutes > 0
                              ? '${recipe.cookingTimeMinutes} phút'
                              : 'Chi tiết xem sau',
                          difficulty: 'Trung bình',
                          hasAllIngredients: isFull,
                          onBuyIngredients: () =>
                              context.push('/shopping', extra: actualMissed),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET CARD ) ---
class _RecipeCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String time;
  final String difficulty;
  final bool hasAllIngredients;
  final VoidCallback? onBuyIngredients;

  const _RecipeCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.time,
    required this.difficulty,
    this.hasAllIngredients = false,
    this.onBuyIngredients,
  });

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    if (hasAllIngredients) {
      statusText = 'Đủ nguyên liệu!';
      statusColor = Colors.green[700]!;
      statusBg = Colors.green[50]!;
      statusIcon = Icons.check_circle;
    } else {
      statusText = 'Cần mua nguyên liệu';
      statusColor = Colors.orange[700]!;
      statusBg = Colors.orange[50]!;
      statusIcon = Icons.shopping_basket;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey[300],
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.bar_chart, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      difficulty,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // BADGE TRẠNG THÁI
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ), // Tăng padding dọc cho đẹp
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          // Dùng Row thay cho Column để icon và chữ nằm trên 1 hàng duy nhất
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 18, color: statusColor),
                            const SizedBox(width: 8),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!hasAllIngredients)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: InkWell(
                          onTap: onBuyIngredients,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
