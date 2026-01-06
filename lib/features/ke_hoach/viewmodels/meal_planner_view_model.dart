import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_enums.dart';
import '../models/meal_plan_model.dart';

class MealPlannerViewModel with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Meal> _availableMeals = [];
  List<Meal> get availableMeals => _availableMeals;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MealPlanModel _plan;
  final List<Meal> _selectedMeals = [];
  int _originalServings = 2;

  MealPlannerViewModel({MealPlanModel? initialPlan})
      : _plan = initialPlan ??
      MealPlanModel(
        date: DateTime.now(),
        mealType: MealType.lunch,
      ) {
    fetchRecipesFromFirebase();
  }

  MealPlanModel get plan => _plan;
  List<Meal> get selectedMeals => _selectedMeals;
  int get originalServings => _originalServings;

  // LẤY DỮ LIỆU TỪ FIREBASE - KHỚP VỚI ẢNH CỦA BẠN
  Future<void> fetchRecipesFromFirebase() async {
    _isLoading = true;
    _errorMessage = null; // Clear previous errors
    notifyListeners();

    try {
      // KIỂM TRA: Tên collection trong ảnh của bạn là 'Recipes' (chữ R viết hoa)
      final snapshot = await _db.collection('Recipes').get();

      if (snapshot.docs.isEmpty) {
        _errorMessage = 'CẢNH BÁO: Collection "Recipes" đang trống trên Firebase';
        debugPrint(_errorMessage);
      }

      _availableMeals = snapshot.docs.map((doc) {
        final data = doc.data();
        return Meal(
          id: doc.id,
          name: data['title'] ?? 'Món ăn không tên',
          imageUrl: data['imageUrl'] ?? 'assets/images/chicken_butter.jpg',
          preparationTimeMinutes: data['cooking_time'] ?? 0,
          kcal: data['kcal'] ?? 0,
        );
      }).toList();

      debugPrint('Thành công: Đã tải được ${availableMeals.length} món');
    } catch (e) {
      _errorMessage = 'Lỗi khi tải công thức: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CÁC HÀM LƯU VÀ CẬP NHẬT (Giữ nguyên logic đã chạy tốt)
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

  Future<bool> saveMealPlan() async {
    final User? user = _auth.currentUser;
    if (user == null || _selectedMeals.isEmpty) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final planData = {
        'date': Timestamp.fromDate(_plan.date),
        'mealType': _plan.mealType.toString().split('.').last,
        'specificTime': '${_plan.specificTime.hour}:${_plan.specificTime.minute}',
        'servings': _plan.servings,
        'notes': _plan.notes,
        'repeatDays': _plan.repeatDays,
        'meals': _selectedMeals.map((m) => {
          'mealId': m.id,
          'name': m.name,
          'imageUrl': m.imageUrl,
        }).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _db.collection('users').doc(user.uid).collection('meal_plans').add(planData);
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi khi lưu kế hoạch: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectDate(DateTime newDate) { _plan = _plan.copyWith(date: newDate); notifyListeners(); }
  void setMealTime(MealType newType) { _plan = _plan.copyWith(mealType: newType); notifyListeners(); }
  void setSpecificTime(TimeOfDay newTime) { _plan = _plan.copyWith(specificTime: newTime); notifyListeners(); }
  void changeServings(int delta) {
    final newServings = _plan.servings + delta;
    if (newServings > 0) {
      _plan = _plan.copyWith(servings: newServings);
      notifyListeners();
    }
  }
  void updateNotes(String newNotes) { _plan = _plan.copyWith(notes: newNotes); notifyListeners(); }
  void toggleRepeatDay(String day) {
    final newRepeatDays = Map<String, bool>.from(_plan.repeatDays);
    newRepeatDays[day] = !newRepeatDays[day]!;
    _plan = _plan.copyWith(repeatDays: newRepeatDays);
    notifyListeners();
  }
}
