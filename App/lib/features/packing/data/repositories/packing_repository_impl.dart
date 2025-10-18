import '../../domain/entities/packing_item.dart';
import '../../domain/repositories/packing_repository.dart';
import '../datasources/packing_local_datasource.dart';
import '../models/packing_item_model.dart';

class PackingRepositoryImpl implements PackingRepository {
  final PackingLocalDataSource _localDataSource;

  PackingRepositoryImpl(this._localDataSource);

  @override
  Future<List<PackingItem>> getAllItems() async {
    final models = await _localDataSource.getAllItems();
    return models.cast<PackingItem>();
  }

  @override
  Future<List<PackingItem>> getItemsByCategory(PackingCategory category) async {
    final models = await _localDataSource.getItemsByCategory(category.name);
    return models.cast<PackingItem>();
  }

  @override
  Future<List<PackingItem>> getItemsByDestination(String destinationId) async {
    final models = await _localDataSource.getItemsByDestination(destinationId);
    return models.cast<PackingItem>();
  }

  @override
  Future<List<PackingItem>> getTemplateItems({String language = 'zh'}) async {
    final models = await _localDataSource.getTemplateItems(language: language);
    return models.cast<PackingItem>();
  }

  @override
  Future<List<PackingItem>> searchItems(String query) async {
    final models = await _localDataSource.searchItems(query);
    return models.cast<PackingItem>();
  }

  @override
  Future<PackingItem?> getItemById(String id) async {
    final model = await _localDataSource.getItemById(id);
    return model;
  }

  @override
  Future<String> createItem(PackingItem item) async {
    final model = PackingItemModel.fromEntity(item);
    return await _localDataSource.insertItem(model);
  }

  @override
  Future<void> updateItem(PackingItem item) async {
    final model = PackingItemModel.fromEntity(item);
    await _localDataSource.updateItem(model);
  }

  @override
  Future<void> deleteItem(String id) async {
    await _localDataSource.deleteItem(id);
  }

  @override
  Future<Map<String, dynamic>> getPackingStatistics() async {
    return await _localDataSource.getPackingStatistics();
  }

  @override
  Future<Map<String, dynamic>> getPackingStatisticsByDestination(
      String destinationId) async {
    return await _localDataSource
        .getPackingStatisticsByDestination(destinationId);
  }

  @override
  Future<void> toggleItemPacked(String id) async {
    await _localDataSource.toggleItemPacked(id);
  }
}
