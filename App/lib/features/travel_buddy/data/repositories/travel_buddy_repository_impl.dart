import '../../domain/entities/travel_buddy.dart';
import '../../domain/repositories/travel_buddy_repository.dart';
import '../datasources/travel_buddy_local_datasource.dart';
import '../models/travel_buddy_model.dart';

class TravelBuddyRepositoryImpl implements TravelBuddyRepository {
  final TravelBuddyLocalDataSource _localDataSource;

  TravelBuddyRepositoryImpl(this._localDataSource);

  @override
  Future<List<TravelBuddy>> getAllTravelBuddies() async {
    return await _localDataSource.getAllTravelBuddies();
  }

  @override
  Future<TravelBuddy?> getTravelBuddyById(String id) async {
    return await _localDataSource.getTravelBuddyById(id);
  }

  @override
  Future<void> addTravelBuddy(TravelBuddy buddy) async {
    final buddyModel = TravelBuddyModel.fromEntity(buddy);
    await _localDataSource.insertTravelBuddy(buddyModel);
  }

  @override
  Future<void> updateTravelBuddy(TravelBuddy buddy) async {
    final buddyModel = TravelBuddyModel.fromEntity(buddy);
    await _localDataSource.updateTravelBuddy(buddyModel);
  }

  @override
  Future<void> deleteTravelBuddy(String id) async {
    await _localDataSource.deleteTravelBuddy(id);
  }

  @override
  Future<List<TravelBuddy>> searchTravelBuddies(String query) async {
    return await _localDataSource.searchTravelBuddies(query);
  }
}
