import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../data/datasources/todo_local_datasource.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../../../core/database/database_helper.dart';

// Data Source Provider
final todoLocalDataSourceProvider = FutureProvider<TodoLocalDataSource>((ref) async {
  final databaseHelper = DatabaseHelper.instance;
  final database = await databaseHelper.database;
  return TodoLocalDataSource(database);
});

// Repository Provider
final todoRepositoryProvider = FutureProvider<TodoRepository>((ref) async {
  final dataSource = await ref.watch(todoLocalDataSourceProvider.future);
  return TodoRepositoryImpl(dataSource);
});

// Todos by Destination Provider
final todosByDestinationProvider = FutureProvider.family<List<Todo>, String>(
  (ref, destinationId) async {
    final repository = await ref.watch(todoRepositoryProvider.future);
    return await repository.getTodosByDestination(destinationId);
  },
);

// Todos by Category Provider
final todosByCategoryProvider = FutureProvider.family<List<Todo>, ({String destinationId, TodoCategory category})>(
  (ref, params) async {
    final repository = await ref.watch(todoRepositoryProvider.future);
    return await repository.getTodosByCategory(params.destinationId, params.category);
  },
);

// Todos by Status Provider (completed/pending)
final todosByStatusProvider = FutureProvider.family<List<Todo>, ({String destinationId, bool isCompleted})>(
  (ref, params) async {
    final repository = await ref.watch(todoRepositoryProvider.future);
    return await repository.getTodosByStatus(params.destinationId, params.isCompleted);
  },
);

// Todo Stats Provider
final todoStatsProvider = FutureProvider.family<Map<String, int>, String>(
  (ref, destinationId) async {
    final repository = await ref.watch(todoRepositoryProvider.future);
    return await repository.getTodoStats(destinationId);
  },
);

// Todo Count by Category Provider
final todoCategoryCountProvider = FutureProvider.family<Map<String, int>, String>(
  (ref, destinationId) async {
    final repository = await ref.watch(todoRepositoryProvider.future);
    return await repository.getTodoCountByCategory(destinationId);
  },
);

// Overdue Todos Provider
final overdueTodosProvider = FutureProvider.family<List<Todo>, String>(
  (ref, destinationId) async {
    final repository = await ref.watch(todoRepositoryProvider.future);
    return await repository.getOverdueTodos(destinationId);
  },
);

// Upcoming Todos Provider
final upcomingTodosProvider = FutureProvider.family<List<Todo>, String>(
  (ref, destinationId) async {
    final repository = await ref.watch(todoRepositoryProvider.future);
    return await repository.getUpcomingTodos(destinationId);
  },
);

// Selected Category State Provider
final selectedTodoCategoryProvider = StateProvider<TodoCategory?>((ref) => null);

// Todo Notifier for managing todos
class TodoNotifier extends StateNotifier<AsyncValue<List<Todo>>> {
  final TodoRepository repository;
  final String destinationId;

  TodoNotifier(this.repository, this.destinationId)
      : super(const AsyncValue.loading()) {
    loadTodos();
  }

  Future<void> loadTodos() async {
    try {
      state = const AsyncValue.loading();
      final todos = await repository.getTodosByDestination(destinationId);
      state = AsyncValue.data(todos);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addTodo(Todo todo) async {
    try {
      await repository.addTodo(todo);
      await loadTodos();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      await repository.updateTodo(todo);
      await loadTodos();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await repository.deleteTodo(id);
      await loadTodos();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleTodoCompletion(String id) async {
    try {
      await repository.toggleTodoCompletion(id);
      await loadTodos();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Loading Todo Notifier
class _LoadingTodoNotifier extends TodoNotifier {
  _LoadingTodoNotifier(super.repository, super.destinationId) {
    state = const AsyncValue.loading();
  }

  @override
  Future<void> loadTodos() async {
    // Do nothing in loading state
  }
}

// Error Todo Notifier
class _ErrorTodoNotifier extends TodoNotifier {
  _ErrorTodoNotifier(super.repository, super.destinationId, Object error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }

  @override
  Future<void> loadTodos() async {
    // Do nothing in error state
  }
}

// Todo Notifier Provider
final todoNotifierProvider = StateNotifierProvider.family<TodoNotifier, AsyncValue<List<Todo>>, String>(
  (ref, destinationId) {
    // This is synchronous but returns a StateNotifier that loads data asynchronously
    // We'll create a placeholder repository that will be replaced when the real one is ready
    final repository = ref.watch(todoRepositoryProvider);

    return repository.when(
      data: (repo) => TodoNotifier(repo, destinationId),
      loading: () => _LoadingTodoNotifier(_PlaceholderTodoRepository(), destinationId),
      error: (error, stack) => _ErrorTodoNotifier(_PlaceholderTodoRepository(), destinationId, error, stack),
    );
  },
);

// Placeholder repository for loading state
class _PlaceholderTodoRepository implements TodoRepository {
  @override
  Future<List<Todo>> getTodosByDestination(String destinationId) async => [];

  @override
  Future<List<Todo>> getTodosByCategory(String destinationId, TodoCategory category) async => [];

  @override
  Future<List<Todo>> getTodosByStatus(String destinationId, bool isCompleted) async => [];

  @override
  Future<Todo?> getTodoById(String id) async => null;

  @override
  Future<void> addTodo(Todo todo) async {}

  @override
  Future<void> addTodos(List<Todo> todos) async {}

  @override
  Future<void> updateTodo(Todo todo) async {}

  @override
  Future<void> toggleTodoCompletion(String id) async {}

  @override
  Future<void> deleteTodo(String id) async {}

  @override
  Future<void> deleteTodosByDestination(String destinationId) async {}

  @override
  Future<Map<String, int>> getTodoStats(String destinationId) async => {};

  @override
  Future<Map<String, int>> getTodoCountByCategory(String destinationId) async => {};

  @override
  Future<List<Todo>> getOverdueTodos(String destinationId) async => [];

  @override
  Future<List<Todo>> getUpcomingTodos(String destinationId) async => [];
}
