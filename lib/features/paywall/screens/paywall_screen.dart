import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/revenue_cat_service.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.textSecondary,
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Crown icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    size: 52, color: Colors.white),
              ),
              const SizedBox(height: 24),

              Text(
                'Unlock Sam Premium',
                style: AppTextStyles.displaySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Supercharge your productivity',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Feature comparison
              _buildFeatureRow(Icons.task_alt_rounded, 'Unlimited Tasks',
                  'Free: 10 tasks max'),
              _buildFeatureRow(Icons.loop_rounded, 'Habit Tracking',
                  'Build daily routines with streaks'),
              _buildFeatureRow(Icons.auto_awesome_rounded, 'Smart Scheduling',
                  'AI-powered urgency sorting'),
              _buildFeatureRow(Icons.bar_chart_rounded, 'Advanced Statistics',
                  'Weekly reviews & insights'),
              _buildFeatureRow(Icons.palette_rounded, 'Themes & Customization',
                  'Personalize your experience'),
              _buildFeatureRow(Icons.all_inclusive_rounded, 'No Limits',
                  'Unlimited subtasks & categories'),

              const SizedBox(height: 32),

              // Purchase buttons
              if (subscription.availablePackages.isNotEmpty)
                ...subscription.availablePackages.map((pkg) =>
                    _buildPackageButton(context, ref, pkg))
              else
                _buildFallbackButton(context, ref),

              const SizedBox(height: 16),

              // Restore purchases
              TextButton(
                onPressed: () async {
                  HapticFeedback.lightImpact();
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
                    if (restored) Navigator.pop(context);
                  }
                },
                child: Text(
                  'Restore Purchases',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              if (subscription.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  subscription.errorMessage!,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 16),
              Text(
                'Payment will be charged to your App Store / Google Play account. '
                'Subscription automatically renews unless cancelled at least 24 hours '
                'before the end of the current period.',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.titleMedium
                        .copyWith(color: AppColors.textPrimary)),
                Text(subtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 22),
        ],
      ),
    );
  }

  Widget _buildPackageButton(
      BuildContext context, WidgetRef ref, Package package) {
    final product = package.storeProduct;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            HapticFeedback.mediumImpact();
            final success = await ref
                .read(subscriptionProvider.notifier)
                .purchase(package);
            if (context.mounted && success) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Welcome to Sam Premium! 🎉'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: Text(
            '${product.title} - ${product.priceString}',
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackButton(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(subscriptionProvider.notifier).simulatePurchase();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Welcome to Sam Premium! 🎉'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              'Monthly — \$1.99/month',
              style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(subscriptionProvider.notifier).simulatePurchase();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Welcome to Sam Premium! 🎉'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Annual — \$9.99/year (save 58%)',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
