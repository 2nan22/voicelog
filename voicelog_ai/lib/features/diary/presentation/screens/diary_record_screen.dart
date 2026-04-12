import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/prompts.dart';
import 'package:voicelog_ai/core/constants/routes.dart';
import 'package:voicelog_ai/core/constants/strings.dart';
import 'package:voicelog_ai/core/theme/app_colors.dart';
import 'package:voicelog_ai/core/utils/logger.dart';
import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';
import 'package:voicelog_ai/features/diary/application/diary_process_provider.dart';
import 'package:voicelog_ai/features/diary/application/diary_record_provider.dart';
import 'package:voicelog_ai/features/diary/application/llm_provider.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';
import 'package:voicelog_ai/features/diary/presentation/widgets/diary_result_widget.dart';
import 'package:voicelog_ai/features/diary/presentation/widgets/mic_button.dart';
import 'package:voicelog_ai/features/diary/presentation/widgets/streaming_text_widget.dart';
import 'package:voicelog_ai/features/diary/presentation/widgets/waveform_widget.dart';
import 'package:voicelog_ai/features/settings/application/settings_provider.dart';
import 'package:voicelog_ai/features/settings/domain/app_settings.dart';

/// 음성 녹음 및 STT/LLM 결과 확인 화면 — Stitch v0.0.2 풀스크린 레이아웃.
///
/// 레이아웃: 앰비언트 글로우 배경 + 상태별 배지/헤딩 + 글래스모픽 컨테이너 + 컨트롤 버튼.
/// 스크롤 없이 Column으로 수직 분배. 모든 비즈니스 로직은 그대로 유지.
class DiaryRecordScreen extends ConsumerStatefulWidget {
  const DiaryRecordScreen({super.key});

  @override
  ConsumerState<DiaryRecordScreen> createState() => _DiaryRecordScreenState();
}

