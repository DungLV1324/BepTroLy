import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_enums.dart';

class Meal {
  final String id;
  final String name;
  final String imageUrl;
  final int preparationTimeMinutes;
  final int kcal;

  const Meal({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.preparationTimeMinutes,
    this.kcal = 0,
  });

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['mealId'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      preparationTimeMinutes: map['preparationTimeMinutes'] ?? 0,
      kcal: map['kcal'] ?? 0,
    );
  }
}

class DailyPlan {
  final DateTime date;
  final List<MealPlanModel> mealPlans; // Danh sách các bữa trong ngày

  DailyPlan({required this.date, required this.mealPlans});

  // Tính tổng Calo của tất cả món ăn trong tất cả các bữa (Sáng, Trưa, Tối) của ngày
  int get totalKcal {
    return mealPlans.fold(0, (sum, plan) {
      final planKcal = plan.selectedMeals.fold(0, (s, m) => s + m.kcal);
      return sum + planKcal;
    });
  }
}

class MealPlanModel {
  final String id;
  final DateTime date;
  final MealType mealType;
  final List<Meal> selectedMeals; // Danh sách các món ăn trong một bữa
  final int servings;
  final TimeOfDay specificTime;
  final String notes;
  final Map<String, bool> repeatDays;

  MealPlanModel({
    String? id,
    required this.date,
    required this.mealType,
    this.selectedMeals = const [],
    this.servings = 2,
    this.specificTime = const TimeOfDay(hour: 12, minute: 0),
    this.notes = '',
    this.repeatDays = const {
      'T2': false, 'T3': false, 'T4': false, 'T5': false, 'T6': false, 'T7': false, 'CN': false
    },
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory MealPlanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final timeParts = (data['specificTime'] as String? ?? "12:0").split(':');
    final timeOfDay = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    // Lấy toàn bộ danh sách món ăn từ mảng 'meals' trong Firestore
    List<Meal> selectedMealsList = [];
    if (data['meals'] != null && data['meals'] is List) {
      selectedMealsList = (data['meals'] as List)
          .map((m) => Meal.fromMap(m as Map<String, dynamic>))
          .toList();
    }

    return MealPlanModel(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      mealType: _parseMealType(data['mealType']),
      selectedMeals: selectedMealsList,
      servings: data['servings'] ?? 2,
      specificTime: timeOfDay,
      notes: data['notes'] ?? '',
      repeatDays: Map<String, bool>.from(data['repeatDays'] ?? {}),
    );
  }

  static MealType _parseMealType(String? type) {
    switch (type?.toLowerCase()) {
      case 'breakfast': return MealType.breakfast;
      case 'lunch': return MealType.lunch;
      case 'dinner': return MealType.dinner;
      case 'snack': return MealType.snack;
      default: return MealType.lunch;
    }
  }

  MealPlanModel copyWith({
    String? id,
    DateTime? date,
    MealType? mealType,
    List<Meal>? selectedMeals,
    int? servings,
    TimeOfDay? specificTime,
    String? notes,
    Map<String, bool>? repeatDays,
  }) {
    return MealPlanModel(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      selectedMeals: selectedMeals ?? this.selectedMeals,
      servings: servings ?? this.servings,
      specificTime: specificTime ?? this.specificTime,
      notes: notes ?? this.notes,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }
}