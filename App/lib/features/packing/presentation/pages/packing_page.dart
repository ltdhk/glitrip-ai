import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import '../../domain/entities/packing_item.dart';
import '../providers/packing_provider.dart';
import '../../../destinations/domain/entities/destination.dart';
import '../../../destinations/presentation/providers/destinations_provider.dart';
import 'add_packing_item_page.dart';
import 'destination_packing_page.dart';

class PackingPage extends ConsumerStatefulWidget {
  const PackingPage({super.key});

  @override
  ConsumerState<PackingPage> createState() => _PackingPageState();
}

class _PackingPageState extends ConsumerState<PackingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 当前行程、模板、历史
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
              l10n.packing,
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
        backgroundColor: Colors.purple,
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
              onPressed: () {
                // 根据当前标签页决定创建什么类型的物品
                final currentIndex = _tabController.index;
                if (currentIndex == 1) {
                  // 模板标签页，创建模板物品
                  _navigateToAddTemplateItem();
                } else {
                  // 其他标签页，显示选择对话框
                  _showAddItemOptions();
                }
              },
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.purple,
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
                      Flexible(
                        child: Text(
                          l10n.currentTrips,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bookmark, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          l10n.templates,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          l10n.history,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
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
                    _buildTemplatesTab(l10n),
                    _buildHistoryTab(l10n),
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

        return destinationsAsync.when(
          data: (destinations) {
            if (destinations.isEmpty) {
              return _buildEmptyCurrentTrips(l10n);
            }
            return _buildDestinationsList(destinations, l10n,
                isCurrentTrip: true);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        );
      },
    );
  }

  Widget _buildTemplatesTab(AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final templatesAsync = ref.watch(templateItemsProvider);

        return templatesAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return _buildEmptyTemplates(l10n);
            }
            return _buildTemplatesList(items, l10n);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final destinationsAsync =
            ref.watch(destinationsByStatusProvider(DestinationStatus.visited));

        return destinationsAsync.when(
          data: (destinations) {
            if (destinations.isEmpty) {
              return _buildEmptyHistory(l10n);
            }
            return _buildDestinationsList(destinations, l10n,
                isCurrentTrip: false);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        );
      },
    );
  }

  Widget _buildDestinationsList(
      List<Destination> destinations, AppLocalizations l10n,
      {required bool isCurrentTrip}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final destination = destinations[index];
        return _buildDestinationCard(destination, l10n, isCurrentTrip);
      },
    );
  }

  Widget _buildDestinationCard(
      Destination destination, AppLocalizations l10n, bool isCurrentTrip) {
    return Consumer(
      builder: (context, ref, child) {
        final statsAsync =
            ref.watch(packingStatsByDestinationProvider(destination.id));

        return Container(
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
                          Text(
                            destination.country,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    statsAsync.when(
                      data: (stats) {
                        final progress = stats['progress'] as int;
                        final total = stats['total'] as int;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(destination.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            total == 0
                                ? '0 items'
                                : '$progress% (${stats['packed']}/$total)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      error: (_, __) => const Text('--'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 打包进度条
                statsAsync.when(
                  data: (stats) {
                    final progress = stats['progress'] as int;
                    final total = stats['total'] as int;
                    final packed = stats['packed'] as int;
                    final progressValue = total > 0 ? progress / 100.0 : 0.0;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.packingProgress,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '$packed/$total ${l10n.items}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getStatusColor(destination.status),
                          ),
                          minHeight: 6,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$progress% ${l10n.completed}',
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStatusColor(destination.status),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  _navigateToDestinationPacking(destination),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(destination.status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  l10n.viewPacking,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTemplatesList(List<PackingItem> items, AppLocalizations l10n) {
    // 按类别分组
    final Map<PackingCategory, List<PackingItem>> groupedItems = {};
    for (final item in items) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final category = groupedItems.keys.elementAt(index);
        final categoryItems = groupedItems[category]!;

        return Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(category),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getCategoryDisplayName(category, l10n),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${categoryItems.length} items',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.grey.shade200,
              ),
              ...categoryItems
                  .map((item) => _buildTemplateItemTile(item, l10n, ref)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTemplateItemTile(
      PackingItem item, AppLocalizations l10n, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.bookmark_border,
            color: Colors.grey.shade400,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                if (item.quantity > 1)
                  Text(
                    '${l10n.quantity}: ${item.quantity}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
          if (item.isEssential)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red, width: 0.5),
              ),
              child: Text(
                l10n.essential,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (item.quantity > 1)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'x${item.quantity}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editTemplateItem(item);
                  break;
                case 'delete':
                  _deleteTemplateItem(item, l10n, ref);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 16),
                    const SizedBox(width: 8),
                    Text(l10n.edit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 16, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.delete,
                        style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCurrentTrips(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.flight_takeoff,
            size: 120,
            color: Colors.purple,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noCurrentTrips,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.planTripToStartPacking,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTemplates(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bookmark,
            size: 120,
            color: Colors.purple,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noTemplatesYet,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.createTemplateToReuse,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history,
            size: 120,
            color: Colors.purple,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noCompletedTrips,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.completedTripsWillAppearHere,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(Destination destination) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddPackingItemPage(destinationId: destination.id),
      ),
    );
  }

  void _navigateToDestinationPacking(Destination destination) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DestinationPackingPage(destination: destination),
      ),
    );
  }

  void _editTemplateItem(PackingItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddPackingItemPage(item: item),
      ),
    );
  }

  void _deleteTemplateItem(
      PackingItem item, AppLocalizations l10n, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTemplateItem),
        content: Text(l10n.deleteTemplateItemConfirm(item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref
                    .read(templateItemsProvider.notifier)
                    .deleteItem(item.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.templateItemDeletedSuccessfully),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.errorDeletingItem(e.toString())),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _navigateToAddTemplateItem() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddPackingItemPage(isTemplate: true),
      ),
    );
  }

  void _showAddItemOptions() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add, color: Colors.purple),
              title: Text(l10n.addToDestination),
              subtitle: Text(l10n.addItemToSpecificDestination),
              onTap: () {
                Navigator.of(context).pop();
                _showDestinationSelection();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_add, color: Colors.orange),
              title: Text(l10n.addToTemplate),
              subtitle: Text(l10n.addItemToTemplate),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToAddTemplateItem();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDestinationSelection() {
    final l10n = AppLocalizations.of(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddPackingItemPage(),
      ),
    );
  }

  Color _getStatusColor(DestinationStatus status) {
    switch (status) {
      case DestinationStatus.planned:
        return Colors.orange;
      case DestinationStatus.visited:
        return Colors.green;
      case DestinationStatus.wishlist:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(DestinationStatus status) {
    switch (status) {
      case DestinationStatus.planned:
        return Icons.schedule;
      case DestinationStatus.visited:
        return Icons.check_circle;
      case DestinationStatus.wishlist:
        return Icons.favorite;
    }
  }

  String _getCategoryDisplayName(
      PackingCategory category, AppLocalizations l10n) {
    switch (category) {
      case PackingCategory.clothing:
        return l10n.clothing;
      case PackingCategory.electronics:
        return l10n.electronics;
      case PackingCategory.cosmetics:
        return l10n.cosmetics;
      case PackingCategory.health:
        return l10n.health;
      case PackingCategory.accessories:
        return l10n.accessories;
      case PackingCategory.books:
        return l10n.books;
      case PackingCategory.entertainment:
        return l10n.entertainment;
      case PackingCategory.other:
        return l10n.other;
    }
  }

  IconData _getCategoryIcon(PackingCategory category) {
    switch (category) {
      case PackingCategory.clothing:
        return Icons.checkroom;
      case PackingCategory.electronics:
        return Icons.devices;
      case PackingCategory.cosmetics:
        return Icons.palette;
      case PackingCategory.health:
        return Icons.medical_services;
      case PackingCategory.accessories:
        return Icons.watch;
      case PackingCategory.books:
        return Icons.book;
      case PackingCategory.entertainment:
        return Icons.games;
      case PackingCategory.other:
        return Icons.category;
    }
  }

  Color _getCategoryColor(PackingCategory category) {
    switch (category) {
      case PackingCategory.clothing:
        return Colors.blue;
      case PackingCategory.electronics:
        return Colors.orange;
      case PackingCategory.cosmetics:
        return Colors.pink;
      case PackingCategory.health:
        return Colors.green;
      case PackingCategory.accessories:
        return Colors.purple;
      case PackingCategory.books:
        return Colors.brown;
      case PackingCategory.entertainment:
        return Colors.red;
      case PackingCategory.other:
        return Colors.grey;
    }
  }
}
