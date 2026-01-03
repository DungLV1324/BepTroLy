// lib/ke_hoach/models/meal_plan_model.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
// Đã sửa: Điều chỉnh đường dẫn Import cho phù hợp với cấu trúc
import '../../../core/constants/app_enums.dart';

class Meal {
  final String id;
  final String name;
  final String imageUrl;
  final int preparationTimeMinutes;

  const Meal({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.preparationTimeMinutes,
  });
}

class MealPlanModel {
  final String id;
  final DateTime date;
  final MealType mealType;
  final String recipeId;
  final String recipeName;
  final String recipeImageUrl;
  final bool isCooked;

  final Meal? selectedMeal;
  final int servings;
  final TimeOfDay specificTime;
  final String notes;
  final Map<String, bool> repeatDays;

  MealPlanModel({
    String? id,
    required this.date,
    required this.mealType,
    required this.recipeId,
    required this.recipeName,
    required this.recipeImageUrl,
    this.isCooked = false,
    this.selectedMeal,
    this.servings = 2,
    this.specificTime = const TimeOfDay(hour: 12, minute: 0),
    this.notes = '',
    // T2, T3, T4, T5, T6, T7, CN
    this.repeatDays = const {'T2': false, 'T3': false, 'T4': false, 'T5': false, 'T6': false, 'T7': false, 'CN': false},
  }) : id = id ?? const Uuid().v4();

  MealPlanModel copyWith({
    String? id,
    DateTime? date,
    MealType? mealType,
    String? recipeId,
    String? recipeName,
    String? recipeImageUrl,
    bool? isCooked,
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
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      recipeImageUrl: recipeImageUrl ?? this.recipeImageUrl,
      isCooked: isCooked ?? this.isCooked,
      selectedMeal: selectedMeal ?? this.selectedMeal,
      servings: servings ?? this.servings,
      specificTime: specificTime ?? this.specificTime,
      notes: notes ?? this.notes,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }
}