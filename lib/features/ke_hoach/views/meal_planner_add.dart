import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../viewmodels/meal_planner_add_viewmodel.dart';
import '../models/meal_plan_model.dart';

class WeeklyMealPlannerScreen extends StatelessWidget {
  const WeeklyMealPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeeklyMealPlannerViewModel(),
      child: Consumer<WeeklyMealPlannerViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF6F8F6),
            appBar: _buildHeader(context, viewModel),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF50C878)))
                : const MealPlannerList(),
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

  PreferredSizeWidget _buildHeader(BuildContext context, WeeklyMealPlannerViewModel viewModel) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: () => viewModel.previousWeek(),
              icon: const Icon(Icons.chevron_left, color: Color(0xFF1A1C1E))),
          const Text('Meal Plan', style: TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.bold)),
          IconButton(
              onPressed: () => viewModel.nextWeek(),
              icon: const Icon(Icons.chevron_right, color: Color(0xFF1A1C1E))),
        ],
      ),
    );
  }
}

class MealPlannerList extends StatelessWidget {
  const MealPlannerList({super.key});

  String _formatDate(DateTime date) {
    const dayOfWeekMap = {1: 'Monday', 2: 'Tuesday', 3: 'Wednesday', 4: 'Thursday', 5: 'Friday', 6: 'Saturday', 7: 'Sunday'};
    return '${dayOfWeekMap[date.weekday] ?? ''}, ${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WeeklyMealPlannerViewModel>();

    if (viewModel.weeklyPlans.isEmpty) {
      return const Center(child: Text('Chưa có kế hoạch nào trong database.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.weeklyPlans.length,
      itemBuilder: (context, index) {
        final dayPlan = viewModel.weeklyPlans[index];
        return Column(
          key: ValueKey(dayPlan.date.toString()),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(dayPlan.date),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
                  ),
                  Text(
                    '${dayPlan.totalKcal} kcal',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF50C878), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ...dayPlan.meals.map((mealPlan) => _buildDismissibleMealCard(context, viewModel, mealPlan)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildDismissibleMealCard(BuildContext context, WeeklyMealPlannerViewModel viewModel, MealPlanModel mealPlan) {
    return Dismissible(
      key: Key(mealPlan.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => viewModel.deleteMealPlan(mealPlan.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: _buildMealCard(context, mealPlan),
    );
  }

  Widget _buildMealCard(BuildContext context, MealPlanModel mealPlan) {
    final meal = mealPlan.selectedMeal;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: InkWell( // Thêm InkWell để bắt sự kiện nhấn
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showPlanDetailSheet(context, mealPlan), // Mở form thông tin chi tiết
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                      meal?.name ?? 'Chưa chọn món',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (meal != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${meal.preparationTimeMinutes} min, ${meal.kcal} kcal',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              if (meal != null)
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: meal.imageUrl.startsWith('http')
                          ? NetworkImage(meal.imageUrl)
                          : AssetImage(meal.imageUrl) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm hiển thị thông tin chi tiết kế hoạch
  void _showPlanDetailSheet(BuildContext context, MealPlanModel mealPlan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text(mealPlan.selectedMeal?.name ?? 'Plan Details', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.restaurant, 'Meal Type', mealPlan.mealType.name.toUpperCase()),
            _buildDetailRow(Icons.access_time, 'Time', '${mealPlan.specificTime.hour.toString().padLeft(2, '0')}:${mealPlan.specificTime.minute.toString().padLeft(2, '0')}'),
            _buildDetailRow(Icons.people, 'Servings', '${mealPlan.servings} People'),
            _buildDetailRow(Icons.event, 'Date', '${mealPlan.date.day}/${mealPlan.date.month}/${mealPlan.date.year}'),
            const SizedBox(height: 16),
            const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(mealPlan.notes.isEmpty ? 'No notes available' : mealPlan.notes, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF50C878),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF50C878)),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}