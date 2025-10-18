import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/memory.dart';
import '../../data/datasources/memory_local_datasource.dart';
import '../../data/models/memory_model.dart';

class MemoriesNotifier extends StateNotifier<AsyncValue<List<TravelMemory>>> {
  final MemoryLocalDataSource _dataSource;

  MemoriesNotifier(this._dataSource) : super(const AsyncValue.loading()) {
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    try {
      final memories = await _dataSource.getAllMemories();
      state = AsyncValue.data(memories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addMemory(TravelMemory memory) async {
    try {
      final memoryModel = TravelMemoryModel.fromEntity(memory);
      await _dataSource.insertMemory(memoryModel);
      await _loadMemories();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateMemory(TravelMemory updatedMemory) async {
    try {
      final memoryModel = TravelMemoryModel.fromEntity(updatedMemory);
      await _dataSource.updateMemory(memoryModel);
      await _loadMemories();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteMemory(String memoryId) async {
    try {
      await _dataSource.deleteMemory(memoryId);
      await _loadMemories();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  List<TravelMemory> getMemoriesForDestination(String destinationId) {
    return state.when(
      data: (memories) => memories
          .where((memory) => memory.destinationId == destinationId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)),
      loading: () => [],
      error: (_, __) => [],
    );
  }
}

// 创建数据源的Provider
final memoryLocalDataSourceProvider = Provider<MemoryLocalDataSource>((ref) {
  return MemoryLocalDataSource(DatabaseHelper.instance);
});

// 回忆管理的Provider
final memoriesProvider =
    StateNotifierProvider<MemoriesNotifier, AsyncValue<List<TravelMemory>>>(
  (ref) {
    final dataSource = ref.watch(memoryLocalDataSourceProvider);
    return MemoriesNotifier(dataSource);
  },
);

// 为特定目的地提供回忆的Provider
final destinationMemoriesProvider = Provider.family<List<TravelMemory>, String>(
  (ref, destinationId) {
    final memoriesAsync = ref.watch(memoriesProvider);
    return memoriesAsync.when(
      data: (memories) => memories
          .where((memory) => memory.destinationId == destinationId)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)),
      loading: () => [],
      error: (_, __) => [],
    );
  },
);
