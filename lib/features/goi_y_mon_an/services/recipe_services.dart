import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/recipe_model.dart';

class RecipeServices {
  final String _apiKey = dotenv.env['SPOONACULAR_API_KEY'] ?? '';
  final String _baseUrl =
      dotenv.env['BASE_URL'] ?? 'https://api.spoonacular.com';

  // 1. Hàm cũ: Tìm kiếm món ăn theo nguyên liệu (Giữ nguyên)
  Future<List<RecipeModel>> findRecipesByIngredients(
    List<String> ingredients,
  ) async {
    if (_apiKey.isEmpty)
      throw Exception('Chưa cấu hình API Key trong file .env');
    if (ingredients.isEmpty) return [];

    final String ingredientsString = ingredients.join(',').toLowerCase();

    final Uri uri = Uri.parse(
      '$_baseUrl/recipes/findByIngredients?ingredients=$ingredientsString&number=10&ranking=2&ignorePantry=true&apiKey=$_apiKey',
    );

    try {
      print('🌐 Đang gọi API Search: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ API Search trả về ${data.length} món ăn');

        return data
            .map((json) => RecipeModel.fromSpoonacularSearch(json))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception(
          'Lỗi API Key không hợp lệ (401). Kiểm tra lại file .env',
        );
      } else if (response.statusCode == 402) {
        throw Exception(
          'Hết lượt gọi API trong ngày (402). Cần nâng cấp gói hoặc đổi Key.',
        );
      } else {
        throw Exception('Lỗi Server: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi kết nối Search: $e');
      rethrow;
    }
  }

  // --- 2. HÀM MỚI THÊM VÀO: Lấy chi tiết món ăn (Thời gian, Khẩu phần, Cách làm) ---
  Future<RecipeModel> getRecipeDetails(String id) async {
    if (_apiKey.isEmpty) throw Exception('Chưa cấu hình API Key');

    // API lấy thông tin chi tiết: /recipes/{id}/information
    final Uri uri = Uri.parse(
      '$_baseUrl/recipes/$id/information?includeNutrition=false&apiKey=$_apiKey',
    );

    try {
      print('🌐 Đang gọi API Detail cho ID: $id');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('✅ Đã lấy được chi tiết món: ${data['title']}');

        // Sử dụng hàm fromSpoonacularDetail trong Model để parse dữ liệu đầy đủ
        return RecipeModel.fromSpoonacularDetail(data);
      } else if (response.statusCode == 402) {
        throw Exception('Hết lượt gọi API (402).');
      } else {
        throw Exception('Lỗi lấy chi tiết: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi kết nối Detail: $e');
      rethrow;
    }
  }
}
