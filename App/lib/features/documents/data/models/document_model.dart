import 'dart:convert';
import '../../domain/entities/document.dart';

class DocumentModel extends Document {
  const DocumentModel({
    required super.id,
    required super.name,
    required super.type,
    required super.hasExpiry,
    super.expiryDate,
    super.description,
    super.imagePaths = const [],
    required super.createdAt,
    required super.updatedAt,
  });

  factory DocumentModel.fromEntity(Document document) {
    return DocumentModel(
      id: document.id,
      name: document.name,
      type: document.type,
      hasExpiry: document.hasExpiry,
      expiryDate: document.expiryDate,
      description: document.description,
      imagePaths: document.imagePaths,
      createdAt: document.createdAt,
      updatedAt: document.updatedAt,
    );
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map,
      {List<String>? imagePaths}) {
    return DocumentModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: DocumentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DocumentType.other,
      ),
      hasExpiry: (map['has_expiry'] as int) == 1,
      expiryDate: map['expiry_date'] != null
          ? DateTime.parse(map['expiry_date'] as String)
          : null,
      description: map['description'] as String?,
      imagePaths: imagePaths ?? const [],
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'has_expiry': hasExpiry ? 1 : 0,
      'expiry_date': expiryDate?.toIso8601String(),
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DocumentModel.fromJson(String source) =>
      DocumentModel.fromMap(jsonDecode(source));

  String toJson() => jsonEncode(toMap());

  @override
  DocumentModel copyWith({
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
    return DocumentModel(
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
}
