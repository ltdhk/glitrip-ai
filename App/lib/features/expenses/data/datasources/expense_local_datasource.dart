import 'package:flutter/foundation.dart';
import '../../../../core/database/database_helper.dart';
import '../models/expense_model.dart';

class ExpenseLocalDataSource {
  final DatabaseHelper _dbHelper;

  ExpenseLocalDataSource(this._dbHelper);

  Future<List<ExpenseModel>> getAllExpenses() async {
    try {
      final results = await _dbHelper.query(
        'expenses',
        orderBy: 'date DESC',
      );

      return results.map((json) => ExpenseModel.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('获取所有费用时出错: $e');
      }
      return [];
    }
  }

  Future<List<ExpenseModel>> getExpensesByDestination(
      String destinationId) async {
    try {
      final results = await _dbHelper.query(
        'expenses',
        where: 'destination_id = ?',
        whereArgs: [destinationId],
        orderBy: 'date DESC',
      );

      return results.map((json) => ExpenseModel.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('获取目的地费用时出错: $e');
      }
      return [];
    }
  }

  Future<ExpenseModel?> getExpenseById(String id) async {
    try {
      final results = await _dbHelper.query(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isNotEmpty) {
        return ExpenseModel.fromJson(results.first);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('获取费用详情时出错: $e');
      }
      return null;
    }
  }

  Future<void> insertExpense(ExpenseModel expense) async {
    try {
      await _dbHelper.insert('expenses', expense.toJson());
      if (kDebugMode) {
        print('费用已插入: ${expense.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('插入费用时出错: $e');
      }
      rethrow;
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _dbHelper.update(
        'expenses',
        expense.toJson(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
      if (kDebugMode) {
        print('费用已更新: ${expense.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('更新费用时出错: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _dbHelper.delete(
        'expenses',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (kDebugMode) {
        print('费用已删除: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('删除费用时出错: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteExpensesByDestination(String destinationId) async {
    try {
      await _dbHelper.delete(
        'expenses',
        where: 'destination_id = ?',
        whereArgs: [destinationId],
      );
      if (kDebugMode) {
        print('目的地的所有费用已删除: $destinationId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('删除目的地费用时出错: $e');
      }
      rethrow;
    }
  }

  Future<double> getTotalSpentForDestination(String destinationId) async {
    try {
      final results = await _dbHelper.rawQuery(
        'SELECT SUM(amount) as total FROM expenses WHERE destination_id = ?',
        [destinationId],
      );

      if (results.isNotEmpty && results.first['total'] != null) {
        return (results.first['total'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      if (kDebugMode) {
        print('计算总花费时出错: $e');
      }
      return 0.0;
    }
  }
}
