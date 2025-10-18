import '../../domain/entities/itinerary_day.dart';

class ItineraryDayModel extends ItineraryDay {
  const ItineraryDayModel({
    required super.id,
    required super.destinationId,
    required super.title,
    required super.date,
    required super.dayNumber,
    required super.activities,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ItineraryDayModel.fromMap(Map<String, dynamic> map,
      {List<ItineraryActivity>? activities}) {
    return ItineraryDayModel(
      id: map['id'] as String,
      destinationId: map['destination_id'] as String,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      dayNumber: map['day_number'] as int,
      activities: activities ?? [],
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'destination_id': destinationId,
      'title': title,
      'date': date.toIso8601String(),
      'day_number': dayNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ItineraryDayModel.fromEntity(ItineraryDay day) {
    return ItineraryDayModel(
      id: day.id,
      destinationId: day.destinationId,
      title: day.title,
      date: day.date,
      dayNumber: day.dayNumber,
      activities: day.activities,
      createdAt: day.createdAt,
      updatedAt: day.updatedAt,
    );
  }
}

class ItineraryActivityModel extends ItineraryActivity {
  const ItineraryActivityModel({
    required super.id,
    required super.dayId,
    required super.time,
    required super.title,
    required super.location,
    super.cost,
    super.notes,
    required super.isBooked,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ItineraryActivityModel.fromMap(Map<String, dynamic> map) {
    return ItineraryActivityModel(
      id: map['id'] as String,
      dayId: map['day_id'] as String,
      time: map['time'] as String,
      title: map['title'] as String,
      location: map['location'] as String,
      cost: map['cost'] != null ? (map['cost'] as num).toDouble() : null,
      notes: map['notes'] as String?,
      isBooked: map['is_booked'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day_id': dayId,
      'time': time,
      'title': title,
      'location': location,
      'cost': cost,
      'notes': notes,
      'is_booked': isBooked ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ItineraryActivityModel.fromEntity(ItineraryActivity activity) {
    return ItineraryActivityModel(
      id: activity.id,
      dayId: activity.dayId,
      time: activity.time,
      title: activity.title,
      location: activity.location,
      cost: activity.cost,
      notes: activity.notes,
      isBooked: activity.isBooked,
      createdAt: activity.createdAt,
      updatedAt: activity.updatedAt,
    );
  }
}
