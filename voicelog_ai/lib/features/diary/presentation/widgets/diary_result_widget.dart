import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voicelog_ai/core/constants/dimensions.dart';
import 'package:voicelog_ai/core/widgets/emotion_chip.dart';
import 'package:voicelog_ai/features/diary/application/diary_process_provider.dart';

/// LLM 파싱 결과(감정 칩, 태그 칩)를 표시하는 위젯.
///
/// [parsedResult]가 null이면 SizedBox.shrink()를 반환한다.
class DiaryResultWidget extends ConsumerWidget {
  const DiaryResultWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(
      diaryProcessNotifierProvider.select((s) => s.parsedResult),
    );
    if (result == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmotionChip(emotion: result.emotion),
          if (result.tags.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            Wrap(
              spacing: AppDimensions.paddingSmall,
              runSpacing: AppDimensions.paddingSmall,
              children: result.tags.map((tag) => _TagChip(label: tag)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Stitch 디자인의 태그 칩: surface-container-high 배경, rounded-full 형태.
class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}
