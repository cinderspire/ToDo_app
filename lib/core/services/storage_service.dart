// Local Storage Service for TaskFlow
import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static Box? _tasksBox;
  static Box? _categoriesBox;

  // Hive Box Names
  static const String tasksBoxName = 'tasks';
  static const String categoriesBoxName = 'categories';

  // Initialize Storage
  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Open boxes
    _tasksBox = await Hive.openBox(tasksBoxName);
    _categoriesBox = await Hive.openBox(categoriesBoxName);
  }

  // Task Methods
  static Box get tasksBox => _tasksBox!;

  static Future<void> saveTask(String id, Map<String, dynamic> data) async {
    await _tasksBox?.put(id, data);
  }

  static Map<String, dynamic>? getTask(String id) {
    final data = _tasksBox?.get(id);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  static List<Map<String, dynamic>> getAllTasks() {
    final tasks = <Map<String, dynamic>>[];
    _tasksBox?.toMap().forEach((key, value) {
      tasks.add(Map<String, dynamic>.from(value));
    });
    return tasks;
  }

  static Future<void> deleteTask(String id) async {
    await _tasksBox?.delete(id);
  }

  static Future<void> updateTask(String id, Map<String, dynamic> data) async {
    await _tasksBox?.put(id, data);
  }

  // Category Methods
  static Box get categoriesBox => _categoriesBox!;

  static Future<void> saveCategory(String id, Map<String, dynamic> data) async {
    await _categoriesBox?.put(id, data);
  }

  static List<Map<String, dynamic>> getAllCategories() {
    final categories = <Map<String, dynamic>>[];
    _categoriesBox?.toMap().forEach((key, value) {
      categories.add(Map<String, dynamic>.from(value));
    });
    return categories;
  }

  static Future<void> deleteCategory(String id) async {
    await _categoriesBox?.delete(id);
  }

  // Clear All Data
  static Future<void> clearAll() async {
    await _tasksBox?.clear();
    await _categoriesBox?.clear();
  }

  // Backup & Restore
  static Map<String, dynamic> exportData() {
    return {
      'tasks': getAllTasks(),
      'categories': getAllCategories(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    // Clear existing
    await _tasksBox?.clear();
    await _categoriesBox?.clear();

    // Import tasks
    final tasks = data['tasks'] as List?;
    if (tasks != null) {
      for (final task in tasks) {
        final taskMap = Map<String, dynamic>.from(task);
        await saveTask(taskMap['id'], taskMap);
      }
    }

    // Import categories
    final categories = data['categories'] as List?;
    if (categories != null) {
      for (final category in categories) {
        final catMap = Map<String, dynamic>.from(category);
        await saveCategory(catMap['id'], catMap);
      }
    }
  }
}
