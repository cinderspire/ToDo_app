import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/revenue_cat_service.dart';
import '../../../../providers/task_provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../paywall/screens/paywall_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final completedTasks = ref.watch(completedTasksProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Subscription Section
          _buildSectionHeader('Subscription'),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context: context,
            children: [
              _buildActionTile(
                icon: Icons.workspace_premium_rounded,
                iconColor: isPremium ? AppColors.success : const Color(0xFFFFD700),
                title: isPremium ? 'Sam Premium' : 'Upgrade to Premium',
                subtitle: isPremium
                    ? 'All features unlocked'
                    : 'Unlimited tasks, habits & more',
                onTap: () {
                  if (!isPremium) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaywallScreen()),
                    );
                  }
                },
              ),
              if (!isPremium) ...[
                const Divider(height: 1),
                _buildActionTile(
                  icon: Icons.restore_rounded,
                  iconColor: AppColors.info,
                  title: 'Restore Purchases',
                  subtitle: 'Already subscribed? Restore here',
                  onTap: () async {
                    final restored = await ref
                        .read(subscriptionProvider.notifier)
                        .restorePurchases();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(restored
                              ? 'Purchases restored!'
                              : 'No purchases to restore'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context: context,
            children: [
              _buildSwitchTile(
                icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                iconColor: isDark ? Colors.amber : AppColors.primary,
                title: 'Dark Mode',
                subtitle: isDark ? 'Dark theme is active' : 'Light theme is active',
                value: isDark,
                onChanged: (_) {
                  HapticFeedback.lightImpact();
                  ref.read(themeModeProvider.notifier).toggle();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Data Section
          _buildSectionHeader('Data'),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context: context,
            children: [
              _buildActionTile(
                icon: Icons.delete_sweep_rounded,
                iconColor: AppColors.error,
                title: 'Clear Completed Tasks',
                subtitle: '${completedTasks.length} completed task${completedTasks.length == 1 ? '' : 's'}',
                onTap: () => _clearCompletedTasks(context, ref, completedTasks.length),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About'),
          const SizedBox(height: 12),
          _buildSettingsCard(
            context: context,
            children: [
              _buildInfoTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.primary,
                title: AppConstants.appName,
                subtitle: 'Version ${AppConstants.appVersion}',
              ),
              const Divider(height: 1),
              _buildInfoTile(
                icon: Icons.description_outlined,
                iconColor: AppColors.accent,
                title: 'Description',
                subtitle: AppConstants.appTagline,
              ),
              const Divider(height: 1),
              _buildInfoTile(
                icon: Icons.code_rounded,
                iconColor: AppColors.categoryWork,
                title: 'Built with',
                subtitle: 'Flutter & Riverpod',
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Footer
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 40,
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 8),
                Text(
                  AppConstants.appName,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stay organized, stay productive',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textTertiary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
      ),
    );
  }

  void _clearCompletedTasks(BuildContext context, WidgetRef ref, int count) {
    if (count == 0) {
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
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear Completed Tasks',
          style: AppTextStyles.headlineMedium,
        ),
        content: Text(
          'Are you sure you want to delete $count completed task${count > 1 ? 's' : ''}? This action cannot be undone.',
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
              ref.read(taskProvider.notifier).clearCompleted();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$count task${count > 1 ? 's' : ''} cleared'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Text(
              'Clear All',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
