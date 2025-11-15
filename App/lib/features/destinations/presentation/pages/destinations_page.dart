import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import '../../domain/entities/destination.dart';
import '../providers/destinations_provider.dart';
import '../widgets/destination_card.dart';
import '../widgets/destination_search_bar.dart';
import '../widgets/destination_status_tabs.dart';
import 'add_destination_page.dart';
import 'ai_create_destination_page.dart';

class DestinationsPage extends ConsumerStatefulWidget {
  const DestinationsPage({super.key});

  @override
  ConsumerState<DestinationsPage> createState() => _DestinationsPageState();
}

class _DestinationsPageState extends ConsumerState<DestinationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<DestinationStatus> _statusTabs = [
    DestinationStatus.wishlist,
    DestinationStatus.planned,
    DestinationStatus.visited,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final searchQuery = ref.watch(destinationSearchQueryProvider);
    final selectedStatus = ref.watch(selectedDestinationStatusProvider);
    final statsAsync = ref.watch(destinationStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.travel,
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
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.add, size: 24, color: Colors.white),
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'manual') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddDestinationPage(),
                    ),
                  );
                } else if (value == 'ai') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AICreateDestinationPage(),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'ai',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF00BCD4),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI智能创建',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '让AI帮你规划行程',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'manual',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '手动创建',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '自己填写详细信息',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: DestinationSearchBar(),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: l10n.all),
                  Tab(text: l10n.visited),
                  Tab(text: l10n.planned),
                  Tab(text: l10n.wishlist),
                ],
                onTap: (index) {
                  if (index == 0) {
                    ref.read(selectedDestinationStatusProvider.notifier).state =
                        null;
                  } else {
                    ref.read(selectedDestinationStatusProvider.notifier).state =
                        _statusTabs[index - 1];
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllDestinations(searchQuery),
          _buildDestinationsByStatus(DestinationStatus.visited, searchQuery),
          _buildDestinationsByStatus(DestinationStatus.planned, searchQuery),
          _buildDestinationsByStatus(DestinationStatus.wishlist, searchQuery),
        ],
      ),
    );
  }

  Widget _buildAllDestinations(String searchQuery) {
    if (searchQuery.isNotEmpty) {
      return _buildSearchResults(searchQuery);
    }
    final l10n = AppLocalizations.of(context)!;
    return Consumer(
      builder: (context, ref, child) {
        final destinationsAsync = ref.watch(destinationsProvider);

        return destinationsAsync.when(
          data: (destinations) {
            if (destinations.isEmpty) {
              return _buildEmptyState();
            }
            return _buildDestinationsList(destinations);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(destinationsProvider),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDestinationsByStatus(
      DestinationStatus status, String searchQuery) {
    if (searchQuery.isNotEmpty) {
      return _buildSearchResults(searchQuery);
    }
    final l10n = AppLocalizations.of(context)!;
    return Consumer(
      builder: (context, ref, child) {
        final destinationsAsync =
            ref.watch(destinationsByStatusProvider(status));

        return destinationsAsync.when(
          data: (destinations) {
            if (destinations.isEmpty) {
              return _buildEmptyStateForStatus(status);
            }
            return _buildDestinationsList(destinations);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.refresh(destinationsByStatusProvider(status)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(String query) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer(
      builder: (context, ref, child) {
        final searchResultsAsync = ref.watch(searchDestinationsProvider(query));

        return searchResultsAsync.when(
          data: (destinations) {
            if (destinations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(l10n.noSearchResults(query)),
                  ],
                ),
              );
            }
            return _buildDestinationsList(destinations);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(l10n.searchError(error.toString())),
          ),
        );
      },
    );
  }

  Widget _buildDestinationsList(List<Destination> destinations) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(destinationsProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: destinations.length,
        itemBuilder: (context, index) {
          final destination = destinations[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: DestinationCard(destination: destination),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(destinationsProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.flight_takeoff,
                  size: 120,
                  color: Color(0xFF00BCD4),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.noDestinationsYet,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.startPlanningNextAdventure,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AICreateDestinationPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addFirstDestination),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateForStatus(DestinationStatus status) {
    final l10n = AppLocalizations.of(context)!;
    String statusText = '';
    IconData statusIcon = Icons.flight_takeoff;

    switch (status) {
      case DestinationStatus.visited:
        statusText = l10n.visited;
        statusIcon = Icons.check_circle;
        break;
      case DestinationStatus.planned:
        statusText = l10n.planned;
        statusIcon = Icons.schedule;
        break;
      case DestinationStatus.wishlist:
        statusText = l10n.wishlist;
        statusIcon = Icons.star;
        break;
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(destinationsByStatusProvider(status));
        ref.invalidate(destinationsProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  statusIcon,
                  size: 120,
                  color: const Color(0xFF00BCD4),
                ),
                const SizedBox(height: 24),
                Text(
                  'No $statusText yet',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.startPlanningNextAdventure,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
