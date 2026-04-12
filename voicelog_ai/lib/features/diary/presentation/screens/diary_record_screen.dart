import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/dimensions.dart';
import 'package:voicelog_ai/core/constants/prompts.dart';
import 'package:voicelog_ai/core/constants/routes.dart';
import 'package:voicelog_ai/core/constants/strings.dart';
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

/// 음성 녹음 및 STT 결과 확인 화면.
///
/// 마이크 버튼으로 녹음을 시작/중지하고, 인식된 텍스트를 실시간으로 표시한다.
/// 레이아웃: 글래스 헤더 + 스크롤 콘텐츠(날짜·STT카드·LLM카드) + 글래스 하단 패널(파형·버튼·타이머).
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

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _inferenceTimer?.cancel();
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

  /// LLM 추론이 [kInferenceTimeoutSeconds] 초과 시 경고 다이얼로그를 표시한다.
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

  /// STT 원문을 LLM에 전달하여 스트리밍 처리를 실행한다.
  ///
  /// 청크마다 [DiaryProcessNotifier.appendChunk]를 호출하고,
  /// 완료 시 [DiaryProcessNotifier.finalize]를 호출한 뒤 done 상태로 전환한다.
  Future<void> _runLLMFlow(String rawText) async {
    final service = ref.read(llmInferenceServiceProvider);
    final processNotifier = ref.read(diaryProcessNotifierProvider.notifier);

    // _onDelete 후 dispose() 상태이거나 최초 초기화 미완료 시 재초기화한다.
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
      // 설정에서 문체를 읽어 {style_instruction} 치환
      final settingsAsync = ref.read(settingsNotifierProvider);
      final writingStyle = settingsAsync.valueOrNull?.writingStyle ?? WritingStyle.diary;
      final styleInstruction =
          kWritingStyleInstructions[writingStyle] ?? kWritingStyleInstructions[WritingStyle.diary]!;
      final prompt = kDiaryProcessingPrompt
          .replaceAll('{style_instruction}', styleInstruction)
          .replaceAll('{raw_text}', rawText);

      await for (final chunk in service.generateStream(prompt)) {
        if (!mounted) return;
        // 삭제 등으로 상태가 바뀌면 중단
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
    // processing 중 취소 시 엔진의 _responseController를 즉시 해제한다.
    if (ref.read(diaryRecordNotifierProvider) == RecordingState.processing) {
      ref.read(llmInferenceServiceProvider).dispose();
    }
    try {
      ref.read(speechToTextServiceProvider).cancelListening();
    } catch (_) {}
    ref.read(diaryRecordNotifierProvider.notifier).reset();
    ref.read(sttTextNotifierProvider.notifier).clear();
    ref.read(diaryProcessNotifierProvider.notifier).reset();
    _stopTimer();
    setState(() => _elapsedSeconds = 0);
  }

  /// recording 상태에서 우측 완료 버튼 동작:
  /// STT를 중지하고 즉시 LLM 처리를 시작한다.
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

      // LLM 세션 즉시 해제 (발열·메모리 관리)
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
    final topPadding = MediaQuery.of(context).padding.top;

    // RecordingState 변화를 감지하여 타이머 및 LLM 흐름을 자동 관리한다
    ref.listen<RecordingState>(diaryRecordNotifierProvider, (prev, next) {
      if (prev != RecordingState.recording && next == RecordingState.recording) {
        _startTimer();
      } else if (prev == RecordingState.recording &&
          next != RecordingState.recording) {
        _stopTimer();
      }
      // processing 진입 시 LLM 스트리밍 시작
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
      backgroundColor: const Color(0xFFF8F9FB),
      body: Stack(
        children: [
          // 배경 블러 장식
          const _BackgroundDecorations(),
          // 스크롤 가능한 콘텐츠 (헤더·하단 패널 높이만큼 여백)
          _ScrollableContent(
            topPadding: topPadding,
            sttText: sttText,
            recordingState: recordingState,
          ),
          // 글래스 헤더 (상단 오버레이)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _GlassHeader(
              recordingState: recordingState,
              onClose: () => context.pop(),
              onSave: _onSave,
            ),
          ),
          // 글래스 하단 패널 (하단 오버레이)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomPanel(
              recordingState: recordingState,
              timerDisplay: _timerDisplay,
              onDelete: _onDelete,
              onFinishRecording: _onFinishRecording,
              onSave: _onSave,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 배경 장식 ────────────────────────────────────────────────────────────────

class _BackgroundDecorations extends StatelessWidget {
  const _BackgroundDecorations();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3182F6).withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: -100,
            child: Container(
              width: 360,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(180),
                color: const Color(0xFFD7E2FF).withValues(alpha: 0.3),
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
    required this.onClose,
    required this.onSave,
  });

  final RecordingState recordingState;
  final VoidCallback onClose;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: topPadding + 64,
          color: const Color(0xFFF8F9FB).withValues(alpha: 0.75),
          padding: EdgeInsets.only(
            top: topPadding,
            left: AppDimensions.paddingSmall,
            right: AppDimensions.paddingSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
                color: const Color(0xFF414754),
                tooltip: '닫기',
              ),
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: const Color(0xFF191C1E),
                ),
              ),
              if (recordingState == RecordingState.done)
                TextButton(
                  onPressed: onSave,
                  child: Text(
                    AppStrings.saveDiary,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 스크롤 콘텐츠 ────────────────────────────────────────────────────────────

class _ScrollableContent extends StatelessWidget {
  const _ScrollableContent({
    required this.topPadding,
    required this.sttText,
    required this.recordingState,
  });

  final double topPadding;
  final String sttText;
  final RecordingState recordingState;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: topPadding + 64 + AppDimensions.paddingXLarge,
        bottom: 260,
        left: AppDimensions.paddingMedium,
        right: AppDimensions.paddingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: _DateHeader()),
          const SizedBox(height: AppDimensions.paddingLarge),
          // STT 원문 카드 — 항상 표시, processing/done 시 dimmed
          _SttCard(sttText: sttText, recordingState: recordingState),
          const SizedBox(height: AppDimensions.paddingMedium),
          // LLM 보정 결과 카드 — processing 진입 후 나타남
          _LlmResultCard(recordingState: recordingState),
        ],
      ),
    );
  }
}

