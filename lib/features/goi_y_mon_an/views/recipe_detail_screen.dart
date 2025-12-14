// File: lib/features/goi_y_mon_an/views/recipe_detail_screen.dart

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

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late RecipeModel _fullRecipe;
  bool _isLoading = true;
  final RecipeServices _recipeService = RecipeServices();

  // 1. Controller để điều khiển việc kéo thả Sheet
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fullRecipe = widget.recipe;
    _loadFullDetails();
  }

  @override
  void dispose() {
    _sheetController.dispose(); // Nhớ dispose controller
    _tabController.dispose();
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

  // 2. Hàm kích hoạt mở rộng Sheet lên full màn hình
  void _expandSheet() {
    if (_sheetController.isAttached) {
      _sheetController.animateTo(
        1.0, // 1.0 tương đương 100% màn hình
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. ẢNH HEADER (Nằm cố định phía sau)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height:
                MediaQuery.of(context).size.height *
                0.6, // Ảnh chiếm 60% màn hình
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

          // 3. SHEET KÉO THẢ (Thay thế cho Positioned.fill cũ)
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.55, // Mặc định hiển thị 55% màn hình
            minChildSize: 0.5, // Kéo xuống thấp nhất là 50%
            maxChildSize: 1.0, // Kéo lên cao nhất là 100%
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
                // Sử dụng SingleChildScrollView với controller của Sheet để đồng bộ cuộn
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      // Thanh gạch ngang (Handle) - Ấn vào để mở rộng
                      GestureDetector(
                        onTap: _expandSheet,
                        child: Container(
                          width: double.infinity,
                          color: Colors.transparent, // Tăng diện tích bấm
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
                            // Tên món ăn - Ấn vào cũng mở rộng
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

                            // TabBar
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

                            // Nội dung Tab
                            // Dùng SizedBox để định chiều cao tối thiểu cho nội dung bên trong
                            SizedBox(
                              height:
                                  600, // Chiều cao đủ lớn để chứa nội dung list
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
                            const SizedBox(
                              height: 50,
                            ), // Padding đáy để không bị cấn
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

  // SỬA: Thêm physics và shrinkWrap để list con không cuộn riêng lẻ
  Widget _buildIngredientsList(Color greenColor) {
    if (_fullRecipe.ingredients.isEmpty) {
      return const Center(child: Text("Không có thông tin nguyên liệu."));
    }
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(), // Khóa cuộn riêng
      shrinkWrap: true, // Co lại vừa đủ nội dung
      padding: EdgeInsets.zero,
      itemCount: _fullRecipe.ingredients.length,
      itemBuilder: (context, index) {
        final item = _fullRecipe.ingredients[index];
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

  // SỬA: Thêm physics và shrinkWrap
  Widget _buildStepsList() {
    if (_fullRecipe.instructions.isEmpty) {
      return const Center(child: Text("Chưa có hướng dẫn chi tiết."));
    }
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(), // Khóa cuộn riêng
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
