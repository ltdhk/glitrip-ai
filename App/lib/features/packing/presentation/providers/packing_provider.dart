import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../domain/entities/packing_item.dart';

// 所有物品状态
final packingItemsProvider =
    StateNotifierProvider<PackingItemsNotifier, AsyncValue<List<PackingItem>>>(
        (ref) {
  final repository = ref.watch(packingRepositoryProvider);
  return PackingItemsNotifier(repository);
});

// 按类别筛选的物品
final itemsByCategoryProvider = StateNotifierProvider.family<
    ItemsByCategoryNotifier,
    AsyncValue<List<PackingItem>>,
    PackingCategory>((ref, category) {
  final repository = ref.watch(packingRepositoryProvider);
  return ItemsByCategoryNotifier(repository, category);
});

// 按目的地筛选的物品
final itemsByDestinationProvider = StateNotifierProvider.family<
    ItemsByDestinationNotifier,
    AsyncValue<List<PackingItem>>,
    String>((ref, destinationId) {
  final repository = ref.watch(packingRepositoryProvider);
  return ItemsByDestinationNotifier(repository, destinationId);
});

// 模板物品
final templateItemsProvider =
    StateNotifierProvider<TemplateItemsNotifier, AsyncValue<List<PackingItem>>>(
        (ref) {
  final repository = ref.watch(packingRepositoryProvider);
  final locale = ref.watch(localeProvider);
  return TemplateItemsNotifier(repository, locale.languageCode);
});

// 搜索物品
final searchItemsProvider = StateNotifierProvider.family<SearchItemsNotifier,
    AsyncValue<List<PackingItem>>, String>((ref, query) {
  final repository = ref.watch(packingRepositoryProvider);
  return SearchItemsNotifier(repository, query);
});

// 打包统计
final packingStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(packingRepositoryProvider);
  // 监听物品列表变化，当物品发生变化时自动刷新统计
  ref.watch(packingItemsProvider);
  return await repository.getPackingStatistics();
});

// 按目的地的打包统计
final packingStatsByDestinationProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
        (ref, destinationId) async {
  final repository = ref.watch(packingRepositoryProvider);
  // 监听对应目的地物品列表变化
  ref.watch(itemsByDestinationProvider(destinationId));
  return await repository.getPackingStatisticsByDestination(destinationId);
});

// 选中的物品类别筛选器
final selectedPackingCategoryProvider =
    StateProvider<PackingCategory?>((ref) => null);

// 搜索查询
final packingSearchQueryProvider = StateProvider<String>((ref) => '');

class PackingItemsNotifier
    extends StateNotifier<AsyncValue<List<PackingItem>>> {
  final packingRepository;

  PackingItemsNotifier(this.packingRepository)
      : super(const AsyncValue.loading()) {
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      state = const AsyncValue.loading();
      final items = await packingRepository.getAllItems();
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addItem(PackingItem item) async {
    try {
      await packingRepository.createItem(item);
      await loadItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateItem(PackingItem item) async {
    try {
      await packingRepository.updateItem(item);
      await loadItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await packingRepository.deleteItem(id);
      await loadItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleItemPacked(String id) async {
    try {
      await packingRepository.toggleItemPacked(id);
      await loadItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class ItemsByCategoryNotifier
    extends StateNotifier<AsyncValue<List<PackingItem>>> {
  final packingRepository;
  final PackingCategory category;

  ItemsByCategoryNotifier(this.packingRepository, this.category)
      : super(const AsyncValue.loading()) {
    loadItemsByCategory();
  }

  Future<void> loadItemsByCategory() async {
    try {
      state = const AsyncValue.loading();
      final items = await packingRepository.getItemsByCategory(category);
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class SearchItemsNotifier extends StateNotifier<AsyncValue<List<PackingItem>>> {
  final packingRepository;
  final String query;

  SearchItemsNotifier(this.packingRepository, this.query)
      : super(const AsyncValue.loading()) {
    if (query.isNotEmpty) {
      searchItems();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> searchItems() async {
    try {
      state = const AsyncValue.loading();
      final items = await packingRepository.searchItems(query);
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class ItemsByDestinationNotifier
    extends StateNotifier<AsyncValue<List<PackingItem>>> {
  final packingRepository;
  final String destinationId;

  ItemsByDestinationNotifier(this.packingRepository, this.destinationId)
      : super(const AsyncValue.loading()) {
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      state = const AsyncValue.loading();
      final items =
          await packingRepository.getItemsByDestination(destinationId);
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addItem(PackingItem item) async {
    try {
      // 确保物品关联到当前目的地
      final itemWithDestination = item.copyWith(destinationId: destinationId);
      await packingRepository.createItem(itemWithDestination);
      await loadItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateItem(PackingItem item) async {
    try {
      await packingRepository.updateItem(item);
      await loadItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await packingRepository.deleteItem(id);
      await loadItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleItemPacked(String id) async {
    try {
      await packingRepository.toggleItemPacked(id);
      await loadItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class TemplateItemsNotifier
    extends StateNotifier<AsyncValue<List<PackingItem>>> {
  final packingRepository;
  final String language;

  TemplateItemsNotifier(this.packingRepository, this.language)
      : super(const AsyncValue.loading()) {
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      state = const AsyncValue.loading();
      final items =
          await packingRepository.getTemplateItems(language: language);
      state = AsyncValue.data(items);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addItem(PackingItem item) async {
    try {
      // 模板物品不关联目的地
      final templateItem = item.copyWith(destinationId: null);
      await packingRepository.createItem(templateItem);
      await loadItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateItem(PackingItem item) async {
    try {
      await packingRepository.updateItem(item);
      await loadItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await packingRepository.deleteItem(id);
      await loadItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleItemPacked(String id) async {
    try {
      await packingRepository.toggleItemPacked(id);
      await loadItems();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
