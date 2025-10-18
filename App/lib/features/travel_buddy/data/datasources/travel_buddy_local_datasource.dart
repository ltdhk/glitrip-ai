import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/travel_buddy_model.dart';

abstract class TravelBuddyLocalDataSource {
  Future<List<TravelBuddyModel>> getAllTravelBuddies();
  Future<TravelBuddyModel?> getTravelBuddyById(String id);
  Future<void> insertTravelBuddy(TravelBuddyModel buddy);
  Future<void> updateTravelBuddy(TravelBuddyModel buddy);
  Future<void> deleteTravelBuddy(String id);
  Future<List<TravelBuddyModel>> searchTravelBuddies(String query);
}

class TravelBuddyLocalDataSourceImpl implements TravelBuddyLocalDataSource {
  final DatabaseHelper _databaseHelper;

  TravelBuddyLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<TravelBuddyModel>> getAllTravelBuddies() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'travel_buddies',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return TravelBuddyModel.fromJson(maps[i]);
    });
  }

  @override
  Future<TravelBuddyModel?> getTravelBuddyById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'travel_buddies',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return TravelBuddyModel.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<void> insertTravelBuddy(TravelBuddyModel buddy) async {
    final db = await _databaseHelper.database;
    final buddyMap = buddy.toJson();
    buddyMap['id'] =
        buddy.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    await db.insert(
      'travel_buddies',
      buddyMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateTravelBuddy(TravelBuddyModel buddy) async {
    final db = await _databaseHelper.database;
    await db.update(
      'travel_buddies',
      buddy.toJson(),
      where: 'id = ?',
      whereArgs: [buddy.id],
    );
  }

  @override
  Future<void> deleteTravelBuddy(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('travel_buddies', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<TravelBuddyModel>> searchTravelBuddies(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'travel_buddies',
      where: 'name LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return TravelBuddyModel.fromJson(maps[i]);
    });
  }
}
