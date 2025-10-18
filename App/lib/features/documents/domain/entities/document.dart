import 'package:uuid/uuid.dart';

enum DocumentType {
  passport,
  idCard,
  visa,
  insurance,
  ticket,
  hotel,
  carRental,
  other
}

class Document {
  final String id;
  final String name;
  final DocumentType type;
  final bool hasExpiry;
  final DateTime? expiryDate;
  final String? description;
  final List<String> imagePaths;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Document({
    required this.id,
    required this.name,
    required this.type,
    required this.hasExpiry,
    this.expiryDate,
    this.description,
    this.imagePaths = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Document.create({
    required String name,
    required DocumentType type,
    bool hasExpiry = false,
    DateTime? expiryDate,
    String? description,
    List<String> imagePaths = const [],
  }) {
    final now = DateTime.now();
    return Document(
      id: const Uuid().v4(),
      name: name,
      type: type,
      hasExpiry: hasExpiry,
      expiryDate: expiryDate,
      description: description,
      imagePaths: imagePaths,
      createdAt: now,
      updatedAt: now,
    );
  }

  Document copyWith({
    String? id,
    String? name,
    DocumentType? type,
    bool? hasExpiry,
    DateTime? expiryDate,
    String? description,
    List<String>? imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      hasExpiry: hasExpiry ?? this.hasExpiry,
      expiryDate: expiryDate ?? this.expiryDate,
      description: description ?? this.description,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  bool get isExpired {
    if (!hasExpiry || expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  bool get isExpiringSoon {
    if (!hasExpiry || expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  String get typeDisplayName {
    switch (type) {
      case DocumentType.passport:
        return '护照';
      case DocumentType.idCard:
        return '身份证';
      case DocumentType.visa:
        return '签证';
      case DocumentType.insurance:
        return '保险';
      case DocumentType.ticket:
        return '机票';
      case DocumentType.hotel:
        return '酒店预订';
      case DocumentType.carRental:
        return '租车';
      case DocumentType.other:
        return '其他';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Document && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Document{id: $id, name: $name, type: $type}';
  }
}
