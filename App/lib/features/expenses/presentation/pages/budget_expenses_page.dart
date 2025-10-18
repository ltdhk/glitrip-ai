import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glitrip/generated/l10n/app_localizations.dart';
import '../../domain/entities/expense.dart';
import '../../../destinations/domain/entities/destination.dart';
import '../providers/expenses_provider.dart';
import 'add_expense_page.dart';

class BudgetExpensesPage extends ConsumerWidget {
  final Destination destination;

  const BudgetExpensesPage({
    super.key,
    required this.destination,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final expenses = ref.watch(destinationExpensesProvider(destination.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.budget} - ${destination.name}'),
        backgroundColor: const Color(0xFF00BCD4),
        foregroundColor: Colors.white,
      ),
      body: Builder(
        builder: (context) {
          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noExpensesYet,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.addFirstExpenseToStartTracking,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          final totalAmount = expenses.fold<double>(
            0,
            (sum, expense) => sum + expense.amount,
          );

          final paidAmount = expenses
              .where((expense) => expense.isPaid)
              .fold<double>(0, (sum, expense) => sum + expense.amount);

          final remainingAmount = totalAmount - paidAmount;

          return Column(
            children: [
              // 预算概览卡片
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.budgetOverview,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBudgetItem(
                          l10n.totalBudget,
                          totalAmount,
                          Colors.white,
                        ),
                        _buildBudgetItem(
                          l10n.paid,
                          paidAmount,
                          Colors.green[300]!,
                        ),
                        _buildBudgetItem(
                          l10n.remaining,
                          remainingAmount,
                          remainingAmount < 0
                              ? Colors.red[300]!
                              : Colors.orange[300]!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 费用列表
              Expanded(
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getCategoryColor(expense.category),
                          child: Icon(
                            _getCategoryIcon(expense.category),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(expense.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getCategoryName(expense.category, l10n),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '¥${expense.amount.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: expense.isPaid
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                            ),
                            if (expense.isPaid)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              )
                            else
                              const Icon(
                                Icons.pending,
                                color: Colors.orange,
                                size: 16,
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddExpensePage(
                                destination: destination,
                                expense: expense,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddExpensePage(destination: destination),
            ),
          );
        },
        backgroundColor: const Color(0xFF00BCD4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBudgetItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '¥${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
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

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.accommodation:
        return Icons.hotel;
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.activities:
        return Icons.attractions;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.insurance:
        return Icons.security;
      case ExpenseCategory.visa:
        return Icons.credit_card;
      case ExpenseCategory.other:
        return Icons.category;
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
}
