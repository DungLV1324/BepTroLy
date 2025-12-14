import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/recipe_model.dart';

class RecipeServices {
  final String _apiKey = dotenv.env['SPOONACULAR_API_KEY'] ?? '';
  final String _baseUrl =
      dotenv.env['BASE_URL'] ?? 'https://api.spoonacular.com';

  // 1. Tìm kiếm món ăn theo nguyên liệu (Dùng cho nút "Have Ingredients")
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
      print('🌐 Đang gọi API Search By Ingredients: $uri');

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

  // 2. Lấy chi tiết món ăn (Dùng cho màn hình Chi tiết - Tab Steps/Ingredients)
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

  // 3. Tìm kiếm nâng cao (Complex Search) - Dùng cho Lọc (Filter), Search Bar, Trending...
  Future<List<RecipeModel>> searchRecipes({
    String? query,
    String? type, // main course, side dish, dessert...
    String? diet, // vegetarian, vegan, gluten free...
    int? maxReadyTime, // phút
    String? sort, // popularity, healthiness, time...
    List<String>? includeIngredients, // Danh sách nguyên liệu có sẵn
  }) async {
    if (_apiKey.isEmpty) throw Exception('API Key is missing');

    // Xây dựng URL với các tham số
    // addRecipeInformation=true để lấy luôn thông tin chi tiết (ảnh, thời gian...)
    String url =
        '$_baseUrl/recipes/complexSearch?apiKey=$_apiKey&number=10&addRecipeInformation=true';

    if (query != null && query.isNotEmpty) url += '&query=$query';
    if (type != null && type.isNotEmpty) url += '&type=$type';
    if (diet != null && diet.isNotEmpty) url += '&diet=$diet';
    if (maxReadyTime != null) url += '&maxReadyTime=$maxReadyTime';
    if (sort != null && sort.isNotEmpty) url += '&sort=$sort';

    // Nếu có nguyên liệu, ưu tiên tìm món chứa nguyên liệu đó
    if (includeIngredients != null && includeIngredients.isNotEmpty) {
      url += '&includeIngredients=${includeIngredients.join(',')}';
      url +=
          '&sort=min-missing-ingredients'; // Sắp xếp theo số nguyên liệu thiếu ít nhất
    }

    try {
      print('🌐 Gọi API Complex Search: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        print('✅ Complex Search tìm thấy ${results.length} kết quả');

        // Map dữ liệu trả về sang RecipeModel
        // Lưu ý: complexSearch trả về cấu trúc hơi khác findByIngredients,
        // nhưng nhờ addRecipeInformation=true nên dùng fromSpoonacularDetail là ổn nhất.
        return results
            .map((e) => RecipeModel.fromSpoonacularDetail(e))
            .toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi Search: $e');
      rethrow;
    }
  }
}
