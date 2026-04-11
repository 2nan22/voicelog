import 'package:flutter/material.dart';
import 'package:voicelog_ai/core/theme/app_colors.dart';

/// 감정값에 따른 색상 칩 위젯.
/// [emotion]: '기쁨' | '슬픔' | '평온' | '화남'
class EmotionChip extends StatelessWidget {
  const EmotionChip({super.key, required this.emotion});

  final String emotion;

  Color get _chipColor => switch (emotion) {
    '기쁨' => AppColors.emotionJoy,
    '슬픔' => AppColors.emotionSadness,
    '평온' => AppColors.emotionCalm,
    '화남' => AppColors.emotionAnger,
    _ => AppColors.emotionCalm,
  };

  String get _emoji => switch (emotion) {
    '기쁨' => '😊',
    '슬픔' => '😢',
    '평온' => '😌',
    '화남' => '😡',
    _ => '😌',
  };

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$_emoji $emotion'),
      backgroundColor: _chipColor.withValues(alpha: 0.2),
      side: BorderSide(color: _chipColor, width: 1.5),
      labelStyle: TextStyle(
        color: _chipColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
