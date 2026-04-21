import 'package:flutter/material.dart';

class AppConstants {
  static const String apiBaseUrl =
      'https://api.pdftoreel.com'; // Update this to your real URL
}

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
  static const Color neonGreen = Color(0xFF16A74B);
  static const Color accentPink = Color(0xFFFF4081);

  // Shimmer colors
  static const Color shimmerBase = Color(0xFF424242); // Darker grey
  static const Color shimmerHighlight = Color(0xFF616161); // Lighter grey

  // Desktop-specific
  static const Color freeTierPurple = Color(0xFFBB86FC);
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

class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const AppLoadingIndicator({
    super.key,
    this.size = 50.0,
    this.strokeWidth = 3.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? AppColors.textPrimary,
        year2023: false,
      ),
    );
  }
}
