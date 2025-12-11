import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // 1. Bắt buộc có import này

import '../viewmodels/recipe_view_model.dart';
// Sử dụng đường dẫn package để tránh lỗi Type Mismatch với app_routes
import 'package:beptroly/features/goi_y_mon_an/models/recipe_model.dart';

class RecipeFeedScreen extends StatefulWidget {
  const RecipeFeedScreen({super.key});

  @override
  State<RecipeFeedScreen> createState() => _RecipeFeedScreenState();
}

class _RecipeFeedScreenState extends State<RecipeFeedScreen> {
  // Giả lập nguyên liệu trong kho
  final List<String> _myPantryIngredients = [
    'chicken',
    'egg',
    'tomato',
    'onion',
    'rice',
  ];
  int _selectedFilter = 0;
  final List<Map<String, dynamic>> _filters = [
    {'label': 'Trending', 'icon': null},
    {'label': 'Under 20 mins', 'icon': Icons.access_time},
    {'label': 'Have Ingredients', 'icon': Icons.check_circle_outline},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeViewModel>().fetchSuggestedRecipes(
        _myPantryIngredients,
      );
    });
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
          onPressed: () => context.pop(), // Quay lại màn hình trước
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
            // Phần Header & Filter (Giữ nguyên)
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
                        final isSelected = _selectedFilter == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Row(
                              children: [
                                if (filter['icon'] != null) ...[
                                  Icon(
                                    filter['icon'],
                                    size: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[700],
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(filter['label']),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) =>
                                setState(() => _selectedFilter = index),
                            backgroundColor: Colors.grey[100],
                            selectedColor: Colors.orange[400],
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Danh sách món ăn
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

                      // --- ĐÂY LÀ PHẦN QUAN TRỌNG ĐỂ ĐIỀU HƯỚNG ---
                      return GestureDetector(
                        onTap: () {
                          // Gọi đúng đường dẫn đã khai báo trong app_routes.dart
                          // Đường dẫn phải là: /home/recipe_detail
                          context.push('/home/recipe_detail', extra: recipe);
                        },
                        child: _RecipeCard(
                          title: recipe.name,
                          imageUrl: recipe.imageUrl,
                          time: recipe.cookingTimeMinutes > 0
                              ? '${recipe.cookingTimeMinutes} phút'
                              : 'Chi tiết xem sau',
                          difficulty: 'Trung bình',
                          usedCount: recipe.usedIngredientCount,
                          totalCount:
                              recipe.usedIngredientCount +
                              recipe.missedIngredientCount,
                        ),
                      );
                      // ---------------------------------------------
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

// Widget Card (Giữ nguyên)
class _RecipeCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String time;
  final String difficulty;
  final int usedCount;
  final int totalCount;

  const _RecipeCard({
    required this.title,
    required this.imageUrl,
    required this.time,
    required this.difficulty,
    this.usedCount = 0,
    this.totalCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasAllIngredients = totalCount > 0 && usedCount == totalCount;
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: hasAllIngredients
                        ? Colors.green[50]
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasAllIngredients
                            ? Icons.check_circle
                            : Icons.shopping_basket,
                        size: 16,
                        color: hasAllIngredients
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasAllIngredients
                            ? 'Đủ nguyên liệu!'
                            : 'Có sẵn $usedCount/$totalCount nguyên liệu',
                        style: TextStyle(
                          color: hasAllIngredients
                              ? Colors.green[700]
                              : Colors.orange[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
