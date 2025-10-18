import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../domain/entities/packing_item.dart';
import '../providers/packing_provider.dart';
import '../../../destinations/domain/entities/destination.dart';
import 'add_packing_item_page.dart';
import 'template_selection_page.dart';
import '../../../../ad_helper.dart';

class DestinationPackingPage extends ConsumerStatefulWidget {
  final Destination destination;

  const DestinationPackingPage({super.key, required this.destination});

  @override
  ConsumerState<DestinationPackingPage> createState() =>
      _DestinationPackingPageState();
}

class _DestinationPackingPageState
    extends ConsumerState<DestinationPackingPage> {
  NativeAd? _nativeAd;
  bool _isNativeAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      factoryId: 'listTileMini', // 使用小尺寸广告
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isNativeAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _nativeAd = null;
          setState(() {
            _isNativeAdLoaded = false;
          });
        },
      ),
    );

    _nativeAd?.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final packingItemsAsync = ref.watch(
      itemsByDestinationProvider(widget.destination.id),
    );
    final statsAsync = ref.watch(
      packingStatsByDestinationProvider(widget.destination.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.destination.name} - ${l10n.packing}'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showAddFromTemplateDialog(context, ref, l10n),
            icon: const Icon(Icons.bookmark_add),
            tooltip: l10n.addFromTemplate,
          ),
          IconButton(
            onPressed: () => _navigateToAddItem(context),
            icon: const Icon(Icons.add),
            tooltip: l10n.addPackingItem,
          ),
        ],
      ),
      body: packingItemsAsync.when(
        data: (items) => _buildContent(context, ref, l10n, items, statsAsync),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                l10n.errorLoadingItems,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(
                  itemsByDestinationProvider(widget.destination.id),
                ),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    List<PackingItem> items,
    AsyncValue<Map<String, dynamic>> statsAsync,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 打包进度概览
          _buildProgressOverview(l10n, statsAsync),

          // 小尺寸原生广告
          if (_isNativeAdLoaded && _nativeAd != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 136, // 调整高度以容纳120x120的媒体视图
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AdWidget(ad: _nativeAd!),
              ),
            ),

          // 物品列表
          if (items.isEmpty)
            _buildEmptyState(context, l10n)
          else
            _buildPackingItemsList(context, ref, l10n, items),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(
    AppLocalizations l10n,
    AsyncValue<Map<String, dynamic>> statsAsync,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.purple, Colors.deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.luggage, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.packingProgress,
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
            data: (stats) {
              final total = stats['total'] as int;
              final packed = stats['packed'] as int;
              final progress = stats['progress'] as int;
              final progressValue = total > 0 ? progress / 100.0 : 0.0;

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.totalItems,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '$total',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10n.packed,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '$packed',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$progress% ${l10n.completed}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (total > 0)
                        Text(
                          '${total - packed} ${l10n.remaining}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (_, __) => Text(
              l10n.errorLoadingStats,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
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
          Icon(Icons.luggage, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            l10n.noItemsYet,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addItemsToPackingList,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _navigateToAddItem(context),
                icon: const Icon(Icons.add),
                label: Text(l10n.addPackingItem),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    _showAddFromTemplateDialog(context, null, l10n),
                icon: const Icon(Icons.bookmark_add),
                label: Text(l10n.addFromTemplate),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.purple),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackingItemsList(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    List<PackingItem> items,
  ) {
    // 按类别分组
    final Map<PackingCategory, List<PackingItem>> groupedItems = {};
    for (final item in items) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    return Column(
      children: groupedItems.entries.map((entry) {
        final category = entry.key;
        final categoryItems = entry.value;
        final packedCount = categoryItems.where((item) => item.isPacked).length;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              // 类别头部
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getPackingCategoryColor(
                    category,
                  ).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPackingCategoryIcon(category),
                      color: _getPackingCategoryColor(category),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getPackingCategoryName(category, l10n),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getPackingCategoryColor(category),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getPackingCategoryColor(category),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$packedCount/${categoryItems.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 物品列表
              ...categoryItems.map(
                (item) => _buildPackingItemTile(context, ref, item, l10n),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPackingItemTile(
    BuildContext context,
    WidgetRef ref,
    PackingItem item,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: item.isPacked,
            onChanged: (value) {
              ref
                  .read(
                    itemsByDestinationProvider(widget.destination.id).notifier,
                  )
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
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration:
                        item.isPacked ? TextDecoration.lineThrough : null,
                    color: item.isPacked ? Colors.grey : Colors.black,
                  ),
                ),
                if (item.quantity > 1)
                  Text(
                    '${l10n.quantity}: ${item.quantity}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editItem(context, item);
                  break;
                case 'delete':
                  _deleteItem(context, ref, item, l10n);
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
                    Text(
                      l10n.delete,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToAddItem(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AddPackingItemPage(destinationId: widget.destination.id),
      ),
    );
  }

  void _editItem(BuildContext context, PackingItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddPackingItemPage(
          item: item,
          destinationId: widget.destination.id,
        ),
      ),
    );
  }

  void _deleteItem(
    BuildContext context,
    WidgetRef ref,
    PackingItem item,
    AppLocalizations l10n,
  ) {
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
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref
                    .read(
                      itemsByDestinationProvider(
                        widget.destination.id,
                      ).notifier,
                    )
                    .deleteItem(item.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.itemDeletedSuccessfully),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
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

  void _showAddFromTemplateDialog(
    BuildContext context,
    WidgetRef? ref,
    AppLocalizations l10n,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TemplateSelectionPage(destinationId: widget.destination.id),
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
    PackingCategory category,
    AppLocalizations l10n,
  ) {
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
}
