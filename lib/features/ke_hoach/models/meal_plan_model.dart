import 'package:flutter/material.dart';
import '../../../core/constants/app_enums.dart';

// Đã sửa: Thêm thuộc tính kcal
class Meal {
  final String id;
  final String name;
  final String imageUrl;
  final int preparationTimeMinutes;
  final int kcal; // Calo của món ăn

  const Meal({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.preparationTimeMinutes,
    this.kcal = 0, // Giá trị mặc định
  });
}

// Đã thêm: Lớp đại diện cho kế hoạch của một ngày
class DailyPlan {
  final DateTime date;
  final List<MealPlanModel> meals;

  DailyPlan({required this.date, required this.meals});

  // Hàm tính tổng calo trong ngày
  int get totalKcal {
    return meals.fold(0, (sum, plan) => sum + (plan.selectedMeal?.kcal ?? 0));
  }
}

class MealPlanModel {
  final String id;
  final DateTime date;
  final MealType mealType;
  final Meal? selectedMeal;
  final int servings;
  final TimeOfDay specificTime;
  final String notes;
  final Map<String, bool> repeatDays;

  MealPlanModel({
    String? id,
    required this.date,
    required this.mealType,
    this.selectedMeal,
    this.servings = 2,
    this.specificTime = const TimeOfDay(hour: 12, minute: 0),
    this.notes = '',
    this.repeatDays = const {'T2': false, 'T3': false, 'T4': false, 'T5': false, 'T6': false, 'T7': false, 'CN': false},
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  MealPlanModel copyWith({
    String? id,
    DateTime? date,
    MealType? mealType,
    Meal? selectedMeal,
    int? servings,
    TimeOfDay? specificTime,
    String? notes,
    Map<String, bool>? repeatDays,
  }) {
    return MealPlanModel(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      selectedMeal: selectedMeal ?? this.selectedMeal,
      servings: servings ?? this.servings,
      specificTime: specificTime ?? this.specificTime,
      notes: notes ?? this.notes,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }
}
