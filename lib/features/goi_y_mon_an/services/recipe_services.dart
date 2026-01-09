import 'dart:convert';
import '../../../core/utils/spoonacular_client.dart';
import '../models/recipe_model.dart';

class RecipeServices {
  final SpoonacularClient _client = SpoonacularClient();

  // 1. Tìm kiếm món ăn theo nguyên liệu
  Future<List<RecipeModel>> findRecipesByIngredients(
      List<String> ingredients,
      ) async {
    if (ingredients.isEmpty) return [];

    try {
      final response = await _client.get(
        '/recipes/findByIngredients',
        params: {
          'ingredients': ingredients.join(',').toLowerCase(),
          'number': '10',
          'ranking': '2',
          'ignorePantry': 'true',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ API Search trả về ${data.length} món ăn');
        return data.map((json) => RecipeModel.fromSpoonacularSearch(json)).toList();
      } else {
        throw Exception('Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi kết nối Search: $e');
      rethrow;
    }
  }

  // 2. Lấy chi tiết món ăn
  Future<RecipeModel> getRecipeDetails(String id) async {
    try {
      final response = await _client.get(
        '/recipes/$id/information',
        params: {
          'includeNutrition': 'false',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('✅ Đã lấy được chi tiết món: ${data['title']}');
        return RecipeModel.fromSpoonacularDetail(data);
      } else {
        throw Exception('Lỗi lấy chi tiết: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi kết nối Detail: $e');
      rethrow;
    }
  }

  // 3. Tìm kiếm nâng cao (Complex Search)
  Future<List<RecipeModel>> searchRecipes({
    String? query,
    String? type,
    String? diet,
    int? maxReadyTime,
    String? sort,
    List<String>? includeIngredients,
  }) async {
    // Tạo Map chứa các tham số cơ bản
    final Map<String, String> queryParams = {
      'number': '10',
      'addRecipeInformation': 'true',
      'fillIngredients': 'true',
    };

    // Thêm các tham số tùy chọn nếu có
    if (query != null && query.isNotEmpty) queryParams['query'] = query;
    if (type != null && type.isNotEmpty) queryParams['type'] = type;

    // Xử lý diet
    if (diet != null && diet.isNotEmpty && diet != 'None') {
      queryParams['diet'] = diet.toLowerCase();
    }

    if (maxReadyTime != null) {
      queryParams['maxReadyTime'] = maxReadyTime.toString();
    }

    if (sort != null && sort.isNotEmpty) {
      queryParams['sort'] = sort;
    }

    if (includeIngredients != null && includeIngredients.isNotEmpty) {
      queryParams['includeIngredients'] = includeIngredients.join(',');
      queryParams['sort'] = 'min-missing-ingredients'; // Ưu tiên món đủ nguyên liệu
    }

    try {
      print('🌐 Đang gọi API Complex Search...');

      final response = await _client.get(
        '/recipes/complexSearch',
        params: queryParams,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        print('✅ Complex Search tìm thấy ${results.length} món');

        return results.map((e) => RecipeModel.fromSpoonacularDetail(e)).toList();
      } else {
        throw Exception('Lỗi API Complex Search: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi kết nối Complex Search: $e');
      rethrow;
    }
  }
}