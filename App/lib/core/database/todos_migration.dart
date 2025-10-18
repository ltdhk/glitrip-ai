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
      priority TEXT CHECK (priority IN ('high', 'medium', 'low')),
      is_completed INTEGER NOT NULL DEFAULT 0,
      deadline TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (destination_id) REFERENCES destinations (id) ON DELETE CASCADE
    )
  ''';

  /// 执行迁移
  static Future<void> migrate(Database db) async {
    await db.execute(createTableSql);
  }

  /// 检查表是否存在
  static Future<bool> tableExists(Database db) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='todos'",
    );
    return result.isNotEmpty;
  }
}
