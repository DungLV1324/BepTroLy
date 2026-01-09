import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../kho_nguyen_lieu/view_models/pantry_view_model.dart';
import '../models/recipe_model.dart';
import '../services/recipe_services.dart';

import 'widgets/detail/recipe_info_circle.dart';
import 'widgets/detail/ingredient_item_tile.dart';
import 'widgets/detail/instruction_step_tile.dart';

class RecipeDetailScreen extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late RecipeModel _fullRecipe;
  bool _isLoading = true;
  final RecipeServices _recipeService = RecipeServices();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fullRecipe = widget.recipe;
    _loadFullDetails();
  }

  // Logic tải dữ liệu chi tiết từ API
  Future<void> _loadFullDetails() async {
    try {
      final detailedRecipe = await _recipeService.getRecipeDetails(
        widget.recipe.id,
      );
      if (mounted) {
        setState(() {
          _fullRecipe = detailedRecipe;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Lỗi load chi tiết: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Logic kiểm tra nguyên liệu trong kho
  bool _checkInPantry(BuildContext context, String ingredientName) {
    final pantryVM = context.read<PantryViewModel>();
    return pantryVM.ingredients.any(
      (p) =>
          ingredientName.toLowerCase().contains(p.name.toLowerCase()) ||
          p.name.toLowerCase().contains(ingredientName.toLowerCase()),
    );
  }

  String _formatUnit(dynamic unit) {
    String unitStr = unit.toString().split('.').last;
    return unitStr.toLowerCase() == 'unknown' ? "" : unitStr;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color greenColor = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          // 1. Ảnh món ăn
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 400,
            child: Image.network(
              _fullRecipe.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: isDark ? Colors.grey[900] : Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 50),
              ),
            ),
          ),

          // 2. Nút quay lại (Back Button)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: CircleAvatar(
              backgroundColor: isDark
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.9),
              radius: 20,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white : Colors.black,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 3. Nội dung chi tiết (Draggable Sheet)
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.6,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black54 : Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      _buildHandleBar(isDark),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _buildTitle(isDark),
                            const SizedBox(height: 24),
                            _buildQuickInfo(greenColor, isDark),
                            const SizedBox(height: 24),
                            _buildTabBar(greenColor, isDark),
                            const SizedBox(height: 16),
                            _buildTabContent(greenColor, isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Các Widget thành phần bổ trợ ---

  Widget _buildHandleBar(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[700] : Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTitle(bool isDark) {
    return Text(
      _fullRecipe.name,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildQuickInfo(Color greenColor, bool isDark) {
    if (_isLoading) return LinearProgressIndicator(color: greenColor);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RecipeInfoCircle(
          icon: Icons.access_time,
          label: "${_fullRecipe.cookingTimeMinutes} mins",
          backgroundColor: Colors.red.withOpacity(0.1),
          iconColor: Colors.redAccent,
        ),
        RecipeInfoCircle(
          icon: Icons.layers_outlined,
          label: "Easy",
          backgroundColor: Colors.green.withOpacity(0.1),
          iconColor: Colors.green,
        ),
        RecipeInfoCircle(
          icon: Icons.people_outline,
          label: "2 people",
          backgroundColor: Colors.orange.withOpacity(0.1),
          iconColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildTabBar(Color greenColor, bool isDark) {
    return TabBar(
      controller: _tabController,
      labelColor: isDark ? greenColor : Colors.black,
      unselectedLabelColor: isDark ? Colors.white54 : Colors.grey,
      indicatorColor: greenColor,
      indicatorWeight: 3,
      tabs: const [
        Tab(text: "Ingredients"),
        Tab(text: "Steps"),
      ],
    );
  }

  Widget _buildTabContent(Color greenColor, bool isDark) {
    return SizedBox(
      height: 600,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildIngredientsTab(greenColor, isDark),
                _buildStepsTab(isDark),
              ],
            ),
    );
  }

  Widget _buildIngredientsTab(Color greenColor, bool isDark) {
    if (_fullRecipe.ingredients.isEmpty) {
      return Center(
        child: Text(
          "Không có thông tin nguyên liệu.",
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _fullRecipe.ingredients.length,
      itemBuilder: (context, index) {
        final item = _fullRecipe.ingredients[index];
        return IngredientItemTile(
          name: item.name,
          quantity: item.quantity,
          unit: _formatUnit(item.unit),
          isHave: _checkInPantry(context, item.name),
        );
      },
    );
  }

  Widget _buildStepsTab(bool isDark) {
    if (_fullRecipe.instructions.isEmpty) {
      return Center(
        child: Text(
          "Chưa có hướng dẫn chi tiết.",
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _fullRecipe.instructions.length,
      itemBuilder: (context, index) {
        return InstructionStepTile(
          stepNumber: index + 1,
          instruction: _fullRecipe.instructions[index],
        );
      },
    );
  }
}
