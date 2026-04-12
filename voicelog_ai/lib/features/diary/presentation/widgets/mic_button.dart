import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voicelog_ai/core/utils/logger.dart';
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

  /// STT 'done' 상태 수신 후 자동 재시작이 진행 중임을 나타내는 플래그.
  /// 중복 재시작 방지를 위해 사용한다.
  bool _isAutoRestarting = false;

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

  /// STT 세션을 시작한다. recording 상태에서 'done' 발생 시 자동 재호출된다.
  Future<void> _beginListening() async {
    if (!mounted) return;
    _isAutoRestarting = false;

    final sttService = ref.read(speechToTextServiceProvider);
    final notifier = ref.read(diaryRecordNotifierProvider.notifier);
    final sttNotifier = ref.read(sttTextNotifierProvider.notifier);
    final amplitudesNotifier = ref.read(amplitudesNotifierProvider.notifier);

    await sttService.startListening(
      onResult: (text, isFinal) {
        if (!mounted) return;
        // 빈 문자열로 기존 인식 결과를 덮어쓰지 않는다.
        if (text.isNotEmpty) {
          sttNotifier.update(text);
        }
        // final 결과에 텍스트가 있을 때만 처리 단계로 전환.
        // 빈 final 결과는 무시하고 'done' 핸들러에 위임한다.
        if (isFinal && text.isNotEmpty) {
          notifier.startProcessing();
          _stopPulse();
        }
      },
      onAmplitude: (amp) {
        if (!mounted) return;
        amplitudesNotifier.add(amp);
      },
      onError: (errorMsg, permanent) {
        if (!permanent) return;
        if (!mounted) return;
        // permanent 오류 = STT 세션 완전 종료
        // 인식된 텍스트가 있으면 LLM 처리로, 없으면 에러 상태로 전환
        final currentText = ref.read(sttTextNotifierProvider);
        if (currentText.isNotEmpty) {
          notifier.startProcessing();
        } else {
          notifier.setError();
        }
        _stopPulse();
      },
      onStatus: (status) async {
        AppLogger.info('onStatus 핸들러 진입: $status, mounted=$mounted');
        if (!mounted) return;
        if (status != 'done') return;

        final currentState = ref.read(diaryRecordNotifierProvider);
        AppLogger.info('onStatus done: state=$currentState');
        // recording 상태가 아니면 (이미 processing/done/error) 아무것도 하지 않는다.
        if (currentState != RecordingState.recording) return;

        final currentText = ref.read(sttTextNotifierProvider);
        if (currentText.isNotEmpty) {
          // 부분 인식 결과가 있으면 처리 단계로 전환
          notifier.startProcessing();
          _stopPulse();
        } else if (!_isAutoRestarting) {
          // 인식 결과 없음 → STT 세션 자동 재시작
          _isAutoRestarting = true;
          AppLogger.info('STT done (결과 없음) → 자동 재시작');
          await Future<void>.delayed(const Duration(milliseconds: 300));
          if (!mounted) return;
          if (ref.read(diaryRecordNotifierProvider) == RecordingState.recording) {
            await _beginListening();
          }
        }
      },
    );
  }

  Future<void> _onTap() async {
    final state = ref.read(diaryRecordNotifierProvider);
    final sttService = ref.read(speechToTextServiceProvider);
    final notifier = ref.read(diaryRecordNotifierProvider.notifier);

    try {
      if (state == RecordingState.idle) {
        final granted = await sttService.initialize();
        if (!mounted) return;
        if (!granted) return;

        // STT를 먼저 시작하여 마이크를 선점한 뒤 recording 상태로 전환.
        await _beginListening();

        // STT 시작 완료 후 recording 상태로 전환
        if (!mounted) return;
        notifier.startRecording();
        _startPulse();
      } else if (state == RecordingState.recording) {
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
