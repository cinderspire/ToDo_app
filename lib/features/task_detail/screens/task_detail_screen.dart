import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/task_model.dart';
import '../../../providers/task_provider.dart';
import '../../add_task/presentation/screens/add_task_screen.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the task provider to get the latest version of this task
    final tasks = ref.watch(taskProvider);
    final currentTask = tasks.firstWhere(
      (t) => t.id == widget.task.id,
      orElse: () => widget.task,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Task Details',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            color: AppColors.primary,
            onPressed: () => _navigateToEdit(context, currentTask),
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded),
            color: AppColors.error,
            onPressed: () => _confirmDelete(context, ref, currentTask),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Completion status banner
            _buildStatusBanner(context, ref, currentTask),
            const SizedBox(height: 20),

            // Title
            Text(
              currentTask.title,
              style: AppTextStyles.displaySmall.copyWith(
                color: currentTask.isCompleted
                    ? AppColors.textTertiary
                    : AppColors.textPrimary,
                decoration: currentTask.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            if (currentTask.description.isNotEmpty) ...[
              Text(
                'Description',
                style: AppTextStyles.titleSmall.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  currentTask.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ─── Subtasks Section ──────────────────────────────────────
            _buildSubtasksSection(currentTask),
            const SizedBox(height: 24),

            // Urgency score badge
            _buildUrgencyBadge(currentTask),
            const SizedBox(height: 12),

            // Info cards
            _buildInfoRow(
              icon: Icons.flag_rounded,
              label: 'Priority',
              value: currentTask.priorityText,
              color: _getPriorityColor(currentTask.priority),
              bgColor: _getPriorityBgColor(currentTask.priority),
            ),
            const SizedBox(height: 12),

            _buildInfoRow(
              icon: _getCategoryIcon(currentTask.category),
              label: 'Category',
              value: currentTask.categoryText,
              color: _getCategoryColor(currentTask.category),
              bgColor: _getCategoryColor(currentTask.category).withOpacity(0.1),
            ),
            const SizedBox(height: 12),

            _buildInfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Due Date',
              value: currentTask.dueDate != null
                  ? DateFormat('EEEE, MMMM d, yyyy').format(currentTask.dueDate!)
                  : 'No due date set',
              color: currentTask.dueDate != null
                  ? _getDueDateColor(currentTask)
                  : AppColors.textTertiary,
              bgColor: currentTask.dueDate != null
                  ? _getDueDateColor(currentTask).withOpacity(0.1)
                  : AppColors.surfaceVariant,
              subtitle: currentTask.dueDate != null
                  ? Helpers.getDueDateLabel(currentTask.dueDate)
                  : null,
            ),
            const SizedBox(height: 12),

            if (currentTask.dueDate != null &&
                currentTask.dueDate!.hour != 0) ...[
              _buildInfoRow(
                icon: Icons.access_time_rounded,
                label: 'Due Time',
                value: DateFormat('hh:mm a').format(currentTask.dueDate!),
                color: AppColors.accent,
                bgColor: AppColors.accent.withOpacity(0.1),
              ),
              const SizedBox(height: 12),
            ],

            _buildInfoRow(
              icon: Icons.calendar_month_rounded,
              label: 'Created',
              value: DateFormat('MMMM d, yyyy - hh:mm a').format(currentTask.createdAt),
              color: AppColors.textSecondary,
              bgColor: AppColors.surfaceVariant,
            ),
            const SizedBox(height: 32),

            // Action buttons
            _buildActionButtons(context, ref, currentTask),
          ],
        ),
      ),
    );
  }

  // ─── Urgency Score Badge ──────────────────────────────────────────────
  Widget _buildUrgencyBadge(Task task) {
    if (task.isCompleted) return const SizedBox.shrink();

    final score = task.urgencyScore;
    final Color badgeColor;
    final String label;

    if (score >= 60) {
      badgeColor = AppColors.error;
      label = 'Critical Urgency';
    } else if (score >= 40) {
      badgeColor = AppColors.warning;
      label = 'High Urgency';
    } else if (score >= 20) {
      badgeColor = AppColors.info;
      label = 'Moderate Urgency';
    } else {
      badgeColor = AppColors.success;
      label = 'Low Urgency';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, color: badgeColor, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart Urgency Score',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: 2),
              Text(
                '$label  (${score.toStringAsFixed(0)} pts)',
                style: AppTextStyles.titleMedium.copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Subtasks Section ─────────────────────────────────────────────────
  Widget _buildSubtasksSection(Task task) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.checklist_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Subtasks',
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
                ),
                if (task.subtasks.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (task.subtaskProgress == 1.0
                              ? AppColors.success
                              : AppColors.primary)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${task.completedSubtaskCount}/${task.subtasks.length}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: task.subtaskProgress == 1.0
                            ? AppColors.success
                            : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Progress bar for subtasks
          if (task.subtasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: task.subtaskProgress ?? 0,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    task.subtaskProgress == 1.0
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                  minHeight: 4,
                ),
              ),
            ),

          // Subtask list
          if (task.subtasks.isNotEmpty)
            ...task.subtasks.map((subtask) => _buildSubtaskItem(task, subtask)),

          // Add subtask input
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subtaskController,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Add a subtask...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addSubtask(task.id),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _addSubtask(task.id),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtaskItem(Task task, SubTask subtask) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(taskProvider.notifier).toggleSubtask(task.id, subtask.id);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: subtask.isCompleted ? AppColors.success : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: subtask.isCompleted ? AppColors.success : AppColors.textTertiary,
                width: 2,
              ),
            ),
            child: subtask.isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : null,
          ),
        ),
        title: Text(
          subtask.title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: subtask.isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
            decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: GestureDetector(
          onTap: () {
            ref.read(taskProvider.notifier).deleteSubtask(task.id, subtask.id);
          },
          child: Icon(
            Icons.close_rounded,
            size: 18,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  void _addSubtask(String taskId) {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    ref.read(taskProvider.notifier).addSubtask(
          taskId,
          SubTask(title: text),
        );
    _subtaskController.clear();
  }

  Widget _buildStatusBanner(BuildContext context, WidgetRef ref, Task task) {
    final isOverdue = task.isOverdue;
    final Color bannerColor;
    final IconData bannerIcon;
    final String bannerText;

    if (task.isCompleted) {
      bannerColor = AppColors.success;
      bannerIcon = Icons.check_circle_rounded;
      bannerText = 'Completed';
    } else if (isOverdue) {
      bannerColor = AppColors.error;
      bannerIcon = Icons.warning_rounded;
      bannerText = 'Overdue';
    } else if (task.isDueToday) {
      bannerColor = AppColors.warning;
      bannerIcon = Icons.schedule_rounded;
      bannerText = 'Due Today';
    } else {
      bannerColor = AppColors.primary;
      bannerIcon = Icons.pending_rounded;
      bannerText = 'In Progress';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(bannerIcon, color: bannerColor, size: 22),
          const SizedBox(width: 12),
          Text(
            bannerText,
            style: AppTextStyles.titleMedium.copyWith(color: bannerColor),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              ref.read(taskProvider.notifier).toggleComplete(task.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: bannerColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                task.isCompleted ? 'Mark Incomplete' : 'Mark Complete',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSmall.copyWith(color: color),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, Task currentTask) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _navigateToEdit(context, currentTask),
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Edit Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmDelete(context, ref, currentTask),
            icon: const Icon(Icons.delete_rounded),
            label: const Text('Delete Task'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToEdit(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(taskToEdit: task),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Task',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
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
              ref.read(taskProvider.notifier).deleteTask(task.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Task deleted'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
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

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return AppColors.priorityHigh;
      case Priority.medium:
        return AppColors.priorityMedium;
      case Priority.low:
        return AppColors.priorityLow;
    }
  }

  Color _getPriorityBgColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return AppColors.priorityHighLight;
      case Priority.medium:
        return AppColors.priorityMediumLight;
      case Priority.low:
        return AppColors.priorityLowLight;
    }
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return AppColors.categoryWork;
      case TaskCategory.personal:
        return AppColors.categoryPersonal;
      case TaskCategory.shopping:
        return AppColors.categoryShopping;
      case TaskCategory.health:
        return AppColors.categoryHealth;
      case TaskCategory.other:
        return AppColors.categoryOther;
    }
  }

  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Icons.work_rounded;
      case TaskCategory.personal:
        return Icons.person_rounded;
      case TaskCategory.shopping:
        return Icons.shopping_bag_rounded;
      case TaskCategory.health:
        return Icons.favorite_rounded;
      case TaskCategory.other:
        return Icons.more_horiz_rounded;
    }
  }

  Color _getDueDateColor(Task task) {
    if (task.isCompleted) return AppColors.textTertiary;
    if (task.isOverdue) return AppColors.error;
    if (task.isDueToday) return AppColors.warning;
    return AppColors.primary;
  }
}
