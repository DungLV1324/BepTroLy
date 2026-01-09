import 'package:http/http.dart' as http;
import 'api_constants.dart';

class SpoonacularClient {
  static final SpoonacularClient _instance = SpoonacularClient._internal();
  factory SpoonacularClient() => _instance;
  SpoonacularClient._internal();

  // Biến theo dõi key (Static để giữ giá trị xuyên suốt app)
  static int _currentKeyIndex = 0;

  // Getter lấy key hiện tại
  String get _currentApiKey {
    final keys = ApiConstants.apiKeys;
    if (keys.isEmpty) return '';
    if (_currentKeyIndex >= keys.length) _currentKeyIndex = 0;
    return keys[_currentKeyIndex];
  }

  Future<http.Response> get(String endpoint, {Map<String, String>? params}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint').replace(
      queryParameters: {
        'apiKey': _currentApiKey,
        ...?params,
      },
    );

    print("🌐 API Call [Key $_currentKeyIndex]: ...${_currentApiKey.substring(0, 5)}");

    try {
      final response = await http.get(uri);

      // Xử lý đổi key tự động
      if (response.statusCode == 402 || response.statusCode == 401) {
        print("⚠️ Key ${_currentApiKey.substring(0, 5)} hết hạn. Đang đổi key...");

        _currentKeyIndex++; // Tăng index

        if (_currentKeyIndex >= ApiConstants.apiKeys.length) {
          _currentKeyIndex = 0;
          throw Exception("❌ TẤT CẢ KEY ĐỀU ĐÃ HẾT HẠN!");
        }

        return await get(endpoint, params: params);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }
}