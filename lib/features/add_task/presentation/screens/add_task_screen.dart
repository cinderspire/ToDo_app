import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/revenue_cat_service.dart';
import '../../../../models/task_model.dart';
import '../../../../providers/task_provider.dart';
import '../../../paywall/screens/paywall_screen.dart';

class AddTaskScreen extends ConsumerStatefulWidget {
  final Task? taskToEdit;

  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  Priority _priority = Priority.low;
  TaskCategory _category = TaskCategory.other;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  bool get isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.taskToEdit?.description ?? '');
    if (widget.taskToEdit != null) {
      _priority = widget.taskToEdit!.priority;
      _category = widget.taskToEdit!.category;
      _dueDate = widget.taskToEdit!.dueDate;
      if (_dueDate != null) {
        _dueTime = TimeOfDay.fromDateTime(_dueDate!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Task' : 'New Task',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: Text(
              'Save',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Task Title',
                hint: 'What do you need to do?',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hint: 'Add more details about this task...',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Priority'),
              const SizedBox(height: 12),
              _buildPrioritySelector(),
              const SizedBox(height: 24),
              _buildSectionTitle('Category'),
              const SizedBox(height: 12),
              _buildCategorySelector(),
              const SizedBox(height: 24),
              _buildSectionTitle('Due Date & Time'),
              const SizedBox(height: 12),
              _buildDatePicker(),
              const SizedBox(height: 12),
              _buildTimePicker(),
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: Priority.values.map((priority) {
        final isSelected = _priority == priority;
        final color = _getPriorityColor(priority);
        final bgColor = _getPriorityBgColor(priority);

        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _priority = priority);
            },
            child: Container(
              margin: EdgeInsets.only(
                right: priority != Priority.low ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? bgColor : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flag_rounded,
                    size: 18,
                    color: isSelected ? color : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getPriorityText(priority),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? color : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TaskCategory.values.map((category) {
        final isSelected = _category == category;
        final color = _getCategoryColor(category);

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _category = category);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(category),
                  size: 18,
                  color: isSelected ? color : AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  _getCategoryText(category),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _dueDate != null
                    ? DateFormat('EEEE, MMMM d, yyyy').format(_dueDate!)
                    : 'Select a due date',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _dueDate != null ? AppColors.textPrimary : AppColors.textTertiary,
                ),
              ),
            ),
            if (_dueDate != null)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AppColors.textTertiary,
                onPressed: () {
                  setState(() => _dueDate = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: _dueDate != null ? _selectTime : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _dueDate != null ? AppColors.surface : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.access_time_rounded,
                size: 20,
                color: _dueDate != null ? AppColors.accent : AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _dueTime != null
                    ? _dueTime!.format(context)
                    : (_dueDate != null ? 'Select a time (optional)' : 'Pick a date first'),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _dueTime != null
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
              ),
            ),
            if (_dueTime != null)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AppColors.textTertiary,
                onPressed: () {
                  setState(() => _dueTime = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  DateTime? get _combinedDueDateTime {
    if (_dueDate == null) return null;
    if (_dueTime == null) return _dueDate;
    return DateTime(
      _dueDate!.year,
      _dueDate!.month,
      _dueDate!.day,
      _dueTime!.hour,
      _dueTime!.minute,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTask,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          isEditing ? 'Update Task' : 'Add Task',
          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = _dueDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    // Enforce free tier limit for new tasks
    if (!isEditing) {
      final isPremium = ref.read(isPremiumProvider);
      final taskCount = ref.read(taskProvider).length;
      if (!isPremium && taskCount >= AppConstants.freeTaskLimit) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaywallScreen()),
        );
        return;
      }
    }

    HapticFeedback.mediumImpact();

    final task = Task(
      id: widget.taskToEdit?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _priority,
      category: _category,
      dueDate: _combinedDueDateTime,
      isCompleted: widget.taskToEdit?.isCompleted ?? false,
      createdAt: widget.taskToEdit?.createdAt,
    );

    if (isEditing) {
      ref.read(taskProvider.notifier).updateTask(task);
    } else {
      ref.read(taskProvider.notifier).addTask(task);
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Task updated' : 'Task added'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
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

  String _getCategoryText(TaskCategory category) {
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
}
