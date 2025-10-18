import '../entities/travel_buddy.dart';

abstract class TravelBuddyRepository {
  Future<List<TravelBuddy>> getAllTravelBuddies();
  Future<TravelBuddy?> getTravelBuddyById(String id);
  Future<void> addTravelBuddy(TravelBuddy buddy);
  Future<void> updateTravelBuddy(TravelBuddy buddy);
  Future<void> deleteTravelBuddy(String id);
  Future<List<TravelBuddy>> searchTravelBuddies(String query);
}
