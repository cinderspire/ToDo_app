import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle displayLarge = GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2);
  static TextStyle displayMedium = GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2);
  static TextStyle displaySmall = GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3);

  static TextStyle headlineLarge = GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3);
  static TextStyle headlineMedium = GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3);
  static TextStyle headlineSmall = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle titleLarge = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);
  static TextStyle titleMedium = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4);
  static TextStyle titleSmall = GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle bodyLarge = GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.normal, height: 1.5);
  static TextStyle bodyMedium = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, height: 1.5);
  static TextStyle bodySmall = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal, height: 1.5);

  static TextStyle labelLarge = GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4);
  static TextStyle labelMedium = GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4);
  static TextStyle labelSmall = GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, height: 1.4);
}
