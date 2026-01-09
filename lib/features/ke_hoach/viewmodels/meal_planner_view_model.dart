import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_enums.dart';
import '../models/meal_plan_model.dart';
import '../services/spoonacular_service.dart';

class MealPlannerViewModel with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SpoonacularService _spoonApi = SpoonacularService();

  List<Meal> _availableMeals = [];
  List<Meal> _searchResultMeals = [];
  List<Meal> get availableMeals => _searchResultMeals.isNotEmpty ? _searchResultMeals : _availableMeals;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MealPlanModel _plan;
  MealPlanModel get plan => _plan;
  final List<Meal> _selectedMeals = [];
  List<Meal> get selectedMeals => _selectedMeals;

  MealPlannerViewModel({MealPlanModel? initialPlan})
      : _plan = initialPlan ?? MealPlanModel(
      date: DateTime.now(),
      mealType: MealType.lunch
  ) {
    fetchRecipesFromFirebase();
  }

  //Tìm kiếm món ăn
  Future<void> searchMeals(String query) async {
    if (query.isEmpty) {
      _searchResultMeals = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResultMeals = await _spoonApi.searchRecipes(query);
    } catch (e) {
      _errorMessage = 'Lỗi tìm kiếm online: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //Lấy dữ liệu local từ firebase
  Future<void> fetchRecipesFromFirebase() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection('Recipes').get();
      _availableMeals = snapshot.docs.map((doc) {
        final data = doc.data();
        return Meal(
          id: doc.id,
          name: data['title'] ?? data['name'] ?? 'Món ăn không tên',
          imageUrl: (data['imageUrl'] ?? '').replaceAll(r'\', '/'),
          preparationTimeMinutes: data['cooking_time'] ?? 0,
          kcal: data['kcal'] ?? 0,
        );
      }).toList();
    } catch (e) {
      _errorMessage = 'Lỗi tải Recipes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveMealPlan() async {
    final User? user = _auth.currentUser;
    if (user == null || _selectedMeals.isEmpty) {
      _errorMessage = "Vui lòng chọn ít nhất một món ăn";
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final planData = {
        'date': Timestamp.fromDate(_plan.date),
        'mealType': _plan.mealType.name,
        'specificTime': '${_plan.specificTime.hour}:${_plan.specificTime.minute}',
        'servings': _plan.servings,
        'notes': _plan.notes,
        'repeatDays': _plan.repeatDays,
        'meals': _selectedMeals.map((m) => {
          'mealId': m.id,
          'name': m.name,
          'imageUrl': m.imageUrl,
          'kcal': m.kcal,
          'preparationTimeMinutes': m.preparationTimeMinutes,
        }).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _db.collection('users')
          .doc(user.uid)
          .collection('meal_plans')
          .add(planData);

      return true;
    } catch (e) {
      _errorMessage = 'Lỗi khi lưu kế hoạch: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectMeal(Meal meal) {
    if (!_selectedMeals.any((item) => item.id == meal.id)) {
      _selectedMeals.add(meal);
      notifyListeners();
    }
  }

  void removeMeal(Meal meal) {
    _selectedMeals.removeWhere((item) => item.id == meal.id);
    notifyListeners();
  }

  void selectDate(DateTime newDate) {
    _plan = _plan.copyWith(date: newDate);
    notifyListeners();
  }

  void setMealTime(MealType newType) {
    _plan = _plan.copyWith(mealType: newType);
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
    final newRepeatDays = Map<String, bool>.from(_plan.repeatDays);
    newRepeatDays[day] = !newRepeatDays[day]!;
    _plan = _plan.copyWith(repeatDays: newRepeatDays);
    notifyListeners();
  }
}