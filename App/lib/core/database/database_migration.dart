import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

class DatabaseMigration {
  static Future<void> fixPackingItemsTable(Database db) async {
    try {
      // 检查 destination_id 列是否存在
      final result = await db.rawQuery('PRAGMA table_info(packing_items)');
      final hasDestinationId =
          result.any((column) => column['name'] == 'destination_id');

      if (!hasDestinationId) {
        // 添加 destination_id 列
        await db.execute(
            'ALTER TABLE packing_items ADD COLUMN destination_id TEXT');
        if (kDebugMode) {
          print('已添加 destination_id 列到 packing_items 表');
        }
      } else {
        if (kDebugMode) {
          print('destination_id 列已存在');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('修复 packing_items 表时出错: $e');
      }
    }
  }
}
