import 'package:sqflite/sqflite.dart';
import '../models/todo_model.dart';
import '../../domain/entities/todo.dart';

/// Todo Local Data Source
class TodoLocalDataSource {
  final Database database;

  TodoLocalDataSource(this.database);

  /// Get all todos for a destination
  Future<List<TodoModel>> getTodosByDestination(String destinationId) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'todos',
      where: 'destination_id = ?',
      whereArgs: [destinationId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => TodoModel.fromJson(map)).toList();
  }

  /// Get todos by destination and category
  Future<List<TodoModel>> getTodosByCategory(
    String destinationId,
    TodoCategory category,
  ) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'todos',
      where: 'destination_id = ? AND category = ?',
      whereArgs: [destinationId, category.value],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => TodoModel.fromJson(map)).toList();
  }

  /// Get todos by completion status
  Future<List<TodoModel>> getTodosByStatus(
    String destinationId,
    bool isCompleted,
  ) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'todos',
      where: 'destination_id = ? AND is_completed = ?',
      whereArgs: [destinationId, isCompleted ? 1 : 0],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => TodoModel.fromJson(map)).toList();
  }

  /// Get a single todo by ID
  Future<TodoModel?> getTodoById(String id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return TodoModel.fromJson(maps.first);
  }

  /// Insert a todo
  Future<void> insertTodo(TodoModel todo) async {
    await database.insert(
      'todos',
      todo.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple todos (batch operation)
  Future<void> insertTodos(List<TodoModel> todos) async {
    final batch = database.batch();
    for (final todo in todos) {
      batch.insert(
        'todos',
        todo.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Update a todo
  Future<void> updateTodo(TodoModel todo) async {
    await database.update(
      'todos',
      todo.toJson(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  /// Toggle todo completion status
  Future<void> toggleTodoCompletion(String id) async {
    final todo = await getTodoById(id);
    if (todo == null) return;

    await database.update(
      'todos',
      {
        'is_completed': todo.isCompleted ? 0 : 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a todo
  Future<void> deleteTodo(String id) async {
    await database.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all todos for a destination
  Future<void> deleteTodosByDestination(String destinationId) async {
    await database.delete(
      'todos',
      where: 'destination_id = ?',
      whereArgs: [destinationId],
    );
  }

  /// Get todo statistics for a destination
  Future<Map<String, int>> getTodoStats(String destinationId) async {
    final todos = await getTodosByDestination(destinationId);

    final total = todos.length;
    final completed = todos.where((t) => t.isCompleted).length;
    final pending = total - completed;
    final highPriority = todos.where((t) => t.priority == 'high' && !t.isCompleted).length;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'highPriority': highPriority,
    };
  }

  /// Get todo count by category for a destination
  Future<Map<String, int>> getTodoCountByCategory(String destinationId) async {
    final todos = await getTodosByDestination(destinationId);

    final Map<String, int> counts = {};
    for (final category in TodoCategory.values) {
      counts[category.value] = todos.where((t) => t.category == category.value).length;
    }

    return counts;
  }

  /// Get overdue todos
  Future<List<TodoModel>> getOverdueTodos(String destinationId) async {
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await database.query(
      'todos',
      where: 'destination_id = ? AND is_completed = 0 AND deadline < ?',
      whereArgs: [destinationId, now],
      orderBy: 'deadline ASC',
    );

    return maps.map((map) => TodoModel.fromJson(map)).toList();
  }

  /// Get upcoming todos (deadline within next 7 days)
  Future<List<TodoModel>> getUpcomingTodos(String destinationId) async {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    final List<Map<String, dynamic>> maps = await database.query(
      'todos',
      where: 'destination_id = ? AND is_completed = 0 AND deadline >= ? AND deadline <= ?',
      whereArgs: [
        destinationId,
        now.toIso8601String(),
        nextWeek.toIso8601String(),
      ],
      orderBy: 'deadline ASC',
    );

    return maps.map((map) => TodoModel.fromJson(map)).toList();
  }
}