class _DiaryRecordScreenState extends ConsumerState<DiaryRecordScreen>
    with TickerProviderStateMixin {
  Timer? _recordingTimer;
  Timer? _inferenceTimer;
  int _elapsedSeconds = 0;

  // ── 오디오 녹음 · 재생 ──────────────────────────────────────────────────────
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  String? _recordedFilePath;
  bool _isPlaying = false;
  late final StreamSubscription<PlayerState> _playerStateSub;

  @override
  void initState() {
    super.initState();
    _playerStateSub = _audioPlayer.onPlayerStateChanged.listen((playerState) {
      if (mounted) setState(() => _isPlaying = playerState == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _inferenceTimer?.cancel();
    _playerStateSub.cancel();
    unawaited(_audioRecorder.dispose());
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  void _startTimer() {
    _elapsedSeconds = 0;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  String get _timerDisplay {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── 오디오 녹음 ─────────────────────────────────────────────────────────────

  Future<void> _startAudioRecording() async {
    try {
      final dir = await getTemporaryDirectory();
      _recordedFilePath =
          '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _recordedFilePath!,
      );
    } catch (e) {
      AppLogger.error('오디오 녹음 시작 실패', e);
    }
  }

  Future<void> _stopAudioRecording() async {
    try {
      await _audioRecorder.stop();
    } catch (e) {
      AppLogger.error('오디오 녹음 중지 실패', e);
    }
  }

  // ── 오디오 재생 ─────────────────────────────────────────────────────────────

  void _togglePlayback() {
    unawaited(_doTogglePlayback());
  }

  Future<void> _doTogglePlayback() async {
    if (_recordedFilePath == null) return;
    try {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(DeviceFileSource(_recordedFilePath!));
      }
    } catch (e) {
      AppLogger.error('오디오 재생 실패', e);
    }
  }

  // ── LLM 추론 타임아웃 ────────────────────────────────────────────────────────

  void _startInferenceTimer() {
    _inferenceTimer?.cancel();
    _inferenceTimer = Timer(const Duration(seconds: kInferenceTimeoutSeconds), () {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('처리 지연'),
          content: const Text(AppStrings.errorTimeout),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _runLLMFlow(String rawText) async {
    final service = ref.read(llmInferenceServiceProvider);
    final processNotifier = ref.read(diaryProcessNotifierProvider.notifier);

    if (!service.isReady) {
      try {
        await service.initialize();
      } catch (e) {
        if (!mounted) return;
        AppLogger.error('LLM 재초기화 실패', e);
        ref.read(diaryRecordNotifierProvider.notifier).setError();
        return;
      }
    }

    try {
      final settingsAsync = ref.read(settingsNotifierProvider);
      final writingStyle = settingsAsync.valueOrNull?.writingStyle ?? WritingStyle.diary;
      final styleInstruction =
          kWritingStyleInstructions[writingStyle] ?? kWritingStyleInstructions[WritingStyle.diary]!;
      final prompt = kDiaryProcessingPrompt
          .replaceAll('{style_instruction}', styleInstruction)
          .replaceAll('{raw_text}', rawText);

      await for (final chunk in service.generateStream(prompt)) {
        if (!mounted) return;
        if (ref.read(diaryRecordNotifierProvider) != RecordingState.processing) {
          return;
        }
        processNotifier.appendChunk(chunk);
      }
      if (!mounted) return;
      processNotifier.finalize();
      _inferenceTimer?.cancel();
      ref.read(diaryRecordNotifierProvider.notifier).finishRecording();
    } catch (e) {
      if (!mounted) return;
      _inferenceTimer?.cancel();
      AppLogger.error('LLM 처리 실패', e);
      ref.read(diaryRecordNotifierProvider.notifier).setError();
    }
  }

  void _onDelete() {
    _inferenceTimer?.cancel();
    if (ref.read(diaryRecordNotifierProvider) == RecordingState.processing) {
      ref.read(llmInferenceServiceProvider).dispose();
    }
    try {
      ref.read(speechToTextServiceProvider).cancelListening();
    } catch (_) {}
    ref.read(diaryRecordNotifierProvider.notifier).reset();
    ref.read(sttTextNotifierProvider.notifier).clear();
    ref.read(diaryProcessNotifierProvider.notifier).reset();
    ref.read(amplitudesNotifierProvider.notifier).clear();
    _recordedFilePath = null;
    unawaited(_audioPlayer.stop());
    _stopTimer();
    setState(() => _elapsedSeconds = 0);
  }

  void _onFinishRecording() {
    unawaited(_finishRecordingAsync());
  }

  Future<void> _finishRecordingAsync() async {
    final sttService = ref.read(speechToTextServiceProvider);
    final notifier = ref.read(diaryRecordNotifierProvider.notifier);
    try {
      await sttService.stopListening();
      notifier.startProcessing();
    } catch (e) {
      AppLogger.error('STT 중지 실패', e);
      notifier.setError();
    }
  }

  Future<void> _onSave() async {
    final processState = ref.read(diaryProcessNotifierProvider);
    final parsedResult = processState.parsedResult;
    if (parsedResult == null) return;

    final rawText = ref.read(sttTextNotifierProvider);
    final entry = DiaryEntry.create(
      rawText: rawText,
      correctedText: parsedResult.correctedText,
      emotion: parsedResult.emotion,
      tags: parsedResult.tags,
    );

    try {
      await ref.read(diaryListNotifierProvider.notifier).addEntry(entry);
      if (!mounted) return;
      ref.read(llmInferenceServiceProvider).dispose();
      ref.read(diaryRecordNotifierProvider.notifier).reset();
      ref.read(sttTextNotifierProvider.notifier).clear();
      ref.read(diaryProcessNotifierProvider.notifier).reset();
      context.go(AppRoutes.diaryList);
    } catch (e) {
      AppLogger.error('일기 저장 실패', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장에 실패했어요. 다시 시도해 주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(diaryRecordNotifierProvider);
    final sttText = ref.watch(sttTextNotifierProvider);
    final amplitudes = ref.watch(amplitudesNotifierProvider);
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final scheme = Theme.of(context).colorScheme;

    // 상태 변화 감지 — 타이머·오디오·LLM 흐름 관리 (로직 변경 없음)
    ref.listen<RecordingState>(diaryRecordNotifierProvider, (prev, next) {
      if (prev != RecordingState.recording && next == RecordingState.recording) {
        _startTimer();
        unawaited(_startAudioRecording());
      } else if (prev == RecordingState.recording &&
          next != RecordingState.recording) {
        _stopTimer();
        unawaited(_stopAudioRecording());
      }
      if (prev != RecordingState.processing &&
          next == RecordingState.processing) {
        final rawText = ref.read(sttTextNotifierProvider);
        if (rawText.isNotEmpty) {
          ref.read(diaryProcessNotifierProvider.notifier).reset();
          _startInferenceTimer();
          // ignore: discarded_futures
          _runLLMFlow(rawText);
        } else {
          ref.read(diaryRecordNotifierProvider.notifier).finishRecording();
        }
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 앰비언트 글로우 배경
          const _AmbientBackground(),
          // 메인 콘텐츠 Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 글래스 헤더 높이만큼 상단 여백
              SizedBox(height: topPadding + 64),
              // 스크롤 없는 콘텐츠 영역
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(flex: 1),
                      // 상태 배지
                      _RecordingStateBadge(state: recordingState),
                      const SizedBox(height: 16),
                      // 상태별 대형 헤딩
                      Text(
                        _headingText(recordingState),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 서브 텍스트
                      Text(
                        _subtitleText(recordingState),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // STT/LLM 통합 글래스모픽 컨테이너
                      _GlassSttContainer(
                        sttText: sttText,
                        recordingState: recordingState,
                      ),
                      const SizedBox(height: 16),
                      // AI 처리 중 배지 (processing 상태에만)
                      if (recordingState == RecordingState.processing)
                        const _AiStatusBadge(),
                      const Spacer(flex: 2),
                      // 파형 (recording 상태에만)
                      if (recordingState == RecordingState.recording) ...[
                        WaveformWidget(
                          isRecording: true,
                          amplitudes: amplitudes,
                        ),
                        const SizedBox(height: 24),
                      ],
                      // 컨트롤 버튼 행
                      Center(
                        child: _ControlsRow(
                          recordingState: recordingState,
                          timerDisplay: _timerDisplay,
                          isPlaying: _isPlaying,
                          onDelete: _onDelete,
                          onFinishRecording: _onFinishRecording,
                          onSave: _onSave,
                          onPlayback: _togglePlayback,
                        ),
                      ),
                      SizedBox(height: bottomPadding + 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 글래스 헤더 (Positioned 오버레이)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _GlassHeader(
              recordingState: recordingState,
              scheme: scheme,
              topPadding: topPadding,
              onClose: () => context.pop(),
              onSave: _onSave,
            ),
          ),
        ],
      ),
    );
  }

  String _headingText(RecordingState state) => switch (state) {
    RecordingState.idle       => '오늘의 목소리를\n담아보세요',
    RecordingState.recording  => '생각을 기록하고\n있습니다',
    RecordingState.processing => 'AI가\n다듬는 중입니다',
    RecordingState.done       => '보정이\n완료되었습니다',
    RecordingState.error      => '문제가\n발생했어요',
  };

  String _subtitleText(RecordingState state) => switch (state) {
    RecordingState.idle       => '마이크 버튼을 눌러 시작하세요',
    RecordingState.recording  => '자연스럽게 말씀해 주세요',
    RecordingState.processing => '잠시만 기다려 주세요',
    RecordingState.done       => '일기를 저장하거나 다시 녹음할 수 있어요',
    RecordingState.error      => '다시 시도해 보세요',
  };
}

// ─── 앰비언트 글로우 배경 ─────────────────────────────────────────────────────

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox.expand(
      child: Stack(
        children: [
          // 우상단 블로브
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          // 좌하단 블로브
          Positioned(
            bottom: -60,
            left: -120,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.06),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 글래스 헤더 ──────────────────────────────────────────────────────────────

class _GlassHeader extends StatelessWidget {
  const _GlassHeader({
    required this.recordingState,
    required this.scheme,
    required this.topPadding,
    required this.onClose,
    required this.onSave,
  });

  final RecordingState recordingState;
  final ColorScheme scheme;
  final double topPadding;
  final VoidCallback onClose;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: topPadding + 64,
          color: Colors.white.withValues(alpha: 0.8),
          padding: EdgeInsets.only(
            top: topPadding,
            left: 8,
            right: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
                color: AppColors.onSurfaceVariant,
                tooltip: '닫기',
              ),
              Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: scheme.primary,
                ),
              ),
              if (recordingState == RecordingState.done)
                TextButton(
                  onPressed: onSave,
                  child: Text(
                    AppStrings.saveDiary,
                    style: TextStyle(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                const SizedBox(width: 64),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 상태 배지 ────────────────────────────────────────────────────────────────

class _RecordingStateBadge extends StatelessWidget {
  const _RecordingStateBadge({required this.state});

  final RecordingState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (state == RecordingState.idle || state == RecordingState.error) {
      return const SizedBox.shrink();
    }

    final (Color bg, Color fg, IconData icon, String label) = switch (state) {
      RecordingState.recording  => (scheme.errorContainer, scheme.error, Icons.fiber_manual_record, '실시간 녹음 중'),
      RecordingState.processing => (scheme.primaryContainer, scheme.primary, Icons.auto_awesome_rounded, 'AI 처리 중'),
      RecordingState.done       => (scheme.secondaryContainer, scheme.secondary, Icons.check_circle_rounded, '보정 완료'),
      _                         => (scheme.primaryContainer, scheme.primary, Icons.info_outline_rounded, ''),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── STT/LLM 통합 글래스모픽 컨테이너 ──────────────────────────────────────────

/// idle/recording: sttText 표시 (블링킹 커서 포함)
/// processing/done: LLM 스트리밍 텍스트 → 파싱 완료 후 DiaryResultWidget 표시
class _GlassSttContainer extends ConsumerWidget {
  const _GlassSttContainer({
    required this.sttText,
    required this.recordingState,
  });

  final String sttText;
  final RecordingState recordingState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLlmPhase = recordingState == RecordingState.processing ||
        recordingState == RecordingState.done;
    final parsedResult = isLlmPhase
        ? ref.watch(diaryProcessNotifierProvider.select((s) => s.parsedResult))
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 200),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: isLlmPhase
              ? _buildLlmContent(context, parsedResult)
              : _buildSttContent(context),
        ),
      ),
    );
  }

  Widget _buildSttContent(BuildContext context) {
    if (sttText.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_none_rounded,
            size: 40,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.recordStart,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            sttText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.6,
              color: AppColors.onSurface,
            ),
          ),
        ),
        if (recordingState == RecordingState.recording)
          const _BlinkingCursor(),
      ],
    );
  }

  Widget _buildLlmContent(BuildContext context, dynamic parsedResult) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI 보정 라벨
        Text(
          'AI 보정',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: scheme.primary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        // 스트리밍 텍스트
        const StreamingTextWidget(),
        // 파싱 완료 후 감정·태그 뱃지
        if (parsedResult != null) ...[
          const SizedBox(height: 16),
          Divider(height: 1, color: scheme.outlineVariant),
          const SizedBox(height: 16),
          const DiaryResultWidget(),
        ],
      ],
    );
  }
}

// ─── AI 상태 배지 ─────────────────────────────────────────────────────────────

class _AiStatusBadge extends StatefulWidget {
  const _AiStatusBadge();

  @override
  State<_AiStatusBadge> createState() => _AiStatusBadgeState();
}

class _AiStatusBadgeState extends State<_AiStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotationTransition(
            turns: _spinController,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'AI 엔진 가동 중',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 블링킹 커서 ──────────────────────────────────────────────────────────────

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Opacity(
        opacity: _controller.value > 0.5 ? 1.0 : 0.0,
        child: Container(
          width: 3,
          height: 28,
          margin: const EdgeInsets.only(left: 4, bottom: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ─── 컨트롤 버튼 행 ───────────────────────────────────────────────────────────

/// 상태별 버튼 구성 (Stitch v0.0.2 기준):
/// 좌측 64px 원형 | 중앙 MicButton(128px) or 재생 | 우측 64px 원형
class _ControlsRow extends StatelessWidget {
  const _ControlsRow({
    required this.recordingState,
    required this.timerDisplay,
    required this.isPlaying,
    required this.onDelete,
    required this.onFinishRecording,
    required this.onSave,
    required this.onPlayback,
  });

  final RecordingState recordingState;
  final String timerDisplay;
  final bool isPlaying;
  final VoidCallback onDelete;
  final VoidCallback onFinishRecording;
  final Future<void> Function() onSave;
  final VoidCallback onPlayback;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildLeftButton(context),
            const SizedBox(width: 24),
            _buildCenterButton(),
            const SizedBox(width: 24),
            _buildRightButton(context),
          ],
        ),
        if (recordingState == RecordingState.recording) ...[
          const SizedBox(height: 16),
          Text(
            timerDisplay,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLeftButton(BuildContext context) => switch (recordingState) {
    RecordingState.idle => const SizedBox(width: 64, height: 64),
    RecordingState.recording => _RoundButton(
        icon: Icons.delete_outline_rounded,
        tooltip: AppStrings.deleteDiary,
        onTap: onDelete,
        isFilled: false,
      ),
    RecordingState.processing => const _RoundButton(
        icon: Icons.delete_outline_rounded,
        tooltip: AppStrings.deleteDiary,
        isFilled: false,
      ),
    RecordingState.done || RecordingState.error => _RoundButton(
        icon: Icons.replay_rounded,
        tooltip: AppStrings.btnReRecord,
        onTap: onDelete,
        isFilled: false,
      ),
  };

  Widget _buildCenterButton() => switch (recordingState) {
    RecordingState.done => _RoundButton(
        icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
        tooltip: AppStrings.btnPlayRecording,
        onTap: onPlayback,
        isFilled: true,
        size: 64,
      ),
    _ => const MicButton(),
  };

  Widget _buildRightButton(BuildContext context) => switch (recordingState) {
    RecordingState.idle || RecordingState.error => const SizedBox(width: 64, height: 64),
    RecordingState.recording => _RoundButton(
        icon: Icons.check_rounded,
        tooltip: AppStrings.btnFinishRecording,
        onTap: onFinishRecording,
        isFilled: true,
      ),
    RecordingState.processing => const _RoundButton(
        icon: Icons.check_rounded,
        tooltip: AppStrings.btnSave,
        isFilled: true,
      ),
    RecordingState.done => _RoundButton(
        icon: Icons.check_rounded,
        tooltip: AppStrings.btnSave,
        onTap: onSave,
        isFilled: true,
      ),
  };
}

// ─── 사이드 원형 버튼 (64px) ──────────────────────────────────────────────────

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.tooltip,
    required this.isFilled,
    this.onTap,
    this.size = 64,
  });

  final IconData icon;
  final String tooltip;
  final bool isFilled;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: onTap == null ? 0.35 : 1.0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? scheme.primary : AppColors.surfaceContainer,
            ),
            child: Icon(
              icon,
              size: 26,
              color: isFilled ? scheme.onPrimary : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
