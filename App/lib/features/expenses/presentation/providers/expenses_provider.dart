import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../../domain/entities/expense.dart';
import '../../data/datasources/expense_local_datasource.dart';
import '../../data/models/expense_model.dart';

class ExpensesNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final ExpenseLocalDataSource _dataSource;

  ExpensesNotifier(this._dataSource) : super(const AsyncValue.loading()) {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final expenses = await _dataSource.getAllExpenses();
      state = AsyncValue.data(expenses);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      await _dataSource.insertExpense(expenseModel);
      await _loadExpenses(); // 重新加载以确保数据同步
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateExpense(Expense updatedExpense) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(updatedExpense);
      await _dataSource.updateExpense(expenseModel);
      await _loadExpenses(); // 重新加载以确保数据同步
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      await _dataSource.deleteExpense(expenseId);
      await _loadExpenses(); // 重新加载以确保数据同步
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  List<Expense> getExpensesForDestination(String destinationId) {
    return state.when(
      data: (expenses) => expenses
          .where((expense) => expense.destinationId == destinationId)
          .toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  double getTotalSpentForDestination(String destinationId) {
    return getExpensesForDestination(destinationId)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  Map<ExpenseCategory, double> getExpensesByCategoryForDestination(
      String destinationId) {
    final expenses = getExpensesForDestination(destinationId);
    final Map<ExpenseCategory, double> categoryTotals = {};

    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0.0) + expense.amount;
    }

    return categoryTotals;
  }
}

// 创建数据源的Provider
final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSource>((ref) {
  return ExpenseLocalDataSource(DatabaseHelper.instance);
});

// 费用管理的Provider
final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, AsyncValue<List<Expense>>>(
  (ref) {
    final dataSource = ref.watch(expenseLocalDataSourceProvider);
    return ExpensesNotifier(dataSource);
  },
);

// 为特定目的地提供费用的Provider
final destinationExpensesProvider = Provider.family<List<Expense>, String>(
  (ref, destinationId) {
    final expensesAsync = ref.watch(expensesProvider);
    return expensesAsync.when(
      data: (expenses) => expenses
          .where((expense) => expense.destinationId == destinationId)
          .toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  },
);

// 为特定目的地提供总花费的Provider
final destinationTotalSpentProvider = Provider.family<double, String>(
  (ref, destinationId) {
    final expenses = ref.watch(destinationExpensesProvider(destinationId));
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  },
);

// 为特定目的地提供分类支出的Provider
final destinationExpensesByCategoryProvider =
    Provider.family<Map<ExpenseCategory, double>, String>(
  (ref, destinationId) {
    final expenses = ref.watch(destinationExpensesProvider(destinationId));
    final Map<ExpenseCategory, double> categoryTotals = {};

    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0.0) + expense.amount;
    }

    return categoryTotals;
  },
);