// ─── 날짜 헤더 ────────────────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  const _DateHeader();

  static const _monthNames = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
    'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateLabel = '${_monthNames[now.month - 1]} ${now.day}, ${now.year}';

    return Column(
      children: [
        Text(
          dateLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '오늘의 일기',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: const Color(0xFF191C1E),
          ),
        ),
      ],
    );
  }
}

// ─── STT 원문 카드 ────────────────────────────────────────────────────────────

/// STT 인식 원문을 표시하는 카드.
///
/// - idle/recording: 실시간 갱신, 녹음 중 블링킹 커서 표시
/// - processing/done: 회색 dimmed (opacity 0.45)
class _SttCard extends StatelessWidget {
  const _SttCard({
    required this.sttText,
    required this.recordingState,
  });

  final String sttText;
  final RecordingState recordingState;

  @override
  Widget build(BuildContext context) {
    final isProcessingOrDone = recordingState == RecordingState.processing ||
        recordingState == RecordingState.done;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: _buildContent(context, isProcessingOrDone),
    );
  }

  Widget _buildContent(BuildContext context, bool isProcessingOrDone) {
    if (sttText.isEmpty && !isProcessingOrDone) {
      return _buildPlaceholder(context);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Opacity(
            opacity: isProcessingOrDone ? 0.45 : 1.0,
            child: Text(
              sttText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                    color: const Color(0xFF191C1E),
                  ),
            ),
          ),
        ),
        if (!isProcessingOrDone && recordingState == RecordingState.recording)
          const _BlinkingCursor(),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: AppDimensions.paddingMedium),
        Icon(
          Icons.mic_none_rounded,
          size: 40,
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant
              .withValues(alpha: 0.3),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.recordStart,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.5),
              ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
      ],
    );
  }
}

// ─── LLM 보정 결과 카드 ───────────────────────────────────────────────────────

/// LLM 보정 텍스트 + 감정·태그 뱃지를 하나의 카드로 표시한다.
///
/// processing 상태 진입 이후에만 나타나며,
/// 파싱 완료([DiaryProcessState.parsedResult] != null) 후 감정·태그 섹션이 표시된다.
class _LlmResultCard extends ConsumerWidget {
  const _LlmResultCard({required this.recordingState});

  final RecordingState recordingState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProcessingOrDone = recordingState == RecordingState.processing ||
        recordingState == RecordingState.done;

    if (!isProcessingOrDone) return const SizedBox.shrink();

