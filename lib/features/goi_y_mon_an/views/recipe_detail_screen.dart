import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../kho_nguyen_lieu/view_models/pantry_view_model.dart';
import '../models/recipe_model.dart';
import '../services/recipe_services.dart';

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

  // Hàm check đồ trong kho thật
  bool _checkInPantry(BuildContext context, String ingredientName) {
    final pantryVM = context.read<PantryViewModel>();
    return pantryVM.ingredients.any(
      (p) =>
          ingredientName.toLowerCase().contains(p.name.toLowerCase()) ||
          p.name.toLowerCase().contains(ingredientName.toLowerCase()),
    );
  }

  // ✅ HÀM ĐÃ CẬP NHẬT: Loại bỏ "unknown" và format Enum
  String _formatUnit(dynamic unit) {
    String unitStr = unit
        .toString()
        .split('.')
        .last; // Lấy phần chữ sau dấu chấm

    // Nếu là unknown thì trả về chuỗi rỗng để không hiện lên màn hình
    if (unitStr.toLowerCase() == 'unknown') {
      return "";
    }

    return unitStr;
  }

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. ẢNH HEADER (Cố định ở nền)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 400,
            child: Image.network(
              _fullRecipe.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
            ),
          ),

          // 2. NÚT BACK
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              radius: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 3. SHEET NỘI DUNG (CÓ THỂ KÉO LÊN/XUỐNG)
          DraggableScrollableSheet(
            initialChildSize: 0.65, // Chiều cao ban đầu
            minChildSize: 0.6, // Chiều cao tối thiểu
            maxChildSize: 0.95, // Chiều cao tối đa khi kéo hết cỡ
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController, // Gán controller để kéo được
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // Thanh gạch ngang giả làm tay cầm kéo
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Text(
                              _fullRecipe.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Thông tin tròn
                            _isLoading
                                ? const LinearProgressIndicator(
                                    color: greenColor,
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildInfoCircle(
                                        Icons.access_time,
                                        "${_fullRecipe.cookingTimeMinutes} mins",
                                        Colors.red.withOpacity(0.1),
                                        Colors.redAccent,
                                      ),
                                      _buildInfoCircle(
                                        Icons.layers_outlined,
                                        "Easy",
                                        Colors.green.withOpacity(0.1),
                                        Colors.green,
                                      ),
                                      _buildInfoCircle(
                                        Icons.people_outline,
                                        "2 people",
                                        Colors.orange.withOpacity(0.1),
                                        Colors.orange,
                                      ),
                                    ],
                                  ),
                            const SizedBox(height: 24),

                            TabBar(
                              controller: _tabController,
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: greenColor,
                              indicatorWeight: 3,
                              tabs: const [
                                Tab(text: "Ingredients"),
                                Tab(text: "Steps"),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // NỘI DUNG TAB (Bọc trong SizedBox để không bị lỗi layout khi kéo)
                            SizedBox(
                              height:
                                  500, // Chiều cao vùng nội dung bên trong sheet
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: greenColor,
                                      ),
                                    )
                                  : TabBarView(
                                      controller: _tabController,
                                      children: [
                                        _buildIngredientsList(greenColor),
                                        _buildStepsList(),
                                      ],
                                    ),
                            ),
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

  Widget _buildInfoCircle(
    IconData icon,
    String label,
    Color color,
    Color iconColor,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsList(Color greenColor) {
    if (_fullRecipe.ingredients.isEmpty) {
      return const Center(child: Text("Không có thông tin nguyên liệu."));
    }
    final pantryVM = context.watch<PantryViewModel>();

    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _fullRecipe.ingredients.length,
      itemBuilder: (context, index) {
        final item = _fullRecipe.ingredients[index];
        final bool isHave = _checkInPantry(context, item.name);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isHave ? greenColor.withOpacity(0.05) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                size: 20,
                color: isHave ? greenColor : Colors.grey[300],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  // CẬP NHẬT: toStringAsFixed(1) để làm tròn và dùng _formatUnit mới
                  "${item.quantity.toStringAsFixed(1)} ${_formatUnit(item.unit)} ${item.name}",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isHave ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepsList() {
    if (_fullRecipe.instructions.isEmpty) {
      return const Center(child: Text("Chưa có hướng dẫn chi tiết."));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _fullRecipe.instructions.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${index + 1}.",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _fullRecipe.instructions[index],
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
