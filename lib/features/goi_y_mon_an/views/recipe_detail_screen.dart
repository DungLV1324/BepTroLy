import 'package:flutter/material.dart';
import '../../kho_nguyen_lieu/models/ingredient_model.dart';
import '../models/recipe_model.dart';
import '../services/recipe_services.dart'; // Import Service

class RecipeDetailScreen extends StatefulWidget {
  final RecipeModel recipe; // Dữ liệu tóm tắt truyền từ màn trước

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Biến để lưu dữ liệu đầy đủ sau khi load
  late RecipeModel _fullRecipe;
  bool _isLoading = true;
  final RecipeServices _recipeService = RecipeServices();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fullRecipe = widget.recipe; // Ban đầu dùng dữ liệu tóm tắt
    _loadFullDetails(); // Gọi API lấy chi tiết ngay
  }

  // Hàm gọi API lấy chi tiết
  Future<void> _loadFullDetails() async {
    try {
      final detailedRecipe = await _recipeService.getRecipeDetails(
        widget.recipe.id,
      );
      if (mounted) {
        setState(() {
          _fullRecipe = detailedRecipe; // Cập nhật dữ liệu đầy đủ
          _isLoading = false; // Tắt loading
        });
      }
    } catch (e) {
      print("Lỗi load chi tiết: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. ẢNH HEADER (Dùng ảnh từ màn trước để hiển thị ngay cho mượt)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
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

          // 3. SHEET NỘI DUNG
          Positioned.fill(
            top: 300,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Thanh gạch ngang
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        children: [
                          // Tên món ăn
                          Text(
                            _fullRecipe.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 3. THÔNG TIN TRÒN (Time, Difficulty, Servings)
                          // Nếu đang load thì hiện vòng xoay, xong thì hiện số liệu
                          _isLoading
                              ? const LinearProgressIndicator(color: greenColor)
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
                                      label:
                                          "Easy", // API Free thường không trả về độ khó, để cứng hoặc logic riêng
                                      color: Colors.green.withOpacity(0.1),
                                      iconColor: Colors.green,
                                    ),
                                    _buildInfoCircle(
                                      icon: Icons.people_outline,
                                      // Model cần có field servings, nếu chưa có thì hiển thị mặc định
                                      label: "2 people",
                                      color: Colors.orange.withOpacity(0.1),
                                      iconColor: Colors.orange,
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 24),

                          // TABBAR
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

                          // NỘI DUNG TAB
                          Expanded(
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị ô tròn thông tin
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

  // Tab 1: Danh sách nguyên liệu
  Widget _buildIngredientsList(Color greenColor) {
    if (_fullRecipe.ingredients.isEmpty) {
      return const Center(child: Text("Không có thông tin nguyên liệu."));
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _fullRecipe.ingredients.length,
      itemBuilder: (context, index) {
        final item = _fullRecipe.ingredients[index];
        // Logic giả lập: index chẵn là có sẵn (để demo UI check xanh)
        final bool isHave = index % 2 == 0;

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
                  // Ghép số lượng + đơn vị + tên (VD: 200g Pork)
                  "${item.quantity} ${item.unit} ${item.name}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Tab 2: Các bước thực hiện
  Widget _buildStepsList() {
    if (_fullRecipe.instructions.isEmpty) {
      return const Center(child: Text("Chưa có hướng dẫn chi tiết."));
    }
    return ListView.builder(
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
