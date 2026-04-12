import 'package:flutter/material.dart';

import 'package:voicelog_ai/core/theme/app_colors.dart';

ThemeData buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.seed,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Pretendard',
    textTheme: _buildTextTheme(colorScheme),
  );
}

ThemeData buildDarkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.seed,
    brightness: Brightness.dark,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'Pretendard',
    textTheme: _buildTextTheme(colorScheme),
  );
}

/// Pretendard 한국어 자간 -2% 적용
TextTheme _buildTextTheme(ColorScheme colorScheme) {
  const letterSpacingRatio = -0.02;
  return Typography.material2021().black.copyWith(
    displayLarge:   _applySpacing(const TextStyle(fontSize: 57), letterSpacingRatio),
    displayMedium:  _applySpacing(const TextStyle(fontSize: 45), letterSpacingRatio),
    displaySmall:   _applySpacing(const TextStyle(fontSize: 36), letterSpacingRatio),
    headlineLarge:  _applySpacing(const TextStyle(fontSize: 32), letterSpacingRatio),
    headlineMedium: _applySpacing(const TextStyle(fontSize: 28), letterSpacingRatio),
    headlineSmall:  _applySpacing(const TextStyle(fontSize: 24), letterSpacingRatio),
    titleLarge:     _applySpacing(const TextStyle(fontSize: 22), letterSpacingRatio),
    titleMedium:    _applySpacing(const TextStyle(fontSize: 16), letterSpacingRatio),
    titleSmall:     _applySpacing(const TextStyle(fontSize: 14), letterSpacingRatio),
    bodyLarge:      _applySpacing(const TextStyle(fontSize: 16, height: 1.7), letterSpacingRatio),
    bodyMedium:     _applySpacing(const TextStyle(fontSize: 14, height: 1.7), letterSpacingRatio),
    bodySmall:      _applySpacing(const TextStyle(fontSize: 12, height: 1.6), letterSpacingRatio),
    labelLarge:     _applySpacing(const TextStyle(fontSize: 14), letterSpacingRatio),
    labelMedium:    _applySpacing(const TextStyle(fontSize: 12), letterSpacingRatio),
    labelSmall:     _applySpacing(const TextStyle(fontSize: 11), letterSpacingRatio),
  );
}

TextStyle _applySpacing(TextStyle base, double ratio) {
  final size = base.fontSize ?? 14;
  return base.copyWith(letterSpacing: size * ratio);
}
