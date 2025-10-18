import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/destination.dart';
import '../providers/destinations_provider.dart';

class DestinationStatusTabs extends ConsumerWidget {
  final TabController tabController;

  const DestinationStatusTabs({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: const Color(0xFF00BCD4),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.all_inclusive, size: 16),
                SizedBox(width: 8),
                Text('All'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 16),
                SizedBox(width: 8),
                Text('Visited'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule, size: 16),
                SizedBox(width: 8),
                Text('Planned'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 16),
                SizedBox(width: 8),
                Text('Wishlist'),
              ],
            ),
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              ref.read(selectedDestinationStatusProvider.notifier).state = null;
              break;
            case 1:
              ref.read(selectedDestinationStatusProvider.notifier).state =
                  DestinationStatus.visited;
              break;
            case 2:
              ref.read(selectedDestinationStatusProvider.notifier).state =
                  DestinationStatus.planned;
              break;
            case 3:
              ref.read(selectedDestinationStatusProvider.notifier).state =
                  DestinationStatus.wishlist;
              break;
          }
        },
      ),
    );
  }
}
