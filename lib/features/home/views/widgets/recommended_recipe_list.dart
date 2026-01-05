import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../goi_y_mon_an/viewmodels/recipe_view_model.dart';

class RecommendedRecipeList extends StatelessWidget {
  const RecommendedRecipeList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeViewModel>(
      builder: (context, recipeModel, child) {
        if (recipeModel.state == RecipeViewState.loading) {
          return const SizedBox(
            height: 250,
            child: Center(child: CircularProgressIndicator(color: Colors.orange)),
          );
        }

        if (recipeModel.recipes.isEmpty) {
          return Container(
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: const Text("No suitable suggestions found yet."),
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
              return GestureDetector(
                onTap: () => context.push('/recipe_detail', extra: item),
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
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
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
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
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              if (item.missedIngredientCount > 0)
                                Text(
                                  'Lack ${item.missedIngredientCount} ingredient',
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
                                )
                              else
                                const Text(
                                  'Enough ingredients!',
                                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
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