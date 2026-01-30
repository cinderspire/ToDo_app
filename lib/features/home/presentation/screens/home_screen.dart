import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../models/task_model.dart';
import '../../../../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../../../add_task/presentation/screens/add_task_screen.dart';
import '../../../task_detail/screens/task_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  late TabController _tabController;

  // Celebration overlay
  OverlayEntry? _celebrationOverlay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _celebrationOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayTasks = ref.watch(todayTasksProvider);
    final upcomingTasks = ref.watch(upcomingTasksProvider);
    final completedTasks = ref.watch(completedTasksProvider);
    final allTasks = ref.watch(taskProvider);
    final smartSort = ref.watch(smartSortProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_isSearching) _buildSearchBar(),
            _buildDailyPlanSection(),
            _buildStats(allTasks),
            _buildSmartSortToggle(smartSort),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGroupedTaskList(todayTasks, upcomingTasks),
                  _buildTaskList(upcomingTasks, 'Upcoming'),
                  _buildTaskList(completedTasks, 'Completed'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddTask,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Add Task',
          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  // ─── Daily Planning View ─────────────────────────────────────────────
  Widget _buildDailyPlanSection() {
    final allTasks = ref.watch(taskProvider);
    // Tasks due today (or overdue), both completed and incomplete
    final todayAllTasks = allTasks.where((task) {
      if (task.dueDate == null) return false;
      return task.isDueToday || task.isOverdue;
    }).toList();

    if (todayAllTasks.isEmpty) return const SizedBox.shrink();

    final completedCount = todayAllTasks.where((t) => t.isCompleted).length;
    final totalCount = todayAllTasks.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0066FF), Color(0xFF00D4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Today's Plan",
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$completedCount / $totalCount done',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, animValue, _) {
                  return LinearProgressIndicator(
                    value: animValue,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              progress >= 1.0
                  ? 'All done! Great work today!'
                  : progress >= 0.5
                      ? 'Over halfway there - keep going!'
                      : 'Let\'s get started on today\'s tasks!',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Smart Sort Toggle ───────────────────────────────────────────────
  Widget _buildSmartSortToggle(bool smartSort) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: smartSort ? AppColors.primary : AppColors.textTertiary,
          ),
          const SizedBox(width: 6),
          Text(
            'Smart Sort',
            style: AppTextStyles.labelMedium.copyWith(
              color: smartSort ? AppColors.primary : AppColors.textTertiary,
              fontWeight: smartSort ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: 'Sort tasks by urgency (deadline + priority)',
            child: Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: AppColors.textTertiary,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 28,
            child: Switch.adaptive(
              value: smartSort,
              onChanged: (value) {
                HapticFeedback.lightImpact();
                ref.read(smartSortProvider.notifier).state = value;
              },
              activeColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              ),
              Text(
                'My Tasks',
                style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  _isSearching ? Icons.close_rounded : Icons.search_rounded,
                ),
                color: AppColors.textSecondary,
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                color: AppColors.textSecondary,
                onPressed: _showOptionsMenu,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary),
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
      ),
    );
  }

  Widget _buildStats(List<Task> allTasks) {
    final pending = allTasks.where((t) => !t.isCompleted).length;
    final completed = allTasks.where((t) => t.isCompleted).length;
    final highPriority = allTasks.where((t) => !t.isCompleted && t.priority == Priority.high).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Pending',
              '$pending',
              AppColors.warning,
              Icons.pending_actions_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Completed',
              '$completed',
              AppColors.success,
              Icons.check_circle_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'High Priority',
              '$highPriority',
              AppColors.priorityHigh,
              Icons.flag_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, val, _) {
              return Text(
                '$val',
                style: AppTextStyles.headlineMedium.copyWith(color: color),
              );
            },
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.labelMedium,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'Today'),
          Tab(text: 'Upcoming'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }

  // Group tasks by Today, Tomorrow, Later for the first tab
  Widget _buildGroupedTaskList(List<Task> todayTasks, List<Task> upcomingTasks) {
    // Separate upcoming into tomorrow and later
    final tomorrowTasks = <Task>[];
    final laterTasks = <Task>[];

    for (final task in upcomingTasks) {
      if (task.dueDate != null && Helpers.isDueTomorrow(task.dueDate)) {
        tomorrowTasks.add(task);
      } else {
        laterTasks.add(task);
      }
    }

    // If all lists are empty, show empty state
    if (todayTasks.isEmpty && tomorrowTasks.isEmpty && laterTasks.isEmpty) {
      return _buildEmptyState('Today');
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        if (todayTasks.isNotEmpty) ...[
          _buildSectionHeader('Today', todayTasks.length, AppColors.warning),
          ...todayTasks.map((task) => TaskCard(
                task: task,
                onToggle: () => _toggleTask(task),
                onDelete: () => _deleteTask(task),
                onEdit: () => _navigateToDetail(task),
              )),
        ],
        if (tomorrowTasks.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildSectionHeader('Tomorrow', tomorrowTasks.length, AppColors.info),
          ...tomorrowTasks.map((task) => TaskCard(
                task: task,
                onToggle: () => _toggleTask(task),
                onDelete: () => _deleteTask(task),
                onEdit: () => _navigateToDetail(task),
              )),
        ],
        if (laterTasks.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildSectionHeader('Later', laterTasks.length, AppColors.textTertiary),
          ...laterTasks.map((task) => TaskCard(
                task: task,
                onToggle: () => _toggleTask(task),
                onDelete: () => _deleteTask(task),
                onEdit: () => _navigateToDetail(task),
              )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, String category) {
    if (tasks.isEmpty) {
      return _buildEmptyState(category);
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onToggle: () => _toggleTask(task),
          onDelete: () => _deleteTask(task),
          onEdit: () => _navigateToDetail(task),
        );
      },
    );
  }

  Widget _buildEmptyState(String category) {
    IconData icon;
    String message;
    String subtitle;

    switch (category) {
      case 'Today':
        icon = Icons.wb_sunny_rounded;
        message = 'No tasks for today';
        subtitle = 'Enjoy your free time or add a new task';
        break;
      case 'Upcoming':
        icon = Icons.event_rounded;
        message = 'No upcoming tasks';
        subtitle = 'Plan ahead by scheduling future tasks';
        break;
      case 'Completed':
        icon = Icons.emoji_events_rounded;
        message = 'No completed tasks yet';
        subtitle = 'Complete tasks to see them here';
        break;
      default:
        icon = Icons.inbox_rounded;
        message = 'No tasks';
        subtitle = 'Add a task to get started';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.12),
                      AppColors.accent.withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 56, color: AppColors.primary.withOpacity(0.6)),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              message,
              style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (category != 'Completed')
              OutlinedButton.icon(
                onPressed: _navigateToAddTask,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add a task'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _toggleTask(Task task) {
    HapticFeedback.mediumImpact();
    final wasCompleted = task.isCompleted;
    ref.read(taskProvider.notifier).toggleComplete(task.id);

    // If task was NOT completed and is now being completed, celebrate!
    if (!wasCompleted) {
      _showCelebration();
    }
  }

  void _deleteTask(Task task) {
    HapticFeedback.mediumImpact();
    ref.read(taskProvider.notifier).deleteTask(task.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref.read(taskProvider.notifier).addTask(task);
          },
        ),
      ),
    );
  }

  // ─── Task Completion Celebration ─────────────────────────────────────
  void _showCelebration() {
    _celebrationOverlay?.remove();

    final overlay = Overlay.of(context);
    _celebrationOverlay = OverlayEntry(
      builder: (context) => _CelebrationOverlay(
        onComplete: () {
          _celebrationOverlay?.remove();
          _celebrationOverlay = null;
        },
      ),
    );
    overlay.insert(_celebrationOverlay!);
  }

  void _navigateToDetail(Task task) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TaskDetailScreen(task: task),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _navigateToAddTask() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddTaskScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showOptionsMenu() {
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
              leading: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
              title: Text(
                'Clear completed tasks',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                _clearCompletedTasks();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.auto_awesome_rounded,
                color: ref.read(smartSortProvider) ? AppColors.primary : AppColors.textSecondary,
              ),
              title: Text(
                'Toggle Smart Sort',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              ),
              subtitle: Text(
                'Sort by urgency (deadline + priority)',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
              ),
              onTap: () {
                Navigator.pop(context);
                ref.read(smartSortProvider.notifier).state =
                    !ref.read(smartSortProvider);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _clearCompletedTasks() {
    final completedCount = ref.read(completedTasksProvider).length;
    if (completedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No completed tasks to clear'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed Tasks'),
        content: Text('Are you sure you want to delete $completedCount completed task${completedCount > 1 ? 's' : ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(taskProvider.notifier).clearCompleted();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$completedCount task${completedCount > 1 ? 's' : ''} cleared'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Celebration overlay with confetti animation + motivational message
// ═══════════════════════════════════════════════════════════════════════════

class _CelebrationOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  const _CelebrationOverlay({required this.onComplete});

  @override
  State<_CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<_CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late List<_ConfettiParticle> _particles;
  final _random = Random();

  static const _motivationalMessages = [
    'Great job!',
    'Well done!',
    'You rock!',
    'Keep it up!',
    'Nailed it!',
    'Awesome!',
    'Way to go!',
    'Fantastic!',
    'Crushing it!',
    'One step closer!',
  ];

  late String _message;

  @override
  void initState() {
    super.initState();
    _message = _motivationalMessages[_random.nextInt(_motivationalMessages.length)];
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    // Generate confetti particles
    _particles = List.generate(30, (_) => _ConfettiParticle(_random));

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return IgnorePointer(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Stack(
              children: [
                // Confetti particles
                ..._particles.map((p) => _buildParticle(p)),
                // Motivational message in center
                Center(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
                          const SizedBox(width: 10),
                          Text(
                            _message,
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticle(_ConfettiParticle particle) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final progress = _controller.value;

    final x = particle.startX * screenWidth +
        particle.velocityX * progress * 200;
    final y = particle.startY * screenHeight * 0.5 +
        progress * screenHeight * 0.8 * particle.speed +
        sin(progress * pi * 4 * particle.wobble) * 20;

    return Positioned(
      left: x,
      top: y,
      child: Transform.rotate(
        angle: progress * pi * 4 * particle.rotation,
        child: Container(
          width: particle.size,
          height: particle.size * particle.aspectRatio,
          decoration: BoxDecoration(
            color: particle.color.withOpacity(1.0 - progress * 0.5),
            borderRadius: BorderRadius.circular(particle.isCircle ? 50 : 2),
          ),
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  final double startX;
  final double startY;
  final double velocityX;
  final double speed;
  final double size;
  final double aspectRatio;
  final double rotation;
  final double wobble;
  final Color color;
  final bool isCircle;

  _ConfettiParticle(Random random)
      : startX = random.nextDouble(),
        startY = random.nextDouble() * 0.2 - 0.1,
        velocityX = random.nextDouble() * 2 - 1,
        speed = 0.3 + random.nextDouble() * 0.7,
        size = 6 + random.nextDouble() * 8,
        aspectRatio = 0.5 + random.nextDouble() * 1.5,
        rotation = random.nextDouble() * 2 - 1,
        wobble = 0.5 + random.nextDouble(),
        color = [
          const Color(0xFFEF4444),
          const Color(0xFFF59E0B),
          const Color(0xFF10B981),
          const Color(0xFF3B82F6),
          const Color(0xFF8B5CF6),
          const Color(0xFFEC4899),
          const Color(0xFF0066FF),
          const Color(0xFF00D4FF),
        ][random.nextInt(8)],
        isCircle = random.nextBool();
}
