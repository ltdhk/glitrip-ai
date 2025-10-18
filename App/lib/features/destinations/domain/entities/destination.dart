import 'package:uuid/uuid.dart';

enum DestinationStatus { visited, planned, wishlist }

enum BudgetLevel { high, medium, low }

class Destination {
  final String id;
  final String name;
  final String country;
  final String? description;
  final DestinationStatus status;
  final BudgetLevel budgetLevel;
  final double? estimatedCost;
  final int recommendedDays;
  final String? bestTimeDescription;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> tags;
  final String? travelNotes;
  final List<String> travelBuddyIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Destination({
    required this.id,
    required this.name,
    required this.country,
    this.description,
    required this.status,
    required this.budgetLevel,
    this.estimatedCost,
    required this.recommendedDays,
    this.bestTimeDescription,
    this.startDate,
    this.endDate,
    required this.tags,
    this.travelNotes,
    required this.travelBuddyIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Destination.create({
    required String name,
    required String country,
    String? description,
    required DestinationStatus status,
    required BudgetLevel budgetLevel,
    double? estimatedCost,
    int recommendedDays = 1,
    String? bestTimeDescription,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    String? travelNotes,
    List<String>? travelBuddyIds,
  }) {
    final now = DateTime.now();
    return Destination(
      id: const Uuid().v4(),
      name: name,
      country: country,
      description: description,
      status: status,
      budgetLevel: budgetLevel,
      estimatedCost: estimatedCost,
      recommendedDays: recommendedDays,
      bestTimeDescription: bestTimeDescription,
      startDate: startDate,
      endDate: endDate,
      tags: tags ?? [],
      travelNotes: travelNotes,
      travelBuddyIds: travelBuddyIds ?? [],
      createdAt: now,
      updatedAt: now,
    );
  }

  Destination copyWith({
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
    return Destination(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Destination && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Destination{id: $id, name: $name, country: $country, status: $status}';
  }
}
