import 'package:equatable/equatable.dart';

enum TravelPreference {
  adventure,
  relaxation,
  culture,
  foodie,
  nature,
  urban,
}

enum BudgetLevel {
  low,
  medium,
  high,
}

class TravelBuddy extends Equatable {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String? availability;
  final BudgetLevel budgetLevel;
  final bool isConfirmedToTravel;
  final List<TravelPreference> travelPreferences;
  final List<String> dreamDestinations;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TravelBuddy({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.availability,
    required this.budgetLevel,
    required this.isConfirmedToTravel,
    required this.travelPreferences,
    required this.dreamDestinations,
    required this.createdAt,
    required this.updatedAt,
  });

  TravelBuddy copyWith({
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
    return TravelBuddy(
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

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        availability,
        budgetLevel,
        isConfirmedToTravel,
        travelPreferences,
        dreamDestinations,
        createdAt,
        updatedAt,
      ];
}
