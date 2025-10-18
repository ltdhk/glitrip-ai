import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../domain/entities/destination.dart';
import '../providers/destinations_provider.dart';
import 'add_destination_page.dart';
import '../../../expenses/presentation/pages/add_expense_page.dart';
import '../../../expenses/presentation/providers/expenses_provider.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../itinerary/presentation/providers/itinerary_provider.dart';
import '../../../itinerary/domain/entities/itinerary_day.dart';
import '../../../itinerary/presentation/pages/add_itinerary_day_page.dart';
import '../../../packing/domain/entities/packing_item.dart';
import '../../../packing/presentation/providers/packing_provider.dart';
import '../../../memories/domain/entities/memory.dart';
import '../../../memories/presentation/providers/memories_provider.dart';
import '../../../memories/presentation/pages/add_memory_page.dart';
import '../../../travel_buddy/presentation/providers/travel_buddy_provider.dart';
import '../../../travel_buddy/domain/entities/travel_buddy.dart'
    as buddy_entities;
import '../../../../ad_helper.dart';
import 'dart:math' as math;

class DestinationDetailPage extends ConsumerStatefulWidget {
  final Destination destination;

  const DestinationDetailPage({
    super.key,
    required this.destination,
  });

  @override
  ConsumerState<DestinationDetailPage> createState() =>
      _DestinationDetailPageState();
}

