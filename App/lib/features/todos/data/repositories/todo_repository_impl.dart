import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../models/todo_model.dart';

/// Todo Repository Implementation
class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource dataSource;

  TodoRepositoryImpl(this.dataSource);

  @override
  Future<List<Todo>> getTodosByDestination(String destinationId) async {
    final models = await dataSource.getTodosByDestination(destinationId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Todo>> getTodosByCategory(
    String destinationId,
    TodoCategory category,
  ) async {
    final models = await dataSource.getTodosByCategory(destinationId, category);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Todo>> getTodosByStatus(
    String destinationId,
    bool isCompleted,
  ) async {
    final models = await dataSource.getTodosByStatus(destinationId, isCompleted);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Todo?> getTodoById(String id) async {
    final model = await dataSource.getTodoById(id);
    return model?.toEntity();
  }

  @override
  Future<void> addTodo(Todo todo) async {
    final model = TodoModel.fromEntity(todo);
    await dataSource.insertTodo(model);
  }

  @override
  Future<void> addTodos(List<Todo> todos) async {
    final models = todos.map((todo) => TodoModel.fromEntity(todo)).toList();
    await dataSource.insertTodos(models);
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final model = TodoModel.fromEntity(todo);
    await dataSource.updateTodo(model);
  }

  @override
  Future<void> toggleTodoCompletion(String id) async {
    await dataSource.toggleTodoCompletion(id);
  }

  @override
  Future<void> deleteTodo(String id) async {
    await dataSource.deleteTodo(id);
  }

  @override
  Future<void> deleteTodosByDestination(String destinationId) async {
    await dataSource.deleteTodosByDestination(destinationId);
  }

  @override
  Future<Map<String, int>> getTodoStats(String destinationId) async {
    return await dataSource.getTodoStats(destinationId);
  }

  @override
  Future<Map<String, int>> getTodoCountByCategory(String destinationId) async {
    return await dataSource.getTodoCountByCategory(destinationId);
  }

  @override
  Future<List<Todo>> getOverdueTodos(String destinationId) async {
    final models = await dataSource.getOverdueTodos(destinationId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Todo>> getUpcomingTodos(String destinationId) async {
    final models = await dataSource.getUpcomingTodos(destinationId);
    return models.map((model) => model.toEntity()).toList();
  }
}
