import 'package:uuid/uuid.dart';

enum Priority { high, medium, low }

enum TaskCategory { work, personal, shopping, health, other }

class SubTask {
  final String id;
  final String title;
  final bool isCompleted;

  SubTask({
    String? id,
    required this.title,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'] as String,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubTask && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Task {
  final String id;
  final String title;
  final String description;
  final Priority priority;
  final TaskCategory category;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final List<SubTask> subtasks;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.priority = Priority.low,
    this.category = TaskCategory.other,
    this.dueDate,
    this.isCompleted = false,
    DateTime? createdAt,
    List<SubTask>? subtasks,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        subtasks = subtasks ?? [];

  Task copyWith({
    String? id,
    String? title,
    String? description,
    Priority? priority,
    TaskCategory? category,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    List<SubTask>? subtasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.index,
      'category': category.index,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      priority: Priority.values[map['priority'] as int? ?? 2],
      category: TaskCategory.values[map['category'] as int? ?? 4],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      subtasks: (map['subtasks'] as List?)
              ?.map((s) => SubTask.fromMap(Map<String, dynamic>.from(s)))
              .toList() ??
          [],
    );
  }

  String get priorityText {
    switch (priority) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }

  String get categoryText {
    switch (category) {
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.shopping:
        return 'Shopping';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.other:
        return 'Other';
    }
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isBefore(today);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isAtSameMomentAs(today);
  }

  bool get isUpcoming {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isAfter(today);
  }

  /// Computes an urgency score for smart sorting.
  /// Higher score = more urgent. Considers deadline proximity + priority level.
  double get urgencyScore {
    double score = 0;

    // Priority weight (high=30, medium=15, low=5)
    switch (priority) {
      case Priority.high:
        score += 30;
        break;
      case Priority.medium:
        score += 15;
        break;
      case Priority.low:
        score += 5;
        break;
    }

    // Deadline proximity weight
    if (dueDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
      final daysUntilDue = due.difference(today).inDays;

      if (daysUntilDue < 0) {
        // Overdue: massive urgency boost
        score += 50 + (daysUntilDue.abs() * 5).clamp(0, 50);
      } else if (daysUntilDue == 0) {
        // Due today
        score += 40;
      } else if (daysUntilDue == 1) {
        // Due tomorrow
        score += 30;
      } else if (daysUntilDue <= 3) {
        score += 20;
      } else if (daysUntilDue <= 7) {
        score += 10;
      } else {
        score += 5;
      }
    }

    return score;
  }

  /// Returns the number of completed subtasks.
  int get completedSubtaskCount =>
      subtasks.where((s) => s.isCompleted).length;

  /// Returns subtask progress as 0.0 to 1.0, or null if no subtasks.
  double? get subtaskProgress {
    if (subtasks.isEmpty) return null;
    return completedSubtaskCount / subtasks.length;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
