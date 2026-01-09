import 'dart:async';
import 'package:flutter/material.dart';
import '../../goi_y_mon_an/models/recipe_model.dart';
import '../../goi_y_mon_an/services/recipe_services.dart';
import '../../kho_nguyen_lieu/models/ingredient_model.dart';
import '../services/home_service.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeService _homeService = HomeService();
  final RecipeServices _recipeService = RecipeServices();

  List<RecipeModel> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingSearch = false;
  Timer? _debounce;

  // Getters
  List<RecipeModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  bool get isLoadingSearch => _isLoadingSearch;
  // State
  bool _isLoading = false;
  List<IngredientModel> _expiringIngredients = [];
  String _userName = 'My friend';
  String? _photoUrl;

  // Quản lý Stream
  StreamSubscription? _pantrySubscription;

  // Getters
  bool get isLoading => _isLoading;
  List<IngredientModel> get expiringIngredients => _expiringIngredients;
  String get userName => _userName;
  String? get photoUrl => _photoUrl;

  void loadHomeData() {
    _isLoading = true;
    notifyListeners();

    _loadUserInfo();

    _listenToExpiringItems();
  }

  void _listenToExpiringItems() {
    _pantrySubscription?.cancel();

    // Gọi Stream đã được xử lý từ Service
    _pantrySubscription = _homeService.getExpiringIngredientsStream().listen(
          (processedList) {
        _expiringIngredients = processedList;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print("Lỗi ViewModel: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> _loadUserInfo() async {
    final userProfile = await _homeService.getUserProfile();

    _userName = userProfile['name'] ?? 'My friend';
    _photoUrl = userProfile['photoUrl'];
    notifyListeners();
  }

  @override
  void dispose() {
    _pantrySubscription?.cancel();
    super.dispose();
  }

  void onSearchQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    // Debounce 600ms
    _debounce = Timer(const Duration(milliseconds: 600), () {
      performSearch(query);
    });
  }

  Future<void> performSearch(String query) async {
    _isSearching = true;
    _isLoadingSearch = true;
    notifyListeners();

    try {
      final results = await _recipeService.searchRecipes(query: query);
      _searchResults = results;
    } catch (e) {
      print("ViewModel Search Error: $e");
      _searchResults = [];
    } finally {
      _isLoadingSearch = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _isSearching = false;
    _searchResults = [];
    _isLoadingSearch = false;
    notifyListeners();
  }
}