import 'dart:math';

import 'package:flutter/material.dart';

import 'package:voicelog_ai/core/theme/app_colors.dart';

/// 감정 분포 도넛 차트 (CustomPainter 구현).
class EmotionDonutChart extends StatelessWidget {
  const EmotionDonutChart({super.key, required this.counts});

  /// 감정 이름 → 건수 맵
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final total = counts.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('아직 데이터가 없어요.')),
      );
    }

    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(180, 180),
        painter: _DonutPainter(counts: counts, total: total),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.counts, required this.total});

  final Map<String, int> counts;
  final int total;

  static const _emotions = ['기쁨', '평온', '슬픔', '화남'];
  static const _colors = [
    AppColors.emotionJoy,
    AppColors.emotionCalm,
    AppColors.emotionSadness,
    AppColors.emotionAnger,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 28.0;
    const gapAngle = 0.04; // 세그먼트 간 간격 (라디안)

    double startAngle = -pi / 2; // 12시 방향 시작

    for (int i = 0; i < _emotions.length; i++) {
      final emotion = _emotions[i];
      final count = counts[emotion] ?? 0;
      if (count == 0) continue;

      final sweepAngle = (count / total) * 2 * pi - gapAngle;
      final paint = Paint()
        ..color = _colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle + gapAngle / 2,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle + gapAngle;
    }

    // 중앙 총 건수 텍스트
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$total',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF191C1E),
            ),
          ),
          const TextSpan(
            text: '\n건',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9AA0B0),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.counts != counts || old.total != total;
}
