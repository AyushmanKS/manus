import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manus/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();
  static String get _bodyFontFamily => Platform.isIOS ? '.SF UI Text' : 'Inter';
  static String get _displayFontFamily =>
      Platform.isIOS ? '.SF UI Display' : 'Inter';
  static String get monoFontFamily => Platform.isIOS ? 'SF Mono' : 'monospace';
  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);
  static ThemeData _buildTheme(final Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color onSurface = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final Color secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final TextTheme baseTextTheme = ThemeData(brightness: brightness).textTheme;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: _bodyFontFamily,
      scaffoldBackgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      dividerColor: isDark ? AppColors.dividerDark : AppColors.dividerLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        onSurface: onSurface,
        outlineVariant: isDark ? AppColors.dotIdleDark : AppColors.dotIdleLight,
        primaryContainer: AppColors.activeBigCircleLight,
        secondaryContainer: isDark
            ? AppColors.msgBubbleBgDark
            : AppColors.msgBubbleBgLight,
        secondary: AppColors.activeSmallCircleLight,
        tertiaryContainer: AppColors.activeHollowCircleLight,
        errorContainer: AppColors.activeTriangleLight,
        surfaceContainerHigh: isDark
            ? AppColors.loaderBgDark
            : AppColors.loaderBgLight,
      ),
      textTheme: baseTextTheme.apply(
        fontFamily: _bodyFontFamily,
        bodyColor: onSurface,
        displayColor: onSurface,
      ).copyWith(
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          color: onSurface,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          fontFamily: _displayFontFamily,
          letterSpacing: -0.5,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          fontFamily: _displayFontFamily,
          letterSpacing: -0.5,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: _displayFontFamily,
          letterSpacing: -0.4,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: onSurface,
          fontSize: 16,
          fontFamily: _bodyFontFamily,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: secondaryText,
          fontSize: 14,
          fontFamily: _bodyFontFamily,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          color: secondaryText,
          fontSize: 12,
          fontFamily: _bodyFontFamily,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w300,
          fontFamily: _bodyFontFamily,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          color: isDark ? AppColors.iconDark : AppColors.textMutedLight,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: _bodyFontFamily,
        ),
      ),
      iconTheme: IconThemeData(
        color: isDark ? AppColors.iconDark : AppColors.textPrimaryLight,
        size: 24,
      ),
    );
  }
}
