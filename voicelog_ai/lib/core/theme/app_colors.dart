import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary — Stitch v0.0.2 기준 토스/삼성 스타일 Vivid Blue
  static const Color seed = Color(0xFF3182F6);

  // 서피스 계층 (Stitch "Seoul Minimalist" 기준)
  static const Color background          = Color(0xFFF9FAFB);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer    = Color(0xFFE5E8EB);
  static const Color onSurface          = Color(0xFF191F28);
  static const Color onSurfaceVariant   = Color(0xFF4E5968);
  static const Color outlineVariant     = Color(0xFFE5E8EB);

  // 감정 색상
  static const Color emotionJoy     = Color(0xFFFFC107);
  static const Color emotionSadness = Color(0xFF42A5F5);
  static const Color emotionCalm    = Color(0xFF66BB6A);
  static const Color emotionAnger   = Color(0xFFEF5350);

  // 기존 호환
  static const Color surfaceDim = Color(0xFFF5F5F5);
}
