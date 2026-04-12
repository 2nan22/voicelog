import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/routes.dart';
import 'package:voicelog_ai/core/extensions/datetime_ext.dart';
import 'package:voicelog_ai/core/theme/app_colors.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';

/// 일기 목록 카드 — Stitch v0.0.2 Seoul Minimalist 스타일.
///
/// 감정 원형 아이콘 뱃지 + 제목(첫 문장) + 날짜 서브텍스트 + 본문 2줄 preview + 태그 칩.
class DiaryCard extends ConsumerWidget {
  const DiaryCard({super.key, required this.entry});

  final DiaryEntry entry;

  Color get _emotionColor => switch (entry.emotion) {
    '기쁨' => AppColors.emotionJoy,
    '슬픔' => AppColors.emotionSadness,
    '평온' => AppColors.emotionCalm,
    '화남' => AppColors.emotionAnger,
    _     => AppColors.emotionCalm,
  };

  IconData get _emotionIcon => switch (entry.emotion) {
    '기쁨' => Icons.sentiment_satisfied_rounded,
    '슬픔' => Icons.sentiment_dissatisfied_rounded,
    '화남' => Icons.mood_bad_rounded,
    _     => Icons.self_improvement_rounded,
  };

  /// 보정 텍스트에서 첫 문장을 제목으로 추출 (최대 30자)
  String get _title {
    final text = entry.correctedText.isNotEmpty
        ? entry.correctedText
        : entry.rawText;
    final dotIdx = text.indexOf('.');
    final raw = dotIdx > 0 ? text.substring(0, dotIdx) : text;
    return raw.length > 30 ? '${raw.substring(0, 30)}…' : raw;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
      child: GestureDetector(
        onTap: () => context.push(
          AppRoutes.diaryDetail.replaceFirst(':id', '${entry.id}'),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 감정 아이콘 뱃지 + 제목 + 날짜 행
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 감정 원형 뱃지
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _emotionColor.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      _emotionIcon,
                      size: 20,
                      color: _emotionColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 제목 + 날짜
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${entry.createdAt.toRelativeDate()} · ${entry.createdAt.toKoreanTime()}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 본문 2줄 preview
              Text(
                entry.correctedText.isNotEmpty
                    ? entry.correctedText
                    : entry.rawText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              // 태그 칩
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: entry.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
