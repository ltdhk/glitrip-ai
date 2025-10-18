import 'package:uuid/uuid.dart';

enum PackingCategory {
  clothing,
  electronics,
  cosmetics,
  health,
  accessories,
  books,
  entertainment,
  other
}

class PackingItem {
  final String id;
  final String name;
  final PackingCategory category;
  final int quantity;
  final bool isEssential;
  final bool isPacked;
  final String? destinationId; // 关联的目的地ID，null表示通用模板物品
  final String language; // 语言标识：'zh' 中文, 'en' 英文
  final DateTime createdAt;
  final DateTime updatedAt;

  const PackingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.isEssential,
    required this.isPacked,
    this.destinationId,
    this.language = 'zh',
    required this.createdAt,
    required this.updatedAt,
  });

  factory PackingItem.create({
    required String name,
    required PackingCategory category,
    int quantity = 1,
    bool isEssential = false,
    bool isPacked = false,
    String? destinationId,
    String language = 'zh',
  }) {
    final now = DateTime.now();
    return PackingItem(
      id: const Uuid().v4(),
      name: name,
      category: category,
      quantity: quantity,
      isEssential: isEssential,
      isPacked: isPacked,
      destinationId: destinationId,
      language: language,
      createdAt: now,
      updatedAt: now,
    );
  }

  PackingItem copyWith({
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
    return PackingItem(
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

  String get categoryDisplayName {
    switch (category) {
      case PackingCategory.clothing:
        return '衣服';
      case PackingCategory.electronics:
        return '电子产品';
      case PackingCategory.cosmetics:
        return '化妆品';
      case PackingCategory.health:
        return '药品';
      case PackingCategory.accessories:
        return '配饰';
      case PackingCategory.books:
        return '书籍';
      case PackingCategory.entertainment:
        return '娱乐';
      case PackingCategory.other:
        return '其他';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PackingItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PackingItem{id: $id, name: $name, category: $category, isPacked: $isPacked}';
  }
}
