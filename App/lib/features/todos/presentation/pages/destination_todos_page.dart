import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../domain/entities/todo.dart';
import '../providers/todo_providers.dart';
import '../../../destinations/domain/entities/destination.dart';
import '../widgets/todo_item_card.dart';
import 'add_edit_todo_page.dart';

class DestinationTodosPage extends ConsumerStatefulWidget {
  final Destination destination;

  const DestinationTodosPage({super.key, required this.destination});

  @override
  ConsumerState<DestinationTodosPage> createState() =>
      _DestinationTodosPageState();
}

class _DestinationTodosPageState extends ConsumerState<DestinationTodosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final todosAsync = ref.watch(todosByDestinationProvider(widget.destination.id));
    final statsAsync = ref.watch(todoStatsProvider(widget.destination.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.destination.name} - ${l10n.todos}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _navigateToAddTodo(context),
            icon: const Icon(Icons.add),
            tooltip: l10n.addTodo,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: const Icon(Icons.card_travel),
              text: l10n.todoCategoryPassport,
            ),
            Tab(
              icon: const Icon(Icons.badge),
              text: l10n.todoCategoryIdCard,
            ),
            Tab(
              icon: const Icon(Icons.document_scanner),
              text: l10n.todoCategoryVisa,
            ),
            Tab(
              icon: const Icon(Icons.health_and_safety),
              text: l10n.todoCategoryInsurance,
            ),
            Tab(
              icon: const Icon(Icons.flight),
              text: l10n.todoCategoryTicket,
            ),
            Tab(
              icon: const Icon(Icons.hotel),
              text: l10n.todoCategoryHotel,
            ),
            Tab(
              icon: const Icon(Icons.directions_car),
              text: l10n.todoCategoryCarRental,
            ),
            Tab(
              icon: const Icon(Icons.more_horiz),
              text: l10n.todoCategoryOther,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Stats Overview
          _buildStatsOverview(l10n, statsAsync),

          // Category Tabs Content
          Expanded(
            child: todosAsync.when(
              data: (todos) => TabBarView(
                controller: _tabController,
                children: TodoCategory.values.map((category) {
                  final categoryTodos = todos
                      .where((todo) => todo.category == category)
                      .toList();
                  return _buildCategoryTodosList(
                    context,
                    ref,
                    l10n,
                    categoryTodos,
                    category,
                  );
                }).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      '${l10n.error}: ${error.toString()}',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(
                        todosByDestinationProvider(widget.destination.id),
                      ),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTodo(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsOverview(
    AppLocalizations l10n,
    AsyncValue<Map<String, int>> statsAsync,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.todoStats,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  l10n.totalTodos,
                  stats['total']?.toString() ?? '0',
                  Icons.format_list_bulleted,
                ),
                _buildStatItem(
                  l10n.completedCount,
                  stats['completed']?.toString() ?? '0',
                  Icons.check_circle,
                ),
                _buildStatItem(
                  l10n.pendingCount,
                  stats['pending']?.toString() ?? '0',
                  Icons.pending,
                ),
                _buildStatItem(
                  l10n.highPriorityCount,
                  stats['highPriority']?.toString() ?? '0',
                  Icons.priority_high,
                ),
              ],
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (_, __) => Text(
              l10n.error,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryTodosList(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    List<Todo> todos,
    TodoCategory category,
  ) {
    if (todos.isEmpty) {
      return _buildEmptyState(l10n, category);
    }

    // Group by completion status
    final pendingTodos = todos.where((t) => !t.isCompleted).toList();
    final completedTodos = todos.where((t) => t.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Pending Todos
        if (pendingTodos.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l10n.pendingCount,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...pendingTodos.map((todo) => TodoItemCard(
                todo: todo,
                onTap: () => _navigateToEditTodo(context, todo),
                onToggleComplete: (_) => _toggleTodoCompletion(ref, todo.id),
                onDelete: () => _deleteTodo(ref, todo.id, l10n),
              )),
        ],

        // Completed Todos
        if (completedTodos.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l10n.completedCount,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
            ),
          ),
          ...completedTodos.map((todo) => TodoItemCard(
                todo: todo,
                onTap: () => _navigateToEditTodo(context, todo),
                onToggleComplete: (_) => _toggleTodoCompletion(ref, todo.id),
                onDelete: () => _deleteTodo(ref, todo.id, l10n),
              )),
        ],
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, TodoCategory category) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noTodosInCategory,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddTodo(context, category: category),
              icon: const Icon(Icons.add),
              label: Text(l10n.addTodo),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(TodoCategory category) {
    switch (category) {
      case TodoCategory.passport:
        return Icons.card_travel;
      case TodoCategory.idCard:
        return Icons.badge;
      case TodoCategory.visa:
        return Icons.document_scanner;
      case TodoCategory.insurance:
        return Icons.health_and_safety;
      case TodoCategory.ticket:
        return Icons.flight;
      case TodoCategory.hotel:
        return Icons.hotel;
      case TodoCategory.carRental:
        return Icons.directions_car;
      case TodoCategory.other:
        return Icons.more_horiz;
    }
  }

  Future<void> _navigateToAddTodo(BuildContext context,
      {TodoCategory? category}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditTodoPage(
          destinationId: widget.destination.id,
        ),
      ),
    );

    if (result == true && mounted) {
      ref.invalidate(todosByDestinationProvider(widget.destination.id));
      ref.invalidate(todoStatsProvider(widget.destination.id));
    }
  }

  Future<void> _navigateToEditTodo(BuildContext context, Todo todo) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditTodoPage(
          destinationId: widget.destination.id,
          todo: todo,
        ),
      ),
    );

    if (result == true && mounted) {
      ref.invalidate(todosByDestinationProvider(widget.destination.id));
      ref.invalidate(todoStatsProvider(widget.destination.id));
    }
  }

  Future<void> _toggleTodoCompletion(WidgetRef ref, String todoId) async {
    try {
      final repository = await ref.read(todoRepositoryProvider.future);
      await repository.toggleTodoCompletion(todoId);
      ref.invalidate(todosByDestinationProvider(widget.destination.id));
      ref.invalidate(todoStatsProvider(widget.destination.id));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).error}: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteTodo(
      WidgetRef ref, String todoId, AppLocalizations l10n) async {
    try {
      final repository = await ref.read(todoRepositoryProvider.future);
      await repository.deleteTodo(todoId);
      ref.invalidate(todosByDestinationProvider(widget.destination.id));
      ref.invalidate(todoStatsProvider(widget.destination.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deleteSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
