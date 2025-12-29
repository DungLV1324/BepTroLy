import 'package:flutter/material.dart';
import '../models/meal_plan_model.dart';
import '../../../core/constants/app_enums.dart';

// Đã sửa: Đổi tên ViewModel để tránh trùng lặp
class WeeklyMealPlannerViewModel with ChangeNotifier {
  List<DailyPlan> _weeklyPlans = [];

  WeeklyMealPlannerViewModel() {
    _generateDummyData();
  }

  List<DailyPlan> get weeklyPlans => _weeklyPlans;

  void _generateDummyData() {
    final monday = DateTime(2024, 12, 9);

    _weeklyPlans = [
      DailyPlan(
        date: monday,
        meals: [
          // Đã sửa: Dữ liệu mẫu giờ đã gọn gàng hơn
          MealPlanModel(
            date: monday,
            mealType: MealType.breakfast,
            selectedMeal: const Meal(id: 'r1', name: 'Avocado Toast', imageUrl: 'https://picsum.photos/200', preparationTimeMinutes: 15, kcal: 350),
          ),
          MealPlanModel(
            date: monday,
            mealType: MealType.lunch, // Bữa trưa trống
          ),
          MealPlanModel(
            date: monday,
            mealType: MealType.dinner,
            selectedMeal: const Meal(id: 'r2', name: 'Grilled Salmon', imageUrl: 'https://picsum.photos/201', preparationTimeMinutes: 20, kcal: 550),
          ),
        ],
      ),
      // Bạn có thể thêm các ngày khác tại đây...
    ];
    notifyListeners();
  }

  void nextWeek() {
    // Logic để tải dữ liệu của tuần tiếp theo
    notifyListeners();
  }

  // Đã thêm: Hàm còn thiếu
  void previousWeek() {
    // Logic để tải dữ liệu của tuần trước đó
    notifyListeners();
  }
}
