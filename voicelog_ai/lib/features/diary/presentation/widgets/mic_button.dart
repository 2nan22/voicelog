import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voicelog_ai/features/diary/application/diary_record_provider.dart';

/// 녹음 시작/중지 마이크 버튼 — Stitch v0.0.2 스타일.
///
/// - idle: 128px 그라디언트 원형, 마이크 아이콘
/// - recording: 에러 색상 그라디언트, 이중 ping ring 애니메이션
/// - processing: CircularProgressIndicator (탭 불가)
class MicButton extends ConsumerStatefulWidget {
  const MicButton({super.key});

  @override
  ConsumerState<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends ConsumerState<MicButton>
    with TickerProviderStateMixin {
  late AnimationController _ring1;
  late AnimationController _ring2;
  Timer? _ring2Delay;

  @override
  void initState() {
    super.initState();
    _ring1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _ring2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _ring2Delay?.cancel();
    _ring1.dispose();
    _ring2.dispose();
    super.dispose();
  }

  void _startPulse() {
    _ring1.repeat();
    _ring2Delay = Timer(const Duration(milliseconds: 700), () {
      if (mounted) _ring2.repeat();
    });
  }

  void _stopPulse() {
    _ring2Delay?.cancel();
    _ring1
      ..stop()
      ..reset();
    _ring2
      ..stop()
      ..reset();
  }

  Future<void> _onTap() async {
    final state = ref.read(diaryRecordNotifierProvider);
    final sttService = ref.read(speechToTextServiceProvider);
    final notifier = ref.read(diaryRecordNotifierProvider.notifier);
    final handler = ref.read(sttCallbackHandlerProvider.notifier);

    try {
      if (state == RecordingState.idle) {
        final granted = await sttService.initialize();
        if (!mounted) return;
        if (!granted) return;

        notifier.startRecording();
        _startPulse();
        await handler.startSession();
      } else if (state == RecordingState.recording) {
        handler.cancelSession();
        await sttService.stopListening();
        notifier.startProcessing();
        _stopPulse();
      }
    } catch (e) {
      notifier.setError();
      _stopPulse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diaryRecordNotifierProvider);
    final isRecording = state == RecordingState.recording;
    final isProcessing = state == RecordingState.processing;
    final scheme = Theme.of(context).colorScheme;
    final primaryColor = isRecording ? scheme.error : scheme.primary;

    return GestureDetector(
      onTap: isProcessing ? null : _onTap,
      child: SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 외부 ping ring (ring1 — 더 크게 퍼짐)
            if (isRecording)
              AnimatedBuilder(
                animation: _ring1,
                builder: (_, __) => Opacity(
                  opacity: (1.0 - _ring1.value).clamp(0.0, 0.2),
                  child: Transform.scale(
                    scale: 1.0 + _ring1.value * 0.5,
                    child: Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            // 내부 ping ring (ring2 — 약간 지연)
            if (isRecording)
              AnimatedBuilder(
                animation: _ring2,
                builder: (_, __) => Opacity(
                  opacity: (1.0 - _ring2.value).clamp(0.0, 0.35),
                  child: Transform.scale(
                    scale: 1.0 + _ring2.value * 0.3,
                    child: Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            // 메인 버튼 원형
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isRecording
                      ? [scheme.error, scheme.errorContainer]
                      : [scheme.primary, scheme.primaryContainer],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 48,
                    offset: const Offset(0, 24),
                  ),
                ],
              ),
              child: isProcessing
                  ? const Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : Icon(
                      isRecording ? Icons.pause_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 52,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
