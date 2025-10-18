import '../../../../core/database/database_helper.dart';
import '../models/packing_item_model.dart';

abstract class PackingLocalDataSource {
  Future<List<PackingItemModel>> getAllItems();
  Future<List<PackingItemModel>> getItemsByCategory(String category);
  Future<List<PackingItemModel>> getItemsByDestination(String destinationId);
  Future<List<PackingItemModel>> getTemplateItems(
      {String language}); // 获取模板物品（destinationId为null）
  Future<List<PackingItemModel>> searchItems(String query);
  Future<PackingItemModel?> getItemById(String id);
  Future<String> insertItem(PackingItemModel item);
  Future<int> updateItem(PackingItemModel item);
  Future<int> deleteItem(String id);
  Future<Map<String, dynamic>> getPackingStatistics();
  Future<Map<String, dynamic>> getPackingStatisticsByDestination(
      String destinationId);
  Future<int> toggleItemPacked(String id);
}

class PackingLocalDataSourceImpl implements PackingLocalDataSource {
  final DatabaseHelper _databaseHelper;

  PackingLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<PackingItemModel>> getAllItems() async {
    final maps = await _databaseHelper.query(
      'packing_items',
      orderBy: 'category, name',
    );
    return maps.map((map) => PackingItemModel.fromMap(map)).toList();
  }

  @override
  Future<List<PackingItemModel>> getItemsByCategory(String category) async {
    final maps = await _databaseHelper.query(
      'packing_items',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name',
    );
    return maps.map((map) => PackingItemModel.fromMap(map)).toList();
  }

  @override
  Future<List<PackingItemModel>> getItemsByDestination(
      String destinationId) async {
    final maps = await _databaseHelper.query(
      'packing_items',
      where: 'destination_id = ?',
      whereArgs: [destinationId],
      orderBy: 'category, name',
    );
    return maps.map((map) => PackingItemModel.fromMap(map)).toList();
  }

  @override
  Future<List<PackingItemModel>> getTemplateItems(
      {String language = 'zh'}) async {
    final maps = await _databaseHelper.query(
      'packing_items',
      where: 'destination_id IS NULL AND language = ?',
      whereArgs: [language],
      orderBy: 'category, name',
    );
    return maps.map((map) => PackingItemModel.fromMap(map)).toList();
  }

  @override
  Future<List<PackingItemModel>> searchItems(String query) async {
    final maps = await _databaseHelper.query(
      'packing_items',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'category, name',
    );
    return maps.map((map) => PackingItemModel.fromMap(map)).toList();
  }

  @override
  Future<PackingItemModel?> getItemById(String id) async {
    final maps = await _databaseHelper.query(
      'packing_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return PackingItemModel.fromMap(maps.first);
  }

  @override
  Future<String> insertItem(PackingItemModel item) async {
    await _databaseHelper.insert('packing_items', item.toMap());
    return item.id;
  }

  @override
  Future<int> updateItem(PackingItemModel item) async {
    return await _databaseHelper.update(
      'packing_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<int> deleteItem(String id) async {
    return await _databaseHelper.delete(
      'packing_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Map<String, dynamic>> getPackingStatistics() async {
    final totalResult = await _databaseHelper.rawQuery(
      'SELECT COUNT(*) as count FROM packing_items',
    );
    final packedResult = await _databaseHelper.rawQuery(
      'SELECT COUNT(*) as count FROM packing_items WHERE is_packed = 1',
    );

    final total = totalResult.first['count'] as int;
    final packed = packedResult.first['count'] as int;
    final progress = total > 0 ? (packed / total * 100).round() : 0;

    return {
      'total': total,
      'packed': packed,
      'progress': progress,
    };
  }

  @override
  Future<Map<String, dynamic>> getPackingStatisticsByDestination(
      String destinationId) async {
    final totalResult = await _databaseHelper.rawQuery(
      'SELECT COUNT(*) as count FROM packing_items WHERE destination_id = ?',
      [destinationId],
    );
    final packedResult = await _databaseHelper.rawQuery(
      'SELECT COUNT(*) as count FROM packing_items WHERE destination_id = ? AND is_packed = 1',
      [destinationId],
    );

    final total = totalResult.first['count'] as int;
    final packed = packedResult.first['count'] as int;
    final progress = total > 0 ? (packed / total * 100).round() : 0;

    return {
      'total': total,
      'packed': packed,
      'progress': progress,
    };
  }

  @override
  Future<int> toggleItemPacked(String id) async {
    final item = await getItemById(id);
    if (item == null) return 0;

    return await _databaseHelper.update(
      'packing_items',
      {
        'is_packed': item.isPacked ? 0 : 1,
        'updated_at': DateTime.now().toIso8601String()
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
