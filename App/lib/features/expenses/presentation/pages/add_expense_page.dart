import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import '../../domain/entities/expense.dart';
import '../../../destinations/domain/entities/destination.dart';
import '../providers/expenses_provider.dart';

class AddExpensePage extends ConsumerStatefulWidget {
  final Destination destination;
  final Expense? expense;

  const AddExpensePage({
    super.key,
    required this.destination,
    this.expense,
  });

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  ExpenseCategory _selectedCategory = ExpenseCategory.other;
  DateTime _selectedDate = DateTime.now();
  bool _isPaid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _populateFields(widget.expense!);
    }
  }

  void _populateFields(Expense expense) {
    _nameController.text = expense.name;
    _amountController.text = expense.amount.toString();
    _notesController.text = expense.notes ?? '';
    _selectedCategory = expense.category;
    _selectedDate = expense.date;
    _isPaid = expense.isPaid;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.expense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editExpense : l10n.addExpense),
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveExpense,
            child: Text(
              l10n.save,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.expenseDetails,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // 费用名称
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.expenseName,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterExpenseName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 金额
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: '0.00',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterAmount;
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return l10n.pleaseEnterAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 分类选择
              InkWell(
                onTap: _showCategoryPicker,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.category,
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(_getCategoryIcon(_selectedCategory)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_getCategoryName(_selectedCategory, l10n)),
                      const Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 日期选择
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.date,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(_formatDate(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),

              // 已支付开关
              SwitchListTile(
                title: Text(l10n.alreadyPaid),
                value: _isPaid,
                onChanged: (value) {
                  setState(() {
                    _isPaid = value;
                  });
                },
                activeColor: const Color(0xFF00BCD4),
              ),
              const SizedBox(height: 24),

              // 备注
              Text(
                l10n.notes.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '添加关于此支出的备注...',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: ExpenseCategory.values.map((category) {
                    final isSelected = category == _selectedCategory;
                    return ListTile(
                      leading: Icon(
                        _getCategoryIcon(category),
                        color: isSelected ? const Color(0xFF00BCD4) : null,
                      ),
                      title: Text(
                        _getCategoryName(category, l10n),
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? const Color(0xFF00BCD4) : null,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Color(0xFF00BCD4))
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final l10n = AppLocalizations.of(context);

      if (widget.expense != null) {
        // 更新现有费用
        final updatedExpense = widget.expense!.copyWith(
          name: _nameController.text.trim(),
          amount: double.parse(_amountController.text),
          category: _selectedCategory,
          date: _selectedDate,
          isPaid: _isPaid,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
        await ref.read(expensesProvider.notifier).updateExpense(updatedExpense);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.expenseUpdatedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        // 创建新费用
        final newExpense = Expense.create(
          destinationId: widget.destination.id,
          name: _nameController.text.trim(),
          amount: double.parse(_amountController.text),
          category: _selectedCategory,
          date: _selectedDate,
          isPaid: _isPaid,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
        await ref.read(expensesProvider.notifier).addExpense(newExpense);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.expenseAddedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSavingExpense(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
    return '${date.month}月 ${date.day}, ${date.year}';
  }
}
