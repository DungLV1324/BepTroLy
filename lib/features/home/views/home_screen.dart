import 'package:beptroly/features/home/views/widgets/home_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../goi_y_mon_an/viewmodels/recipe_view_model.dart';
import '../viewmodels/home_view_model.dart';
import 'widgets/home_header.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/section_header.dart';
import 'widgets/expiring_list.dart';
import 'widgets/recommended_recipe_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadHomeData();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncPantryToRecipes();
    });
  }

  void _syncPantryToRecipes() {
    final pantryItems = context.read<HomeViewModel>().expiringIngredients;
    if (pantryItems.isNotEmpty) {
      List<String> ingredients = pantryItems.map((e) => e.name).toList();
      context.read<RecipeViewModel>().fetchSuggestedRecipes(ingredients);
    } else {
      context.read<RecipeViewModel>().fetchSuggestedRecipes(['chicken', 'egg']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              );
            }

            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.orange));
            }

            return RefreshIndicator(
              onRefresh: () async => viewModel.loadHomeData(),
              color: Colors.orange,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header
                    const HomeHeader(),
                    const SizedBox(height: 20),

                    // 2. Search
                    const HomeSearchBar(),
                    const SizedBox(height: 30),
                    if (viewModel.isSearching)
                      buildSearchResults(viewModel)

                    // Nếu không -> Hiện trang chủ bình thường
                    else ...[
                      SectionHeader(title: 'Expiring Soon', onSeeAll: () => context.go('/pantry')),
                      const SizedBox(height: 15),
                      ExpiringList(ingredients: viewModel.expiringIngredients),
                      const SizedBox(height: 30),
                      SectionHeader(title: 'Recommended for you', onSeeAll: () => context.push('/recipes')),
                      const SizedBox(height: 15),
                      const RecommendedRecipeList(),
                    ],
                    // 3. Expiring Section
                    SectionHeader(
                      title: 'Expiring Soon',
                      onSeeAll: () => context.go('/pantry'),
                    ),
                    const SizedBox(height: 15),
                    ExpiringList(ingredients: viewModel.expiringIngredients),

                    const SizedBox(height: 30),

                    // 4. Recipe Section
                    SectionHeader(
                      title: 'Recommended for you',
                      onSeeAll: () => context.push('/recipes'),
                    ),
                    const SizedBox(height: 15),
                    const RecommendedRecipeList(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
