import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voicelog_ai/core/constants/dimensions.dart';
import 'package:voicelog_ai/core/widgets/loading_shimmer.dart';
import 'package:voicelog_ai/features/diary/application/diary_process_provider.dart';
import 'package:voicelog_ai/features/diary/application/diary_record_provider.dart';

/// LLM 스트리밍 응답을 실시간으로 표시하는 위젯.
///
/// - processing 상태 + 텍스트 없음: LoadingShimmer 표시
/// - processing 상태 + 텍스트 있음: 누적 텍스트 + 깜빡이는 커서
/// - done 상태: 파싱된 보정본 텍스트 (커서 없음)
class StreamingTextWidget extends ConsumerWidget {
  const StreamingTextWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(diaryRecordNotifierProvider);
    final processState = ref.watch(diaryProcessNotifierProvider);

    final isProcessing = recordingState == RecordingState.processing;
    final isDone = recordingState == RecordingState.done;

    if (!isProcessing && !isDone) return const SizedBox.shrink();

    // 스트리밍이 시작되지 않았으면 shimmer
    if (isProcessing && processState.rawAccumulated.isEmpty) {
      return const LoadingShimmer(height: 80, borderRadius: AppDimensions.borderRadius);
    }

    // 보정 완료 시 correctedText 우선 사용, 아니면 rawAccumulated에서 [보정본] 추출
    final displayText = processState.correctedText?.isNotEmpty == true
        ? processState.correctedText!
        : _extractCorrectedText(processState.rawAccumulated);

    if (displayText.isEmpty) return const SizedBox.shrink();

    return _StreamingText(text: displayText, showCursor: isProcessing);
  }

  static String _extractCorrectedText(String raw) {
    final match =
        RegExp(r'\[보정본\](.*?)(?=\[감정\]|\[태그\]|$)', dotAll: true)
            .firstMatch(raw);
    return match?.group(1)?.trim() ?? raw;
  }
}

/// 텍스트를 깜빡이는 커서와 함께 표시하는 애니메이션 위젯.
class _StreamingText extends StatefulWidget {
  const _StreamingText({required this.text, required this.showCursor});

  final String text;
  final bool showCursor;

  @override
  State<_StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<_StreamingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cursorController,
      builder: (context, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                widget.text,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      height: 1.5,
                      color: const Color(0xFF191C1E),
                    ),
              ),
            ),
            if (widget.showCursor)
              Opacity(
                opacity: _cursorController.value > 0.5 ? 1.0 : 0.0,
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
          ],
        );
      },
    );
  }
}
