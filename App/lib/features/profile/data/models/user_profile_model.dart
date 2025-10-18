import 'dart:convert';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.signature,
    super.avatarPath,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      name: profile.name,
      signature: profile.signature,
      avatarPath: profile.avatarPath,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as String,
      name: map['name'] as String,
      signature: map['signature'] as String,
      avatarPath: map['avatar_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'signature': signature,
      'avatar_path': avatarPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfileModel.fromJson(String source) =>
      UserProfileModel.fromMap(jsonDecode(source));

  String toJson() => jsonEncode(toMap());

  @override
  UserProfileModel copyWith({
    String? id,
    String? name,
    String? signature,
    String? avatarPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      signature: signature ?? this.signature,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
