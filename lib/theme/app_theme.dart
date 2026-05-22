import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Raleway',
        bodyColor: AppColors.deepChocolate,
        displayColor: AppColors.deepChocolate,
      ),
      splashFactory: InkRipple.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.routinyBg,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}

/// Common text styles.
class T {
  T._();
  static const String body = 'Raleway';
  static const String display = 'InterDisplay';
  static const String mono = 'Montserrat';
}
