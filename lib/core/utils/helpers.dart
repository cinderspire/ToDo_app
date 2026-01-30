// Helper utilities for TaskFlow ToDo App
import 'package:intl/intl.dart';

class Helpers {
  // Date Formatting
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }

  // Due Date Helpers
  static String getDueDateLabel(DateTime? dueDate) {
    if (dueDate == null) return 'No due date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (dueDay.isBefore(today)) {
      return 'Overdue';
    } else if (dueDay.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dueDay.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else if (dueDay.difference(today).inDays < 7) {
      return DateFormat('EEEE').format(dueDate); // Day name
    } else {
      return formatDate(dueDate);
    }
  }

  static bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return dueDay.isBefore(today);
  }

  static bool isDueToday(DateTime? dueDate) {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  static bool isDueTomorrow(DateTime? dueDate) {
    if (dueDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate.year == tomorrow.year &&
        dueDate.month == tomorrow.month &&
        dueDate.day == tomorrow.day;
  }

  static bool isDueThisWeek(DateTime? dueDate) {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final weekEnd = now.add(Duration(days: 7 - now.weekday));
    return dueDate.isAfter(now) && dueDate.isBefore(weekEnd);
  }

  // Priority Helpers
  static int getPriorityValue(String priority) {
    switch (priority) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }

  // Statistics
  static int countCompleted(List<dynamic> tasks) {
    return tasks.where((t) => t.isCompleted == true).length;
  }

  static int countPending(List<dynamic> tasks) {
    return tasks.where((t) => t.isCompleted == false).length;
  }

  static int countOverdue(List<dynamic> tasks) {
    return tasks.where((t) =>
      t.isCompleted == false &&
      t.dueDate != null &&
      isOverdue(t.dueDate)
    ).length;
  }

  static double getCompletionRate(List<dynamic> tasks) {
    if (tasks.isEmpty) return 0;
    return (countCompleted(tasks) / tasks.length) * 100;
  }

  // String Helpers
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
