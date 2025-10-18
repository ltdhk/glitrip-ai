import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import '../../domain/entities/packing_item.dart';
import '../providers/packing_provider.dart';
import '../../../destinations/domain/entities/destination.dart';
import '../../../destinations/presentation/providers/destinations_provider.dart';

class AddPackingItemPage extends ConsumerStatefulWidget {
  final PackingItem? item;
  final String? destinationId;
  final bool isTemplate;

  const AddPackingItemPage({
    super.key,
    this.item,
    this.destinationId,
    this.isTemplate = false,
  });

  @override
  ConsumerState<AddPackingItemPage> createState() => _AddPackingItemPageState();
}

class _AddPackingItemPageState extends ConsumerState<AddPackingItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  PackingCategory _selectedCategory = PackingCategory.other;
  int _quantity = 1;
  bool _isEssential = false;
  String? _selectedDestinationId;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _initializeWithExistingData();
    }
  }

  void _initializeWithExistingData() {
    final item = widget.item!;
    _nameController.text = item.name;
    _selectedCategory = item.category;
    _quantity = item.quantity;
    _isEssential = item.isEssential;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editPackingItem : l10n.addPackingItem),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveItem,
            child: Text(
              l10n.save,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.itemDetails.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // 目的地选择（如果没有预设destinationId且不是模板物品）
              if (widget.destinationId == null && !widget.isTemplate) ...[
                _buildDestinationSelector(l10n),
                const SizedBox(height: 16),
              ],

              // 显示模板物品提示
              if (widget.isTemplate)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bookmark, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.creatingTemplateItem,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return l10n.pleaseEnterItemName;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: l10n.itemName,
                  prefixIcon:
                      const Icon(Icons.shopping_bag, color: Colors.purple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.purple),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildCategorySelector(l10n),
              const SizedBox(height: 16),
              _buildQuantitySelector(l10n),
              const SizedBox(height: 16),
              _buildEssentialToggle(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.category,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<PackingCategory>(
              value: _selectedCategory,
              isExpanded: true,
              onChanged: (PackingCategory? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
              items: PackingCategory.values
                  .map<DropdownMenuItem<PackingCategory>>(
                      (PackingCategory category) {
                return DropdownMenuItem<PackingCategory>(
                  value: category,
                  child: Row(
                    children: [
                      Icon(_getCategoryIcon(category), color: Colors.purple),
                      const SizedBox(width: 12),
                      Text(_getCategoryDisplayName(category, l10n)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector(AppLocalizations l10n) {
    return Row(
      children: [
        const Icon(Icons.numbers, color: Colors.purple),
        const SizedBox(width: 8),
        Text(
          '${l10n.quantity}: $_quantity',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_quantity > 1) {
                    setState(() {
                      _quantity--;
                    });
                  }
                },
                icon: const Icon(Icons.remove),
              ),
              Text(
                '$_quantity',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _quantity++;
                  });
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEssentialToggle(AppLocalizations l10n) {
    return Row(
      children: [
        const Icon(Icons.warning, color: Colors.red),
        const SizedBox(width: 8),
        Text(
          l10n.essentialItem,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Switch(
          value: _isEssential,
          onChanged: (value) {
            setState(() {
              _isEssential = value;
            });
          },
          activeColor: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildDestinationSelector(AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final destinationsAsync = ref.watch(destinationsProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.selectDestination,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                    color: _selectedDestinationId == null
                        ? Colors.red
                        : Colors.grey[400]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: destinationsAsync.when(
                data: (destinations) {
                  if (destinations.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.noDestinationsAvailable,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDestinationId,
                      isExpanded: true,
                      hint: Text(l10n.selectDestination),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDestinationId = newValue;
                        });
                      },
                      items: destinations.map<DropdownMenuItem<String>>(
                        (Destination destination) {
                          return DropdownMenuItem<String>(
                            value: destination.id,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.place,
                                  color: Colors.purple,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    destination.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.errorLoadingDestinations,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
            if (_selectedDestinationId == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.pleaseSelectDestination,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
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

  void _saveItem() async {
    final l10n = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 对于新物品，使用提供的destinationId或选择的destinationId
    final destinationId = widget.isTemplate
        ? null
        : (widget.destinationId ?? _selectedDestinationId);

    // 验证目的地选择（如果没有预设destinationId且不是模板物品）
    if (!widget.isTemplate &&
        widget.destinationId == null &&
        _selectedDestinationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectDestination),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final item = _isEditing
        ? widget.item!.copyWith(
            name: _nameController.text.trim(),
            category: _selectedCategory,
            quantity: _quantity,
            isEssential: _isEssential,
          )
        : PackingItem.create(
            name: _nameController.text.trim(),
            category: _selectedCategory,
            quantity: _quantity,
            isEssential: _isEssential,
            destinationId: destinationId,
          );

    try {
      if (_isEditing) {
        // 更新物品
        if (widget.isTemplate || destinationId == null) {
          await ref.read(templateItemsProvider.notifier).updateItem(item);
        } else {
          await ref
              .read(itemsByDestinationProvider(destinationId).notifier)
              .updateItem(item);
        }
      } else {
        // 添加新物品
        if (widget.isTemplate) {
          await ref.read(templateItemsProvider.notifier).addItem(item);
        } else if (destinationId != null) {
          await ref
              .read(itemsByDestinationProvider(destinationId).notifier)
              .addItem(item);
        } else {
          await ref.read(packingItemsProvider.notifier).addItem(item);
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true); // 返回true表示成功保存
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? l10n.itemUpdatedSuccessfully
                : l10n.itemAddedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSavingItem(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
