import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_enums.dart';

class ShoppingItemModel {
  final String id;
  final String name;
  final double quantity;
  final MeasureUnit unit;
  final bool isBought;
  final String? note;
  final String category;
  final DateTime? updatedAt;

  ShoppingItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.isBought = false,
    this.note,
    this.category = 'Khác',
    this.updatedAt,
  });

  /// Chuyển object sang Map để lưu lên Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit.name, // Lưu tên enum (ví dụ: 'kg', 'g')
      'isBought': isBought,
      'note': note,
      'category': category,
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  /// Khởi tạo object từ dữ liệu Firestore
  factory ShoppingItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingItemModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: _parseUnitString(json['unit'] as String?),
      isBought: json['isBought'] as bool? ?? false,
      note: json['note'] as String?,
      category: json['category'] as String? ?? 'Khác',
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Tạo bản sao với các giá trị thay đổi
  ShoppingItemModel copyWith({
    String? name,
    double? quantity,
    MeasureUnit? unit,
    bool? isBought,
    String? note,
    String? category,
    DateTime? updatedAt,
  }) {
    return ShoppingItemModel(
      id: this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isBought: isBought ?? this.isBought,
      note: note ?? this.note,
      category: category ?? this.category,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  ShoppingItemModel merge(ShoppingItemModel other) {
    if (name.toLowerCase().trim() != other.name.toLowerCase().trim()) return this;

    return copyWith(
      quantity: quantity + other.quantity,
      updatedAt: DateTime.now(),
    );
  }

  /// Hàm parse chuỗi String từ DB sang Enum an toàn
  static MeasureUnit _parseUnitString(String? unitString) {
    if (unitString == null || unitString.isEmpty) return MeasureUnit.piece;

    final u = unitString.toLowerCase().trim();

    // So khớp theo tên Enum hoặc các ký tự phổ biến
    for (var value in MeasureUnit.values) {
      if (value.name == u) return value;
    }

    if (['g', 'gram'].contains(u)) return MeasureUnit.g;
    if (['kg', 'kilo'].contains(u)) return MeasureUnit.kg;
    if (['ml'].contains(u)) return MeasureUnit.ml;
    if (['l', 'liters'].contains(u)) return MeasureUnit.l;
    if (['spoon', 'tbsp', 'tsp'].any((e) => u.contains(e))) return MeasureUnit.spoon;
    if (['cup'].contains(u)) return MeasureUnit.cup;

    return MeasureUnit.piece;
  }
}