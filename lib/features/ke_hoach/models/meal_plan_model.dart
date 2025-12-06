import '../../../../core/constants/app_enums.dart';

class MealPlanModel {
  final String id;
  final DateTime date;
  final MealType mealType;
  final String recipeId;
  final String recipeName;
  final String recipeImageUrl;
  final bool isCooked;

  MealPlanModel({
    required this.id,
    required this.date,
    required this.mealType,
    required this.recipeId,
    required this.recipeName,
    required this.recipeImageUrl,
    this.isCooked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mealType': mealType.toString().split('.').last,
      'recipeId': recipeId,
      'recipeName': recipeName,
      'recipeImageUrl': recipeImageUrl,
      'isCooked': isCooked,
    };
  }

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date']),

      mealType: MealType.values.firstWhere(
            (e) => e.toString().split('.').last == json['mealType'],
        orElse: () => MealType.dinner,
      ),

      recipeId: json['recipeId'] as String,
      recipeName: json['recipeName'] as String? ?? 'Món ăn',
      recipeImageUrl: json['recipeImageUrl'] as String? ?? '',
      isCooked: json['isCooked'] as bool? ?? false,
    );
  }

  MealPlanModel copyWith({
    String? id,
    DateTime? date,
    MealType? mealType,
    String? recipeId,
    String? recipeName,
    String? recipeImageUrl,
    bool? isCooked,
  }) {
    return MealPlanModel(
      id: id ?? this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      recipeImageUrl: recipeImageUrl ?? this.recipeImageUrl,
      isCooked: isCooked ?? this.isCooked,
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}