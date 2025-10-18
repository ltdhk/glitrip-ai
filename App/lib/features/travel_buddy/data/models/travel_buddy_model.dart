import 'dart:convert';
import '../../../travel_buddy/domain/entities/travel_buddy.dart';

class TravelBuddyModel extends TravelBuddy {
  const TravelBuddyModel({
    super.id,
    required super.name,
    required super.email,
    required super.phone,
    super.availability,
    required super.budgetLevel,
    required super.isConfirmedToTravel,
    required super.travelPreferences,
    required super.dreamDestinations,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TravelBuddyModel.fromJson(Map<String, dynamic> json) {
    // 处理旅行偏好
    List<TravelPreference> preferences = [];
    if (json['adventure_preference'] == 1)
      preferences.add(TravelPreference.adventure);
    if (json['relaxation_preference'] == 1)
      preferences.add(TravelPreference.relaxation);
    if (json['culture_preference'] == 1)
      preferences.add(TravelPreference.culture);
    if (json['foodie_preference'] == 1)
      preferences.add(TravelPreference.foodie);
    if (json['nature_preference'] == 1)
      preferences.add(TravelPreference.nature);
    if (json['urban_preference'] == 1) preferences.add(TravelPreference.urban);

    // 处理梦想目的地
    List<String> destinations = [];
    if (json['dream_destinations'] != null &&
        json['dream_destinations'].isNotEmpty) {
      try {
        final decoded = jsonDecode(json['dream_destinations']);
        if (decoded is List) {
          destinations = decoded.map((e) => e.toString()).toList();
        }
      } catch (e) {
        // 如果解析失败，尝试按逗号分割
        destinations = json['dream_destinations']
            .toString()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    return TravelBuddyModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      availability: json['availability'],
      budgetLevel: json['budget_level'] != null
          ? BudgetLevel.values.firstWhere(
              (e) => e.name == json['budget_level'],
              orElse: () => BudgetLevel.medium,
            )
          : BudgetLevel.medium,
      isConfirmedToTravel: (json['confirmed_to_travel'] ?? 0) == 1,
      travelPreferences: preferences,
      dreamDestinations: destinations,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'availability': availability,
      'budget_level': budgetLevel.name,
      'confirmed_to_travel': isConfirmedToTravel ? 1 : 0,
      'adventure_preference':
          travelPreferences.contains(TravelPreference.adventure) ? 1 : 0,
      'relaxation_preference':
          travelPreferences.contains(TravelPreference.relaxation) ? 1 : 0,
      'culture_preference':
          travelPreferences.contains(TravelPreference.culture) ? 1 : 0,
      'foodie_preference':
          travelPreferences.contains(TravelPreference.foodie) ? 1 : 0,
      'nature_preference':
          travelPreferences.contains(TravelPreference.nature) ? 1 : 0,
      'urban_preference':
          travelPreferences.contains(TravelPreference.urban) ? 1 : 0,
      'dream_destinations':
          dreamDestinations.isNotEmpty ? jsonEncode(dreamDestinations) : null,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TravelBuddyModel.fromEntity(TravelBuddy buddy) {
    return TravelBuddyModel(
      id: buddy.id,
      name: buddy.name,
      email: buddy.email,
      phone: buddy.phone,
      availability: buddy.availability,
      budgetLevel: buddy.budgetLevel,
      isConfirmedToTravel: buddy.isConfirmedToTravel,
      travelPreferences: buddy.travelPreferences,
      dreamDestinations: buddy.dreamDestinations,
      createdAt: buddy.createdAt,
      updatedAt: buddy.updatedAt,
    );
  }

  @override
  TravelBuddyModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? availability,
    BudgetLevel? budgetLevel,
    bool? isConfirmedToTravel,
    List<TravelPreference>? travelPreferences,
    List<String>? dreamDestinations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TravelBuddyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      availability: availability ?? this.availability,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      isConfirmedToTravel: isConfirmedToTravel ?? this.isConfirmedToTravel,
      travelPreferences: travelPreferences ?? this.travelPreferences,
      dreamDestinations: dreamDestinations ?? this.dreamDestinations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
