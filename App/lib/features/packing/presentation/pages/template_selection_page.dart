import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import '../../domain/entities/packing_item.dart';
import '../providers/packing_provider.dart';

class TemplateSelectionPage extends ConsumerWidget {
  final String destinationId;

  const TemplateSelectionPage({
    super.key,
    required this.destinationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final templatesAsync = ref.watch(templateItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectFromTemplate),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => _addSelectedItems(context, ref, l10n),
            child: Text(
              l10n.addSelected,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: templatesAsync.when(
        data: (templates) => _buildContent(context, ref, l10n, templates),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                l10n.errorLoadingTemplates,
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
                onPressed: () => ref.refresh(templateItemsProvider),
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
    List<PackingItem> templates,
  ) {
    if (templates.isEmpty) {
      return _buildEmptyState(l10n);
    }

    // 按类别分组
    final Map<PackingCategory, List<PackingItem>> groupedItems = {};
    for (final item in templates) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // 全选/全不选控制
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.select_all, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.selectAllTemplateItems,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final selectedItems = ref.watch(_selectedItemsProvider);
                    final allSelected =
                        selectedItems.length == templates.length;
                    return Switch(
                      value: allSelected,
                      onChanged: (value) {
                        if (value) {
                          ref.read(_selectedItemsProvider.notifier).state =
                              Set.from(templates);
                        } else {
                          ref.read(_selectedItemsProvider.notifier).state = {};
                        }
                      },
                      activeColor: Colors.orange,
                    );
                  },
                ),
              ],
            ),
          ),

          // 分类展示
          ...groupedItems.entries.map((entry) {
            final category = entry.key;
            final categoryItems = entry.value;

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
                      color:
                          _getPackingCategoryColor(category).withOpacity(0.1),
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
                        Consumer(
                          builder: (context, ref, child) {
                            final selectedItems =
                                ref.watch(_selectedItemsProvider);
                            final categorySelectedCount = categoryItems
                                .where((item) => selectedItems.contains(item))
                                .length;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getPackingCategoryColor(category),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$categorySelectedCount/${categoryItems.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // 物品列表
                  ...categoryItems.map(
                    (item) => _buildTemplateItemTile(context, ref, item, l10n),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noTemplatesYet,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.createTemplateFirst,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateItemTile(
    BuildContext context,
    WidgetRef ref,
    PackingItem item,
    AppLocalizations l10n,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedItems = ref.watch(_selectedItemsProvider);
        final isSelected = selectedItems.contains(item);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  final currentSelected = Set<PackingItem>.from(selectedItems);
                  if (value == true) {
                    currentSelected.add(item);
                  } else {
                    currentSelected.remove(item);
                  }
                  ref.read(_selectedItemsProvider.notifier).state =
                      currentSelected;
                },
                activeColor: Colors.orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            ],
          ),
        );
      },
    );
  }

  void _addSelectedItems(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final selectedItems = ref.read(_selectedItemsProvider);

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectItems),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(l10n.addingItems)),
            ],
          ),
        ),
      );

      // 批量添加物品
      final destinationNotifier =
          ref.read(itemsByDestinationProvider(destinationId).notifier);
      for (final templateItem in selectedItems) {
        final newItem = PackingItem.create(
          name: templateItem.name,
          category: templateItem.category,
          quantity: templateItem.quantity,
          isEssential: templateItem.isEssential,
          destinationId: destinationId,
        );
        await destinationNotifier.addItem(newItem);
      }

      if (context.mounted) {
        Navigator.of(context).pop(); // 关闭加载对话框
        Navigator.of(context).pop(true); // 返回上一页，返回true表示成功添加

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.itemsAddedSuccessfully(selectedItems.length)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // 关闭加载对话框
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorAddingItems(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

// 选中物品的状态provider
final _selectedItemsProvider = StateProvider<Set<PackingItem>>((ref) => {});