class _DestinationDetailPageState extends ConsumerState<DestinationDetailPage>
    with SingleTickerProviderStateMixin {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  TabController? _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController!.addListener(_handleTabChange);
    _loadBannerAd();
  }

  void _handleTabChange() {
    setState(() {
      _currentTabIndex = _tabController!.index;
    });
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          setState(() {
            _isAdLoaded = false;
          });
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.destination.name),
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AddDestinationPage(destination: widget.destination),
                    ),
                  );
                  break;
                case 'delete':
                  _showDeleteDialog(context, ref);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit),
                    const SizedBox(width: 8),
                    Text(l10n.edit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 头部卡片
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: _getStatusGradient(widget.destination.status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              widget.destination.country,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.destination.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.destination.description != null &&
                            widget.destination.description!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.destination.description!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (widget.destination.startDate != null &&
                                widget.destination.endDate != null)
                              _buildInfoChip(
                                icon: Icons.calendar_today,
                                label: _getDateRangeText(
                                  widget.destination.startDate!,
                                  widget.destination.endDate!,
                                ),
                              )
                            else
                              _buildInfoChip(
                                icon: Icons.calendar_today,
                                label: widget.destination.bestTimeDescription ??
                                    'Not set',
                              ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              icon: Icons.attach_money,
                              label: widget.destination.estimatedCost != null
                                  ? '${widget.destination.estimatedCost!.toStringAsFixed(0)}'
                                  : _getBudgetText(
                                      widget.destination.budgetLevel, l10n),
                            ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              icon: Icons.access_time,
                              label: '${widget.destination.recommendedDays}d',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tab 导航
                  Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: const Color(0xFF00BCD4),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: const Color(0xFF00BCD4),
                        tabs: [
                          Tab(text: l10n.overview),
                          Tab(text: l10n.budget),
                          Tab(text: l10n.itinerary),
                          Tab(text: l10n.packing),
                          Tab(text: l10n.memories),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height -
                            350 -
                            (_isAdLoaded && _currentTabIndex == 0 ? 50 : 0),
                        child: Stack(
                          children: [
                            TabBarView(
                              controller: _tabController,
                              children: [
                                _buildOverviewTab(l10n),
                                _buildBudgetTab(l10n, context, ref),
                                _buildItineraryTab(l10n, context, ref),
                                _buildPackingTab(l10n, ref, context),
                                _buildMemoriesTab(l10n, ref, context),
                              ],
                            ),
                            // 浮动操作按钮，在预算和行程标签页显示
                            if (_currentTabIndex == 1)
                              // 预算标签页
                              Positioned(
                                right: 16,
                                bottom: 80,
                                child: FloatingActionButton(
                                  onPressed: () =>
                                      _navigateToAddExpense(context, ref),
                                  backgroundColor: const Color(0xFF00BCD4),
                                  child: const Icon(Icons.add,
                                      color: Colors.white),
                                ),
                              )
                            else if (_currentTabIndex == 2)
                              // 行程标签页
                              Positioned(
                                right: 16,
                                bottom: 80,
                                child: FloatingActionButton(
                                  onPressed: () =>
                                      _navigateToAddItineraryDay(context, ref),
                                  backgroundColor: Colors.orange,
                                  child: const Icon(Icons.add,
                                      color: Colors.white),
                                ),
                              )
                            else if (_currentTabIndex == 4)
                              // 回忆标签页
                              Positioned(
                                right: 16,
                                bottom: 80,
                                child: FloatingActionButton(
                                  onPressed: () =>
                                      _navigateToAddMemory(context, ref),
                                  backgroundColor: Colors.pink,
                                  child: const Icon(Icons.add,
                                      color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 底部横幅广告 - 只在总览页显示
          if (_isAdLoaded && _bannerAd != null && _currentTabIndex == 0)
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              color: Colors.white,
              child: SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 预算级别
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Color(0xFF00BCD4),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.budgetLevelCard,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildBudgetOption(
                label: l10n.budgetOption,
                symbol: '\$',
                isSelected: widget.destination.budgetLevel == BudgetLevel.low,
              ),
              const SizedBox(width: 8),
              _buildBudgetOption(
                label: l10n.comfort,
                symbol: '\$\$',
                isSelected:
                    widget.destination.budgetLevel == BudgetLevel.medium,
              ),
              const SizedBox(width: 8),
              _buildBudgetOption(
                label: l10n.luxury,
                symbol: '\$\$\$',
                isSelected: widget.destination.budgetLevel == BudgetLevel.high,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 旅行笔记
          if (widget.destination.travelNotes != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.note_alt,
                  color: Color(0xFF00BCD4),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.travelNotes,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.destination.travelNotes!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 标签
          if (widget.destination.tags.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.local_offer,
                  color: Color(0xFF00BCD4),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.tags,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.destination.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: const Color(0xFF00BCD4).withOpacity(0.1),
                  avatar: const Icon(
                    Icons.tag,
                    size: 16,
                    color: Color(0xFF00BCD4),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // 旅伴
          if (widget.destination.travelBuddyIds.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.people,
                  color: Color(0xFF00BCD4),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.travelBuddies,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTravelBuddiesSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildTravelBuddiesSection() {
    final l10n = AppLocalizations.of(context);
    final travelBuddiesAsync = ref.watch(travelBuddiesProvider);

    return travelBuddiesAsync.when(
      data: (List<buddy_entities.TravelBuddy> allBuddies) {
        // 过滤出选中的旅伴
        final selectedBuddies = allBuddies
            .where(
                (buddy) => widget.destination.travelBuddyIds.contains(buddy.id))
            .toList();

        if (selectedBuddies.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(l10n.noTravelBuddyInfo),
          );
        }

        return Column(
          children: selectedBuddies.map((buddy) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00BCD4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF00BCD4).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF00BCD4),
                    child: Text(
                      buddy.name.isNotEmpty ? buddy.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          buddy.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildBuddyMeta(buddy),
                      ],
                    ),
                  ),
                  if (buddy.isConfirmedToTravel)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Text(l10n.loadingTravelBuddiesFailed(error.toString())),
    );
  }

  Widget _buildBuddyMeta(buddy_entities.TravelBuddy buddy) {
    final l10n = AppLocalizations.of(context);
    final String budgetText = _getBuddyBudgetLevelText(buddy.budgetLevel, l10n);
    final List<String> prefLabels = buddy.travelPreferences
        .map((p) => _getBuddyPreferenceLabel(p, l10n))
        .where((t) => t.isNotEmpty)
        .toList();

    final String prefsText = prefLabels.isNotEmpty ? prefLabels.join('、') : '';

    if (budgetText.isEmpty && prefsText.isEmpty && buddy.email.isEmpty) {
      return const SizedBox.shrink();
    }

    final baseStyle = TextStyle(fontSize: 12, color: Colors.grey[700]);
    const accentColor = Color(0xFF00BCD4);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text.rich(
        TextSpan(
          children: [
            if (budgetText.isNotEmpty) ...[
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(Icons.attach_money, size: 14, color: accentColor),
              ),
              const WidgetSpan(child: SizedBox(width: 2)),
              TextSpan(text: budgetText, style: baseStyle),
            ],
            if (budgetText.isNotEmpty && prefsText.isNotEmpty)
              TextSpan(text: ' · ', style: baseStyle),
            if (prefsText.isNotEmpty) ...[
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(Icons.interests, size: 14, color: accentColor),
              ),
              const WidgetSpan(child: SizedBox(width: 2)),
              TextSpan(text: prefsText, style: baseStyle),
            ],
            if (budgetText.isEmpty &&
                prefsText.isEmpty &&
                buddy.email.isNotEmpty)
              TextSpan(text: buddy.email, style: baseStyle),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _getBuddyBudgetLevelText(
      buddy_entities.BudgetLevel level, AppLocalizations l10n) {
    switch (level) {
      case buddy_entities.BudgetLevel.low:
        return l10n.low;
      case buddy_entities.BudgetLevel.medium:
        return l10n.medium;
      case buddy_entities.BudgetLevel.high:
        return l10n.high;
    }
  }

  // 旧的彩色胶囊展示已不再使用，移除相关方法

  String _getBuddyPreferenceLabel(
      buddy_entities.TravelPreference preference, AppLocalizations l10n) {
    switch (preference) {
      case buddy_entities.TravelPreference.adventure:
        return l10n.adventure;
      case buddy_entities.TravelPreference.relaxation:
        return l10n.relaxation;
      case buddy_entities.TravelPreference.culture:
        return l10n.culture;
      case buddy_entities.TravelPreference.foodie:
        return l10n.foodie;
      case buddy_entities.TravelPreference.nature:
        return l10n.nature;
      case buddy_entities.TravelPreference.urban:
        return l10n.urban;
    }
  }

  Widget _buildBudgetOption({
    required String label,
    required String symbol,
    required bool isSelected,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF9800)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              symbol,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetTab(
      AppLocalizations l10n, BuildContext context, WidgetRef ref) {
    final expenses =
        ref.watch(destinationExpensesProvider(widget.destination.id));
    final totalSpent =
        ref.watch(destinationTotalSpentProvider(widget.destination.id));
    final expensesByCategory =
        ref.watch(destinationExpensesByCategoryProvider(widget.destination.id));

    final totalBudget = widget.destination.estimatedCost ?? 2000.0;
    final remaining = totalBudget - totalSpent;
    final usedPercentage =
        totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBudgetOverview(
              l10n, totalBudget, totalSpent, remaining, usedPercentage),
          const SizedBox(height: 24),
          if (expenses.isNotEmpty) ...[
            _buildExpensesByCategory(l10n, expensesByCategory),
            const SizedBox(height: 24),
          ],
          _buildRecentExpenses(context, ref, l10n, expenses),
        ],
      ),
    );
  }

  // 从BudgetExpensesPage复制的方法
  Widget _buildBudgetOverview(AppLocalizations l10n, double totalBudget,
      double totalSpent, double remaining, double usedPercentage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.budgetOverview,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.budget,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    totalBudget.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00BCD4),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.spent,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    totalSpent.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: usedPercentage,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              usedPercentage > 0.8 ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(usedPercentage * 100).toInt()}% ${l10n.used}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                '${l10n.remaining}: ${remaining.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesByCategory(
      AppLocalizations l10n, Map<ExpenseCategory, double> categoryTotals) {
    if (categoryTotals.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.expensesByCategory,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // 紧凑的图表和图例布局
          Row(
            children: [
              // 左侧圆饼图
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: PieChartPainter(categoryTotals),
                ),
              ),
              const SizedBox(width: 24),
              // 右侧图例
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categoryTotals.entries
                      .map((entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Icon(
                                  _getCategoryIcon(entry.key),
                                  color: _getCategoryColor(entry.key),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getCategoryName(entry.key, l10n),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${entry.value.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExpenses(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, List<Expense> expenses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentExpenses,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${expenses.length} ${l10n.items}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (expenses.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.credit_card,
                  size: 64,
                  color: Colors.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noExpensesYet,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.addFirstExpenseToStartTracking,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ] else ...[
          // 按日期降序排列（最新的在前面）
          ...expenses.reversed
              .map((expense) => _buildExpenseItem(context, ref, expense, l10n)),
        ],
      ],
    );
  }

  Widget _buildExpenseItem(BuildContext context, WidgetRef ref, Expense expense,
      AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _showExpenseDetail(context, ref, expense),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(expense.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: _getCategoryColor(expense.category),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _getCategoryName(expense.category, l10n),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      if (expense.isPaid) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l10n.paid,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  expense.amount.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(expense.date),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItineraryTab(
      AppLocalizations l10n, BuildContext context, WidgetRef ref) {
    final itineraryDays =
        ref.watch(destinationItineraryProvider(widget.destination.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.itinerary,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (itineraryDays.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.days(itineraryDays.length),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (itineraryDays.isEmpty)
            _buildEmptyItinerary(l10n, context, ref)
          else
            ...itineraryDays
                .map((day) => _buildItineraryDayCard(day, context, ref, l10n)),
        ],
      ),
    );
  }

  Widget _buildEmptyItinerary(
      AppLocalizations l10n, BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
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
            Icons.calendar_month,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noItineraryYet,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.planYourTripDayByDay,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _navigateToAddItineraryDay(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.addFirstDay),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryDayCard(ItineraryDay day, BuildContext context,
      WidgetRef ref, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.day(day.dayNumber),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  day.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${day.date.month.toString().padLeft(2, '0')}/${day.date.day.toString().padLeft(2, '0')}, ${day.date.year}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _editItineraryDay(context, day);
                  } else if (value == 'delete') {
                    _deleteItineraryDay(context, day, ref);
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
          if (day.activities.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...day.activities
                .map((activity) => _buildActivityItem(activity, l10n)),
          ] else ...[
            const SizedBox(height: 16),
            Text(
              l10n.noActivitiesPlanned,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityItem(ItineraryActivity activity, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                activity.time,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: activity.isBooked ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        activity.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    if (activity.isBooked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green, width: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                size: 10, color: Colors.green),
                            const SizedBox(width: 2),
                            Text(
                              l10n.alreadyBooked,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (activity.cost != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    activity.cost!.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackingTab(
      AppLocalizations l10n, WidgetRef ref, BuildContext context) {
    final packingItemsAsync =
        ref.watch(itemsByDestinationProvider(widget.destination.id));
    final statsAsync =
        ref.watch(packingStatsByDestinationProvider(widget.destination.id));

    return packingItemsAsync.when(
      data: (items) =>
          _buildPackingContent(l10n, items, statsAsync, ref, context),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildPackingContent(
      AppLocalizations l10n,
      List<PackingItem> items,
      AsyncValue<Map<String, dynamic>> statsAsync,
      WidgetRef ref,
      BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 打包进度
          Container(
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
            child: Row(
              children: [
                const Icon(Icons.luggage, color: Colors.purple, size: 24),
                const SizedBox(width: 12),
                Text(
                  l10n.packingList,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                statsAsync.when(
                  data: (stats) {
                    final total = stats['total'] as int? ?? 0;
                    final packed = stats['packed'] as int? ?? 0;
                    final percentage =
                        total > 0 ? (packed / total * 100).round() : 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$percentage%',
                        style: const TextStyle(
                          color: Colors.purple,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 进度条
          statsAsync.when(
            data: (stats) {
              final total = stats['total'] as int? ?? 0;
              final packed = stats['packed'] as int? ?? 0;
              final progress = total > 0 ? packed / total : 0.0;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.progress,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 16),
          // 物品列表
          if (items.isEmpty)
            SizedBox(
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.all(40),
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
                      Icons.luggage,
                      size: 64,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noItemsYet,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.addItemsToPackingList,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            _buildPackingItemsList(l10n, items, ref, context),
        ],
      ),
    );
  }

  Widget _buildPackingItemsList(AppLocalizations l10n, List<PackingItem> items,
      WidgetRef ref, BuildContext context) {
    // 按类别分组
    final Map<PackingCategory, List<PackingItem>> groupedItems = {};
    for (final item in items) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    return Column(
      children: groupedItems.entries.map((entry) {
        final category = entry.key;
        final categoryItems = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(_getPackingCategoryIcon(category),
                        color: _getPackingCategoryColor(category), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _getPackingCategoryName(category, l10n),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ...categoryItems.map(
                  (item) => _buildPackingItemTile(item, ref, context, l10n)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPackingItemTile(PackingItem item, WidgetRef ref,
      BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: item.isPacked,
            onChanged: (value) {
              ref
                  .read(itemsByDestinationProvider(widget.destination.id)
                      .notifier)
                  .toggleItemPacked(item.id);
            },
            activeColor: Colors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration:
                        item.isPacked ? TextDecoration.lineThrough : null,
                    color: item.isPacked ? Colors.grey : Colors.black,
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
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
            onPressed: () => _deletePackingItem(item, context, ref),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _deletePackingItem(
      PackingItem item, BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteItem),
        content: Text(l10n.deleteItemConfirm(item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(packingItemsProvider.notifier).deleteItem(item.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.itemDeletedSuccessfully)),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  IconData _getPackingCategoryIcon(PackingCategory category) {
    switch (category) {
      case PackingCategory.clothing:
        return Icons.checkroom;
      case PackingCategory.electronics:
        return Icons.devices;
      case PackingCategory.cosmetics:
        return Icons.face;
      case PackingCategory.health:
        return Icons.health_and_safety;
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

  Color _getPackingCategoryColor(PackingCategory category) {
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

  String _getPackingCategoryName(
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

  Widget _buildMemoriesTab(
      AppLocalizations l10n, WidgetRef ref, BuildContext context) {
    final memories =
        ref.watch(destinationMemoriesProvider(widget.destination.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Container(
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
            child: Row(
              children: [
                const Icon(Icons.photo_library, color: Colors.pink, size: 24),
                const SizedBox(width: 12),
                Text(
                  l10n.travelMemories,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${memories.length}',
                    style: const TextStyle(
                      color: Colors.pink,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 回忆列表
          if (memories.isEmpty)
            SizedBox(
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.all(40),
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
                      Icons.photo_album,
                      size: 64,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noMemoriesYet,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.addPhotosAndStories,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _navigateToAddMemory(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(l10n.addFirstMemory),
                    ),
                  ],
                ),
              ),
            )
          else
            ...memories
                .map((memory) => _buildMemoryCard(memory, context, ref, l10n)),
        ],
      ),
    );
  }

  Widget _buildMemoryCard(TravelMemory memory, BuildContext context,
      WidgetRef ref, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memory.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            memory.location,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      color: index < memory.rating
                          ? Colors.amber
                          : Colors.grey[300],
                      size: 16,
                    );
                  }),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editMemory(context, memory);
                    } else if (value == 'delete') {
                      _deleteMemory(context, memory, ref);
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
            const SizedBox(height: 12),
            Text(
              '${memory.date.month.toString().padLeft(2, '0')}/${memory.date.day.toString().padLeft(2, '0')}, ${memory.date.year}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (memory.description != null &&
                memory.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                memory.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToAddMemory(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMemoryPage(destination: widget.destination),
      ),
    );
    if (result == true) {
      // 回忆已更新，自动刷新
    }
  }

  void _editMemory(BuildContext context, TravelMemory memory) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMemoryPage(
          destination: widget.destination,
          memory: memory,
        ),
      ),
    );
    if (result == true) {
      // 回忆已更新，自动刷新
    }
  }

  void _deleteMemory(BuildContext context, TravelMemory memory, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMemory),
        content: Text(l10n.deleteMemoryConfirm(memory.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(memoriesProvider.notifier).deleteMemory(memory.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.memoryDeletedSuccessfully)),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getStatusGradient(DestinationStatus status) {
    switch (status) {
      case DestinationStatus.visited:
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DestinationStatus.planned:
        return const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case DestinationStatus.wishlist:
        return const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  String _getBudgetText(BudgetLevel level, AppLocalizations l10n) {
    switch (level) {
      case BudgetLevel.low:
        return l10n.low;
      case BudgetLevel.medium:
        return l10n.medium;
      case BudgetLevel.high:
        return l10n.high;
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDestination),
        content: Text(l10n.deleteDestinationConfirm(widget.destination.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              await ref.read(destinationsProvider.notifier).deleteDestination(
                  widget.destination.id, widget.destination.status);
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // 支出相关的辅助方法
  void _showExpenseDetail(
      BuildContext context, WidgetRef ref, Expense expense) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.expenseDetails,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showDeleteConfirmation(
                            context, ref, expense, l10n),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: l10n.delete,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildExpenseOverview(expense, l10n),
                  const SizedBox(height: 24),
                  _buildExpenseDetailsSection(expense, l10n),
                  if (expense.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: 24),
                    _buildNotesSection(expense, l10n),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpenseOverview(Expense expense, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(expense.category),
            size: 48,
            color: _getCategoryColor(expense.category),
          ),
          const SizedBox(height: 16),
          Text(
            expense.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getCategoryName(expense.category, l10n),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${l10n.amount}: ${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00BCD4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: expense.isPaid ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              expense.isPaid ? l10n.paid : '未付款',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseDetailsSection(Expense expense, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '详细信息',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('日期', _formatDate(expense.date)),
          _buildDetailRow('分类', _getCategoryName(expense.category, l10n)),
          _buildDetailRow('状态', expense.isPaid ? l10n.paid : '未付款'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(Expense expense, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.notes,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            expense.notes ?? '',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref,
      Expense expense, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteExpense),
        content: Text(l10n.deleteExpenseConfirm(expense.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // 关闭确认对话框
              Navigator.of(context).pop(); // 关闭底部面板
              try {
                ref.read(expensesProvider.notifier).deleteExpense(expense.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Expense deleted successfully')),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $error')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.accommodation:
        return Icons.hotel;
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.activities:
        return Icons.local_activity;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.insurance:
        return Icons.security;
      case ExpenseCategory.visa:
        return Icons.description;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.accommodation:
        return Colors.blue;
      case ExpenseCategory.transport:
        return Colors.green;
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.activities:
        return Colors.purple;
      case ExpenseCategory.shopping:
        return Colors.pink;
      case ExpenseCategory.insurance:
        return Colors.teal;
      case ExpenseCategory.visa:
        return Colors.indigo;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }

  String _getCategoryName(ExpenseCategory category, AppLocalizations l10n) {
    switch (category) {
      case ExpenseCategory.accommodation:
        return l10n.accommodation;
      case ExpenseCategory.transport:
        return l10n.transport;
      case ExpenseCategory.food:
        return l10n.food;
      case ExpenseCategory.activities:
        return l10n.activities;
      case ExpenseCategory.shopping:
        return l10n.shopping;
      case ExpenseCategory.insurance:
        return l10n.insurance;
      case ExpenseCategory.visa:
        return l10n.visa;
      case ExpenseCategory.other:
        return l10n.other;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日, ${date.year}';
  }

  void _navigateToAddExpense(BuildContext context, WidgetRef ref) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => AddExpensePage(destination: widget.destination),
      ),
    )
        .then((result) {
      if (result == true) {
        // 页面会自动更新，因为我们使用了Riverpod
        // 不需要手动刷新
      }
    });
  }

  void _navigateToAddItineraryDay(BuildContext context, WidgetRef ref) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) =>
            AddItineraryDayPage(destination: widget.destination),
      ),
    )
        .then((result) {
      if (result == true) {
        // 页面会自动更新，因为我们使用了Riverpod
        // 不需要手动刷新
      }
    });
  }

  void _editItineraryDay(BuildContext context, ItineraryDay day) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddItineraryDayPage(
          destination: widget.destination,
          day: day,
        ),
      ),
    );
  }

  void _deleteItineraryDay(
      BuildContext context, ItineraryDay day, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDay),
        content: Text(l10n.deleteDayConfirm(day.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(itineraryProvider.notifier).deleteDay(day.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.dayDeletedSuccessfully)),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  /// 格式化日期范围为 "MM/DD-MM/DD" 格式
  String _getDateRangeText(DateTime startDate, DateTime endDate) {
    final startMonth = startDate.month.toString().padLeft(2, '0');
    final startDay = startDate.day.toString().padLeft(2, '0');
    final endMonth = endDate.month.toString().padLeft(2, '0');
    final endDay = endDate.day.toString().padLeft(2, '0');

    // 如果是同一天，只显示一个日期
    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      return '$startMonth/$startDay';
    }

    // 显示日期范围
    return '$startMonth/$startDay-$endMonth/$endDay';
  }
}

class PieChartPainter extends CustomPainter {
  final Map<ExpenseCategory, double> data;

  PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2.5;
    final innerRadius = outerRadius * 0.6; // 创建环形图

    final total = data.values.fold(0.0, (sum, value) => sum + value);
    if (total == 0) return;

    double startAngle = -math.pi / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final entry in data.entries) {
      final sweepAngle = (entry.value / total) * 2 * math.pi;
      paint.color = _getCategoryColor(entry.key);

      // 绘制环形扇形
      final path = Path();
      final outerRect = Rect.fromCircle(center: center, radius: outerRadius);
      final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

      path.arcTo(outerRect, startAngle, sweepAngle, false);
      path.arcTo(innerRect, startAngle + sweepAngle, -sweepAngle, false);
      path.close();

      canvas.drawPath(path, paint);
      startAngle += sweepAngle;
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.accommodation:
        return Colors.blue;
      case ExpenseCategory.transport:
        return Colors.green;
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.activities:
        return Colors.purple;
      case ExpenseCategory.shopping:
        return Colors.pink;
      case ExpenseCategory.insurance:
        return Colors.indigo;
      case ExpenseCategory.visa:
        return Colors.teal;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
