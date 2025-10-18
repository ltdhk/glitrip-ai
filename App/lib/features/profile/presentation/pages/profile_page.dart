import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../destinations/presentation/providers/destinations_provider.dart';
import '../providers/profile_provider.dart';
import '../../../destinations/presentation/pages/add_destination_page.dart';
import '../../../packing/presentation/pages/add_packing_item_page.dart';
import '../../../travel_buddy/presentation/pages/add_travel_buddy_page.dart';
import '../../../travel_buddy/presentation/pages/travel_buddies_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(destinationStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myProfile),
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLocale();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 用户信息卡片
            Container(
              width: double.infinity,
              color: const Color(0xFF00BCD4),
              padding: const EdgeInsets.all(24),
              child: profileAsync.when(
                data: (profile) => Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getDisplayName(profile?.name, l10n),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getDisplaySignature(profile?.signature, l10n),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                loading: () =>
                    const CircularProgressIndicator(color: Colors.white),
                error: (error, stack) => Text(
                  l10n.errorLoadingProfile,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 旅行统计
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.travelStatistics,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  statsAsync.when(
                    data: (stats) => Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.map,
                            value: stats['total']?.toString() ?? '3',
                            label: l10n.total,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.check_circle,
                            value: stats['visited']?.toString() ?? '0',
                            label: l10n.visited,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.map,
                            value: '3',
                            label: l10n.total,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.check_circle,
                            value: '0',
                            label: l10n.visited,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  statsAsync.when(
                    data: (stats) => Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.schedule,
                            value: stats['planned']?.toString() ?? '1',
                            label: l10n.planned,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.star,
                            value: stats['wishlist']?.toString() ?? '2',
                            label: l10n.wishlist,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (error, stack) => Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.schedule,
                            value: '1',
                            label: l10n.planned,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.star,
                            value: '2',
                            label: l10n.wishlist,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 快捷操作
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.quickActions,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.add,
                    title: l10n.addDestination,
                    subtitle: l10n.planYourNextAdventure,
                    color: const Color(0xFF00BCD4),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddDestinationPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.person_add,
                    title: l10n.addTravelBuddy,
                    subtitle: l10n.findSomeoneToTravelWith,
                    color: Colors.green,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TravelBuddiesPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.luggage,
                    title: l10n.addPackingItem,
                    subtitle: l10n.dontForgetEssentials,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddPackingItemPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDisplayName(String? profileName, AppLocalizations l10n) {
    // 如果数据库中存储的是默认的中文名称，则根据当前语言显示
    if (profileName == null || profileName == '旅行家') {
      return l10n.travelExplorer;
    }
    return profileName;
  }

  String _getDisplaySignature(String? profileSignature, AppLocalizations l10n) {
    // 如果数据库中存储的是默认的中文签名，则根据当前语言显示
    if (profileSignature == null || profileSignature == '新的冒险等待着！') {
      return l10n.adventureAwaits;
    }
    return profileSignature;
  }
}
