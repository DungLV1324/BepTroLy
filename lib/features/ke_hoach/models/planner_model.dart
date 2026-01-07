import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/meal_plan_model.dart';

class PlannerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;


  Future<List<Meal>> getRecipesFromFirebase() async {
    try {
      var snapshot = await _db.collection('Recipes').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Meal(
          id: doc.id,
          name: data['name'] ?? 'No Name',
          imageUrl: data['imageUrl'] ?? '',
          preparationTimeMinutes: data['cooking_time'] ?? 0,
          kcal: data['kcal'] ?? 0,
        );
      }).toList();
    } catch (e) {
      print("Error fetching recipes: $e");
      return [];
    }
  }

  // 2. Lưu Plan vào collection riêng của User
  Future<bool> saveMealPlanToUser(MealPlanModel plan, List<Meal> selectedMeals) async {
    if (userId == null) return false;

    try {
      final planData = {
        'date': plan.date.toIso8601String(),
        'mealType': plan.mealType.name,
        'servings': plan.servings,
        'specificTime': '${plan.specificTime.hour}:${plan.specificTime.minute}',
        'notes': plan.notes,
        'repeatDays': plan.repeatDays,
        // Lưu danh sách ID các món đã chọn
        'mealIds': selectedMeals.map((m) => m.id).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _db
          .collection('users')
          .doc(userId)
          .collection('meal_plans') // Collection riêng bên trong User
          .add(planData);

      return true;
    } catch (e) {
      print("Error saving plan: $e");
      return false;
    }
  }
}