import '../../domain/entities/todo.dart';

/// Todo Data Model
class TodoModel {
  final String id;
  final String destinationId;
  final String title;
  final String? description;
  final String category;
  final String priority;
  final bool isCompleted;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TodoModel({
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

  /// Convert to Entity
  Todo toEntity() {
    return Todo(
      id: id,
      destinationId: destinationId,
      title: title,
      description: description,
      category: TodoCategoryExtension.fromString(category),
      priority: TodoPriorityExtension.fromString(priority),
      isCompleted: isCompleted,
      deadline: deadline,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from Entity
  factory TodoModel.fromEntity(Todo todo) {
    return TodoModel(
      id: todo.id,
      destinationId: todo.destinationId,
      title: todo.title,
      description: todo.description,
      category: todo.category.value,
      priority: todo.priority.value,
      isCompleted: todo.isCompleted,
      deadline: todo.deadline,
      createdAt: todo.createdAt,
      updatedAt: todo.updatedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination_id': destinationId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'is_completed': isCompleted ? 1 : 0,
      'deadline': deadline?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      destinationId: json['destination_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'other',
      priority: json['priority'] as String? ?? 'medium',
      isCompleted: (json['is_completed'] as int) == 1,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Create a copy with updated fields
  TodoModel copyWith({
    String? id,
    String? destinationId,
    String? title,
    String? description,
    String? category,
    String? priority,
    bool? isCompleted,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TodoModel{id: $id, title: $title, category: $category}';
  }
}
