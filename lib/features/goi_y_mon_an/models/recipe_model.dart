import '../../kho_nguyen_lieu/models/ingredient_model.dart';

class RecipeModel {
  final String id;
  final String name;
  final String description;
  final int cookingTimeMinutes;
  final List<String> instructions;
  final List<IngredientModel> ingredients;
  final String imageUrl;

  // --- CÁC TRƯỜNG HỖ TRỢ LOGIC GỢI Ý ---
  final int missedIngredientCount; // Số lượng món thiếu
  final int usedIngredientCount; // Số lượng món đã có
  final List<String>
  missedIngredients; // [MỚI] Tên các món thiếu (VD: ["hành tây", "tỏi"])

  RecipeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.cookingTimeMinutes,
    required this.instructions,
    required this.ingredients,
    required this.imageUrl,
    this.missedIngredientCount = 0,
    this.usedIngredientCount = 0,
    this.missedIngredients = const [], // Mặc định là rỗng
  });

  /// 1. Convert từ JSON (Lưu trong máy) -> Object
  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'No Name',
      description: json['description'] as String? ?? '',
      cookingTimeMinutes: json['cookingTimeMinutes'] as int? ?? 0,

      instructions: json['instructions'] != null
          ? List<String>.from(json['instructions'])
          : [],

      ingredients: json['ingredients'] != null
          ? (json['ingredients'] as List)
                .map((e) => IngredientModel.fromJson(e))
                .toList()
          : [],

      imageUrl: json['imageUrl'] as String? ?? '',
      missedIngredientCount: json['missedIngredientCount'] as int? ?? 0,
      usedIngredientCount: json['usedIngredientCount'] as int? ?? 0,

      // Load danh sách món thiếu từ Local Storage
      missedIngredients: json['missedIngredients'] != null
          ? List<String>.from(json['missedIngredients'])
          : [],
    );
  }

  /// 2. Convert từ Object -> JSON (Để lưu xuống máy)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cookingTimeMinutes': cookingTimeMinutes,
      'instructions': instructions,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'imageUrl': imageUrl,
      'missedIngredientCount': missedIngredientCount,
      'usedIngredientCount': usedIngredientCount,
      'missedIngredients': missedIngredients, // Lưu danh sách món thiếu
    };
  }

  /// 3. Factory cho API Search (findByIngredients) - QUAN TRỌNG NHẤT
  factory RecipeModel.fromSpoonacularSearch(Map<String, dynamic> json) {
    // Xử lý lấy tên các món thiếu từ API
    List<String> missingList = [];
    if (json['missedIngredients'] != null) {
      missingList = (json['missedIngredients'] as List)
          .map((e) => e['name'].toString())
          .toList();
    }

    return RecipeModel(
      id: json['id'].toString(),
      name: json['title'] ?? 'No Name',
      description: '',
      cookingTimeMinutes:
          0, // API Search thường không trả về time, phải gọi Detail sau
      instructions: [],
      ingredients: [],
      imageUrl: json['image'] ?? '',

      // Gán dữ liệu gợi ý
      missedIngredientCount: json['missedIngredientCount'] ?? 0,
      usedIngredientCount: json['usedIngredientCount'] ?? 0,
      missedIngredients: missingList, // <--- Đã thêm
    );
  }

  /// 4. Factory cho API Detail (Lấy chi tiết món ăn)
  factory RecipeModel.fromSpoonacularDetail(Map<String, dynamic> json) {
    // Xử lý Hướng dẫn nấu (Steps)
    List<String> steps = [];
    if (json['analyzedInstructions'] != null &&
        (json['analyzedInstructions'] as List).isNotEmpty) {
      var stepList = json['analyzedInstructions'][0]['steps'] as List;
      steps = stepList.map((e) => e['step'] as String).toList();
    } else {
      // Fallback nếu không có analyzedInstructions
      steps = (json['instructions'] as String? ?? '').split('. ');
    }

    // Xử lý Nguyên liệu chi tiết (Extended Ingredients)
    List<IngredientModel> ingrList = [];
    if (json['extendedIngredients'] != null) {
      ingrList = (json['extendedIngredients'] as List)
          .map((e) => IngredientModel.fromSpoonacularJson(e))
          .toList();
    }

    return RecipeModel(
      id: json['id'].toString(),
      name: json['title'],
      description: json['summary'] != null
          ? _removeHtmlTags(json['summary'])
          : '',
      cookingTimeMinutes: json['readyInMinutes'] ?? 0,
      instructions: steps,
      ingredients: ingrList,
      imageUrl: json['image'] ?? '',

      // Khi xem chi tiết, ta thường không quan tâm thiếu đủ (hoặc đã có từ màn trước)
      // nên để mặc định hoặc giữ nguyên logic cũ
      missedIngredientCount: 0,
      usedIngredientCount: 0,
      missedIngredients: [],
    );
  }

  // Hàm tiện ích loại bỏ thẻ HTML trong description
  static String _removeHtmlTags(String htmlString) {
    return htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
