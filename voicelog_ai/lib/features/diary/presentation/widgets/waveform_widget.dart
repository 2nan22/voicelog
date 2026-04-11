import 'package:flutter/material.dart';

/// 녹음 중 실시간 음성 파형을 표시하는 위젯.
///
/// [isRecording]이 true일 때 디자인 시스템의 바 형태 파형을 표시한다.
/// 꼭지 2에서 CustomPainter + AnimationController 기반으로 완성된다.
class WaveformWidget extends StatelessWidget {
  const WaveformWidget({
    super.key,
    required this.isRecording,
    this.amplitudes = const [],
  });

  final bool isRecording;

  /// STT 진폭 데이터 (0.0 ~ 1.0). 꼭지 2에서 활성화.
  final List<double> amplitudes;

  // 디자인 시스템 목업 기준 정적 바 높이 (px)
  static const _staticHeights = [
    12.0, 24.0, 48.0, 32.0, 56.0, 40.0, 64.0, 44.0, 32.0, 20.0, 40.0, 28.0, 16.0,
  ];

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return SizedBox(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_staticHeights.length, (i) {
          final height = isRecording ? _staticHeights[i] : 4.0;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 4,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    );
  }
}
