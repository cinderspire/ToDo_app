import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors - Blue/Cyan Theme (kept from A)
  static const Color primary = Color(0xFF0066FF);
  static const Color primaryLight = Color(0xFF4D94FF);
  static const Color primaryDark = Color(0xFF0052CC);

  // Accent Colors - Cyan
  static const Color accent = Color(0xFF00D4FF);
  static const Color accentLight = Color(0xFF66E5FF);
  static const Color accentDark = Color(0xFF00A3CC);

  // Layout Constants - Boxy/Modern Design
  static const double cardRadius = 8.0;
  static const double buttonRadius = 8.0;
  static const double inputRadius = 8.0;
  static const double chipRadius = 6.0;
  static const double containerRadius = 8.0;

  // Background Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Priority Colors
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityHighLight = Color(0xFFFEE2E2);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityMediumLight = Color(0xFFFEF3C7);
  static const Color priorityLow = Color(0xFF10B981);
  static const Color priorityLowLight = Color(0xFFD1FAE5);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Card & Border Colors
  static const Color backgroundLightCard = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // Shadow Color
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
  );

  // Category Colors
  static const Color categoryWork = Color(0xFF6366F1);
  static const Color categoryPersonal = Color(0xFFEC4899);
  static const Color categoryShopping = Color(0xFF14B8A6);
  static const Color categoryHealth = Color(0xFFF97316);
  static const Color categoryOther = Color(0xFF8B5CF6);

  // Get priority color based on priority level
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return priorityHigh;
      case 'medium':
        return priorityMedium;
      case 'low':
        return priorityLow;
      default:
        return priorityLow;
    }
  }

  // Get priority background color
  static Color getPriorityBackgroundColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return priorityHighLight;
      case 'medium':
        return priorityMediumLight;
      case 'low':
        return priorityLowLight;
      default:
        return priorityLowLight;
    }
  }

  // Get category color
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return categoryWork;
      case 'personal':
        return categoryPersonal;
      case 'shopping':
        return categoryShopping;
      case 'health':
        return categoryHealth;
      default:
        return categoryOther;
    }
  }
}
