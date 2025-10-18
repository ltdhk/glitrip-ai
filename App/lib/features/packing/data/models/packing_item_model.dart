import 'dart:convert';
import '../../domain/entities/packing_item.dart';

class PackingItemModel extends PackingItem {
  const PackingItemModel({
    required super.id,
    required super.name,
    required super.category,
    required super.quantity,
    required super.isEssential,
    required super.isPacked,
    super.destinationId,
    super.language = 'zh',
    required super.createdAt,
    required super.updatedAt,
  });

  factory PackingItemModel.fromEntity(PackingItem item) {
    return PackingItemModel(
      id: item.id,
      name: item.name,
      category: item.category,
      quantity: item.quantity,
      isEssential: item.isEssential,
      isPacked: item.isPacked,
      destinationId: item.destinationId,
      language: item.language,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  factory PackingItemModel.fromMap(Map<String, dynamic> map) {
    return PackingItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      category: PackingCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => PackingCategory.other,
      ),
      quantity: map['quantity'] as int,
      isEssential: (map['is_essential'] as int) == 1,
      isPacked: (map['is_packed'] as int) == 1,
      destinationId: map['destination_id'] as String?,
      language: map['language'] as String? ?? 'zh',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'quantity': quantity,
      'is_essential': isEssential ? 1 : 0,
      'is_packed': isPacked ? 1 : 0,
      'destination_id': destinationId,
      'language': language,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PackingItemModel.fromJson(String source) =>
      PackingItemModel.fromMap(jsonDecode(source));

  String toJson() => jsonEncode(toMap());

  @override
  PackingItemModel copyWith({
    String? id,
    String? name,
    PackingCategory? category,
    int? quantity,
    bool? isEssential,
    bool? isPacked,
    String? destinationId,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PackingItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      isEssential: isEssential ?? this.isEssential,
      isPacked: isPacked ?? this.isPacked,
      destinationId: destinationId ?? this.destinationId,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
