import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:beptroly/features/goi_y_mon_an/viewmodels/recipe_view_model.dart';
import 'package:beptroly/features/kho_nguyen_lieu/view_models/pantry_view_model.dart';

import 'widgets/feed/recipe_card.dart';
import 'widgets/feed/recipe_search_bar.dart';
import 'widgets/feed/recipe_filter_chips.dart';
import 'widgets/feed/recipe_filter_sheet.dart';

class RecipeFeedScreen extends StatefulWidget {
  const RecipeFeedScreen({super.key});

  @override
  State<RecipeFeedScreen> createState() => _RecipeFeedScreenState();
}

class _RecipeFeedScreenState extends State<RecipeFeedScreen> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDataForFilter(0));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // --- LOGIC HỖ TRỢ ---

  void _loadDataForFilter(int index) {
    final viewModel = context.read<RecipeViewModel>();
    final type = _filters[index]['type'];

    if (type == 'pantry') {
      final pantryNames = context
          .read<PantryViewModel>()
          .ingredients
          .map((e) => e.name)
          .toList();
      viewModel.fetchSuggestedRecipes(pantryNames);
    } else if (type == 'time') {
      viewModel.fetchRecipesWithFilter(query: '', time: '< 20 mins');
    } else {
      viewModel.fetchRecipesWithFilter(query: '');
    }
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RecipeFilterSheet(),
    );

    if (result != null && mounted) {
      int? maxTime;
      if (result['maxReadyTime'] != 'All') {
        maxTime = int.tryParse(
          result['maxReadyTime'].replaceAll(RegExp(r'[^0-9]'), ''),
        );
      }
      String difficulty = result['difficulty'] == 'All'
          ? ''
          : result['difficulty'];
      context.read<RecipeViewModel>().fetchRecipesWithFilter(
        query: '',
        time: maxTime != null ? maxTime.toString() : '',
        difficulty: difficulty,
      );
    }
  }

  bool _checkInPantry(String name) {
    final pantryVM = context.read<PantryViewModel>();
    return pantryVM.ingredients.any(
      (item) =>
          name.toLowerCase().contains(item.name.toLowerCase()) ||
          item.name.toLowerCase().contains(name.toLowerCase()),
    );
  }

  String _calculateDifficulty(int minutes) {
    if (minutes <= 20) return 'Easy';
    if (minutes <= 45) return 'Medium';
    return 'Hard';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recipeVM = context.watch<RecipeViewModel>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: _buildAppBar(isDark),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderSection(recipeVM, isDark),
            Expanded(child: _buildRecipeList(recipeVM)),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? Colors.white : Colors.black,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        "Recipe Suggestions",
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeaderSection(RecipeViewModel recipeVM, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What do you want\nto cook today? 🔍',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),

          RecipeSearchBar(
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 1000), () {
                context.read<RecipeViewModel>().fetchRecipesWithFilter(
                  query: value,
                );
              });
            },
            onFilterTap: _openFilterSheet,
          ),
          const SizedBox(height: 16),

          RecipeFilterChips(
            filters: _filters,
            selectedIndex: _selectedFilterIndex,
            onSelected: (index) {
              setState(() => _selectedFilterIndex = index);
              _loadDataForFilter(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList(RecipeViewModel recipeVM) {
    if (recipeVM.state == RecipeViewState.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }
    if (recipeVM.state == RecipeViewState.error) {
      return Center(child: Text('Error: ${recipeVM.errorMessage}'));
    }
    if (recipeVM.recipes.isEmpty) {
      return const Center(child: Text("No recipes found!"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: recipeVM.recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipeVM.recipes[index];

        // Tính toán nguyên liệu thiếu
        final actualMissed = recipe.ingredients.isNotEmpty
            ? recipe.ingredients
                  .where((ing) => !_checkInPantry(ing.name))
                  .map((ing) => ing.name)
                  .toList()
            : recipe.missedIngredients
                  .where((name) => !_checkInPantry(name))
                  .toList();

        final bool isFull =
            actualMissed.isEmpty &&
            (recipe.ingredients.isNotEmpty || recipe.usedIngredientCount > 0);
        return RecipeCard(
          title: recipe.name,
          imageUrl: recipe.imageUrl,
          time: recipe.cookingTimeMinutes > 0
              ? '${recipe.cookingTimeMinutes} mins'
              : '15 mins',
          difficulty: _calculateDifficulty(recipe.cookingTimeMinutes),
          hasAllIngredients: isFull,
          onTap: () => context.push('/recipe_detail', extra: recipe),
          onBuyIngredients: () => context.go('/shopping', extra: actualMissed),
        );
      },
    );
  }
}
