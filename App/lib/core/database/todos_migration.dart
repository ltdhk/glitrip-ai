/// Todos Table Migration
///
/// 为AI生成的待办事项创建表

import 'package:sqflite/sqflite.dart';

class TodosMigration {
  /// 创建todos表的SQL
  static const String createTableSql = '''
    CREATE TABLE IF NOT EXISTS todos (
      id TEXT PRIMARY KEY,
      destination_id TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT,
      category TEXT CHECK (category IN ('passport', 'idCard', 'visa', 'insurance', 'ticket', 'hotel', 'carRental', 'other')),
      priority TEXT CHECK (priority IN ('high', 'medium', 'low')),
      is_completed INTEGER NOT NULL DEFAULT 0,
      deadline TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (destination_id) REFERENCES destinations (id) ON DELETE CASCADE
    )
  ''';

  /// 添加category字段的迁移SQL（用于更新现有表）
  static const String addCategoryColumnSql = '''
    ALTER TABLE todos ADD COLUMN category TEXT CHECK (category IN ('passport', 'idCard', 'visa', 'insurance', 'ticket', 'hotel', 'carRental', 'other'))
  ''';

  /// 执行迁移
  static Future<void> migrate(Database db) async {
    await db.execute(createTableSql);
  }

  /// 添加category字段（用于更新现有数据库）
  static Future<void> addCategoryColumn(Database db) async {
    try {
      // 检查category字段是否已存在
      final columns = await db.rawQuery('PRAGMA table_info(todos)');
      final hasCategoryColumn = columns.any((col) => col['name'] == 'category');

      if (!hasCategoryColumn) {
        await db.execute(addCategoryColumnSql);
      }
    } catch (e) {
      print('Error adding category column: $e');
      // 忽略错误，字段可能已存在
    }
  }

  /// 检查表是否存在
  static Future<bool> tableExists(Database db) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='todos'",
    );
    return result.isNotEmpty;
  }
}
