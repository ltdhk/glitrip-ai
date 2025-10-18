import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../data/datasources/travel_buddy_local_datasource.dart';
import '../../data/repositories/travel_buddy_repository_impl.dart';
import '../../domain/entities/travel_buddy.dart';
import '../../domain/repositories/travel_buddy_repository.dart';

// Providers
final travelBuddyLocalDataSourceProvider =
    Provider<TravelBuddyLocalDataSource>((ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  return TravelBuddyLocalDataSourceImpl(databaseHelper);
});

final travelBuddyRepositoryProvider = Provider<TravelBuddyRepository>((ref) {
  final localDataSource = ref.watch(travelBuddyLocalDataSourceProvider);
  return TravelBuddyRepositoryImpl(localDataSource);
});

// State providers
final travelBuddiesProvider =
    StateNotifierProvider<TravelBuddiesNotifier, AsyncValue<List<TravelBuddy>>>(
        (ref) {
  final repository = ref.watch(travelBuddyRepositoryProvider);
  return TravelBuddiesNotifier(repository);
});

final travelBuddySearchProvider = StateNotifierProvider<
    TravelBuddySearchNotifier, AsyncValue<List<TravelBuddy>>>((ref) {
  final repository = ref.watch(travelBuddyRepositoryProvider);
  return TravelBuddySearchNotifier(repository);
});

class TravelBuddiesNotifier
    extends StateNotifier<AsyncValue<List<TravelBuddy>>> {
  final TravelBuddyRepository _repository;

  TravelBuddiesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTravelBuddies();
  }

  Future<void> loadTravelBuddies() async {
    try {
      state = const AsyncValue.loading();
      final buddies = await _repository.getAllTravelBuddies();
      state = AsyncValue.data(buddies);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addTravelBuddy(TravelBuddy buddy) async {
    try {
      await _repository.addTravelBuddy(buddy);
      await loadTravelBuddies();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTravelBuddy(TravelBuddy buddy) async {
    try {
      await _repository.updateTravelBuddy(buddy);
      await loadTravelBuddies();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTravelBuddy(String id) async {
    try {
      await _repository.deleteTravelBuddy(id);
      await loadTravelBuddies();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class TravelBuddySearchNotifier
    extends StateNotifier<AsyncValue<List<TravelBuddy>>> {
  final TravelBuddyRepository _repository;

  TravelBuddySearchNotifier(this._repository)
      : super(const AsyncValue.data([]));

  Future<void> searchTravelBuddies(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      final results = await _repository.searchTravelBuddies(query);
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}
