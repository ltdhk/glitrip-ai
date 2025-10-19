import '../entities/todo.dart';

/// Todo Repository Interface
abstract class TodoRepository {
  /// Get all todos for a destination
  Future<List<Todo>> getTodosByDestination(String destinationId);

  /// Get todos by destination and category
  Future<List<Todo>> getTodosByCategory(
    String destinationId,
    TodoCategory category,
  );

  /// Get todos by completion status
  Future<List<Todo>> getTodosByStatus(
    String destinationId,
    bool isCompleted,
  );

  /// Get a single todo by ID
  Future<Todo?> getTodoById(String id);

  /// Add a new todo
  Future<void> addTodo(Todo todo);

  /// Add multiple todos (batch operation)
  Future<void> addTodos(List<Todo> todos);

  /// Update a todo
  Future<void> updateTodo(Todo todo);

  /// Toggle todo completion status
  Future<void> toggleTodoCompletion(String id);

  /// Delete a todo
  Future<void> deleteTodo(String id);

  /// Delete all todos for a destination
  Future<void> deleteTodosByDestination(String destinationId);

  /// Get todo statistics for a destination
  Future<Map<String, int>> getTodoStats(String destinationId);

  /// Get todo count by category
  Future<Map<String, int>> getTodoCountByCategory(String destinationId);

  /// Get overdue todos
  Future<List<Todo>> getOverdueTodos(String destinationId);

  /// Get upcoming todos (deadline within next 7 days)
  Future<List<Todo>> getUpcomingTodos(String destinationId);
}
