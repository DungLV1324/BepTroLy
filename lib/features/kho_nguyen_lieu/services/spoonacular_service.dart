import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ingredient_model.dart';

class SpoonacularService {
  final String _apiKey = "506a39440242421f930ca2fd8fcbf5d0";
  final String _baseUrl = "https://api.spoonacular.com/food/ingredients";

  // Hàm tìm kiếm gợi ý (Autocomplete)
  Future<List<IngredientModel>> searchIngredients(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse('$_baseUrl/autocomplete?apiKey=$_apiKey&query=$query&number=5&metaInformation=true');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Convert JSON từ Spoonacular sang Model của bạn
        return data.map((json) => IngredientModel.fromSpoonacularJson(json)).toList();
      } else {
        print("Lỗi API: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      return [];
    }
  }
}