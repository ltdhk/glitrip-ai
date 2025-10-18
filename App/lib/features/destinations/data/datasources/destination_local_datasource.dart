import '../../../../core/database/database_helper.dart';
import '../models/destination_model.dart';

abstract class DestinationLocalDataSource {
  Future<List<DestinationModel>> getAllDestinations();
  Future<List<DestinationModel>> getDestinationsByStatus(String status);
  Future<List<DestinationModel>> searchDestinations(String query);
  Future<DestinationModel?> getDestinationById(String id);
  Future<String> insertDestination(DestinationModel destination);
  Future<int> updateDestination(DestinationModel destination);
  Future<int> deleteDestination(String id);
  Future<Map<String, int>> getDestinationStatistics();
}

class DestinationLocalDataSourceImpl implements DestinationLocalDataSource {
  final DatabaseHelper _databaseHelper;

  DestinationLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<DestinationModel>> getAllDestinations() async {
    final maps = await _databaseHelper.query(
      'destinations',
      orderBy: 'updated_at DESC',
    );
    final destinations = <DestinationModel>[];
    for (var map in maps) {
      final destination = DestinationModel.fromMap(map);
      final buddyIds = await _getTravelBuddyIds(destination.id);
      destinations.add(destination.copyWith(travelBuddyIds: buddyIds));
    }
    return destinations;
  }

  Future<List<String>> _getTravelBuddyIds(String destinationId) async {
    final maps = await _databaseHelper.query(
      'destination_buddies',
      columns: ['buddy_id'],
      where: 'destination_id = ?',
      whereArgs: [destinationId],
    );
    return maps.map((map) => map['buddy_id'] as String).toList();
  }

  @override
  Future<List<DestinationModel>> getDestinationsByStatus(String status) async {
    final maps = await _databaseHelper.query(
      'destinations',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'updated_at DESC',
    );
    final destinations = <DestinationModel>[];
    for (var map in maps) {
      final destination = DestinationModel.fromMap(map);
      final buddyIds = await _getTravelBuddyIds(destination.id);
      destinations.add(destination.copyWith(travelBuddyIds: buddyIds));
    }
    return destinations;
  }

  @override
  Future<List<DestinationModel>> searchDestinations(String query) async {
    final maps = await _databaseHelper.query(
      'destinations',
      where: 'name LIKE ? OR country LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'updated_at DESC',
    );
    final destinations = <DestinationModel>[];
    for (var map in maps) {
      final destination = DestinationModel.fromMap(map);
      final buddyIds = await _getTravelBuddyIds(destination.id);
      destinations.add(destination.copyWith(travelBuddyIds: buddyIds));
    }
    return destinations;
  }

  @override
  Future<DestinationModel?> getDestinationById(String id) async {
    final maps = await _databaseHelper.query(
      'destinations',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    final destination = DestinationModel.fromMap(maps.first);
    final buddyIds = await _getTravelBuddyIds(destination.id);
    return destination.copyWith(travelBuddyIds: buddyIds);
  }

  @override
  Future<String> insertDestination(DestinationModel destination) async {
    await _databaseHelper.insert('destinations', destination.toMap());
    await _saveTravelBuddyAssociations(
        destination.id, destination.travelBuddyIds);
    return destination.id;
  }

  Future<void> _saveTravelBuddyAssociations(
      String destinationId, List<String> buddyIds) async {
    // 先删除旧的关联
    await _databaseHelper.delete(
      'destination_buddies',
      where: 'destination_id = ?',
      whereArgs: [destinationId],
    );
    // 插入新的关联
    for (var buddyId in buddyIds) {
      await _databaseHelper.insert('destination_buddies', {
        'destination_id': destinationId,
        'buddy_id': buddyId,
      });
    }
  }

  @override
  Future<int> updateDestination(DestinationModel destination) async {
    await _saveTravelBuddyAssociations(
        destination.id, destination.travelBuddyIds);
    return await _databaseHelper.update(
      'destinations',
      destination.toMap(),
      where: 'id = ?',
      whereArgs: [destination.id],
    );
  }

  @override
  Future<int> deleteDestination(String id) async {
    return await _databaseHelper.delete(
      'destinations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Map<String, int>> getDestinationStatistics() async {
    final totalResult = await _databaseHelper.rawQuery(
      'SELECT COUNT(*) as count FROM destinations',
    );
    final visitedResult = await _databaseHelper.rawQuery(
      'SELECT COUNT(*) as count FROM destinations WHERE status = ?',
      ['visited'],
    );
    final plannedResult = await _databaseHelper.rawQuery(
      'SELECT COUNT(*) as count FROM destinations WHERE status = ?',
      ['planned'],
    );
    final wishlistResult = await _databaseHelper.rawQuery(
      'SELECT COUNT(*) as count FROM destinations WHERE status = ?',
      ['wishlist'],
    );

    return {
      'total': totalResult.first['count'] as int,
      'visited': visitedResult.first['count'] as int,
      'planned': plannedResult.first['count'] as int,
      'wishlist': wishlistResult.first['count'] as int,
    };
  }
}
