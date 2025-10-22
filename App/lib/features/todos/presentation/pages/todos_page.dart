import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../destinations/domain/entities/destination.dart';
import '../../../destinations/presentation/providers/destinations_provider.dart';
import '../providers/todo_providers.dart';
import 'destination_todos_page.dart';
import 'add_edit_todo_page.dart';

class TodosPage extends ConsumerStatefulWidget {
  const TodosPage({super.key});

  @override
  ConsumerState<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends ConsumerState<TodosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(destinationStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.todos,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            statsAsync.when(
              data: (stats) => Text(
                l10n.destinationsTotal(stats['total'] ?? 0),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, size: 24),
              onPressed: () => _showAddTodoOptions(context, l10n),
              tooltip: l10n.addTodo,
            ),
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Column(
          children: [
            // TabBar
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flight_takeoff, size: 16),
                      const SizedBox(width: 4),
                      Text(l10n.currentTodoTrips),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, size: 16),
                      const SizedBox(width: 4),
                      Text(l10n.completedTodos),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.list, size: 16),
                      const SizedBox(width: 4),
                      Text(l10n.allTodos),
                    ],
                  ),
                ),
              ],
            ),
            // TabBarView
            Expanded(
              child: Container(
                color: Colors.white,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCurrentTripsTab(l10n),
                    _buildCompletedTab(l10n),
                    _buildAllTab(l10n),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTripsTab(AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final destinationsAsync =
            ref.watch(destinationsByStatusProvider(DestinationStatus.planned));

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(destinationsByStatusProvider(DestinationStatus.planned));
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: destinationsAsync.when(
            data: (destinations) {
              if (destinations.isEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: _buildEmptyState(
                      l10n,
                      Icons.flight_takeoff,
                      l10n.noPlannedDestinations,
                      l10n.createDestinationPrompt,
                    ),
                  ),
                );
              }
              return _buildDestinationsList(destinations, l10n);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('${l10n.error}: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(
                          destinationsByStatusProvider(DestinationStatus.planned),
                        ),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletedTab(AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final destinationsAsync =
            ref.watch(destinationsByStatusProvider(DestinationStatus.visited));

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(destinationsByStatusProvider(DestinationStatus.visited));
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: destinationsAsync.when(
            data: (destinations) {
              if (destinations.isEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: _buildEmptyState(
                      l10n,
                      Icons.check_circle_outline,
                      l10n.noCompletedTrips,
                      l10n.completeFirstTrip,
                    ),
                  ),
                );
              }
              return _buildDestinationsList(destinations, l10n);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('${l10n.error}: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(
                          destinationsByStatusProvider(DestinationStatus.visited),
                        ),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllTab(AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final destinationsAsync = ref.watch(destinationsProvider);

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(destinationsProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: destinationsAsync.when(
            data: (destinations) {
              if (destinations.isEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: _buildEmptyState(
                      l10n,
                      Icons.explore_off,
                      l10n.noDestinations,
                      l10n.createFirstDestination,
                    ),
                  ),
                );
              }
              return _buildDestinationsList(destinations, l10n);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('${l10n.error}: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(destinationsProvider),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDestinationsList(
      List<Destination> destinations, AppLocalizations l10n) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final destination = destinations[index];
        return _buildDestinationCard(destination, l10n);
      },
    );
  }

  Widget _buildDestinationCard(Destination destination, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final statsAsync = ref.watch(todoStatsProvider(destination.id));

        return GestureDetector(
          onTap: () => _navigateToDestinationTodos(destination),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(destination.status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getStatusIcon(destination.status),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destination.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  destination.country,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  if (destination.startDate != null ||
                      destination.endDate != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateRange(
                              destination.startDate, destination.endDate, l10n),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Stats Row
                  statsAsync.when(
                    data: (stats) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatChip(
                          l10n.totalTodos,
                          stats['total']?.toString() ?? '0',
                          Icons.format_list_bulleted,
                          Colors.blue,
                        ),
                        _buildStatChip(
                          l10n.completedCount,
                          stats['completed']?.toString() ?? '0',
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _buildStatChip(
                          l10n.pendingCount,
                          stats['pending']?.toString() ?? '0',
                          Icons.pending,
                          Colors.orange,
                        ),
                        _buildStatChip(
                          l10n.priorityHigh,
                          stats['highPriority']?.toString() ?? '0',
                          Icons.priority_high,
                          Colors.red,
                        ),
                      ],
                    ),
                    loading: () => const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    AppLocalizations l10n,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DestinationStatus status) {
    switch (status) {
      case DestinationStatus.planned:
        return Colors.blue;
      case DestinationStatus.visited:
        return Colors.green;
      case DestinationStatus.wishlist:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(DestinationStatus status) {
    switch (status) {
      case DestinationStatus.planned:
        return Icons.event;
      case DestinationStatus.visited:
        return Icons.check_circle;
      case DestinationStatus.wishlist:
        return Icons.favorite;
    }
  }

  String _formatDateRange(
      DateTime? startDate, DateTime? endDate, AppLocalizations l10n) {
    if (startDate == null && endDate == null) return '';
    if (startDate == null) return '~ ${_formatDate(endDate!)}';
    if (endDate == null) return '${_formatDate(startDate)} ~';
    return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  void _navigateToDestinationTodos(Destination destination) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DestinationTodosPage(destination: destination),
      ),
    );
  }

  void _showAddTodoOptions(BuildContext context, AppLocalizations l10n) async {
    // 获取计划中的目的地列表
    final destinationsAsync = ref.read(destinationsByStatusProvider(DestinationStatus.planned));

    destinationsAsync.whenOrNull(
      data: (destinations) {
        if (destinations.isEmpty) {
          // 如果没有计划中的目的地，提示用户先创建目的地
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.createDestinationPrompt),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return;
        }

        // 显示目的地选择对话框
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.selectDestination),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final destination = destinations[index];
                  return ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(destination.name),
                    subtitle: Text(destination.country),
                    onTap: () {
                      Navigator.of(context).pop();
                      _navigateToAddTodo(destination);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        );
      },
      error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
    );
  }

  Future<void> _navigateToAddTodo(Destination destination) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditTodoPage(
          destinationId: destination.id,
        ),
      ),
    );

    if (result == true && mounted) {
      // 刷新列表
      ref.invalidate(destinationsByStatusProvider(DestinationStatus.planned));
    }
  }
}
