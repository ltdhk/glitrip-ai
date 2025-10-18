import 'package:uuid/uuid.dart';

class TravelMemory {
  final String id;
  final String destinationId;
  final String title;
  final String location;
  final DateTime date;
  final int rating; // 1-5 stars
  final String? description;
  final List<String> photos; // 照片路径列表
  final DateTime createdAt;
  final DateTime updatedAt;

  const TravelMemory({
    required this.id,
    required this.destinationId,
    required this.title,
    required this.location,
    required this.date,
    required this.rating,
    this.description,
    required this.photos,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TravelMemory.create({
    required String destinationId,
    required String title,
    required String location,
    required DateTime date,
    required int rating,
    String? description,
    List<String>? photos,
  }) {
    final now = DateTime.now();
    return TravelMemory(
      id: const Uuid().v4(),
      destinationId: destinationId,
      title: title,
      location: location,
      date: date,
      rating: rating,
      description: description,
      photos: photos ?? [],
      createdAt: now,
      updatedAt: now,
    );
  }

  TravelMemory copyWith({
    String? id,
    String? destinationId,
    String? title,
    String? location,
    DateTime? date,
    int? rating,
    String? description,
    List<String>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TravelMemory(
      id: id ?? this.id,
      destinationId: destinationId ?? this.destinationId,
      title: title ?? this.title,
      location: location ?? this.location,
      date: date ?? this.date,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
