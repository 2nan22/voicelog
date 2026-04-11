import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/dimensions.dart';
import 'package:voicelog_ai/core/constants/strings.dart';
import 'package:voicelog_ai/features/diary/application/diary_record_provider.dart';
import 'package:voicelog_ai/features/diary/presentation/widgets/mic_button.dart';
import 'package:voicelog_ai/features/diary/presentation/widgets/waveform_widget.dart';

/// 음성 녹음 및 STT 결과 확인 화면.
///
/// 마이크 버튼으로 녹음을 시작/중지하고, 인식된 텍스트를 실시간으로 표시한다.
/// 레이아웃: 글래스 헤더 + 스크롤 콘텐츠(날짜·텍스트 카드) + 글래스 하단 패널(파형·버튼·타이머).
class DiaryRecordScreen extends ConsumerStatefulWidget {
  const DiaryRecordScreen({super.key});

  @override
  ConsumerState<DiaryRecordScreen> createState() => _DiaryRecordScreenState();
}

class _DiaryRecordScreenState extends ConsumerState<DiaryRecordScreen>
    with TickerProviderStateMixin {
  Timer? _recordingTimer;
  int _elapsedSeconds = 0;

  @override
  void dispose() {
    _recordingTimer?.cancel();
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

  void _onDelete() {
    try {
      ref.read(speechToTextServiceProvider).cancelListening();
    } catch (_) {}
    ref.read(diaryRecordNotifierProvider.notifier).reset();
    ref.read(sttTextNotifierProvider.notifier).clear();
    _stopTimer();
    setState(() => _elapsedSeconds = 0);
  }

  Future<void> _onSave() async {
    // Session 07에서 LLM 처리 연동 후 완성
  }

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(diaryRecordNotifierProvider);
    final sttText = ref.watch(sttTextNotifierProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    // RecordingState 변화를 감지하여 타이머를 자동 관리한다
    ref.listen<RecordingState>(diaryRecordNotifierProvider, (prev, next) {
      if (prev != RecordingState.recording && next == RecordingState.recording) {
        _startTimer();
      } else if (prev == RecordingState.recording &&
          next != RecordingState.recording) {
        _stopTimer();
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
                color: const Color(0xFF3182F6).withValues(alpha:0.08),
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
                color: const Color(0xFFD7E2FF).withValues(alpha:0.3),
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
          color: const Color(0xFFF8F9FB).withValues(alpha:0.75),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _DateHeader(),
          const SizedBox(height: AppDimensions.paddingLarge),
          _SttTextCard(
            sttText: sttText,
            recordingState: recordingState,
          ),
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

// ─── STT 텍스트 카드 ──────────────────────────────────────────────────────────

class _SttTextCard extends StatelessWidget {
  const _SttTextCard({
    required this.sttText,
    required this.recordingState,
  });

  final String sttText;
  final RecordingState recordingState;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha:0.04),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: sttText.isEmpty
          ? _buildPlaceholder(context)
          : _buildText(context),
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
          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha:0.3),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.recordStart,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha:0.5),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
      ],
    );
  }

  Widget _buildText(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            sttText,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.5,
              color: const Color(0xFF191C1E),
            ),
          ),
        ),
        if (recordingState == RecordingState.recording)
          const _BlinkingCursor(),
      ],
    );
  }
}

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
  });

  final RecordingState recordingState;
  final String timerDisplay;
  final VoidCallback onDelete;

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
            color: Colors.white.withValues(alpha:0.85),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.08),
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

class _ControlsRow extends StatelessWidget {
  const _ControlsRow({
    required this.recordingState,
    required this.onDelete,
  });

  final RecordingState recordingState;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SideButton(
          icon: Icons.delete_outline_rounded,
          tooltip: AppStrings.deleteDiary,
          onTap: recordingState != RecordingState.idle ? onDelete : null,
        ),
        const MicButton(),
        const _SideButton(
          icon: Icons.check_rounded,
          tooltip: AppStrings.saveDiary,
          isFilled: true,
        ),
      ],
    );
  }
}

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
