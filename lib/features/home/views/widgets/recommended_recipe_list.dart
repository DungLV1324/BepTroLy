import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../goi_y_mon_an/viewmodels/recipe_view_model.dart';
import '../../../kho_nguyen_lieu/view_models/pantry_view_model.dart';

class RecommendedRecipeList extends StatelessWidget {
  const RecommendedRecipeList({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pantryVM = context.watch<PantryViewModel>();

    return Consumer<RecipeViewModel>(
      builder: (context, recipeModel, child) {
        if (recipeModel.state == RecipeViewState.loading) {
          return const SizedBox(
            height: 250,
            child: Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          );
        }

        if (recipeModel.recipes.isEmpty) {
          return Container(
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "No suitable suggestions found yet.",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          );
        }

        return SizedBox(
          height: 260,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            scrollDirection: Axis.horizontal,
            itemCount: recipeModel.recipes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              final item = recipeModel.recipes[index];
              final List<String> recipeIngNames = item.ingredients
                  .map((e) => e.name)
                  .toList();

              final bool isReady =
                  recipeIngNames.isNotEmpty &&
                  recipeIngNames.every(
                    (ingName) => pantryVM.ingredients.any(
                      (p) =>
                          ingName.toLowerCase().contains(
                            p.name.toLowerCase(),
                          ) ||
                          p.name.toLowerCase().contains(ingName.toLowerCase()),
                    ),
                  );

              return GestureDetector(
                onTap: () => context.push('/recipe_detail', extra: item),
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      isReady
                                          ? "Enough ingredients!"
                                          : "Lack ingredients",
                                      style: TextStyle(
                                        color: isReady
                                            ? Colors.green
                                            : Colors.redAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (!isReady)
                                    InkWell(
                                      onTap: () {
                                        final List<String>
                                        missed = recipeIngNames
                                            .where(
                                              (
                                                name,
                                              ) => !pantryVM.ingredients.any(
                                                (p) =>
                                                    name.toLowerCase().contains(
                                                      p.name.toLowerCase(),
                                                    ) ||
                                                    p.name
                                                        .toLowerCase()
                                                        .contains(
                                                          name.toLowerCase(),
                                                        ),
                                              ),
                                            )
                                            .toList();

                                        context.push(
                                          '/shopping',
                                          extra: missed,
                                        );
                                      },
                                      child: const Icon(
                                        Icons.shopping_cart_outlined,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
