import 'dart:convert';
import '../../domain/entities/memory.dart';

class TravelMemoryModel extends TravelMemory {
  const TravelMemoryModel({
    required super.id,
    required super.destinationId,
    required super.title,
    required super.location,
    required super.date,
    required super.rating,
    super.description,
    required super.photos,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TravelMemoryModel.fromJson(Map<String, dynamic> json) {
    List<String> photosList = [];
    if (json['photos'] != null && json['photos'] is String) {
      try {
        final decoded = jsonDecode(json['photos']);
        if (decoded is List) {
          photosList = decoded.cast<String>();
        }
      } catch (e) {
        photosList = [];
      }
    }

    return TravelMemoryModel(
      id: json['id'],
      destinationId: json['destination_id'],
      title: json['title'],
      location: json['location'],
      date: DateTime.parse(json['date']),
      rating: json['rating'] as int,
      description: json['description'],
      photos: photosList,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination_id': destinationId,
      'title': title,
      'location': location,
      'date': date.toIso8601String(),
      'rating': rating,
      'description': description,
      'photos': photos.isNotEmpty ? jsonEncode(photos) : null,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TravelMemoryModel.fromEntity(TravelMemory memory) {
    return TravelMemoryModel(
      id: memory.id,
      destinationId: memory.destinationId,
      title: memory.title,
      location: memory.location,
      date: memory.date,
      rating: memory.rating,
      description: memory.description,
      photos: memory.photos,
      createdAt: memory.createdAt,
      updatedAt: memory.updatedAt,
    );
  }
}
