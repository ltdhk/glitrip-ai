import 'dart:convert';
import '../../domain/entities/destination.dart';

class DestinationModel extends Destination {
  const DestinationModel({
    required super.id,
    required super.name,
    required super.country,
    super.description,
    required super.status,
    required super.budgetLevel,
    super.estimatedCost,
    required super.recommendedDays,
    super.bestTimeDescription,
    super.startDate,
    super.endDate,
    required super.tags,
    super.travelNotes,
    required super.travelBuddyIds,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DestinationModel.fromEntity(Destination destination) {
    return DestinationModel(
      id: destination.id,
      name: destination.name,
      country: destination.country,
      description: destination.description,
      status: destination.status,
      budgetLevel: destination.budgetLevel,
      estimatedCost: destination.estimatedCost,
      recommendedDays: destination.recommendedDays,
      bestTimeDescription: destination.bestTimeDescription,
      startDate: destination.startDate,
      endDate: destination.endDate,
      tags: destination.tags,
      travelNotes: destination.travelNotes,
      travelBuddyIds: destination.travelBuddyIds,
      createdAt: destination.createdAt,
      updatedAt: destination.updatedAt,
    );
  }

  factory DestinationModel.fromMap(Map<String, dynamic> map) {
    return DestinationModel(
      id: map['id'] as String,
      name: map['name'] as String,
      country: map['country'] as String,
      description: map['description'] as String?,
      status: DestinationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DestinationStatus.wishlist,
      ),
      budgetLevel: BudgetLevel.values.firstWhere(
        (e) => e.name == map['budget_level'],
        orElse: () => BudgetLevel.medium,
      ),
      estimatedCost: map['estimated_cost'] as double?,
      recommendedDays: map['recommended_days'] as int,
      bestTimeDescription: map['best_time_description'] as String?,
      startDate: map['start_date'] != null
          ? DateTime.parse(map['start_date'] as String)
          : null,
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'] as String)
          : null,
      tags: map['tags'] != null && (map['tags'] as String).isNotEmpty
          ? (map['tags'] as String).split(',')
          : [],
      travelNotes: map['travel_notes'] as String?,
      travelBuddyIds: [], // 从关联表中单独加载
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'description': description,
      'status': status.name,
      'budget_level': budgetLevel.name,
      'estimated_cost': estimatedCost,
      'recommended_days': recommendedDays,
      'best_time_description': bestTimeDescription,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'tags': tags.join(','), // 使用逗号分隔，与数据库存储格式一致
      'travel_notes': travelNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DestinationModel.fromJson(String source) =>
      DestinationModel.fromMap(jsonDecode(source));

  String toJson() => jsonEncode(toMap());

  @override
  DestinationModel copyWith({
    String? id,
    String? name,
    String? country,
    String? description,
    DestinationStatus? status,
    BudgetLevel? budgetLevel,
    double? estimatedCost,
    int? recommendedDays,
    String? bestTimeDescription,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    String? travelNotes,
    List<String>? travelBuddyIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DestinationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      description: description ?? this.description,
      status: status ?? this.status,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      recommendedDays: recommendedDays ?? this.recommendedDays,
      bestTimeDescription: bestTimeDescription ?? this.bestTimeDescription,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      tags: tags ?? this.tags,
      travelNotes: travelNotes ?? this.travelNotes,
      travelBuddyIds: travelBuddyIds ?? this.travelBuddyIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
