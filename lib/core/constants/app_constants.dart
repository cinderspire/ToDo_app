// App Constants for TaskFlow ToDo App
class AppConstants {
  // App Info
  static const String appName = 'TaskFlow';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Simple Task Management';

  // Storage Keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyDefaultSortOrder = 'default_sort_order';
  static const String keyShowCompleted = 'show_completed';

  // Priority Levels
  static const String priorityHigh = 'high';
  static const String priorityMedium = 'medium';
  static const String priorityLow = 'low';

  // Priority Colors (as int for storage)
  static const Map<String, int> priorityColors = {
    'high': 0xFFEF4444,
    'medium': 0xFFF59E0B,
    'low': 0xFF22C55E,
  };

  // Priority Labels
  static const Map<String, String> priorityLabels = {
    'high': 'High Priority',
    'medium': 'Medium Priority',
    'low': 'Low Priority',
  };

  // Sort Options
  static const String sortByDate = 'date';
  static const String sortByPriority = 'priority';
  static const String sortByName = 'name';
  static const String sortByCreated = 'created';

  // Default Categories
  static const List<Map<String, dynamic>> defaultCategories = [
    {'name': 'Personal', 'icon': '👤', 'color': 0xFF6366F1},
    {'name': 'Work', 'icon': '💼', 'color': 0xFF3B82F6},
    {'name': 'Shopping', 'icon': '🛒', 'color': 0xFF10B981},
    {'name': 'Health', 'icon': '❤️', 'color': 0xFFEF4444},
    {'name': 'Home', 'icon': '🏠', 'color': 0xFFF59E0B},
    {'name': 'Other', 'icon': '📌', 'color': 0xFF8B5CF6},
  ];

  // Limits
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;

  // Date Format
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
}
