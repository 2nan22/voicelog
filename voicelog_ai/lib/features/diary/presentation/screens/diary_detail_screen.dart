import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/strings.dart';
import 'package:voicelog_ai/core/extensions/datetime_ext.dart';
import 'package:voicelog_ai/core/theme/app_colors.dart';
import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';

/// 일기 상세 화면.
///
/// Stitch 디자인 기준: 글래스 헤더 + 날짜 배지 + 대제목 + 감정·태그 필 칩 + 본문 + 원문 접기 섹션.
class DiaryDetailScreen extends ConsumerWidget {
  const DiaryDetailScreen({super.key, required this.entryId});

  final int entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diariesAsync = ref.watch(diaryListNotifierProvider);

    return diariesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('오류: $e')),
      ),
      data: (entries) {
        final index = entries.indexWhere((e) => e.id == entryId);
        if (index == -1) {
          return const Scaffold(
            body: Center(child: Text('일기를 찾을 수 없습니다.')),
          );
        }
        return _DiaryDetailBody(entry: entries[index]);
      },
    );
  }
}

// ─── 상세 본문 ────────────────────────────────────────────────────────────────

class _DiaryDetailBody extends ConsumerWidget {
  const _DiaryDetailBody({required this.entry});

  final DiaryEntry entry;

  Color get _emotionColor => switch (entry.emotion) {
    '기쁨' => AppColors.emotionJoy,
    '슬픔' => AppColors.emotionSadness,
    '평온' => AppColors.emotionCalm,
    '화남' => AppColors.emotionAnger,
    _ => AppColors.emotionCalm,
  };

  /// 첫 문장(50자 이내) 또는 50자 요약을 대제목으로 추출.
  String _extractHeadline(String text) {
    final dotIdx = text.indexOf('.');
    final korPeriodIdx = text.indexOf('。');
    final candidates = [
      if (dotIdx > 0 && dotIdx <= 50) dotIdx,
      if (korPeriodIdx > 0 && korPeriodIdx <= 50) korPeriodIdx,
    ];
    if (candidates.isNotEmpty) {
      final end = candidates.reduce((a, b) => a < b ? a : b);
      return text.substring(0, end + 1);
    }
    return text.length > 50 ? '${text.substring(0, 50)}...' : text;
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('일기 삭제'),
        content: const Text('이 일기를 삭제하면 복구할 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFBA1A1A), // error color
            ),
            child: const Text(AppStrings.deleteDiary),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(diaryListNotifierProvider.notifier).deleteEntry(entry.id);
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(topPadding + 64),
        child: _GlassAppBar(
          topPadding: topPadding,
          onDelete: () => _confirmDelete(context, ref),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: topPadding + 64 + 24,
          left: 24,
          right: 24,
          bottom: 56,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 배지 + 시간
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7E2FF).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    entry.createdAt.toKoreanDate(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Color(0xFF004491),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  entry.createdAt.toKoreanTime(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF414754),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 대제목 (첫 문장 or 50자)
            Text(
              _extractHeadline(entry.correctedText),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.3,
                color: Color(0xFF191C1E),
              ),
            ),
            const SizedBox(height: 28),
            // 감정 칩 + 태그 칩
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _EmotionPill(emotion: entry.emotion, color: _emotionColor),
                ...entry.tags.map((t) => _TagPill(tag: t)),
              ],
            ),
            const SizedBox(height: 32),
            // 본문 (line-height 2.0)
            Text(
              entry.correctedText,
              style: const TextStyle(
                fontSize: 17,
                height: 2.0,
                fontWeight: FontWeight.w400,
                color: Color(0xFF191C1E),
                letterSpacing: 0.15,
              ),
            ),
            const SizedBox(height: 40),
            // 원문 접기/펼치기
            _OriginalTextSection(rawText: entry.rawText),
          ],
        ),
      ),
    );
  }
}

// ─── 글래스 앱바 ──────────────────────────────────────────────────────────────

class _GlassAppBar extends StatelessWidget {
  const _GlassAppBar({
    required this.topPadding,
    required this.onDelete,
  });

  final double topPadding;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          color: const Color(0xFFF8F9FB).withValues(alpha: 0.7),
          padding: EdgeInsets.only(top: topPadding, left: 8, right: 8),
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 24),
                  color: const Color(0xFF191C1E),
                  tooltip: '뒤로',
                  onPressed: () => context.pop(),
                ),
                const Expanded(
                  child: Text(
                    'Diary Detail',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: Color(0xFF191C1E),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 24),
                  color: const Color(0xFFBA1A1A),
                  tooltip: AppStrings.deleteDiary,
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 감정 필 칩 ───────────────────────────────────────────────────────────────

class _EmotionPill extends StatelessWidget {
  const _EmotionPill({required this.emotion, required this.color});

  final String emotion;
  final Color color;

  IconData get _icon => switch (emotion) {
    '기쁨' => Icons.sentiment_very_satisfied_rounded,
    '슬픔' => Icons.sentiment_dissatisfied_rounded,
    '평온' => Icons.sentiment_satisfied_alt_rounded,
    '화남' => Icons.sentiment_very_dissatisfied_rounded,
    _ => Icons.mood_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(99),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08191C1E),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            emotion,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 태그 필 칩 ───────────────────────────────────────────────────────────────

class _TagPill extends StatelessWidget {
  const _TagPill({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFECEEF0),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: const Color(0xFFC1C6D6).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF414754),
        ),
      ),
    );
  }
}

// ─── 원문 접기/펼치기 섹션 ───────────────────────────────────────────────────

class _OriginalTextSection extends StatefulWidget {
  const _OriginalTextSection({required this.rawText});

  final String rawText;

  @override
  State<_OriginalTextSection> createState() => _OriginalTextSectionState();
}

class _OriginalTextSectionState extends State<_OriginalTextSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  const Icon(
                    Icons.graphic_eq_rounded,
                    size: 20,
                    color: Color(0xFF414754),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'VIEW ORIGINAL RECORDING',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                        color: Color(0xFF414754),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.expand_more_rounded,
                      size: 22,
                      color: Color(0xFF414754),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"${widget.rawText}"',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.9,
                  color: Color(0xFF727785),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
