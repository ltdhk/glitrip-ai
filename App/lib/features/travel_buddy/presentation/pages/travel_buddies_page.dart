import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import '../../domain/entities/travel_buddy.dart';
import '../providers/travel_buddy_provider.dart';
import '../widgets/travel_buddy_card.dart';
import 'add_travel_buddy_page.dart';

class TravelBuddiesPage extends ConsumerWidget {
  const TravelBuddiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final travelBuddiesAsync = ref.watch(travelBuddiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addTravelBuddy),
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTravelBuddyPage(),
            ),
          );
        },
        backgroundColor: const Color(0xFF00BCD4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: travelBuddiesAsync.when(
        data: (buddies) => _buildBuddiesList(context, buddies, l10n),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $error',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuddiesList(
      BuildContext context, List<TravelBuddy> buddies, AppLocalizations l10n) {
    if (buddies.isEmpty) {
      return _buildEmptyState(context, l10n);
    }

    return Column(
      children: [
        // 统计信息
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF00BCD4).withOpacity(0.1),
          child: Text(
            l10n.travelBuddiesTotal(buddies.length),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF00BCD4),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // 旅伴列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: buddies.length,
            itemBuilder: (context, index) {
              final buddy = buddies[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TravelBuddyCard(
                  buddy: buddy,
                  onTap: () => _editBuddy(context, buddy),
                  onDelete: () => _deleteBuddy(context, buddy),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_add,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noTravelBuddiesYet,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.addTravelBuddiesToGetStarted,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddTravelBuddyPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.addFirstTravelBuddy),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editBuddy(BuildContext context, TravelBuddy buddy) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTravelBuddyPage(existingBuddy: buddy),
      ),
    );
  }

  void _deleteBuddy(BuildContext context, TravelBuddy buddy) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteTravelBuddy),
          content: Text(l10n.deleteTravelBuddyConfirm(buddy.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // 使用 Consumer 来访问 ref
                if (context.mounted) {
                  final container = ProviderScope.containerOf(context);
                  await container
                      .read(travelBuddiesProvider.notifier)
                      .deleteTravelBuddy(buddy.id!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.travelBuddyDeleted),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }
}
