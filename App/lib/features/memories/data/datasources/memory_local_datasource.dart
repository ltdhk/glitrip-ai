import 'package:flutter/foundation.dart';
import '../../../../core/database/database_helper.dart';
import '../models/memory_model.dart';

class MemoryLocalDataSource {
  final DatabaseHelper _dbHelper;

  MemoryLocalDataSource(this._dbHelper);

  Future<List<TravelMemoryModel>> getAllMemories() async {
    try {
      final results = await _dbHelper.query(
        'memories',
        orderBy: 'date DESC',
      );

      return results.map((json) => TravelMemoryModel.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('获取所有回忆时出错: $e');
      }
      return [];
    }
  }

  Future<List<TravelMemoryModel>> getMemoriesByDestination(
      String destinationId) async {
    try {
      final results = await _dbHelper.query(
        'memories',
        where: 'destination_id = ?',
        whereArgs: [destinationId],
        orderBy: 'date DESC',
      );

      return results.map((json) => TravelMemoryModel.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('获取目的地回忆时出错: $e');
      }
      return [];
    }
  }

  Future<TravelMemoryModel?> getMemoryById(String id) async {
    try {
      final results = await _dbHelper.query(
        'memories',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isNotEmpty) {
        return TravelMemoryModel.fromJson(results.first);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('获取回忆详情时出错: $e');
      }
      return null;
    }
  }

  Future<void> insertMemory(TravelMemoryModel memory) async {
    try {
      await _dbHelper.insert('memories', memory.toJson());
      if (kDebugMode) {
        print('回忆已插入: ${memory.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('插入回忆时出错: $e');
      }
      rethrow;
    }
  }

  Future<void> updateMemory(TravelMemoryModel memory) async {
    try {
      await _dbHelper.update(
        'memories',
        memory.toJson(),
        where: 'id = ?',
        whereArgs: [memory.id],
      );
      if (kDebugMode) {
        print('回忆已更新: ${memory.title}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('更新回忆时出错: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteMemory(String id) async {
    try {
      await _dbHelper.delete(
        'memories',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (kDebugMode) {
        print('回忆已删除: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('删除回忆时出错: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteMemoriesByDestination(String destinationId) async {
    try {
      await _dbHelper.delete(
        'memories',
        where: 'destination_id = ?',
        whereArgs: [destinationId],
      );
      if (kDebugMode) {
        print('目的地的所有回忆已删除: $destinationId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('删除目的地回忆时出错: $e');
      }
      rethrow;
    }
  }
}
