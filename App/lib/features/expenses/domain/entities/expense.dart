import 'package:uuid/uuid.dart';

enum ExpenseCategory {
  accommodation,
  transport,
  food,
  activities,
  shopping,
  insurance,
  visa,
  other,
}

class Expense {
  final String id;
  final String destinationId;
  final String name;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final bool isPaid;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.destinationId,
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
    required this.isPaid,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.create({
    required String destinationId,
    required String name,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    bool isPaid = false,
    String? notes,
  }) {
    final now = DateTime.now();
    return Expense(
      id: const Uuid().v4(),
      destinationId: destinationId,
      name: name,
      amount: amount,
      category: category,
      date: date,
      isPaid: isPaid,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  Expense copyWith({
    String? id,
    String? destinationId,
    String? name,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    bool? isPaid,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      destinationId: destinationId ?? this.destinationId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isPaid: isPaid ?? this.isPaid,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Expense{id: $id, name: $name, amount: $amount, category: $category}';
  }
}
