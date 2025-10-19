import 'package:uuid/uuid.dart';

/// Todo Category Enum
enum TodoCategory {
  passport,
  idCard,
  visa,
  insurance,
  ticket,
  hotel,
  carRental,
  other
}

/// Todo Priority Enum
enum TodoPriority {
  high,
  medium,
  low
}

/// Todo Entity
class Todo {
  final String id;
  final String destinationId;
  final String title;
  final String? description;
  final TodoCategory category;
  final TodoPriority priority;
  final bool isCompleted;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Todo({
    required this.id,
    required this.destinationId,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    required this.isCompleted,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a new Todo
  factory Todo.create({
    required String destinationId,
    required String title,
    String? description,
    required TodoCategory category,
    TodoPriority priority = TodoPriority.medium,
    DateTime? deadline,
  }) {
    final now = DateTime.now();
    return Todo(
      id: const Uuid().v4(),
      destinationId: destinationId,
      title: title,
      description: description,
      category: category,
      priority: priority,
      isCompleted: false,
      deadline: deadline,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Copy with method
  Todo copyWith({
    String? id,
    String? destinationId,
    String? title,
    String? description,
    TodoCategory? category,
    TodoPriority? priority,
    bool? isCompleted,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      destinationId: destinationId ?? this.destinationId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Check if todo is overdue
  bool get isOverdue {
    if (deadline == null || isCompleted) return false;
    return DateTime.now().isAfter(deadline!);
  }

  /// Check if deadline is approaching (within 3 days)
  bool get isDeadlineApproaching {
    if (deadline == null || isCompleted) return false;
    final daysUntilDeadline = deadline!.difference(DateTime.now()).inDays;
    return daysUntilDeadline <= 3 && daysUntilDeadline >= 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Todo{id: $id, title: $title, category: $category, isCompleted: $isCompleted}';
  }
}

/// Extension for TodoCategory
extension TodoCategoryExtension on TodoCategory {
  String get value {
    switch (this) {
      case TodoCategory.passport:
        return 'passport';
      case TodoCategory.idCard:
        return 'idCard';
      case TodoCategory.visa:
        return 'visa';
      case TodoCategory.insurance:
        return 'insurance';
      case TodoCategory.ticket:
        return 'ticket';
      case TodoCategory.hotel:
        return 'hotel';
      case TodoCategory.carRental:
        return 'carRental';
      case TodoCategory.other:
        return 'other';
    }
  }

  static TodoCategory fromString(String value) {
    switch (value) {
      case 'passport':
        return TodoCategory.passport;
      case 'idCard':
        return TodoCategory.idCard;
      case 'visa':
        return TodoCategory.visa;
      case 'insurance':
        return TodoCategory.insurance;
      case 'ticket':
        return TodoCategory.ticket;
      case 'hotel':
        return TodoCategory.hotel;
      case 'carRental':
        return TodoCategory.carRental;
      case 'other':
      default:
        return TodoCategory.other;
    }
  }
}

/// Extension for TodoPriority
extension TodoPriorityExtension on TodoPriority {
  String get value {
    switch (this) {
      case TodoPriority.high:
        return 'high';
      case TodoPriority.medium:
        return 'medium';
      case TodoPriority.low:
        return 'low';
    }
  }

  static TodoPriority fromString(String value) {
    switch (value) {
      case 'high':
        return TodoPriority.high;
      case 'medium':
        return TodoPriority.medium;
      case 'low':
      default:
        return TodoPriority.low;
    }
  }
}
