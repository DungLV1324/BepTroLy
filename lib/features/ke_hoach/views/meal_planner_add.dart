import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/meal_planner_add_viewmodel.dart';
import '../models/meal_plan_model.dart';
import '../../../core/constants/app_enums.dart';

class WeeklyMealPlannerScreen extends StatelessWidget {
  const WeeklyMealPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeeklyMealPlannerViewModel(),
      // Đã sửa: Sử dụng Consumer để cung cấp context mới cho các widget con
      child: Consumer<WeeklyMealPlannerViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF6F8F6),
            appBar: _buildHeader(context, viewModel),
            body: const MealPlannerList(),
            floatingActionButton: FloatingActionButton(
              onPressed: () => GoRouter.of(context).push('/planner/add'),
              backgroundColor: const Color(0xFF50C878),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  // Đã sửa: _buildHeader giờ nhận viewModel trực tiếp
  PreferredSizeWidget _buildHeader(BuildContext context, WeeklyMealPlannerViewModel viewModel) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false, // Tắt nút back mặc định
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: () => viewModel.previousWeek(), icon: const Icon(Icons.chevron_left, color: Color(0xFF1A1C1E))),
          const Text('Lịch bữa ăn', style: TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => viewModel.nextWeek(), icon: const Icon(Icons.chevron_right, color: Color(0xFF1A1C1E))),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(20),
        child: Text('Tháng 12, 09 - 15', style: TextStyle(color: Color(0xFF50C878), fontSize: 12)),
      ),
    );
  }
}

class MealPlannerList extends StatelessWidget {
  const MealPlannerList({super.key});

  String _formatDate(DateTime date) {
    const dayOfWeekMap = {1: 'Thứ Hai', 2: 'Thứ Ba', 3: 'Thứ Tư', 4: 'Thứ Năm', 5: 'Thứ Sáu', 6: 'Thứ Bảy', 7: 'Chủ Nhật'};
    return '${dayOfWeekMap[date.weekday] ?? ''}, ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WeeklyMealPlannerViewModel>();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.weeklyPlans.length,
      itemBuilder: (context, index) {
        final dayPlan = viewModel.weeklyPlans[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _formatDate(dayPlan.date),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
              ),
            ),
            ...dayPlan.meals.map((mealPlan) => _buildMealCard(context, mealPlan)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildMealCard(BuildContext context, MealPlanModel mealPlan) {
    final bool isEmpty = mealPlan.selectedMeal == null;

    if (isEmpty) {
      return GestureDetector(
        onTap: () => GoRouter.of(context).push('/planner/add'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFC8E6C9)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(mealPlan.mealType.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('Chạm để thêm món', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => GoRouter.of(context).push('/planner/add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF0F0F0),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Thêm món', style: TextStyle(fontSize: 12)),
              )
            ],
          ),
        ),
      );
    }

    final meal = mealPlan.selectedMeal!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealPlan.mealType.name.toUpperCase(),
                  style: const TextStyle(color: Color(0xFF50C878), fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${meal.preparationTimeMinutes} phút, ${meal.kcal} kcal',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(image: NetworkImage(meal.imageUrl), fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}
