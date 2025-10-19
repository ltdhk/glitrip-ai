import 'package:flutter/material.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../domain/entities/todo.dart';

class CategorySelector extends StatelessWidget {
  final TodoCategory? selectedCategory;
  final ValueChanged<TodoCategory> onCategorySelected;

  const CategorySelector({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: TodoCategory.values
            .map((category) => _buildCategoryTile(context, category))
            .toList(),
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, TodoCategory category) {
    final l10n = AppLocalizations.of(context);
    final isSelected = selectedCategory == category;
    final (icon, color, label) = _getCategoryInfo(category, l10n);

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: color)
          : Icon(Icons.circle_outlined, color: Colors.grey[300]),
      selected: isSelected,
      onTap: () {
        onCategorySelected(category);
        Navigator.of(context).pop();
      },
    );
  }

  (IconData, Color, String) _getCategoryInfo(
      TodoCategory category, AppLocalizations l10n) {
    switch (category) {
      case TodoCategory.passport:
        return (Icons.card_travel, Colors.purple, l10n.todoCategoryPassport);
      case TodoCategory.idCard:
        return (Icons.badge, Colors.blue, l10n.todoCategoryIdCard);
      case TodoCategory.visa:
        return (Icons.document_scanner, Colors.green, l10n.todoCategoryVisa);
      case TodoCategory.insurance:
        return (Icons.health_and_safety, Colors.teal, l10n.todoCategoryInsurance);
      case TodoCategory.ticket:
        return (Icons.flight, Colors.indigo, l10n.todoCategoryTicket);
      case TodoCategory.hotel:
        return (Icons.hotel, Colors.orange, l10n.todoCategoryHotel);
      case TodoCategory.carRental:
        return (Icons.directions_car, Colors.brown, l10n.todoCategoryCarRental);
      case TodoCategory.other:
        return (Icons.more_horiz, Colors.grey, l10n.todoCategoryOther);
    }
  }

  /// Static method to show category selector bottom sheet
  static Future<TodoCategory?> show(
    BuildContext context, {
    TodoCategory? selectedCategory,
  }) async {
    TodoCategory? result;

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => CategorySelector(
        selectedCategory: selectedCategory,
        onCategorySelected: (category) {
          result = category;
        },
      ),
    );

    return result;
  }
}
