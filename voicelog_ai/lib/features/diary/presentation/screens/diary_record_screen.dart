import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/dimensions.dart';
import 'package:voicelog_ai/core/constants/prompts.dart';
import 'package:voicelog_ai/core/constants/routes.dart';
import 'package:voicelog_ai/core/constants/strings.dart';
import 'package:voicelog_ai/core/theme/app_colors.dart';
import 'package:voicelog_ai/core/utils/logger.dart';
import 'package:voicelog_ai/core/utils/llm_response_parser.dart';
import 'package:voicelog_ai/core/widgets/emotion_chip.dart';
import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';
import 'package:voicelog_ai/features/diary/application/diary_process_provider.dart';
import 'package:voicelog_ai/features/diary/application/diary_record_provider.dart';
import 'package:voicelog_ai/features/diary/application/llm_provider.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';
import 'package:voicelog_ai/features/diary/presentation/widgets/mic_button.dart';
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
    final correctionEnabled =
        ref.read(settingsNotifierProvider).valueOrNull?.correctionEnabled ?? false;

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

    // Phase 1: 메타데이터 추출
    try {
      processNotifier.startMetadata();
      final prompt = kMetadataExtractionPrompt.replaceAll('{raw_text}', rawText);
      await for (final chunk in service.generateStream(prompt)) {
        if (!mounted) return;
        processNotifier.appendChunk(chunk);
      }
      processNotifier.finalizeMetadata();
      _inferenceTimer?.cancel();
    } catch (e) {
      if (!mounted) return;
      _inferenceTimer?.cancel();
      AppLogger.error('메타데이터 추출 실패', e);
      ref.read(diaryRecordNotifierProvider.notifier).setError();
      return;
    }

    // Phase 2: 문맥 보정 (설정 활성화 시)
    if (correctionEnabled && mounted) {
      try {
        final settingsAsync = ref.read(settingsNotifierProvider);
        final writingStyle = settingsAsync.valueOrNull?.writingStyle ?? WritingStyle.diary;
        final styleInstruction =
            kWritingStyleInstructions[writingStyle] ?? kWritingStyleInstructions[WritingStyle.diary]!;
        processNotifier.startCorrection();
        final prompt = kCorrectionPrompt
            .replaceAll('{style_instruction}', styleInstruction)
            .replaceAll('{raw_text}', rawText);
        await for (final chunk in service.generateStream(prompt)) {
          if (!mounted) return;
          processNotifier.appendChunk(chunk);
        }
        processNotifier.finalizeCorrection();
      } catch (e) {
        AppLogger.error('문맥 보정 실패', e);
        // 보정 실패는 치명적이지 않음 — 메타데이터로 계속 진행
      }
    }

    if (!mounted) return;
    ref.read(diaryRecordNotifierProvider.notifier).finishRecording();
  }

  void _onDelete() {
    _inferenceTimer?.cancel();
    ref.read(sttCallbackHandlerProvider.notifier).cancelSession();
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
    _stopTimer();
    setState(() => _elapsedSeconds = 0);
  }

  void _onFinishRecording() {
    unawaited(_finishRecordingAsync());
  }

  Future<void> _finishRecordingAsync() async {
    final sttService = ref.read(speechToTextServiceProvider);
    final notifier = ref.read(diaryRecordNotifierProvider.notifier);
    ref.read(sttCallbackHandlerProvider.notifier).cancelSession();
    try {
      await sttService.stopListening();
      notifier.startProcessing();
    } catch (e) {
      AppLogger.error('STT 중지 실패', e);
      notifier.setError();
    }
  }

  Future<void> _onSave({bool useCorrection = false}) async {
    final processState = ref.read(diaryProcessNotifierProvider);
    final metadataResult = processState.metadataResult;
    if (metadataResult == null) return;

    final rawText = ref.read(sttTextNotifierProvider);
    final correctedText = useCorrection ? processState.correctedText : null;
    final entry = DiaryEntry.create(
      rawText: rawText,
      title: metadataResult.title,
      emotion: metadataResult.emotion,
      tags: metadataResult.tags,
      people: metadataResult.people,
      places: metadataResult.places,
      correctedText: correctedText,
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
    final correctionEnabled = ref.watch(
      settingsNotifierProvider.select((s) => s.valueOrNull?.correctionEnabled ?? false),
    );
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final scheme = Theme.of(context).colorScheme;

    // 상태 변화 감지 — 타이머·LLM 흐름 관리
    // NOTE: 오디오 녹음(record 패키지)은 Android 12+에서 SpeechRecognizer와
    //        마이크를 동시에 사용할 수 없어 STT가 즉시 error_speech_timeout됨.
    //        재생 기능은 추후 단일 오디오 캡처 아키텍처로 재구현 예정.
    ref.listen<RecordingState>(diaryRecordNotifierProvider, (prev, next) {
      if (prev != RecordingState.recording && next == RecordingState.recording) {
        _startTimer();
      } else if (prev == RecordingState.recording &&
          next != RecordingState.recording) {
        _stopTimer();
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
                      const Flexible(child: SizedBox()),
                      // 상태 배지
                      _RecordingStateBadge(state: recordingState),
                      const SizedBox(height: 12),
                      // 상태별 대형 헤딩
                      Text(
                        _headingText(recordingState),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // 서브 텍스트
                      Text(
                        _subtitleText(recordingState),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      // STT/LLM 통합 글래스모픽 컨테이너
                      _GlassSttContainer(
                        sttText: sttText,
                        recordingState: recordingState,
                        onSaveOriginal: () => _onSave(),
                        onSaveCorrected: () => _onSave(useCorrection: true),
                      ),
                      const SizedBox(height: 16),
                      // AI 처리 중 배지 — Visibility로 감싸야 Center(_ControlsRow)의
                      // 리스트 위치가 상태 전환 시 밀리지 않는다.
                      Visibility(
                        visible: recordingState == RecordingState.processing,
                        child: const _AiStatusBadge(),
                      ),
                      const Flexible(flex: 2, child: SizedBox()),
                      // 파형 — 동일 이유로 Visibility 사용.
                      // if(...) spread를 쓰면 WaveformWidget 삽입 시
                      // 뒤 Center의 인덱스가 밀려 _MicButtonState가 dispose된다.
                      Visibility(
                        visible: recordingState == RecordingState.recording,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            WaveformWidget(
                              isRecording: true,
                              amplitudes: amplitudes,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                      // 컨트롤 버튼 행 — 항상 동일 인덱스 위치
                      Center(
                        child: _ControlsRow(
                          recordingState: recordingState,
                          timerDisplay: _timerDisplay,
                          onDelete: _onDelete,
                          onFinishRecording: _onFinishRecording,
                          onSave: _onSave,
                          onPlayback: null,
                          correctionEnabled: correctionEnabled,
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
              correctionEnabled: correctionEnabled,
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
    RecordingState.recording  => '자연스럽게 말씀해 주세요. AI가 경청하고 있습니다.',
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
    required this.correctionEnabled,
  });

  final RecordingState recordingState;
  final ColorScheme scheme;
  final double topPadding;
  final VoidCallback onClose;
  final Future<void> Function() onSave;
  final bool correctionEnabled;

  @override
  Widget build(BuildContext context) {
    // 보정 활성화 + done: 저장 버튼 숨기고 본문의 2개 버튼으로 대체
    final showSave = recordingState == RecordingState.done && !correctionEnabled;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: topPadding + 64,
          color: Colors.white.withValues(alpha: 0.8),
          padding: EdgeInsets.only(top: topPadding, left: 8, right: 8),
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
              if (showSave)
                TextButton(
                  onPressed: onSave,
                  child: Text(
                    AppStrings.saveDiary,
                    style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700),
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

/// idle/recording: STT 원본 텍스트 표시
/// processing/done: STT 원본 + 메타데이터 결과 카드 + (옵션) 보정 카드
class _GlassSttContainer extends ConsumerWidget {
  const _GlassSttContainer({
    required this.sttText,
    required this.recordingState,
    required this.onSaveOriginal,
    required this.onSaveCorrected,
  });

  final String sttText;
  final RecordingState recordingState;
  final Future<void> Function() onSaveOriginal;
  final Future<void> Function() onSaveCorrected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLlmPhase = recordingState == RecordingState.processing ||
        recordingState == RecordingState.done;
    final metadataResult = isLlmPhase
        ? ref.watch(diaryProcessNotifierProvider.select((s) => s.metadataResult))
        : null;
    final phase = isLlmPhase
        ? ref.watch(diaryProcessNotifierProvider.select((s) => s.phase))
        : LlmPhase.idle;
    final correctedText = isLlmPhase
        ? ref.watch(diaryProcessNotifierProvider.select((s) => s.correctedText))
        : null;
    final correctionEnabled = ref.watch(
      settingsNotifierProvider.select((s) => s.valueOrNull?.correctionEnabled ?? false),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 180),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: isLlmPhase
              ? _buildLlmContent(
                  context, metadataResult, phase, correctedText, correctionEnabled)
              : _buildSttContent(context),
        ),
      ),
    );
  }

  Widget _buildSttContent(BuildContext context) {
    if (sttText.isEmpty) {
      final isRecording = recordingState == RecordingState.recording;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isRecording ? Icons.graphic_eq_rounded : Icons.mic_none_rounded,
            size: 40,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            isRecording ? '말씀해 주세요...' : AppStrings.recordStart,
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
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.6,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (recordingState == RecordingState.recording)
          const _BlinkingCursor(),
      ],
    );
  }

  Widget _buildLlmContent(
    BuildContext context,
    LlmMetadataResult? metadataResult,
    LlmPhase phase,
    String? correctedText,
    bool correctionEnabled,
  ) {
    final scheme = Theme.of(context).colorScheme;

    // 메타데이터 미완료 → 로딩 스피너
    if (metadataResult == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: scheme.primary, strokeWidth: 2.5),
          const SizedBox(height: 16),
          Text(
            'AI가 분석 중이에요...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // STT 원본 (compact)
          if (sttText.isNotEmpty) ...[
            Text(
              sttText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: scheme.outlineVariant),
            const SizedBox(height: 12),
          ],
          // AI 분석 결과 헤더
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 14, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                'AI 분석 결과',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 제목
          Text(
            metadataResult.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          // 감정 칩
          EmotionChip(emotion: metadataResult.emotion),
          // 태그
          if (metadataResult.tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: metadataResult.tags
                  .map((tag) => _TagBadge(label: tag))
                  .toList(),
            ),
          ],
          // 인물 (있을 때만)
          if (metadataResult.people.isNotEmpty) ...[
            const SizedBox(height: 8),
            _MetaRow(
              icon: Icons.person_outline_rounded,
              text: metadataResult.people.join(', '),
            ),
          ],
          // 장소 (있을 때만)
          if (metadataResult.places.isNotEmpty) ...[
            const SizedBox(height: 6),
            _MetaRow(
              icon: Icons.place_outlined,
              text: metadataResult.places.join(', '),
            ),
          ],
          // 보정 섹션 (설정 활성화 시)
          if (correctionEnabled) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: scheme.outlineVariant),
            const SizedBox(height: 12),
            if (phase == LlmPhase.correction)
              Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      color: scheme.primary,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '보정 중...',
                    style: TextStyle(fontSize: 12, color: scheme.primary),
                  ),
                ],
              )
            else if (correctedText != null && correctedText.isNotEmpty) ...[
              Text(
                '보정본',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                correctedText,
                style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.onSurface),
              ),
            ],
            // 저장 버튼 (done 상태)
            if (phase == LlmPhase.done) ...[
              const SizedBox(height: AppDimensions.paddingMedium),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSaveOriginal,
                      child: const Text('원본으로 저장'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: correctedText != null ? onSaveCorrected : null,
                      child: const Text('보정본으로 저장'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
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
    required this.onDelete,
    required this.onFinishRecording,
    required this.onSave,
    required this.onPlayback,
    required this.correctionEnabled,
  });

  final RecordingState recordingState;
  final String timerDisplay;
  final VoidCallback onDelete;
  final VoidCallback onFinishRecording;
  final Future<void> Function() onSave;
  final VoidCallback? onPlayback;
  final bool correctionEnabled;

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
        icon: Icons.play_arrow_rounded,
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
        icon: Icons.stop_rounded,
        tooltip: AppStrings.btnFinishRecording,
        onTap: onFinishRecording,
        isFilled: true,
      ),
    RecordingState.processing => const _RoundButton(
        icon: Icons.check_rounded,
        tooltip: AppStrings.btnSave,
        isFilled: true,
      ),
    // 보정 활성화 + done: 본문 버튼으로 저장하므로 우측 버튼 비활성화
    RecordingState.done => correctionEnabled
        ? const SizedBox(width: 64, height: 64)
        : _RoundButton(
            icon: Icons.check_rounded,
            tooltip: AppStrings.btnSave,
            onTap: onSave,
            isFilled: true,
          ),
  };
}

// ─── 메타데이터 보조 위젯 ──────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
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
