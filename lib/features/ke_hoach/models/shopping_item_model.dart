import '../../../../core/constants/app_enums.dart';

class ShoppingItemModel {
  final String id;
  final String name;
  final double quantity;
  final MeasureUnit unit;
  final bool isBought;
  final bool isManualAdded;
  final String? note;
  final String category;

  ShoppingItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.isBought = false,
    this.isManualAdded = true,
    this.note,
    this.category = 'Khác',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit.toString().split('.').last,
      'isBought': isBought,
      'isManualAdded': isManualAdded,
      'note': note,
      'category': category,
    };
  }

  factory ShoppingItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),

      unit: _parseUnitString(json['unit']),

      isBought: json['isBought'] as bool? ?? false,
      isManualAdded: json['isManualAdded'] as bool? ?? true,
      note: json['note'] as String?,
      category: json['category'] as String? ?? 'Khác',
    );
  }

  ShoppingItemModel copyWith({
    String? name,
    double? quantity,
    MeasureUnit? unit,
    bool? isBought,
    String? note,
    String? category,
  }) {
    return ShoppingItemModel(
      id: this.id,
      isManualAdded: this.isManualAdded,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isBought: isBought ?? this.isBought,
      note: note ?? this.note,
      category: category ?? this.category,
    );
  }

  ShoppingItemModel merge(ShoppingItemModel other) {
    if (name.toLowerCase().trim() != other.name.toLowerCase().trim()) return this;

    return copyWith(
      quantity: quantity + other.quantity,
    );
  }

  static MeasureUnit _parseUnitString(String? unitString) {
    if (unitString == null) return MeasureUnit.piece;
    final u = unitString.toLowerCase().trim();
    if (['g', 'gram'].contains(u)) return MeasureUnit.g;
    if (['kg', 'kilo'].contains(u)) return MeasureUnit.kg;
    if (['ml'].contains(u)) return MeasureUnit.ml;
    if (['l', 'liters'].contains(u)) return MeasureUnit.l;
    if (['spoon', 'tbsp', 'tsp'].any((e) => u.contains(e))) return MeasureUnit.spoon;
    if (['cup'].contains(u)) return MeasureUnit.cup;
    return MeasureUnit.piece;
  }
}