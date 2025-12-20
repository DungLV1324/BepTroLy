import 'package:flutter/material.dart';
import '../../kho_nguyen_lieu/models/ingredient_model.dart';
import '../models/recipe_model.dart';
import '../services/recipe_services.dart';

class RecipeDetailScreen extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  // --- 1. BIẾN QUẢN LÝ TAB TỰ CHẾ (Thay cho TabController) ---
  int _selectedTabIndex = 0; // 0: Ingredients, 1: Steps

  late RecipeModel _fullRecipe;
  bool _isLoading = true;
  final RecipeServices _recipeService = RecipeServices();

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // --- 2. TỦ LẠNH GIẢ LẬP ---
  final List<String> _myPantry = [
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
  ];

  @override
  void initState() {
    super.initState();

    _fullRecipe = widget.recipe;
    _loadFullDetails();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
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
      print("Lỗi load chi tiết: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _expandSheet() {
    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _cleanUnit(dynamic unit) {
    String text = unit.toString();
    if (text.contains('.')) text = text.split('.').last;
    if (text.toLowerCase() == 'unknown' || text.toLowerCase() == 'undefined')
      return '';
    return text;
  }

  bool _checkIngredientInPantry(String ingredientName) {
    return _myPantry.any(
      (pantryItem) =>
          ingredientName.toLowerCase().contains(pantryItem.toLowerCase()) ||
          pantryItem.toLowerCase().contains(ingredientName.toLowerCase()),
    );
  }

  // --- 3. HÀM VẼ NÚT TAB ---
  Widget _buildCustomTabButton(String title, int index, Color activeColor) {
    bool isActive = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? activeColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ẢNH NỀN
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Image.network(
              _fullRecipe.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
            ),
          ),
          // NÚT BACK
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
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
          // SHEET KÉO THẢ
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.55,
            minChildSize: 0.5,
            maxChildSize: 1.0,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _expandSheet,
                        child: Container(
                          width: double.infinity,
                          color: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _expandSheet,
                              child: Text(
                                _fullRecipe.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            _isLoading
                                ? const LinearProgressIndicator(
                                    color: greenColor,
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildInfoCircle(
                                        icon: Icons.access_time,
                                        label:
                                            "${_fullRecipe.cookingTimeMinutes} mins",
                                        color: Colors.red.withOpacity(0.1),
                                        iconColor: Colors.redAccent,
                                      ),
                                      _buildInfoCircle(
                                        icon: Icons.layers_outlined,
                                        label: "Easy",
                                        color: Colors.green.withOpacity(0.1),
                                        iconColor: Colors.green,
                                      ),
                                      _buildInfoCircle(
                                        icon: Icons.people_outline,
                                        label: "2 people",
                                        color: Colors.orange.withOpacity(0.1),
                                        iconColor: Colors.orange,
                                      ),
                                    ],
                                  ),
                            const SizedBox(height: 24),

                            // --- 4. TAB BAR MỚI (Dùng Row + Hàm vẽ nút) ---
                            Row(
                              children: [
                                _buildCustomTabButton(
                                  "Ingredients",
                                  0,
                                  greenColor,
                                ),
                                _buildCustomTabButton("Steps", 1, greenColor),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // --- 5. NỘI DUNG TAB (Không giới hạn chiều cao nữa) ---
                            _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: greenColor,
                                    ),
                                  )
                                : (_selectedTabIndex == 0
                                      ? _buildIngredientsList(greenColor)
                                      : _buildStepsList()),

                            const SizedBox(height: 50),
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

  Widget _buildInfoCircle({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
  }) {
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
    if (_fullRecipe.ingredients.isEmpty)
      return const Center(child: Text("Không có thông tin nguyên liệu."));

    int totalCount = _fullRecipe.ingredients.length;
    int haveCount = 0;
    for (var item in _fullRecipe.ingredients) {
      if (_checkIngredientInPantry(item.name)) haveCount++;
    }

    bool hasAll = haveCount == totalCount && totalCount > 0;
    String statusText = hasAll
        ? "Đủ nguyên liệu!"
        : "Có sẵn $haveCount/$totalCount nguyên liệu";
    Color badgeColor = hasAll ? Colors.green[50]! : Colors.orange[50]!;
    Color textColor = hasAll ? Colors.green[700]! : Colors.orange[700]!;
    IconData badgeIcon = hasAll ? Icons.check_circle : Icons.shopping_basket;

    return Column(
      children: [
        // Badge
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(badgeIcon, color: textColor, size: 20),
              const SizedBox(width: 10),
              Text(
                statusText,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              if (!hasAll)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_shopping_cart,
                    size: 16,
                    color: textColor,
                  ),
                ),
            ],
          ),
        ),

        // List Ingredients
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _fullRecipe.ingredients.length,
          itemBuilder: (context, index) {
            final item = _fullRecipe.ingredients[index];
            bool isHave = _checkIngredientInPantry(item.name);

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
                    isHave ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 20,
                    color: isHave ? greenColor : Colors.grey[300],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "${item.quantity} ${_cleanUnit(item.unit)} ${item.name}",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isHave ? Colors.black87 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStepsList() {
    if (_fullRecipe.instructions.isEmpty)
      return const Center(child: Text("Chưa có hướng dẫn chi tiết."));
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 10),
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
