import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit_model.dart';

const _storageKey = 'sam_habits';

final habitProvider =
    StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  return HabitNotifier();
});

final todaysHabitsProvider = Provider<List<Habit>>((ref) {
  final habits = ref.watch(habitProvider);
  return habits.where((h) => h.isScheduledToday).toList();
});

final completedTodayHabitCountProvider = Provider<int>((ref) {
  final habits = ref.watch(todaysHabitsProvider);
  return habits.where((h) => h.isCompletedToday).length;
});

final bestCurrentStreakProvider = Provider<int>((ref) {
  final habits = ref.watch(habitProvider);
  if (habits.isEmpty) return 0;
  return habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);
});

class HabitNotifier extends StateNotifier<List<Habit>> {
  HabitNotifier() : super([]) {
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsString = prefs.getString(_storageKey);
    if (habitsString != null && habitsString.isNotEmpty) {
      try {
        state = Habit.decode(habitsString);
      } catch (_) {
        state = [];
      }
    }
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, Habit.encode(state));
  }

  void addHabit(Habit habit) {
    state = [...state, habit];
    _saveHabits();
  }

  void updateHabit(Habit updated) {
    state = [
      for (final h in state)
        if (h.id == updated.id) updated else h,
    ];
    _saveHabits();
  }

  void deleteHabit(String id) {
    state = state.where((h) => h.id != id).toList();
    _saveHabits();
  }

  void toggleCompletion(String habitId, String date) {
    state = [
      for (final h in state)
        if (h.id == habitId)
          h.copyWith(
            completedDates: h.completedDates.contains(date)
                ? (List<String>.from(h.completedDates)..remove(date))
                : [...h.completedDates, date],
            completionTimes: !h.completedDates.contains(date)
                ? [...h.completionTimes, Habit.nowTimeFormatted()]
                : h.completionTimes,
          )
        else
          h,
    ];
    _saveHabits();
  }
}
