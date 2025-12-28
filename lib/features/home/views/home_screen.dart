import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../goi_y_mon_an/models/recipe_model.dart';
import '../../goi_y_mon_an/viewmodels/recipe_view_model.dart';
import '../../kho_nguyen_lieu/models/ingredient_model.dart';
import '../../thongbao/view/notification_screen.dart';
import '../viewmodels/home_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadHomeData();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncPantryToRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      body: SafeArea(
        child: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            // 1. Loading State
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              );
            }

            // 2. Main Content
            return RefreshIndicator(
              onRefresh: () async => viewModel.loadHomeData(),
              color: Colors.orange,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),

                    _buildSearchBar(),
                    const SizedBox(height: 30),

                    // --- SECTION: EXPIRING SOON ---
                    _buildSectionHeader('Expiring Soon', () {
                      context.go('/pantry');
                      print("See all Pantry");
                    }),
                    const SizedBox(height: 15),
                    _buildExpiringList(viewModel.expiringIngredients),

                    const SizedBox(height: 30),

                    // --- SECTION: RECOMMENDED FOR YOU ---
                    _buildSectionHeader('Recommended for you', () {
                      context.push('/recipes');
                      print("See all Recipes");
                    }),
                    const SizedBox(height: 15),
                    _buildRecipeList(),

                    const SizedBox(height: 20), // Bottom spacing
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 1. Header: Avatar + Greeting + Notification Button
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 24,
              // Replace with actual user image URL
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
              backgroundColor: Colors.grey,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Good morning,', // "Chào buổi sáng"
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  'User Name!', // Replace with actual user name
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 28),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            );
          },
        ),
      ],
    );
  }

  /// 2. Search Bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Search recipes or ingredients',
          hintStyle: TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  /// 3. Section Header
  Widget _buildSectionHeader(String title, VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: onPressed,
          child: const Text(
            'See All', // "Xem tất cả"
            style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.w600,
                fontSize: 14
            ),
          ),
        ),
      ],
    );
  }

  /// 4. Horizontal List: Expiring Soon
  Widget _buildExpiringList(List<IngredientModel> ingredients) {
    if (ingredients.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)
        ),
        child: const Text(
          "Your pantry is safe! No items expiring soon.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
        ),

      );
    }

    return SizedBox(
      height: 165,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ingredients.length,
        separatorBuilder: (_, _) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final item = ingredients[index];
          final isUrgent = item.daysRemaining <= 1;

          return Container(
            width: 120,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Load ảnh pantry
                Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFF0E0), // Nền màu cam nhạt
                  ),
                  child: ClipOval(
                    // Logic: Có Link ảnh -> Load ảnh mạng. Không có hoặc lỗi -> Hiện Icon
                    child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                        ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover, // Cắt ảnh cho vừa hình tròn

                      // Xử lý khi ảnh mạng bị lỗi (link chết, mất mạng...)
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.kitchen, // <--- Icon bạn muốn
                          color: Colors.orange[800],
                          size: 30,
                        );
                      },

                      // (Tùy chọn) Hiện loading khi đang tải ảnh
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                            child: SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2)
                            )
                        );
                      },
                    )
                    // Trường hợp không có imageUrl ngay từ đầu
                        : Icon(
                      Icons.kitchen, // <--- Icon bạn muốn
                      color: Colors.orange[800],
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Item Name
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Days Remaining
                Text(
                  item.daysRemaining == 0
                      ? 'Expires today'
                      : '${item.daysRemaining} days left',
                  style: TextStyle(
                    color: isUrgent ? Colors.red : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );  }

  /// 5. Horizontal List: Recipes
  Widget _buildRecipeList() { // Bỏ tham số đầu vào, ta lấy trực tiếp từ Provider
    return Consumer<RecipeViewModel>(
      builder: (context, recipeModel, child) {

        // 1. Trạng thái đang tải
        if (recipeModel.state == RecipeViewState.loading) {
          return const SizedBox(
            height: 250,
            child: Center(child: CircularProgressIndicator(color: Colors.orange)),
          );
        }

        // 2. Trạng thái lỗi hoặc rỗng
        if (recipeModel.recipes.isEmpty) {
          return Container(
            height: 100,
            width: double.infinity,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12)
            ),
            child: const Text("Chưa có gợi ý nào phù hợp."),
          );
        }

        // 3. Hiển thị danh sách
        return SizedBox(
          height: 260, // Tăng chiều cao xíu để chứa đủ thông tin
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            scrollDirection: Axis.horizontal,
            itemCount: recipeModel.recipes.length, // Lấy số lượng thật
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              final item = recipeModel.recipes[index]; // Lấy món ăn thật

              return GestureDetector(
                onTap: () {
                  // Navigate sang màn hình chi tiết món ăn (nếu có)
                  // Hoặc chuyển tab sang Recipes
                  print("Click vào món: ${item.name}");
                },
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
                      // Image Section
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                color: Colors.grey,
                              ),
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: Image.network(
                                  item.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_,__,___) => const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                            // Favorite Icon
                            const Positioned(
                              top: 10,
                              right: 10,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 14,
                                child: Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Info Section
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Recipe Name
                              Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              // Cooking Time
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.cookingTimeMinutes > 0
                                        ? '${item.cookingTimeMinutes} mins'
                                        : 'N/A',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),

                              // Missing Ingredients Logic
                              if (item.missedIngredientCount > 0)
                                Text(
                                  'Thiếu ${item.missedIngredientCount} nguyên liệu',
                                  style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600
                                  ),
                                )
                              else
                                const Text(
                                  'Đủ nguyên liệu!',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold
                                  ),
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
  void _syncPantryToRecipes() {
    // Lấy danh sách nguyên liệu hiện có từ HomeViewModel
    final pantryItems = context.read<HomeViewModel>().expiringIngredients;

    // Nếu chưa có data thì thôi, nếu có rồi thì gọi API
    if (pantryItems.isNotEmpty) {
      // Chuyển đổi: List<IngredientModel> -> List<String> (tên tiếng Anh)
      // Ví dụ: item.name là "thịt gà" -> cần đảm bảo API hiểu, hoặc lưu tên tiếng Anh trong DB
      List<String> ingredients = pantryItems.map((e) => e.name).toList();

      // Gọi RecipeViewModel để fetch
      context.read<RecipeViewModel>().fetchSuggestedRecipes(ingredients);
    } else {
      // Nếu Home chưa kịp load pantry, ta có thể gọi một list mặc định hoặc chờ stream cập nhật
      // Để đơn giản, ta gọi tạm list mẫu hoặc để trống
      context.read<RecipeViewModel>().fetchSuggestedRecipes(['chicken', 'egg']);
    }
  }
}