import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../goi_y_mon_an/models/recipe_model.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context), // Truyền context để điều hướng
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 30),

                  _buildSectionHeader('Sắp hết hạn', () {
                    context.go('/pantry');
                  }),
                  const SizedBox(height: 15),
                  _buildExpiringList(viewModel.expiringIngredients),

                  const SizedBox(height: 30),

                  _buildSectionHeader('Gợi ý cho bạn', () {
                    context.go('/home/recipes');
                  }),
                  const SizedBox(height: 15),
                  _buildRecipeList(viewModel.recommendedRecipes),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Bọc InkWell để bấm được
        InkWell(
          onTap: () => context.push('/settings'), // Chuyển sang Cài đặt
          borderRadius: BorderRadius.circular(30),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=11',
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Chào buổi sáng,',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  Text(
                    'Tên User!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Tìm công thức hoặc nguyên liệu',
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onPressed,
          child: const Text(
            'Xem tất cả',
            style: TextStyle(color: Colors.deepOrange),
          ),
        ),
      ],
    );
  }

  Widget _buildExpiringList(List<IngredientModel> ingredients) {
    if (ingredients.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text("Tủ lạnh của bạn đang trống!"),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ingredients.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final item = ingredients[index];
          final isUrgent = item.daysRemaining <= 2;

          return Container(
            width: 120,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFF0E0),
                  ),
                  child: ClipOval(
                    child: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                        ? Image.asset(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.eco,
                                color: Colors.orange,
                                size: 30,
                              );
                            },
                          )
                        : const Icon(Icons.eco, color: Colors.orange, size: 30),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  'Còn ${item.daysRemaining} ngày',
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
    );
  }

  Widget _buildRecipeList(List<RecipeModel> recipes) {
    if (recipes.isEmpty) {
      return const Text("Chưa có gợi ý nào.");
    }

    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recipes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final item = recipes[index];

          ImageProvider imageProvider;
          if (item.imageUrl.startsWith('http')) {
            imageProvider = NetworkImage(item.imageUrl);
          } else {
            imageProvider = AssetImage(item.imageUrl);
          }

          // 2. Logic điều hướng (Từ code cũ - Stashed)
          return GestureDetector(
            onTap: () {
              // Chuyển sang màn hình chi tiết món ăn
              context.push('/home/recipe_detail', extra: item);
            },
            child: Container(
              width: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            image: DecorationImage(
                              image: imageProvider, // Sử dụng provider đã xử lý
                              fit: BoxFit.cover,
                              onError: (e, s) => const Icon(Icons.broken_image),
                            ),
                            color: Colors.grey[200],
                          ),
                        ),
                        const Positioned(
                          top: 10,
                          right: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 14,
                            child: Icon(
                              Icons.favorite_border,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${item.cookingTimeMinutes} phút',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (item.missedIngredientCount > 0)
                            Text(
                              'Thiếu ${item.missedIngredientCount} nguyên liệu',
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            )
                          else
                            const Text(
                              'Đủ nguyên liệu!',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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
  }
}
