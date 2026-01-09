import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/meal_plan_model.dart';

class PlannerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<bool> saveMealPlanToUser(MealPlanModel plan) async {
    if (userId == null) return false;

    try {
      final planData = {
        'date': Timestamp.fromDate(plan.date),
        'mealType': plan.mealType.name,
        'servings': plan.servings,
        'specificTime': '${plan.specificTime.hour}:${plan.specificTime.minute}',
        'notes': plan.notes,
        'repeatDays': plan.repeatDays,
        'meals': plan.selectedMeals.map((m) => {
          'mealId': m.id,
          'name': m.name,
          'imageUrl': m.imageUrl,
          'preparationTimeMinutes': m.preparationTimeMinutes,
          'kcal': m.kcal,
        }).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _db
          .collection('users')
          .doc(userId)
          .collection('meal_plans')
          .add(planData);
      return true;
    } catch (e) {
      return false;
    }
  }
}