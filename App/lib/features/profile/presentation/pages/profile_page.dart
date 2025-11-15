import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../ai_planning/data/datasources/ai_planning_datasource_v2.dart'
    show AIUsageModelV2;
import '../../../ai_planning/presentation/providers/ai_create_provider.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../destinations/presentation/providers/destinations_provider.dart';
import '../providers/profile_provider.dart';
import '../../../destinations/presentation/pages/add_destination_page.dart';
import '../../../packing/presentation/pages/add_packing_item_page.dart';
import '../../../travel_buddy/presentation/pages/add_travel_buddy_page.dart';
import '../../../travel_buddy/presentation/pages/travel_buddies_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../subscription/presentation/pages/vip_upgrade_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(destinationStatsProvider);
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final aiUsageAsync = ref.watch(aiUsageV2Provider);
    final usageData = aiUsageAsync.asData?.value;
    final usageToDisplay = usageData ?? _buildFallbackUsage(user);

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

            // 会员信息
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  if (aiUsageAsync.isLoading && usageData == null)
                    const LinearProgressIndicator(minHeight: 2),
                  _buildMembershipCard(
                    context,
                    usage: usageToDisplay,
                    user: user,
                    l10n: l10n,
                  ),
                ],
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

            // 账户与支持
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.accountSettings,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAccountActionCard(
                    context,
                    icon: Icons.logout,
                    title: l10n.logoutAction,
                    subtitle: l10n.logoutDescription,
                    color: Colors.redAccent,
                    onTap: () => _confirmLogout(context, ref, l10n),
                  ),
                  const SizedBox(height: 12),
                  _buildAccountActionCard(
                    context,
                    icon: Icons.delete_forever,
                    title: l10n.deleteAccountAction,
                    subtitle: l10n.deleteAccountDescription,
                    color: Colors.red,
                    onTap: () => _confirmDeleteAccount(context, ref, l10n),
                  ),
                  const SizedBox(height: 12),
                  _buildAccountActionCard(
                    context,
                    icon: Icons.support_agent,
                    title: l10n.contactUsAction,
                    subtitle: l10n.contactUsDescription,
                    color: const Color(0xFF00BCD4),
                    onTap: () => _showContactSheet(context, l10n),
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

  Widget _buildAccountActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
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

  Widget _buildMembershipCard(
    BuildContext context, {
    required AIUsageModelV2 usage,
    required UserModel? user,
    required AppLocalizations l10n,
  }) {
    final isVip = usage.isVip;
    final levelText = isVip ? l10n.membershipVip : l10n.membershipFree;
    final levelColor = isVip ? const Color(0xFFB26A00) : const Color(0xFF0277BD);
    final gradient = isVip
        ? const LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
    final expiryText = user?.subscriptionEndDate != null
        ? l10n.membershipExpiry(user!.subscriptionEndDate!)
        : null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.08),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isVip ? Icons.workspace_premium : Icons.card_membership,
                    color: levelColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        levelText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: levelColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.aiUsageLimit(
                          usage.usedCount,
                          usage.totalQuota,
                          usage.remainingQuota,
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (expiryText != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          expiryText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const VIPUpgradePage(),
                    ),
                  );
                },
                icon: Icon(
                  isVip ? Icons.autorenew : Icons.trending_up,
                  size: 18,
                ),
                label: Text(
                  isVip ? l10n.renewMembership : l10n.upgradeMembership,
                  style: const TextStyle(fontSize: 13),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: levelColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AIUsageModelV2 _buildFallbackUsage(UserModel? user) {
    final isVip = user?.isVip ?? false;
    final totalQuota = isVip ? 1000 : 3;
    return AIUsageModelV2(
      usedCount: 0,
      totalQuota: totalQuota,
      remainingQuota: totalQuota,
      subscriptionType: isVip ? 'vip' : 'free',
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.confirmLogoutTitle),
            content: Text(l10n.confirmLogoutMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.logoutAction),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldLogout) return;

    final messenger = ScaffoldMessenger.of(context);

    await ref.read(authStateProvider.notifier).logout();

    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.logoutSuccessMessage),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.confirmDeleteTitle),
            content: Text(l10n.confirmDeleteMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton.tonalIcon(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                icon: const Icon(Icons.delete_forever),
                label: Text(l10n.deleteAccountAction),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final errorMessage = await ref.read(authStateProvider.notifier).deleteAccount();

    navigator.pop(); // 关闭加载框

    if (errorMessage == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.deleteAccountSuccessMessage),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    }
  }

  void _showContactSheet(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.contactUsAction,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.contactDialogMessage,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(l10n.contactEmailLabel),
                subtitle: Text(l10n.supportEmailAddress),
                trailing: TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: l10n.supportEmailAddress),
                    );
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(l10n.emailCopiedMessage),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text(l10n.copy),
                ),
              ),
            ),
          ],
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
