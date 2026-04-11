import 'dart:math';

import 'package:flutter/material.dart';

/// 녹음 중 실시간 음성 파형을 표시하는 위젯.
///
/// - [isRecording] == true: [amplitudes] 데이터 또는 sin 애니메이션으로 바 파형 표시
/// - [isRecording] == false: 모든 바가 4px 평탄선으로 수렴
///
/// [RepaintBoundary]로 격리하여 파형 repaint가 부모 위젯에 영향을 주지 않는다.
class WaveformWidget extends StatefulWidget {
  const WaveformWidget({
    super.key,
    required this.isRecording,
    this.amplitudes = const [],
  });

  final bool isRecording;

  /// STT 진폭 데이터 (0.0 ~ 1.0). 값이 없으면 sin 애니메이션으로 대체.
  final List<double> amplitudes;

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: 60,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _WaveformPainter(
                isRecording: widget.isRecording,
                amplitudes: widget.amplitudes,
                animationValue: _controller.value,
                color: Theme.of(context).colorScheme.primary,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.isRecording,
    required this.amplitudes,
    required this.animationValue,
    required this.color,
  });

  final bool isRecording;
  final List<double> amplitudes;
  final double animationValue;
  final Color color;

  static const int _barCount = 30;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / (_barCount * 2 - 1);
    final spacing = barWidth;

    for (int i = 0; i < _barCount; i++) {
      final x = i * (barWidth + spacing) + barWidth / 2;
      final barHeight = _barHeight(i, size.height);
      final top = (size.height - barHeight) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - barWidth / 2, top, barWidth, barHeight),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  double _barHeight(int index, double maxHeight) {
    if (!isRecording) return 4.0;

    if (index < amplitudes.length) {
      // 실제 진폭 데이터가 있을 때 — 최소 4px 보장
      return (amplitudes[index] * maxHeight).clamp(4.0, maxHeight);
    }

    // 진폭 없을 때 sin 파형으로 대체 (자연스러운 애니메이션)
    final phase = (index / _barCount) * 2 * pi + animationValue * 2 * pi;
    return (sin(phase).abs() * 0.7 + 0.3) * maxHeight;
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) =>
      oldDelegate.isRecording != isRecording ||
      oldDelegate.animationValue != animationValue ||
      oldDelegate.amplitudes != amplitudes;
}
