import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_plan_model.dart';

class SpoonacularService {
  final String apiKey = '7ef4a6ea3ac9465aa77a4ab7336bb002';

  Future<List<Meal>> searchRecipes(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/complexSearch?query=$query&addRecipeNutrition=true&number=10&apiKey=$apiKey'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List results = data['results'];
        return results.map((json) => Meal.fromSpoonacular(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}