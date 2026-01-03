import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:beptroly/features/goi_y_mon_an/viewmodels/recipe_view_model.dart';
import 'package:beptroly/features/goi_y_mon_an/models/recipe_model.dart';
import 'package:beptroly/features/goi_y_mon_an/views/widgets/recipe_filter_sheet.dart';

class RecipeFeedScreen extends StatefulWidget {
  const RecipeFeedScreen({super.key});

  @override
  State<RecipeFeedScreen> createState() => _RecipeFeedScreenState();
}

class _RecipeFeedScreenState extends State<RecipeFeedScreen> {
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

  // --- HÀM MỞ BẢNG LỌC NÂNG CAO ---
  Future<void> _openFilterSheet() async {
    // Mở Bottom Sheet và đợi dữ liệu lọc trả về
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RecipeFilterSheet(),
    );

    // Nếu người dùng nhấn 'Apply Filters'
    if (result != null) {
      debugPrint("Selected filters: $result");

      context.read<RecipeViewModel>().fetchRecipesWithFilter(
        query: '',
        time: result['maxReadyTime'] == 'All' ? '' : result['maxReadyTime'],
        diet: result['diet'] == 'None' ? '' : result['diet'],
      );
    }
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

  String _calculateDifficulty(int minutes) {
    if (minutes <= 0 || minutes <= 20) return 'Easy';
    if (minutes <= 45) return 'Medium';
    return 'Hard';
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecipeViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Recipe Suggestions",
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
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'What do you want\nto cook today? ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const Text('🔍', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Ô TÌM KIẾM CÓ NÚT LỌC (Tune Icon)
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
                      hintText: 'Search recipes...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),

                      // NÚT Lọc
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.tune, color: Colors.orange),
                        onPressed: _openFilterSheet,
                      ),

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

                  // Filter Chips
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
                            avatar: Icon(
                              filter['icon'],
                              size: 18,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
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
                                setState(() => _selectedFilterIndex = index);
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

            Expanded(
              child: Builder(
                builder: (context) {
                  if (viewModel.state == RecipeViewState.loading)
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    );
                  if (viewModel.state == RecipeViewState.error)
                    return Center(
                      child: Text('Error: ${viewModel.errorMessage}'),
                    );
                  if (viewModel.recipes.isEmpty)
                    return const Center(child: Text("No recipes found!"));

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: viewModel.recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = viewModel.recipes[index];

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
                          // FALLBACK: Không hiện See details
                          time: recipe.cookingTimeMinutes > 0
                              ? '${recipe.cookingTimeMinutes} mins'
                              : '15 mins',
                          difficulty: _calculateDifficulty(
                            recipe.cookingTimeMinutes,
                          ),
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

class _RecipeCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String time;
  final String difficulty;
  final bool hasAllIngredients;
  final VoidCallback? onBuyIngredients;

  const _RecipeCard({
    required this.title,
    required this.imageUrl,
    required this.time,
    required this.difficulty,
    this.hasAllIngredients = false,
    this.onBuyIngredients,
  });

  @override
  Widget build(BuildContext context) {
    String statusText = hasAllIngredients
        ? 'Ingredients ready!'
        : 'Needs ingredients';
    Color statusColor = hasAllIngredients
        ? Colors.green[700]!
        : Colors.orange[700]!;
    Color statusBg = hasAllIngredients ? Colors.green[50]! : Colors.orange[50]!;
    IconData statusIcon = hasAllIngredients
        ? Icons.check_circle
        : Icons.shopping_basket;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: Colors.grey[200], height: 200),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                time,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(width: 12),
              Icon(Icons.bar_chart, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                difficulty,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
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
              const SizedBox(width: 10),
              // giỏ hàng
              InkWell(
                onTap: onBuyIngredients,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5722),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}