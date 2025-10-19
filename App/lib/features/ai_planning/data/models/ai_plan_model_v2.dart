// AI Plan Model V2 with Structured Activities
//
// 包含结构化的activities和AI生成的country字段

class ActivityModel {
  final String title;
  final String startTime; // HH:MM
  final String endTime; // HH:MM
  final String location;
  final String description;
  final double? estimatedCost;

  ActivityModel({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.description,
    this.estimatedCost,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      title: json['title'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      estimatedCost: json['estimatedCost'] != null
          ? (json['estimatedCost'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'description': description,
      if (estimatedCost != null) 'estimatedCost': estimatedCost,
    };
  }
}

class DailyItineraryModelV2 {
  final int dayNumber;
  final String date; // YYYY-MM-DD
  final String title;
  final List<ActivityModel> activities;

  DailyItineraryModelV2({
    required this.dayNumber,
    required this.date,
    required this.title,
    required this.activities,
  });

  factory DailyItineraryModelV2.fromJson(Map<String, dynamic> json) {
    return DailyItineraryModelV2(
      dayNumber: json['dayNumber'] as int,
      date: json['date'] as String,
      title: json['title'] as String,
      activities: (json['activities'] as List<dynamic>)
          .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'date': date,
      'title': title,
      'activities': activities.map((e) => e.toJson()).toList(),
    };
  }
}

class PackingItemModelV2 {
  final String name;
  final String category;
  final int quantity;
  final bool isEssential;

  PackingItemModelV2({
    required this.name,
    required this.category,
    required this.quantity,
    required this.isEssential,
  });

  factory PackingItemModelV2.fromJson(Map<String, dynamic> json) {
    return PackingItemModelV2(
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: json['quantity'] as int? ?? 1,
      isEssential: json['isEssential'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'isEssential': isEssential,
    };
  }
}

class TodoItemModelV2 {
  final String title;
  final String? description;
  final String? category; // passport, idCard, visa, insurance, ticket, hotel, carRental, other
  final String? priority; // high, medium, low

  TodoItemModelV2({
    required this.title,
    this.description,
    this.category,
    this.priority,
  });

  factory TodoItemModelV2.fromJson(Map<String, dynamic> json) {
    return TodoItemModelV2(
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      priority: json['priority'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (priority != null) 'priority': priority,
    };
  }
}

class AIPlanModelV2 {
  final String tagline;
  final List<String> tags;
  final String detailedDescription;
  final String country; // AI生成的国家
  final List<DailyItineraryModelV2> itineraries;
  final List<PackingItemModelV2> packingItems;
  final List<TodoItemModelV2> todoChecklist;

  AIPlanModelV2({
    required this.tagline,
    required this.tags,
    required this.detailedDescription,
    required this.country,
    required this.itineraries,
    required this.packingItems,
    required this.todoChecklist,
  });

  factory AIPlanModelV2.fromJson(Map<String, dynamic> json) {
    return AIPlanModelV2(
      tagline: json['tagline'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      detailedDescription: json['detailedDescription'] as String,
      country: json['country'] as String,
      itineraries: (json['itineraries'] as List<dynamic>)
          .map((e) => DailyItineraryModelV2.fromJson(e as Map<String, dynamic>))
          .toList(),
      packingItems: (json['packingItems'] as List<dynamic>)
          .map((e) => PackingItemModelV2.fromJson(e as Map<String, dynamic>))
          .toList(),
      todoChecklist: (json['todoChecklist'] as List<dynamic>)
          .map((e) => TodoItemModelV2.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tagline': tagline,
      'tags': tags,
      'detailedDescription': detailedDescription,
      'country': country,
      'itineraries': itineraries.map((e) => e.toJson()).toList(),
      'packingItems': packingItems.map((e) => e.toJson()).toList(),
      'todoChecklist': todoChecklist.map((e) => e.toJson()).toList(),
    };
  }
}
