import 'package:flutter/material.dart';
import '../../../core/constants/app_enums.dart';
import '../models/meal_plan_model.dart';

class MealPlannerViewModel with ChangeNotifier {
  final List<Meal> availableMeals = const [
    Meal(
      id: 'r1',
      name: 'Salad ức gà và bơ',
      imageUrl: 'assets/images/chicken_butter.jpg',
      preparationTimeMinutes: 25,
    ),
    Meal(
      id: 'r2',
      name: 'Cá hồi áp chảo sốt chanh leo',
      imageUrl: 'assets/images/alfredo.jpg',
      preparationTimeMinutes: 40,
    ),
    Meal(
      id: 'r3',
      name: 'Súp bí đỏ kem tươi',
      imageUrl: 'assets/images/bruschetta.jpg',
      preparationTimeMinutes: 30,
    ),
  ];

  MealPlanModel _plan;
  final int _originalServings = 3;

  MealPlannerViewModel({MealPlanModel? initialPlan})
      : _plan = initialPlan ??
            MealPlanModel(
              date: DateTime.now(),
              mealType: MealType.lunch,
            );

  MealPlanModel get plan => _plan;
  int get originalServings => _originalServings;

  void selectMeal(Meal meal) {
    _plan = _plan.copyWith(
      selectedMeal: meal,
    );
    notifyListeners();
  }

  void removeMeal() {
    _plan = _plan.copyWith(
      selectedMeal: null,
    );
    notifyListeners();
  }

  void selectDate(DateTime newDate) {
    _plan = _plan.copyWith(date: newDate);
    notifyListeners();
  }

  void setMealTime(MealType newType) {
    TimeOfDay specificTime;
    if (newType == MealType.breakfast) {
      specificTime = const TimeOfDay(hour: 7, minute: 0);
    } else if (newType == MealType.lunch) {
      specificTime = const TimeOfDay(hour: 12, minute: 0);
    } else if (newType == MealType.dinner) {
      specificTime = const TimeOfDay(hour: 19, minute: 0);
    } else {
      specificTime = const TimeOfDay(hour: 16, minute: 0); // snack
    }
    _plan = _plan.copyWith(mealType: newType, specificTime: specificTime);
    notifyListeners();
  }

  void setSpecificTime(TimeOfDay newTime) {
    _plan = _plan.copyWith(specificTime: newTime);
    notifyListeners();
  }

  void changeServings(int delta) {
    final newServings = _plan.servings + delta;
    if (newServings > 0) {
      _plan = _plan.copyWith(servings: newServings);
      notifyListeners();
    }
  }

  void updateNotes(String newNotes) {
    _plan = _plan.copyWith(notes: newNotes);
    notifyListeners();
  }

  void toggleRepeatDay(String day) {
    final updatedRepeatDays = Map<String, bool>.from(_plan.repeatDays);
    updatedRepeatDays[day] = !(updatedRepeatDays[day] ?? false);
    _plan = _plan.copyWith(repeatDays: updatedRepeatDays);
    notifyListeners();
  }

  // Đã sửa: Chuyển sang Future<bool> để báo hiệu thành công
  Future<bool> saveMealPlan() async {
    if (_plan.selectedMeal == null) {
      print('Lỗi: Cần chọn món ăn trước khi lưu.');
      return false; // Lưu thất bại
    }

    print('--- KẾ HOẠCH ĐÃ LƯU ---');
    print('ID: ${_plan.id}');
    print('Món: ${_plan.selectedMeal?.name ?? 'Không có món'}');
    print('Ngày: ${_formatDate(_plan.date)}');
    print('Buổi: ${_plan.mealType.toString().split('.').last}');
    print('Giờ: ${_plan.specificTime.hour.toString().padLeft(2, '0')}:${_plan.specificTime.minute.toString().padLeft(2, '0')}');
    print('Khẩu phần: ${_plan.servings}');
    print('Ghi chú: ${_plan.notes}');
    print('Lặp lại: ${_plan.repeatDays.entries.where((e) => e.value).map((e) => e.key).join(', ')}');
    print('-----------------------');

    // Ở đây bạn có thể gọi API/Service để lưu trữ.
    // Sau khi lưu thành công, trả về true.
    await Future.delayed(const Duration(milliseconds: 500)); // Giả lập độ trễ mạng
    return true; // Giả định lưu thành công
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }
}