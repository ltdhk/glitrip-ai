/// AI Plan Models
///
/// AI生成的旅行计划相关模型

class AIPlanModel {
  final String tagline;
  final List<String> tags;
  final String description;
  final List<DailyItineraryModel> dailyItineraries;
  final List<PackingItemModel> packingItems;
  final List<TodoItemModel> todoItems;

  AIPlanModel({
    required this.tagline,
    required this.tags,
    required this.description,
    required this.dailyItineraries,
    required this.packingItems,
    required this.todoItems,
  });

  factory AIPlanModel.fromJson(Map<String, dynamic> json) {
    return AIPlanModel(
      tagline: json['tagline'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      description: json['description'] as String,
      dailyItineraries: (json['dailyItineraries'] as List<dynamic>)
          .map((e) => DailyItineraryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      packingItems: (json['packingItems'] as List<dynamic>)
          .map((e) => PackingItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      todoItems: (json['todoItems'] as List<dynamic>)
          .map((e) => TodoItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DailyItineraryModel {
  final int dayNumber;
  final String activities;
  final String meals;
  final String notes;

  DailyItineraryModel({
    required this.dayNumber,
    required this.activities,
    required this.meals,
    required this.notes,
  });

  factory DailyItineraryModel.fromJson(Map<String, dynamic> json) {
    return DailyItineraryModel(
      dayNumber: json['dayNumber'] as int,
      activities: json['activities'] as String,
      meals: json['meals'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'activities': activities,
      'meals': meals,
      'notes': notes,
    };
  }
}

class PackingItemModel {
  final String name;
  final String category;
  final int quantity;

  PackingItemModel({
    required this.name,
    required this.category,
    required this.quantity,
  });

  factory PackingItemModel.fromJson(Map<String, dynamic> json) {
    return PackingItemModel(
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
    };
  }
}

class TodoItemModel {
  final String title;
  final String? deadline;

  TodoItemModel({
    required this.title,
    this.deadline,
  });

  factory TodoItemModel.fromJson(Map<String, dynamic> json) {
    return TodoItemModel(
      title: json['title'] as String,
      deadline: json['deadline'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (deadline != null) 'deadline': deadline,
    };
  }
}

/// AI生成请求
class AIPlanRequest {
  final String destinationName;
  final String budgetLevel;
  final String startDate;
  final String endDate;

  AIPlanRequest({
    required this.destinationName,
    required this.budgetLevel,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'destinationName': destinationName,
      'budgetLevel': budgetLevel,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}

/// AI使用情况
class AIUsageModel {
  final int usedCount;
  final int totalQuota;
  final int remainingQuota;
  final String subscriptionType;

  AIUsageModel({
    required this.usedCount,
    required this.totalQuota,
    required this.remainingQuota,
    required this.subscriptionType,
  });

  factory AIUsageModel.fromJson(Map<String, dynamic> json) {
    return AIUsageModel(
      usedCount: json['usedCount'] as int? ?? json['used_count'] as int,
      totalQuota: json['totalQuota'] as int? ?? json['total_quota'] as int,
      remainingQuota: json['remainingQuota'] as int? ?? json['remaining_quota'] as int,
      subscriptionType: json['subscriptionType'] as String? ?? json['subscription_type'] as String,
    );
  }

  bool get hasQuota => remainingQuota > 0;
  bool get isVip => subscriptionType == 'vip';
}