    final parsedResult = ref.watch(
      diaryProcessNotifierProvider.select((s) => s.parsedResult),
    );
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 상단 레이블
          Text(
            'AI 보정',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          // 스트리밍 텍스트 (처리 중 실시간 갱신)
          const StreamingTextWidget(),
          // 파싱 완료 후 감정·태그 뱃지
          if (parsedResult != null) ...[
            const SizedBox(height: AppDimensions.paddingMedium),
            Divider(height: 1, color: scheme.outlineVariant),
            const SizedBox(height: AppDimensions.paddingMedium),
            const DiaryResultWidget(),
          ],
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

// ─── 하단 글래스 패널 ─────────────────────────────────────────────────────────

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.recordingState,
    required this.timerDisplay,
    required this.onDelete,
    required this.onFinishRecording,
    required this.onSave,
  });

  final RecordingState recordingState;
  final String timerDisplay;
  final VoidCallback onDelete;
  final VoidCallback onFinishRecording;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(48),
        topRight: Radius.circular(48),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 40,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(
            AppDimensions.paddingMedium,
            AppDimensions.paddingXLarge + 8,
            AppDimensions.paddingMedium,
            AppDimensions.paddingXLarge + bottomPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WaveformWidget(
                isRecording: recordingState == RecordingState.recording,
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: _ControlsRow(
                    recordingState: recordingState,
                    onDelete: onDelete,
                    onFinishRecording: onFinishRecording,
                    onSave: onSave,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall + 4),
              Text(
                timerDisplay,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  color: const Color(0xFF191C1E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 컨트롤 버튼 행 ───────────────────────────────────────────────────────────

/// 녹음 상태별 버튼 구성:
///
/// | 상태       | 좌측        | 중앙           | 우측          |
/// |-----------|------------|---------------|--------------|
/// | idle      | 투명        | MicButton(시작) | 투명          |
/// | recording | 삭제        | MicButton(중지) | 완료체크       |
/// | processing | 삭제(비활성) | MicButton(스피너) | 저장(비활성) |
/// | done      | 재녹음      | ▶재생(placeholder) | 저장      |
/// | error     | 재녹음      | MicButton     | 투명          |
class _ControlsRow extends StatelessWidget {
  const _ControlsRow({
    required this.recordingState,
    required this.onDelete,
    required this.onFinishRecording,
    required this.onSave,
  });

  final RecordingState recordingState;
  final VoidCallback onDelete;
  final VoidCallback onFinishRecording;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLeftButton(),
        _buildCenterButton(),
        _buildRightButton(),
      ],
    );
  }

  Widget _buildLeftButton() => switch (recordingState) {
    RecordingState.idle => const _InvisibleButton(),
    RecordingState.recording => _SideButton(
        icon: Icons.delete_outline_rounded,
        tooltip: AppStrings.deleteDiary,
        onTap: onDelete,
      ),
    RecordingState.processing => const _SideButton(
        icon: Icons.delete_outline_rounded,
        tooltip: AppStrings.deleteDiary,
      ),
    RecordingState.done || RecordingState.error => _SideButton(
        icon: Icons.replay_rounded,
        tooltip: AppStrings.btnReRecord,
        onTap: onDelete,
      ),
  };

  Widget _buildCenterButton() => switch (recordingState) {
    RecordingState.done => const _SideButton(
        icon: Icons.play_arrow_rounded,
        tooltip: AppStrings.btnPlayRecording,
        isFilled: true, // 꼭지 3에서 onTap 구현
      ),
    _ => const MicButton(),
  };

  Widget _buildRightButton() => switch (recordingState) {
    RecordingState.idle || RecordingState.error => const _InvisibleButton(),
    RecordingState.recording => _SideButton(
        icon: Icons.check_rounded,
        tooltip: AppStrings.btnFinishRecording,
        onTap: onFinishRecording,
        isFilled: true,
      ),
    RecordingState.processing => const _SideButton(
        icon: Icons.check_rounded,
        tooltip: AppStrings.btnSave,
        isFilled: true,
      ),
    RecordingState.done => _SideButton(
        icon: Icons.check_rounded,
        tooltip: AppStrings.btnSave,
        onTap: onSave,
        isFilled: true,
      ),
  };
}

// ─── 투명 자리 확보 버튼 ──────────────────────────────────────────────────────

class _InvisibleButton extends StatelessWidget {
  const _InvisibleButton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 48, height: 48);
  }
}

// ─── 사이드 버튼 ──────────────────────────────────────────────────────────────

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.icon,
    required this.tooltip,
    this.isFilled = false,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isFilled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: onTap == null ? 0.35 : 1.0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled
                  ? colorScheme.primaryContainer
                  : const Color(0xFFF2F4F6),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isFilled
                  ? colorScheme.onPrimaryContainer
                  : const Color(0xFF414754),
            ),
          ),
        ),
      ),
    );
  }
}
