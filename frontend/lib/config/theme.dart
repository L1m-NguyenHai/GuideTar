import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryOrange = Color(0xFFFF923E);
  
  // Background & Surface
  static const Color darkBg = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2A2A2A);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFADAAAA);
  static const Color textDark = Color(0xFF1A1A1A);
  
  // Other
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color borderDark = Color(0xFF3A3A3A);
  static const Color divider = Color(0xFF444444);
}

class AppTextStyles {
  static const fontFamily = 'Plus Jakarta Sans';
  
  // Headings
  static TextStyle h1 = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.6,
  );
  
  static TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.33,
    letterSpacing: -0.6,
  );
  
  static TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );
  
  // Body
  static TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.22,
  );
  
  static TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );
  
  // Labels
  static TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 1.4,
  );
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryOrange,
    scaffoldBackgroundColor: AppColors.darkBg,
    fontFamily: AppTextStyles.fontFamily,
    useMaterial3: true,
  );
}
