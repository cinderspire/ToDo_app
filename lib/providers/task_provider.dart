import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

/// Toggle for smart sort mode (urgency-based sorting).
final smartSortProvider = StateProvider<bool>((ref) => false);

/// Filter: selected category (null = all)
final categoryFilterProvider = StateProvider<TaskCategory?>((ref) => null);

/// Filter: selected priority (null = all)
final priorityFilterProvider = StateProvider<Priority?>((ref) => null);

/// Filter: show completed tasks toggle
final showCompletedFilterProvider = StateProvider<bool>((ref) => false);

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final smartSort = ref.watch(smartSortProvider);
  final categoryFilter = ref.watch(categoryFilterProvider);
  final priorityFilter = ref.watch(priorityFilterProvider);
  final showCompleted = ref.watch(showCompletedFilterProvider);

  List<Task> result = List.of(tasks);

  // Text search
  if (query.isNotEmpty) {
    result = result.where((task) {
      return task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query) ||
          task.categoryText.toLowerCase().contains(query);
    }).toList();
  }

  // Category filter
  if (categoryFilter != null) {
    result = result.where((task) => task.category == categoryFilter).toList();
  }

  // Priority filter
  if (priorityFilter != null) {
    result = result.where((task) => task.priority == priorityFilter).toList();
  }

  // Show completed toggle - when off, hide completed
  if (!showCompleted) {
    result = result.where((task) => !task.isCompleted).toList();
  }

  if (smartSort) {
    result.sort((a, b) {
      // Completed tasks always go to the bottom
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Sort by urgency score descending
      return b.urgencyScore.compareTo(a.urgencyScore);
    });
  }

  return result;
});

final todayTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(filteredTasksProvider);
  return tasks.where((task) {
    if (task.isCompleted) return false;
    if (task.dueDate == null) return true;
    return task.isDueToday;
  }).toList();
});

final overdueTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(filteredTasksProvider);
  return tasks.where((task) => !task.isCompleted && task.isOverdue).toList();
});

final upcomingTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(filteredTasksProvider);
  return tasks.where((task) => !task.isCompleted && task.isUpcoming).toList();
});

final completedTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks.where((task) => task.isCompleted).toList();
});

/// Provider that returns all tasks due today (including completed ones) for daily planning.
final dailyPlanTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks.where((task) {
    if (task.dueDate == null) return false;
    return task.isDueToday || (task.isOverdue && !task.isCompleted);
  }).toList();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  late Box _taskBox;

  TaskNotifier() : super([]) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _taskBox = Hive.box('tasks');
    final tasksData = _taskBox.get('tasks', defaultValue: <dynamic>[]) as List;
    state = tasksData.map((e) => Task.fromMap(Map<String, dynamic>.from(e))).toList();
    _sortTasks();
  }

  Future<void> _saveTasks() async {
    await _taskBox.put('tasks', state.map((e) => e.toMap()).toList());
  }

  void _sortTasks() {
    state = [...state]..sort((a, b) {
      // Sort by completion status first
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Then by priority
      if (a.priority.index != b.priority.index) {
        return a.priority.index - b.priority.index;
      }
      // Then by due date
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;
      // Finally by creation date
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  void addTask(Task task) {
    state = [...state, task];
    _sortTasks();
    _saveTasks();
  }

  void updateTask(Task task) {
    state = state.map((t) => t.id == task.id ? task : t).toList();
    _sortTasks();
    _saveTasks();
  }

  void deleteTask(String id) {
    state = state.where((t) => t.id != id).toList();
    _saveTasks();
  }

  void toggleComplete(String id) {
    state = state.map((task) {
      if (task.id == id) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();
    _sortTasks();
    _saveTasks();
  }

  void clearCompleted() {
    state = state.where((task) => !task.isCompleted).toList();
    _saveTasks();
  }

  Future<void> refresh() async {
    await _loadTasks();
  }

  // --- Subtask management ---

  void addSubtask(String taskId, SubTask subtask) {
    state = state.map((task) {
      if (task.id == taskId) {
        final updatedSubtasks = [...task.subtasks, subtask];
        return task.copyWith(subtasks: updatedSubtasks);
      }
      return task;
    }).toList();
    _saveTasks();
  }

  void toggleSubtask(String taskId, String subtaskId) {
    state = state.map((task) {
      if (task.id == taskId) {
        final updatedSubtasks = task.subtasks.map((s) {
          if (s.id == subtaskId) {
            return s.copyWith(isCompleted: !s.isCompleted);
          }
          return s;
        }).toList();
        return task.copyWith(subtasks: updatedSubtasks);
      }
      return task;
    }).toList();
    _saveTasks();
  }

  void deleteSubtask(String taskId, String subtaskId) {
    state = state.map((task) {
      if (task.id == taskId) {
        final updatedSubtasks = task.subtasks.where((s) => s.id != subtaskId).toList();
        return task.copyWith(subtasks: updatedSubtasks);
      }
      return task;
    }).toList();
    _saveTasks();
  }
}
