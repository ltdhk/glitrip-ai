import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.destinationId,
    required super.name,
    required super.amount,
    required super.category,
    required super.date,
    required super.isPaid,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      destinationId: json['destination_id'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ExpenseCategory.other,
      ),
      date: DateTime.parse(json['date']),
      isPaid: (json['is_paid'] ?? 0) == 1,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination_id': destinationId,
      'name': name,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
      'is_paid': isPaid ? 1 : 0,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      destinationId: expense.destinationId,
      name: expense.name,
      amount: expense.amount,
      category: expense.category,
      date: expense.date,
      isPaid: expense.isPaid,
      notes: expense.notes,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    );
  }
}
