import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'https://api.spoonacular.com';

  static List<String> get apiKeys {
    String rawString = dotenv.env['SPOONACULAR_API_KEY'] ?? "";

    if (rawString.isEmpty) {
      print("⚠️ CẢNH BÁO: Chưa cấu hình SPOONACULAR_API_KEY trong .env");
      return [];
    }

    return rawString.split(',').map((e) => e.trim()).toList();
  }
}