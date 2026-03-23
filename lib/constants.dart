import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds & Surfaces
  static const Color background = Color(0xFF141414);
  static const Color scaffoldBackground = Color(0xFF1E1E1E);
  static const Color surface1 = Color(0xFF212121);
  static const Color surface2 = Color(0xFF2E2E2E);
  static const Color surface3 = Color(0xFF3B3B3B);
  static const Color surface4 = Color(0xFF474747);

  // Text
  static const Color textPrimary = Color(0xFFE6E6E6);
  static const Color textSecondary = Color(0xFF999999);

  // Accents
  static const Color neonGreen = Color(0xFF34CB36);
  static const Color accentPink = Color(0xFFFF4081);

  // Shimmer colors
  static const Color shimmerBase = Color(0xFF424242); // Darker grey
  static const Color shimmerHighlight = Color(0xFF616161); // Lighter grey
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      useMaterial3: true,
    );
  }
}
