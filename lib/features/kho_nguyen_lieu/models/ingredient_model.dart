import '../../../../core/constants/app_enums.dart';

class IngredientModel {
  final String id;
  final String name;
  final double quantity;
  final MeasureUnit unit;

  // Các trường Nullable (Có thể null)
  final DateTime? expiryDate; // Null nếu là nguyên liệu trong công thức nấu ăn
  final DateTime? addedDate;  // Ngày thêm vào kho
  final String? imageUrl;     // URL ảnh từ Spoonacular
  final String? aisle;        // Dãy hàng trong siêu thị (dùng cho Shopping List)

  IngredientModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.expiryDate,
    this.addedDate,
    this.imageUrl,
    this.aisle,
  });

  /// FR3.1: Kiểm tra trạng thái hạn sử dụng
  ExpiryStatus get status {
    if (expiryDate == null) return ExpiryStatus.fresh;

    // Lấy ngày hôm nay (chỉ lấy ngày, bỏ qua giờ phút giây để so sánh chính xác)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiration = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);

    final diff = expiration.difference(today).inDays;

    if (diff < 0) return ExpiryStatus.expired;
    if (diff <= 2) return ExpiryStatus.expiringSoon; // Cảnh báo trước 2 ngày
    return ExpiryStatus.fresh;
  }

  /// Trả về số ngày còn lại (dùng để hiển thị UI: "Còn 2 ngày")
  int get daysRemaining {
    if (expiryDate == null) return 999; // Giá trị mặc định lớn
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiration = DateTime(expiryDate!.year, expiryDate!.month, expiryDate!.day);
    return expiration.difference(today).inDays;
  }

  /// Tạo bản sao mới với một số trường thay đổi (Immutable pattern)
  IngredientModel copyWith({
    String? id,
    String? name,
    double? quantity,
    MeasureUnit? unit,
    DateTime? expiryDate,
    DateTime? addedDate,
    String? imageUrl,
    String? aisle,
  }) {
    return IngredientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      addedDate: addedDate ?? this.addedDate,
      imageUrl: imageUrl ?? this.imageUrl,
      aisle: aisle ?? this.aisle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit.toString().split('.').last, // Lưu "kg" thay vì "MeasureUnit.kg"
      'expiryDate': expiryDate?.toIso8601String(),
      'addedDate': addedDate?.toIso8601String(),
      'imageUrl': imageUrl,
      'aisle': aisle,
    };
  }

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: _parseUnitString(json['unit']),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      addedDate: json['addedDate'] != null ? DateTime.parse(json['addedDate']) : null,
      imageUrl: json['imageUrl'] as String?,
      aisle: json['aisle'] as String?,
    );
  }

  /// Factory đặc biệt để parse dữ liệu từ Spoonacular API
  factory IngredientModel.fromSpoonacularJson(Map<String, dynamic> json) {
    // Spoonacular trả về ID là int, convert sang String
    final String apiId = json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();

    // Ưu tiên lấy tên sạch (nameClean) nếu có, nếu không lấy originalString hoặc name
    final String apiName = json['nameClean'] ?? json['name'] ?? 'Unknown Ingredient';

    // Lấy ảnh: Spoonacular chỉ trả về filename, cần ghép với base URL
    // Base URL icon: https://spoonacular.com/cdn/ingredients_100x100/
    String? imgUrl;
    if (json['image'] != null) {
      imgUrl = "https://spoonacular.com/cdn/ingredients_100x100/${json['image']}";
    }

    return IngredientModel(
      id: apiId,
      name: apiName,
      quantity: (json['amount'] as num?)?.toDouble() ?? 0.0,
      unit: _parseUnitString(json['unit']),
      aisle: json['aisle'],
      // Lưu ý: Spoonacular không trả về expiryDate, user phải tự nhập khi thêm vào kho
      expiryDate: null,
      addedDate: DateTime.now(), // Mặc định là lúc gọi API
      imageUrl: imgUrl,
    );
  }

  /// Hàm chuẩn hóa đơn vị từ String (API/Local) sang Enum
  static MeasureUnit _parseUnitString(String? unitString) {
    if (unitString == null) return MeasureUnit.piece;

    final u = unitString.toLowerCase().trim();

    // Mapping các đơn vị phổ biến
    if (['g', 'gram', 'grams'].contains(u)) return MeasureUnit.g;
    if (['kg', 'kilo', 'kilogram', 'kilograms'].contains(u)) return MeasureUnit.kg;
    if (['ml', 'milliliter', 'milliliters'].contains(u)) return MeasureUnit.ml;
    if (['l', 'liter', 'liters'].contains(u)) return MeasureUnit.l;
    if (['tbsp', 'tsp', 'spoon', 'tablespoon', 'teaspoon'].any((e) => u.contains(e))) return MeasureUnit.spoon;
    if (['cup', 'cups'].contains(u)) return MeasureUnit.cup;
    if (['pcs', 'piece', 'pieces', 'slice', 'slices'].contains(u)) return MeasureUnit.piece;

    // Nếu API trả về đơn vị lạ (oz, pound...), tạm thời quy về unknown hoặc piece
    return MeasureUnit.unknown;
  }
}