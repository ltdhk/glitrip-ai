import 'package:flutter/material.dart';
import '../../../../generated/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/todo.dart';

class TodoItemCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggleComplete;
  final VoidCallback? onDelete;

  const TodoItemCard({
    super.key,
    required this.todo,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(todo.id),
      direction: onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.deleteTodo),
            content: Text(l10n.todoDeleteConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.delete),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        onDelete?.call();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                Checkbox(
                  value: todo.isCompleted,
                  onChanged: onToggleComplete != null
                      ? (value) => onToggleComplete!(value ?? false)
                      : null,
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with strike-through if completed
                      Text(
                        todo.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: todo.isCompleted
                              ? Colors.grey
                              : theme.textTheme.titleMedium?.color,
                        ),
                      ),

                      // Description
                      if (todo.description != null &&
                          todo.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          todo.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: todo.isCompleted
                                ? Colors.grey
                                : Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Tags Row (Category, Priority, Deadline)
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          // Category Tag
                          _buildCategoryChip(context, todo.category),

                          // Priority Tag
                          _buildPriorityChip(context, todo.priority),

                          // Deadline Tag
                          if (todo.deadline != null)
                            _buildDeadlineChip(context, todo.deadline!),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Icons
                Column(
                  children: [
                    // Overdue indicator
                    if (todo.isOverdue)
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 20,
                      ),

                    // Deadline approaching indicator
                    if (todo.isDeadlineApproaching && !todo.isOverdue)
                      Icon(
                        Icons.schedule,
                        color: Colors.orange[700],
                        size: 20,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, TodoCategory category) {
    final l10n = AppLocalizations.of(context);
    final (icon, color, label) = _getCategoryInfo(category, l10n);

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(fontSize: 11, color: color),
      ),
      backgroundColor: color.withOpacity(0.1),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildPriorityChip(BuildContext context, TodoPriority priority) {
    final l10n = AppLocalizations.of(context);
    final (color, label) = _getPriorityInfo(priority, l10n);

    return Chip(
      label: Text(
        label,
        style: TextStyle(fontSize: 11, color: color),
      ),
      backgroundColor: color.withOpacity(0.1),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildDeadlineChip(BuildContext context, DateTime deadline) {
    final dateFormat = DateFormat('MMM d');
    final color = todo.isOverdue
        ? Colors.red
        : (todo.isDeadlineApproaching ? Colors.orange : Colors.blue);

    return Chip(
      avatar: Icon(Icons.calendar_today, size: 14, color: color),
      label: Text(
        dateFormat.format(deadline),
        style: TextStyle(fontSize: 11, color: color),
      ),
      backgroundColor: color.withOpacity(0.1),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
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

  (Color, String) _getPriorityInfo(TodoPriority priority, AppLocalizations l10n) {
    switch (priority) {
      case TodoPriority.high:
        return (Colors.red, l10n.priorityHigh);
      case TodoPriority.medium:
        return (Colors.orange, l10n.priorityMedium);
      case TodoPriority.low:
        return (Colors.green, l10n.priorityLow);
    }
  }
}
