import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../domain/entities/destination.dart';

// 所有目的地状态
final destinationsProvider =
    StateNotifierProvider<DestinationsNotifier, AsyncValue<List<Destination>>>(
        (ref) {
  final repository = ref.watch(destinationRepositoryProvider);
  return DestinationsNotifier(repository, ref);
});

// 按状态筛选的目的地
final destinationsByStatusProvider = StateNotifierProvider.family<
    DestinationsByStatusNotifier,
    AsyncValue<List<Destination>>,
    DestinationStatus>((ref, status) {
  final repository = ref.watch(destinationRepositoryProvider);
  return DestinationsByStatusNotifier(repository, status);
});

// 搜索目的地
final searchDestinationsProvider = StateNotifierProvider.family<
    SearchDestinationsNotifier,
    AsyncValue<List<Destination>>,
    String>((ref, query) {
  final repository = ref.watch(destinationRepositoryProvider);
  return SearchDestinationsNotifier(repository, query);
});

// 目的地统计
final destinationStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(destinationRepositoryProvider);
  return await repository.getDestinationStatistics();
});

// 选中的目的地状态筛选器
final selectedDestinationStatusProvider =
    StateProvider<DestinationStatus?>((ref) => null);

// 搜索查询
final destinationSearchQueryProvider = StateProvider<String>((ref) => '');

class DestinationsNotifier
    extends StateNotifier<AsyncValue<List<Destination>>> {
  final destinationRepository;
  final Ref ref;

  DestinationsNotifier(this.destinationRepository, this.ref)
      : super(const AsyncValue.loading()) {
    loadDestinations();
  }

  Future<void> loadDestinations() async {
    try {
      state = const AsyncValue.loading();
      final destinations = await destinationRepository.getAllDestinations();
      state = AsyncValue.data(destinations);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addDestination(Destination destination) async {
    try {
      await destinationRepository.createDestination(destination);
      await loadDestinations();
      ref.invalidate(destinationsByStatusProvider(destination.status));
      ref.invalidate(destinationStatsProvider); // 刷新统计数据
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateDestination(Destination destination) async {
    try {
      await destinationRepository.updateDestination(destination);
      await loadDestinations();
      ref.invalidate(destinationsByStatusProvider(DestinationStatus.planned));
      ref.invalidate(destinationsByStatusProvider(DestinationStatus.visited));
      ref.invalidate(destinationsByStatusProvider(DestinationStatus.wishlist));
      ref.invalidate(destinationStatsProvider); // 刷新统计数据
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteDestination(String id, DestinationStatus status) async {
    try {
      await destinationRepository.deleteDestination(id);
      await loadDestinations();
      ref.invalidate(destinationsByStatusProvider(status));
      ref.invalidate(destinationStatsProvider); // 刷新统计数据
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class DestinationsByStatusNotifier
    extends StateNotifier<AsyncValue<List<Destination>>> {
  final destinationRepository;
  final DestinationStatus status;

  DestinationsByStatusNotifier(this.destinationRepository, this.status)
      : super(const AsyncValue.loading()) {
    loadDestinationsByStatus();
  }

  Future<void> loadDestinationsByStatus() async {
    try {
      state = const AsyncValue.loading();
      final destinations =
          await destinationRepository.getDestinationsByStatus(status);
      state = AsyncValue.data(destinations);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class SearchDestinationsNotifier
    extends StateNotifier<AsyncValue<List<Destination>>> {
  final destinationRepository;
  final String query;

  SearchDestinationsNotifier(this.destinationRepository, this.query)
      : super(const AsyncValue.loading()) {
    if (query.isNotEmpty) {
      searchDestinations();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> searchDestinations() async {
    try {
      state = const AsyncValue.loading();
      final destinations =
          await destinationRepository.searchDestinations(query);
      state = AsyncValue.data(destinations);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
