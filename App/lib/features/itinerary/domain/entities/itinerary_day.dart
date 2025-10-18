class ItineraryDay {
  final String id;
  final String destinationId;
  final String title;
  final DateTime date;
  final int dayNumber;
  final List<ItineraryActivity> activities;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ItineraryDay({
    required this.id,
    required this.destinationId,
    required this.title,
    required this.date,
    required this.dayNumber,
    required this.activities,
    required this.createdAt,
    required this.updatedAt,
  });

  ItineraryDay copyWith({
    String? id,
    String? destinationId,
    String? title,
    DateTime? date,
    int? dayNumber,
    List<ItineraryActivity>? activities,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItineraryDay(
      id: id ?? this.id,
      destinationId: destinationId ?? this.destinationId,
      title: title ?? this.title,
      date: date ?? this.date,
      dayNumber: dayNumber ?? this.dayNumber,
      activities: activities ?? this.activities,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ItineraryActivity {
  final String id;
  final String dayId;
  final String time;
  final String title;
  final String location;
  final double? cost;
  final String? notes;
  final bool isBooked;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ItineraryActivity({
    required this.id,
    required this.dayId,
    required this.time,
    required this.title,
    required this.location,
    this.cost,
    this.notes,
    required this.isBooked,
    required this.createdAt,
    required this.updatedAt,
  });

  ItineraryActivity copyWith({
    String? id,
    String? dayId,
    String? time,
    String? title,
    String? location,
    double? cost,
    String? notes,
    bool? isBooked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItineraryActivity(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      time: time ?? this.time,
      title: title ?? this.title,
      location: location ?? this.location,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      isBooked: isBooked ?? this.isBooked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
