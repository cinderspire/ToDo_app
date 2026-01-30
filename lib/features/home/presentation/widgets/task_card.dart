import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    this.onEdit,
  });

  Color get _priorityColor {
    switch (task.priority) {
      case Priority.high:
        return AppColors.priorityHigh;
      case Priority.medium:
        return AppColors.priorityMedium;
      case Priority.low:
        return AppColors.priorityLow;
    }
  }

  Color get _priorityBackgroundColor {
    switch (task.priority) {
      case Priority.high:
        return AppColors.priorityHighLight;
      case Priority.medium:
        return AppColors.priorityMediumLight;
      case Priority.low:
        return AppColors.priorityLowLight;
    }
  }

  Color get _categoryColor {
    return AppColors.getCategoryColor(task.categoryText);
  }

  String get _dueDateText {
    if (task.dueDate == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);

    if (dueDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dueDate.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else if (dueDate.isBefore(today)) {
      return 'Overdue';
    } else {
      return DateFormat('MMM d').format(task.dueDate!);
    }
  }

  Color get _dueDateColor {
    if (task.dueDate == null) return AppColors.textTertiary;
    if (task.isCompleted) return AppColors.textTertiary;
    if (task.isOverdue) return AppColors.error;
    if (task.isDueToday) return AppColors.warning;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: Key(task.id),
        // Swipe RIGHT to complete/undo
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.3,
          dismissible: DismissiblePane(
            onDismissed: onToggle,
            closeOnCancel: true,
          ),
          children: [
            CustomSlidableAction(
              onPressed: (_) => onToggle(),
              backgroundColor: task.isCompleted ? AppColors.warning : AppColors.success,
              foregroundColor: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    task.isCompleted ? Icons.undo_rounded : Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.isCompleted ? 'Undo' : 'Done',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Swipe LEFT to delete (with confirmation)
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.3,
          children: [
            CustomSlidableAction(
              onPressed: (slideContext) {
                _confirmDelete(context);
              },
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    'Delete',
                    style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onEdit?.call();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: task.isCompleted
                    ? AppColors.success.withOpacity(0.3)
                    : AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: task.isCompleted ? AppColors.success : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: task.isCompleted ? AppColors.success : AppColors.textTertiary,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),

                // Priority indicator
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_priorityColor, _priorityColor.withOpacity(0.4)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        task.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: task.isCompleted
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Description
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Subtask progress indicator
                      if (task.subtasks.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildSubtaskProgress(),
                      ],

                      const SizedBox(height: 10),

                      // Tags row
                      Row(
                        children: [
                          // Category chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              task.categoryText,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: _categoryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Priority chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _priorityBackgroundColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flag_rounded,
                                  size: 12,
                                  color: _priorityColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  task.priorityText,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: _priorityColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Due date chip
                          if (task.dueDate != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _dueDateColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    task.isOverdue && !task.isCompleted
                                        ? Icons.warning_rounded
                                        : Icons.schedule_rounded,
                                    size: 12,
                                    color: _dueDateColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _dueDateText,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: _dueDateColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtaskProgress() {
    final completed = task.completedSubtaskCount;
    final total = task.subtasks.length;
    final progress = task.subtaskProgress ?? 0;

    return Row(
      children: [
        Icon(
          Icons.checklist_rounded,
          size: 14,
          color: progress == 1.0 ? AppColors.success : AppColors.textTertiary,
        ),
        const SizedBox(width: 6),
        Text(
          '$completed/$total',
          style: AppTextStyles.labelSmall.copyWith(
            color: progress == 1.0 ? AppColors.success : AppColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, animValue, _) {
                return LinearProgressIndicator(
                  value: animValue,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress == 1.0 ? AppColors.success : AppColors.primary,
                  ),
                  minHeight: 4,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Task',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${task.title}"?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onDelete();
            },
            child: Text(
              'Delete',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
