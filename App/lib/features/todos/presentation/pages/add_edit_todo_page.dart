import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../domain/entities/todo.dart';
import '../widgets/category_selector.dart';
import '../providers/todo_providers.dart';

class AddEditTodoPage extends ConsumerStatefulWidget {
  final String destinationId;
  final Todo? todo;

  const AddEditTodoPage({
    super.key,
    required this.destinationId,
    this.todo,
  });

  @override
  ConsumerState<AddEditTodoPage> createState() => _AddEditTodoPageState();
}

class _AddEditTodoPageState extends ConsumerState<AddEditTodoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  TodoCategory? _selectedCategory;
  TodoPriority _selectedPriority = TodoPriority.medium;
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(text: widget.todo?.description ?? '');
    _selectedCategory = widget.todo?.category;
    _selectedPriority = widget.todo?.priority ?? TodoPriority.medium;
    _selectedDeadline = widget.todo?.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isEditing = widget.todo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editTodo : l10n.addTodo),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTodo,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.todoTitle,
                hintText: l10n.todoTitleRequired,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.todoTitleRequired;
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            // Category Selector
            InkWell(
              onTap: _selectCategory,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.todoCategory,
                  border: const OutlineInputBorder(),
                  prefixIcon: _selectedCategory != null
                      ? Icon(_getCategoryIcon(_selectedCategory!), color: _getCategoryColor(_selectedCategory!))
                      : const Icon(Icons.category),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
                child: Text(
                  _selectedCategory != null
                      ? _getCategoryLabel(_selectedCategory!, l10n)
                      : l10n.selectCategory,
                  style: TextStyle(
                    color: _selectedCategory != null ? theme.textTheme.bodyLarge?.color : Colors.grey,
                  ),
                ),
              ),
            ),

            if (_selectedCategory == null) ...[
              const SizedBox(height: 8),
              Text(
                l10n.todoCategoryRequired,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            ],

            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.todoDescription,
                hintText: '${l10n.todoDescription} (${l10n.optional})',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textInputAction: TextInputAction.newline,
            ),

            const SizedBox(height: 16),

            // Priority Selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.todoPriority,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: TodoPriority.values.map((priority) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(_getPriorityLabel(priority, l10n)),
                          selected: _selectedPriority == priority,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedPriority = priority;
                              });
                            }
                          },
                          selectedColor: _getPriorityColor(priority).withOpacity(0.3),
                          labelStyle: TextStyle(
                            color: _selectedPriority == priority
                                ? _getPriorityColor(priority)
                                : Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Deadline Selector
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(l10n.todoDeadline),
                subtitle: _selectedDeadline != null
                    ? Text(DateFormat('yyyy-MM-dd HH:mm').format(_selectedDeadline!))
                    : Text(l10n.selectDeadline),
                trailing: _selectedDeadline != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedDeadline = null;
                          });
                        },
                      )
                    : null,
                onTap: _selectDeadline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectCategory() async {
    final category = await CategorySelector.show(
      context,
      selectedCategory: _selectedCategory,
    );

    if (category != null) {
      setState(() {
        _selectedCategory = category;
      });
    }
  }

  Future<void> _selectDeadline() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (selectedDate != null && mounted) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDeadline ?? now),
      );

      if (selectedTime != null) {
        setState(() {
          _selectedDeadline = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).todoCategoryRequired),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    final l10n = AppLocalizations.of(context);

    try {
      final repository = await ref.read(todoRepositoryProvider.future);

      if (widget.todo != null) {
        // Update existing todo
        final updatedTodo = widget.todo!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          category: _selectedCategory!,
          priority: _selectedPriority,
          deadline: _selectedDeadline,
        );
        await repository.updateTodo(updatedTodo);
      } else {
        // Create new todo
        final newTodo = Todo.create(
          destinationId: widget.destinationId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          category: _selectedCategory!,
          priority: _selectedPriority,
          deadline: _selectedDeadline,
        );
        await repository.addTodo(newTodo);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.todo != null ? l10n.updateSuccess : l10n.addSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  IconData _getCategoryIcon(TodoCategory category) {
    switch (category) {
      case TodoCategory.passport:
        return Icons.card_travel;
      case TodoCategory.idCard:
        return Icons.badge;
      case TodoCategory.visa:
        return Icons.document_scanner;
      case TodoCategory.insurance:
        return Icons.health_and_safety;
      case TodoCategory.ticket:
        return Icons.flight;
      case TodoCategory.hotel:
        return Icons.hotel;
      case TodoCategory.carRental:
        return Icons.directions_car;
      case TodoCategory.other:
        return Icons.more_horiz;
    }
  }

  Color _getCategoryColor(TodoCategory category) {
    switch (category) {
      case TodoCategory.passport:
        return Colors.purple;
      case TodoCategory.idCard:
        return Colors.blue;
      case TodoCategory.visa:
        return Colors.green;
      case TodoCategory.insurance:
        return Colors.teal;
      case TodoCategory.ticket:
        return Colors.indigo;
      case TodoCategory.hotel:
        return Colors.orange;
      case TodoCategory.carRental:
        return Colors.brown;
      case TodoCategory.other:
        return Colors.grey;
    }
  }

  String _getCategoryLabel(TodoCategory category, AppLocalizations l10n) {
    switch (category) {
      case TodoCategory.passport:
        return l10n.todoCategoryPassport;
      case TodoCategory.idCard:
        return l10n.todoCategoryIdCard;
      case TodoCategory.visa:
        return l10n.todoCategoryVisa;
      case TodoCategory.insurance:
        return l10n.todoCategoryInsurance;
      case TodoCategory.ticket:
        return l10n.todoCategoryTicket;
      case TodoCategory.hotel:
        return l10n.todoCategoryHotel;
      case TodoCategory.carRental:
        return l10n.todoCategoryCarRental;
      case TodoCategory.other:
        return l10n.todoCategoryOther;
    }
  }

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return Colors.red;
      case TodoPriority.medium:
        return Colors.orange;
      case TodoPriority.low:
        return Colors.green;
    }
  }

  String _getPriorityLabel(TodoPriority priority, AppLocalizations l10n) {
    switch (priority) {
      case TodoPriority.high:
        return l10n.priorityHigh;
      case TodoPriority.medium:
        return l10n.priorityMedium;
      case TodoPriority.low:
        return l10n.priorityLow;
    }
  }
}
