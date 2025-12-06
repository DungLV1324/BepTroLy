import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/recipe_view_model.dart';

class RecipeFeedScreen extends StatefulWidget {
  const RecipeFeedScreen({super.key});

  @override
  State<RecipeFeedScreen> createState() => _RecipeFeedScreenState();
}

class _RecipeFeedScreenState extends State<RecipeFeedScreen> {
  int _selectedFilter = 0;

  final List<String> _myPantryIngredients = [
    'chicken',
    'egg',
    'tomato',
    'onion',
    'rice',
  ];

  final List<Map<String, dynamic>> _filters = [
    {'label': 'Trending', 'icon': null},
    {'label': 'Under 20 mins', 'icon': Icons.access_time},
    {'label': 'Have Ingredients', 'icon': Icons.check_circle_outline},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeViewModel>().fetchSuggestedRecipes(_myPantryIngredients);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecipeViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Hôm nay bạn muốn\nnấu món gì? 🍳',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.grey[100],
                        child: const Text('😊', style: TextStyle(fontSize: 20)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  TextField(
                    onSubmitted: (value) {
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
                        final isSelected = _selectedFilter == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
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
                              fontWeight: FontWeight.w500,
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

            Expanded(
              child: Builder(
                builder: (context) {
                  // 1. Trạng thái Loading
                  if (viewModel.state == RecipeViewState.loading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.orange),
                          SizedBox(height: 10),
                          Text("Đang hỏi đầu bếp Spoonacular..."),
                        ],
                      ),
                    );
                  }

                  if (viewModel.state == RecipeViewState.error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 10),
                            Text(
                              'Lỗi: ${viewModel.errorMessage}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.read<RecipeViewModel>().fetchSuggestedRecipes(_myPantryIngredients);
                              },
                              child: const Text("Thử lại"),
                            )
                          ],
                        ),
                      ),
                    );
                  }

                  if (viewModel.recipes.isEmpty) {
                    return const Center(
                      child: Text("Không tìm thấy món nào với nguyên liệu này!"),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = viewModel.recipes[index];

                      return _RecipeCard(
                        title: recipe.name,
                        imageUrl: recipe.imageUrl,

                        time: recipe.cookingTimeMinutes > 0
                            ? '${recipe.cookingTimeMinutes} phút'
                            : 'Chi tiết xem sau',

                        difficulty: 'Trung bình',
                        usedCount: recipe.usedIngredientCount,
                        totalCount: recipe.usedIngredientCount + recipe.missedIngredientCount,
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
          // Recipe Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey[300],
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        Text("Lỗi ảnh", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Recipe Info
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

                // Time and Difficulty
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    const SizedBox(width: 16),
                    const Icon(Icons.bar_chart, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(difficulty, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: hasAllIngredients ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasAllIngredients ? Icons.check_circle : Icons.shopping_basket,
                        size: 16,
                        color: hasAllIngredients ? Colors.green[700] : Colors.orange[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasAllIngredients
                            ? 'Đủ nguyên liệu!'
                            : 'Có sẵn $usedCount/$totalCount nguyên liệu',
                        style: TextStyle(
                          color: hasAllIngredients ? Colors.green[700] : Colors.orange[700],
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