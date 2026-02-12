import 'dart:convert';

class Habit {
  final String id;
  final String name;
  final String icon;
  final int color;
  final String frequency; // 'daily', 'weekly', or 'custom'
  final List<int> customDays; // weekday numbers 1-7
  final String? reminderTime; // HH:mm format
  final int targetPerDay;
  final List<String> completedDates; // yyyy-MM-dd format
  final DateTime createdAt;
  final List<String> completionTimes; // HH:mm timestamps

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.frequency = 'daily',
    List<int>? customDays,
    this.reminderTime,
    this.targetPerDay = 1,
    List<String>? completedDates,
    DateTime? createdAt,
    List<String>? completionTimes,
  })  : completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now(),
        customDays = customDays ?? [],
        completionTimes = completionTimes ?? [];

  String get _todayString {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool get isCompletedToday => completedDates.contains(_todayString);

  bool get isScheduledToday {
    if (frequency == 'daily') return true;
    if (frequency == 'weekly') return DateTime.now().weekday == 1;
    if (frequency == 'custom' && customDays.isNotEmpty) {
      return customDays.contains(DateTime.now().weekday);
    }
    return true;
  }

  int get currentStreak {
    if (completedDates.isEmpty) return 0;
    final sorted = completedDates.toList()..sort((a, b) => b.compareTo(a));
    final today = DateTime.now();
    final todayStr = _todayString;
    final yesterdayStr = _formatDate(today.subtract(const Duration(days: 1)));

    if (!sorted.contains(todayStr) && !sorted.contains(yesterdayStr)) return 0;

    int streak = 0;
    DateTime checkDate = sorted.contains(todayStr)
        ? today
        : today.subtract(const Duration(days: 1));

    while (true) {
      final dateStr = _formatDate(checkDate);
      if (completedDates.contains(dateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  double get completionRate {
    if (completedDates.isEmpty) return 0.0;
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays + 1;
    final uniqueDates = completedDates.toSet().length;
    return (uniqueDates / daysSinceCreation).clamp(0.0, 1.0);
  }

  /// Habit Strength: 0-100 based on consistency over last 30 days
  double get strength {
    final now = DateTime.now();
    double score = 0.0;
    int totalWeight = 0;

    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = _formatDate(date);
      final weight = 30 - i;
      totalWeight += weight;

      if (completedDates.contains(dateStr)) {
        score += weight;
      }
    }

    if (totalWeight == 0) return 0.0;
    return ((score / totalWeight) * 100).clamp(0.0, 100.0);
  }

  String get frequencyDisplayText {
    if (frequency == 'daily') return 'Daily';
    if (frequency == 'weekly') return 'Weekly';
    if (frequency == 'custom' && customDays.isNotEmpty) {
      const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final labels = customDays.map((d) => dayLabels[d - 1]).toList();
      return labels.join(', ');
    }
    return 'Daily';
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String todayFormatted() => _formatDate(DateTime.now());

  static String nowTimeFormatted() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Habit copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
    String? frequency,
    List<int>? customDays,
    String? reminderTime,
    int? targetPerDay,
    List<String>? completedDates,
    DateTime? createdAt,
    List<String>? completionTimes,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? List<int>.from(this.customDays),
      reminderTime: reminderTime ?? this.reminderTime,
      targetPerDay: targetPerDay ?? this.targetPerDay,
      completedDates: completedDates ?? List<String>.from(this.completedDates),
      createdAt: createdAt ?? this.createdAt,
      completionTimes: completionTimes ?? List<String>.from(this.completionTimes),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'frequency': frequency,
      'customDays': customDays,
      'reminderTime': reminderTime,
      'targetPerDay': targetPerDay,
      'completedDates': completedDates,
      'createdAt': createdAt.toIso8601String(),
      'completionTimes': completionTimes,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as int,
      frequency: json['frequency'] as String? ?? 'daily',
      customDays: (json['customDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      reminderTime: json['reminderTime'] as String?,
      targetPerDay: json['targetPerDay'] as int? ?? 1,
      completedDates: (json['completedDates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      completionTimes: (json['completionTimes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  static String encode(List<Habit> habits) {
    return jsonEncode(habits.map((h) => h.toJson()).toList());
  }

  static List<Habit> decode(String habitsString) {
    final List<dynamic> jsonList = jsonDecode(habitsString) as List<dynamic>;
    return jsonList
        .map((json) => Habit.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
