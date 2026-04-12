import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voicelog_ai/core/constants/dimensions.dart';
import 'package:voicelog_ai/features/diary/application/diary_record_provider.dart';

/// 녹음 시작/중지 마이크 버튼.
///
/// - idle → recording: 마이크 아이콘 → 일시정지 아이콘, 펄스 애니메이션 시작
/// - recording → processing: 일시정지 → CircularProgressIndicator, 펄스 정지
/// - STT finalResult 또는 수동 중지 시 processing 상태로 전환
class MicButton extends ConsumerStatefulWidget {
  const MicButton({super.key});

  @override
  ConsumerState<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends ConsumerState<MicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    final state = ref.read(diaryRecordNotifierProvider);
    final sttService = ref.read(speechToTextServiceProvider);
    final notifier = ref.read(diaryRecordNotifierProvider.notifier);
    final sttNotifier = ref.read(sttTextNotifierProvider.notifier);

    try {
      if (state == RecordingState.idle) {
        final granted = await sttService.initialize();
        if (!granted) return;
        notifier.startRecording();
        unawaited(_pulseController.repeat(reverse: true));
        final amplitudesNotifier = ref.read(amplitudesNotifierProvider.notifier);
        await sttService.startListening(
          onResult: (text, isFinal) {
            sttNotifier.update(text);
            if (isFinal) {
              notifier.startProcessing();
              _pulseController
                ..stop()
                ..reset();
            }
          },
          onAmplitude: amplitudesNotifier.add,
        );
      } else if (state == RecordingState.recording) {
        await sttService.stopListening();
        notifier.startProcessing();
        _pulseController
          ..stop()
          ..reset();
      }
    } catch (e) {
      notifier.setError();
      _pulseController
        ..stop()
        ..reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(diaryRecordNotifierProvider);
    final isRecording = state == RecordingState.recording;
    final isProcessing = state == RecordingState.processing;
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor =
        isRecording ? colorScheme.error : colorScheme.primary;

    return GestureDetector(
      onTap: isProcessing ? null : _onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 펄스 리플 레이어 (녹음 중에만 표시)
              if (isRecording)
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: AppDimensions.micButtonSize + 24,
                    height: AppDimensions.micButtonSize + 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.18),
                    ),
                  ),
                ),
              child!,
            ],
          );
        },
        child: Container(
          width: AppDimensions.micButtonSize + 24,
          height: AppDimensions.micButtonSize + 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isRecording
                  ? [colorScheme.error, colorScheme.errorContainer]
                  : [colorScheme.primary, colorScheme.primaryContainer],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isProcessing
              ? const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : Icon(
                  isRecording ? Icons.pause_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 38,
                ),
        ),
      ),
    );
  }
}
