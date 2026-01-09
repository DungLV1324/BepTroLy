import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/meal_plan_model.dart';

class WeeklyMealPlannerViewModel with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<DailyPlan> _weeklyPlans = [];
  bool _isLoading = true;
  List<DailyPlan> get weeklyPlans => _weeklyPlans;
  bool get isLoading => _isLoading;

  WeeklyMealPlannerViewModel() {
    listenToMealPlans();
  }

  void listenToMealPlans() async {
    final user = _auth.currentUser;
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    // 1. Tải dữ liệu Recipes làm tham chiếu kcal
    Map<String, dynamic> recipeMap = {};
    try {
      final recipeSnapshot = await _db.collection('Recipes').get();
      for (var doc in recipeSnapshot.docs) {
        recipeMap[doc.id.trim()] = doc.data();
      }
    } catch (e) {
      debugPrint("Lỗi tải Recipes: $e");
    }

    _db.collection('users')
        .doc(user.uid)
        .collection('meal_plans')
        .orderBy('date', descending: false)
        .snapshots()
        .listen((snapshot) {

      final allPlans = snapshot.docs.map((doc) {
        final plan = MealPlanModel.fromFirestore(doc);

        final updatedMeals = plan.selectedMeals.map((meal) {
          final recipeData = recipeMap[meal.id];
          if (recipeData != null) {
            return Meal(
              id: meal.id,
              name: recipeData['title'] ?? meal.name,
              imageUrl: meal.imageUrl,
              // Lấy cooking_time và kcal từ collection Recipes
              preparationTimeMinutes: recipeData['cooking_time'] is int
                  ? recipeData['cooking_time']
                  : int.tryParse(recipeData['cooking_time'].toString()) ?? 0,
              kcal: recipeData['kcal'] is int
                  ? recipeData['kcal']
                  : int.tryParse(recipeData['kcal'].toString()) ?? 0,
            );
          }
          return meal;
        }).toList();

        return plan.copyWith(selectedMeals: updatedMeals);
      }).toList();

      _weeklyPlans = _groupPlansByDate(allPlans);
      _isLoading = false;
      notifyListeners();
    });
  }

  List<DailyPlan> _groupPlansByDate(List<MealPlanModel> plans) {
    Map<String, List<MealPlanModel>> grouped = {};
    for (var plan in plans) {
      String dateKey = "${plan.date.day}/${plan.date.month}/${plan.date.year}";
      if (grouped[dateKey] == null) grouped[dateKey] = [];
      grouped[dateKey]!.add(plan);
    }
    final List<DailyPlan> dailyPlans = grouped.entries.map((e) => DailyPlan(date: e.value.first.date, mealPlans: e.value)).toList();
    dailyPlans.sort((a, b) => a.date.compareTo(b.date));
    return dailyPlans;
  }

  Future<void> deleteMealPlan(String planId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).collection('meal_plans').doc(planId).delete();
  }
}