import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_enums.dart';
import '../models/ingredient_model.dart';

class SpoonacularService {
  final String _apiKey = "506a39440242421f930ca2fd8fcbf5d0";
  final String _baseUrl = "https://api.spoonacular.com/food/ingredients";
  final String _baseUrlProducts = 'https://api.spoonacular.com/food/products/upc';

  Future<List<IngredientModel>> searchIngredients(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse('$_baseUrl/autocomplete?apiKey=$_apiKey&query=$query&number=5&metaInformation=true');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => IngredientModel.fromSpoonacularJson(json)).toList();
      } else {
        print("Lỗi API Search: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Lỗi kết nối Search: $e");
      return [];
    }
  }

  Future<IngredientModel?> findProductByBarcode(String barcode) async {
    IngredientModel? product = await _fetchFromOpenFoodFacts(barcode);
    if (product != null) return product;
    return await _fetchFromSpoonacular(barcode);
  }

  Future<IngredientModel?> getProductByUpc(String upc) async {
    return _fetchFromSpoonacular(upc);
  }

  Future<IngredientModel?> _fetchFromOpenFoodFacts(String barcode) async {
    final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // check status: 1 là tìm thấy
        if (data['status'] == 1) {
          final p = data['product'];

          return IngredientModel(
            id: '',
            name: p['product_name_vi'] ?? p['product_name_en'] ?? p['product_name'] ?? 'Unknown Product',
            imageUrl: p['image_front_url'] ?? p['image_url'],
            aisle: 'Pantry',
            quantity: 1,
            unit: MeasureUnit.g,
            expiryDate: DateTime.now().add(const Duration(days: 180)),
            addedDate: DateTime.now(),
          );
        }
      }
    } catch (e) {
      print("Lỗi OpenFoodFacts: $e");
    }
    return null;
  }

  Future<IngredientModel?> _fetchFromSpoonacular(String barcode) async {
    final url = Uri.parse('$_baseUrlProducts/$barcode?apiKey=$_apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return IngredientModel(
          id: '',
          name: data['title'] ?? 'Unknown Product',
          imageUrl: data['image'],
          aisle: data['aisle'] ?? 'Pantry',
          quantity: 1,
          unit: MeasureUnit.g,
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          addedDate: DateTime.now(),
        );
      }
    } catch (e) {
      print("Lỗi Spoonacular: $e");
    }
    return null;
  }
}