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
      // Khởi tạo ViewModel và lắng nghe dữ liệu real-time
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


      ),
    );
  }

  // Hàm định dạng chuỗi ngày lặp lại từ Map<String, bool>
  String _getRepeatDaysText(Map<String, bool> repeatDays) {
    final selectedDays = repeatDays.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    if (selectedDays.isEmpty) return 'No repetition';
    if (selectedDays.length == 7) return 'Every day';
    return selectedDays.join(', ');
  }
}

class MealPlannerList extends StatelessWidget {
  const MealPlannerList({super.key});

  String _formatDate(DateTime date) {
    const dayOfWeekMap = {1: 'Monday', 2: 'Tuesday', 3: 'Wednesday', 4: 'Thursday', 5: 'Friday', 6: 'Saturday', 7: 'Sunday'};
    return '${dayOfWeekMap[date.weekday] ?? ''}, ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
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
                  Text(_formatDate(dayPlan.date), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('${dayPlan.totalKcal} kcal', style: const TextStyle(color: Color(0xFF50C878), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // mealPlans đã được tham chiếu dữ liệu từ Recipes
            ...dayPlan.mealPlans.map((mealPlan) => _buildDismissibleMealCard(context, viewModel, mealPlan)).toList(),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        onTap: () => _showPlanDetailSheet(context, mealPlan),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mealPlan.mealType.name.toUpperCase(),
                  style: const TextStyle(color: Color(0xFF50C878), fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Hiển thị tên tất cả các món trong mảng selectedMeals
              Text(
                mealPlan.selectedMeals.map((m) => m.name).join(", "),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Hàng ảnh thu nhỏ cho nhiều món ăn
              if (mealPlan.selectedMeals.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: mealPlan.selectedMeals.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) => _buildSafeImage(mealPlan.selectedMeals[i].imageUrl),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafeImage(String path) {
    final cleanPath = path.replaceAll(r'\', '/').trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: cleanPath.startsWith('http')
          ? Image.network(cleanPath, width: 40, height: 40, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
          : Image.asset(cleanPath, width: 40, height: 40, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 40, height: 40, color: Colors.grey[200],
            child: const Icon(Icons.fastfood, size: 20, color: Colors.grey),
          )),
    );
  }

  void _showPlanDetailSheet(BuildContext context, MealPlanModel mealPlan) {
    final viewModel = Provider.of<WeeklyMealPlannerViewModel>(context, listen: false);
    final screen = const WeeklyMealPlannerScreen(); // Để gọi hàm helper

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Plan Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

              ],
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Meals:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...mealPlan.selectedMeals.map((meal) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: _buildSafeImage(meal.imageUrl),
                          title: Text(meal.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          subtitle: Text('${meal.kcal} kcal • ${meal.preparationTimeMinutes} min', style: const TextStyle(fontSize: 12)),
                        )).toList(),
                    const Divider(),
                    _buildDetailRow(Icons.restaurant, 'Type', mealPlan.mealType.name.toUpperCase()),
                    _buildDetailRow(Icons.access_time, 'Time', mealPlan.specificTime.format(context)),
                    _buildDetailRow(Icons.people, 'Servings', '${mealPlan.servings} People'),
                    _buildDetailRow(Icons.repeat, 'Repeat', screen._getRepeatDaysText(mealPlan.repeatDays)),
                    const SizedBox(height: 16),
                    const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(mealPlan.notes.isEmpty ? 'No notes' : mealPlan.notes, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))),
                const SizedBox(width: 12),
                Expanded(
                    child: ElevatedButton(
                        onPressed: () => _confirmDelete(context, viewModel, mealPlan.id),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Delete Plan', style: TextStyle(color: Colors.white)))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WeeklyMealPlannerViewModel viewModel, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Plan?'),
        content: const Text('Are you sure you want to delete this plan??'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          TextButton(onPressed: () {
            viewModel.deleteMealPlan(id);
            Navigator.pop(ctx);
            Navigator.pop(context);
          }, child: const Text('Yes', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [Icon(icon, size: 18, color: const Color(0xFF50C878)), const SizedBox(width: 8), Text('$label: $value')]),
    );
  }
}
