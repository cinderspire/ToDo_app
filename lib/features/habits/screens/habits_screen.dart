import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/revenue_cat_service.dart';
import '../../../models/habit_model.dart';
import '../../../providers/habit_provider.dart';
import '../../paywall/screens/paywall_screen.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todaysHabits = ref.watch(todaysHabitsProvider);
    final allHabits = ref.watch(habitProvider);
    final completedCount = ref.watch(completedTodayHabitCountProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Habits',
                    style: AppTextStyles.displaySmall
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedCount/${todaysHabits.length} completed today',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            // Premium banner for free users
            if (!isPremium && allHabits.length >= AppConstants.freeHabitLimit)
              _buildUpgradeBanner(context),

            // Progress ring
            if (todaysHabits.isNotEmpty)
              _buildProgressCard(todaysHabits, completedCount),

            // Habit list
            Expanded(
              child: todaysHabits.isEmpty
                  ? _buildEmptyState(context, ref, isPremium, allHabits.length)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: todaysHabits.length,
                      itemBuilder: (context, index) {
                        final habit = todaysHabits[index];
                        return _buildHabitCard(context, ref, habit);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_habit',
        onPressed: () => _showAddHabitDialog(context, ref, isPremium, allHabits.length),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Habit',
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _buildUpgradeBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PaywallScreen())),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.workspace_premium_rounded,
                  color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unlock Unlimited Habits',
                        style: AppTextStyles.titleMedium
                            .copyWith(color: Colors.white)),
                    Text('Upgrade to Premium for more',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Colors.white70)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(List<Habit> todaysHabits, int completedCount) {
    final progress = todaysHabits.isEmpty
        ? 0.0
        : completedCount / todaysHabits.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accent.withValues(alpha: 0.15),
              AppColors.primary.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            // Circular progress
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: AppColors.border,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.accent),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress >= 1.0
                        ? 'All habits done! 🎉'
                        : progress >= 0.5
                            ? 'Keep going! 💪'
                            : 'Start your routine!',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedCount of ${todaysHabits.length} habits completed',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, WidgetRef ref, Habit habit) {
    final isCompleted = habit.isCompletedToday;
    final habitColor = Color(habit.color);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onLongPress: () => _showHabitOptions(context, ref, habit),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCompleted
                ? habitColor.withValues(alpha: 0.08)
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? habitColor.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Habit icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: habitColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(habit.icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              // Habit info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isCompleted
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded,
                            size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.currentStreak} day streak',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          habit.frequencyDisplayText,
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Toggle button
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref
                      .read(habitProvider.notifier)
                      .toggleCompletion(habit.id, Habit.todayFormatted());
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isCompleted ? habitColor : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted ? habitColor : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 20)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, WidgetRef ref, bool isPremium, int habitCount) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.12),
                    AppColors.primary.withValues(alpha: 0.06),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.loop_rounded,
                  size: 56, color: AppColors.accent.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 28),
            Text('No habits yet',
                style: AppTextStyles.headlineSmall
                    .copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('Build productive routines by adding your first habit',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textTertiary),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () =>
                  _showAddHabitDialog(context, ref, isPremium, habitCount),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add a habit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHabitDialog(
      BuildContext context, WidgetRef ref, bool isPremium, int habitCount) {
    if (!isPremium && habitCount >= AppConstants.freeHabitLimit) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const PaywallScreen()));
      return;
    }

    final nameController = TextEditingController();
    String selectedIcon = '✅';
    int selectedColor = AppColors.primary.toARGB32();

    final icons = ['✅', '💪', '📚', '🏃', '💧', '🧘', '🎯', '✍️', '🍎', '😴'];
    final colors = [
      AppColors.primary.toARGB32(),
      AppColors.accent.toARGB32(),
      AppColors.categoryWork.toARGB32(),
      AppColors.categoryPersonal.toARGB32(),
      AppColors.categoryShopping.toARGB32(),
      AppColors.categoryHealth.toARGB32(),
      AppColors.categoryOther.toARGB32(),
      AppColors.warning.toARGB32(),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('New Habit',
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 16),

              // Name field
              TextField(
                controller: nameController,
                autofocus: true,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Habit name...',
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(height: 16),

              // Icon selector
              Text('Icon',
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: icons
                    .map((icon) => GestureDetector(
                          onTap: () =>
                              setModalState(() => selectedIcon = icon),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: selectedIcon == icon
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectedIcon == icon
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: selectedIcon == icon ? 2 : 1,
                              ),
                            ),
                            child: Center(
                                child: Text(icon,
                                    style: const TextStyle(fontSize: 22))),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Color selector
              Text('Color',
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: colors
                    .map((c) => GestureDetector(
                          onTap: () =>
                              setModalState(() => selectedColor = c),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColor == c
                                    ? AppColors.textPrimary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),

              // Add button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    HapticFeedback.mediumImpact();
                    ref.read(habitProvider.notifier).addHabit(Habit(
                          id: const Uuid().v4(),
                          name: name,
                          icon: selectedIcon,
                          color: selectedColor,
                        ));
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Add Habit',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHabitOptions(BuildContext context, WidgetRef ref, Habit habit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading:
                  const Icon(Icons.delete_rounded, color: AppColors.error),
              title: Text('Delete Habit',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                ref.read(habitProvider.notifier).deleteHabit(habit.id);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
