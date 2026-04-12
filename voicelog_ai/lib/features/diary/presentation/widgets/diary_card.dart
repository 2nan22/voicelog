import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/routes.dart';
import 'package:voicelog_ai/core/extensions/datetime_ext.dart';
import 'package:voicelog_ai/core/theme/app_colors.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';

/// 일기 목록에서 각 항목을 표시하는 카드 위젯.
///
/// Stitch 디자인 기준: 왼쪽 full-height 감정 컬러 바 + 날짜·감정 배지 + 텍스트 + 태그
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
      child: GestureDetector(
        onTap: () => context.push(
          AppRoutes.diaryDetail.replaceFirst(':id', '${entry.id}'),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F191C1E),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // 감정 컬러 바 — 왼쪽 full-height (Stitch: w-1.5 = 6px)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 6,
                  child: ColoredBox(color: _emotionColor),
                ),
                // 카드 콘텐츠 (왼쪽 컬러 바 너비만큼 패딩)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 날짜·시간 + 감정 배지 행
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              '${entry.createdAt.toRelativeDate()} · ${entry.createdAt.toKoreanTime()}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF414754).withValues(alpha: 0.6),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _EmotionBadge(
                            emotion: entry.emotion,
                            color: _emotionColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 보정 텍스트 (2줄 미리보기)
                      Text(
                        entry.correctedText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF191C1E),
                          height: 1.55,
                        ),
                      ),
                      // 태그 (최대 3개)
                      if (entry.tags.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: entry.tags.take(3).map((tag) {
                            return _TagChip(tag: tag, context: context);
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmotionBadge extends StatelessWidget {
  const _EmotionBadge({required this.emotion, required this.color});

  final String emotion;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        emotion,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag, required this.context});

  final String tag;
  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
