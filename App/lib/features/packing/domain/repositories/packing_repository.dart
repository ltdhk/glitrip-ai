import '../entities/packing_item.dart';

abstract class PackingRepository {
  Future<List<PackingItem>> getAllItems();
  Future<List<PackingItem>> getItemsByCategory(PackingCategory category);
  Future<List<PackingItem>> getItemsByDestination(String destinationId);
  Future<List<PackingItem>> getTemplateItems({String language});
  Future<List<PackingItem>> searchItems(String query);
  Future<PackingItem?> getItemById(String id);
  Future<String> createItem(PackingItem item);
  Future<void> updateItem(PackingItem item);
  Future<void> deleteItem(String id);
  Future<Map<String, dynamic>> getPackingStatistics();
  Future<Map<String, dynamic>> getPackingStatisticsByDestination(
      String destinationId);
  Future<void> toggleItemPacked(String id);
}
