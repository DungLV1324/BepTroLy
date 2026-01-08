import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_enums.dart';
import '../../../core/utils/api_constants.dart';
import '../models/ingredient_model.dart';

class SpoonacularService {
  int _currentKeyIndex = 0;

  String get _currentApiKey => ApiConstants.apiKeys[_currentKeyIndex];

  Future<http.Response> _performGetRequest(String endpoint, {Map<String, String>? params}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint').replace(
      queryParameters: {
        'apiKey': _currentApiKey,
        ...?params,
      },
    );

    print("Dang goi API voi Key thu ${_currentKeyIndex + 1}: ...${_currentApiKey.substring(0, 5)}");

    try {
      final response = await http.get(uri);

      if (response.statusCode == 402 || response.statusCode == 401) {
        print("⚠️ Key ${_currentApiKey.substring(0, 5)} da het han! Dang doi key...");
        _currentKeyIndex++;

        if (_currentKeyIndex >= ApiConstants.apiKeys.length) {
          _currentKeyIndex = 0;
          throw Exception("TẤT CẢ API KEY ĐỀU ĐÃ HẾT HẠN TRONG NGÀY!");
        }

        return await _performGetRequest(endpoint, params: params);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // 1. Tìm kiếm nguyên liệu
  Future<List<IngredientModel>> searchIngredients(String query) async {
    try {
      final response = await _performGetRequest(
        '/food/ingredients/autocomplete',
        params: {
          'query': query,
          'number': '5',
          'metaInformation': 'true',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => IngredientModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Lỗi search: $e");
      return [];
    }
  }

  // 2. Tìm sản phẩm qua Barcode
  Future<IngredientModel?> findProductByBarcode(String barcode) async {
    try {
      final response = await _performGetRequest(
        '/food/products/upc/$barcode',
        params: {},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return IngredientModel(
          id: data['id'].toString(),
          name: data['title'],
          quantity: 1,
          unit: MeasureUnit.values.first,
          imageUrl: data['image'] ?? "",
        );
      }
      return null;
    } catch (e) {
      print("Lỗi barcode: $e");
      return null;
    }
  }
}