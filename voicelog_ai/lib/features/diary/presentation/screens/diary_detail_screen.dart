import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/strings.dart';
import 'package:voicelog_ai/core/extensions/datetime_ext.dart';
import 'package:voicelog_ai/core/theme/app_colors.dart';
import 'package:voicelog_ai/features/diary/application/diary_detail_llm_provider.dart';
import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';
import 'package:voicelog_ai/features/settings/application/settings_provider.dart';
import 'package:voicelog_ai/features/settings/domain/app_settings.dart';

/// 일기 상세 화면 — Stitch v0.0.2 에디토리얼 레이아웃.
///
/// 에디토리얼 헤더 + 감정·키워드 2열 그리드 + prose 본문 + 원본 텍스트 토글 카드.
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
              backgroundColor: const Color(0xFFBA1A1A),
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
    final llmState = ref.watch(diaryDetailLlmNotifierProvider(entry.id));
    final writingStyle =
        ref.watch(settingsNotifierProvider).valueOrNull?.writingStyle ?? WritingStyle.diary;

    ref.listen(diaryDetailLlmNotifierProvider(entry.id), (prev, next) {
      if (next.phase == DetailLlmPhase.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI 처리에 실패했어요. 다시 시도해 주세요.')),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
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
          top: topPadding + 64 + 32,
          left: 24,
          right: 24,
          bottom: 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EditorialHeader(entry: entry, emotionColor: _emotionColor),
            const SizedBox(height: 40),
            _EmotionKeywordGrid(entry: entry, emotionColor: _emotionColor),
            if (entry.people.isNotEmpty || entry.places.isNotEmpty) ...[
              const SizedBox(height: 16),
              _PeoplePlacesRow(entry: entry),
            ],
            const SizedBox(height: 40),
            _ProseBody(text: entry.correctedText ?? entry.rawText),
            const SizedBox(height: 40),
            _OriginalTextSection(rawText: entry.rawText),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: _DetailActionBar(
        entry: entry,
        llmState: llmState,
        onReanalyze: () => ref
            .read(diaryDetailLlmNotifierProvider(entry.id).notifier)
            .reExtractMetadata(entry),
        onCorrect: () => ref
            .read(diaryDetailLlmNotifierProvider(entry.id).notifier)
            .runCorrection(entry, writingStyle),
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
    final scheme = Theme.of(context).colorScheme;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: Colors.white.withValues(alpha: 0.8),
          padding: EdgeInsets.only(top: topPadding, left: 8, right: 8),
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 24),
                  color: AppColors.onSurfaceVariant,
                  tooltip: '뒤로',
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Text(
                    AppStrings.appName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: scheme.primary,
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

// ─── 에디토리얼 헤더 ──────────────────────────────────────────────────────────

class _EditorialHeader extends StatelessWidget {
  const _EditorialHeader({
    required this.entry,
    required this.emotionColor,
  });

  final DiaryEntry entry;
  final Color emotionColor;

  static const _weekDays = ['월', '화', '수', '목', '금', '토', '일'];

  String get _dateHeading {
    final d = entry.createdAt;
    final weekDay = _weekDays[d.weekday - 1];
    return '${d.month}월 ${d.day}일 $weekDay요일';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 소제목 (Primary, 극소, 넓은 자간, uppercase)
        Text(
          '오늘의 기록',
          style: TextStyle(
            color: scheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 12),
        // 대제목 — 날짜 + 감정 요약
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(text: _dateHeading),
              const TextSpan(
                text: '  |  ',
                style: TextStyle(
                  color: AppColors.outlineVariant,
                  fontWeight: FontWeight.w300,
                ),
              ),
              TextSpan(
                text: entry.emotion,
                style: TextStyle(color: emotionColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // 태그 행 (감정 pill + 시각 pill)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _EmotionTag(emotion: entry.emotion, color: emotionColor),
            _TimeTag(time: entry.createdAt.toKoreanTime()),
          ],
        ),
      ],
    );
  }
}

class _EmotionTag extends StatelessWidget {
  const _EmotionTag({required this.emotion, required this.color});

  final String emotion;
  final Color color;

  IconData get _icon => switch (emotion) {
    '기쁨' => Icons.sentiment_very_satisfied_rounded,
    '슬픔' => Icons.sentiment_dissatisfied_rounded,
    '화남' => Icons.mood_bad_rounded,
    _     => Icons.sentiment_satisfied_alt_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            emotion,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeTag extends StatelessWidget {
  const _TimeTag({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ─── 감정·키워드 2열 그리드 ────────────────────────────────────────────────────

class _EmotionKeywordGrid extends StatelessWidget {
  const _EmotionKeywordGrid({
    required this.entry,
    required this.emotionColor,
  });

  final DiaryEntry entry;
  final Color emotionColor;

  IconData get _emotionBgIcon => switch (entry.emotion) {
    '기쁨' => Icons.sentiment_satisfied_rounded,
    '슬픔' => Icons.sentiment_dissatisfied_rounded,
    '화남' => Icons.mood_bad_rounded,
    _     => Icons.self_improvement_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 좌: 감정 카드
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: emotionColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '주요 감정',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.emotion,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      _emotionBgIcon,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 우: 키워드 카드
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '주요 키워드',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: entry.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.outlineVariant,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 본문 prose ───────────────────────────────────────────────────────────────

class _ProseBody extends StatelessWidget {
  const _ProseBody({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    // 단락 분리 (줄바꿈 기준)
    final paragraphs = text
        .split('\n')
        .where((p) => p.trim().isNotEmpty)
        .toList();

    if (paragraphs.isEmpty) {
      return Text(
        text,
        style: _proseStyle,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < paragraphs.length; i++) ...[
          Text(paragraphs[i], style: _proseStyle),
          if (i < paragraphs.length - 1) const SizedBox(height: 32),
        ],
      ],
    );
  }

  static const TextStyle _proseStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.9,
    color: AppColors.onSurfaceVariant,
    letterSpacing: -0.3,
  );
}

// ─── 원본 텍스트 토글 카드 ────────────────────────────────────────────────────

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
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 토글 헤더
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Icon(Icons.mic_rounded, size: 20, color: scheme.primary),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '음성 기록 및 원본 텍스트',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.expand_more_rounded,
                      size: 22,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 원본 텍스트 (펼쳐질 때)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '"${widget.rawText}"',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.9,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// ─── 인물·장소 칩 행 ──────────────────────────────────────────────────────────

class _PeoplePlacesRow extends StatelessWidget {
  const _PeoplePlacesRow({required this.entry});

  final DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...entry.people.map(
          (p) => _InfoChip(
            icon: Icons.person_outline_rounded,
            label: p,
            color: scheme.tertiary,
          ),
        ),
        ...entry.places.map(
          (p) => _InfoChip(
            icon: Icons.place_outlined,
            label: p,
            color: scheme.secondary,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 하단 AI 액션 바 ──────────────────────────────────────────────────────────

class _DetailActionBar extends StatelessWidget {
  const _DetailActionBar({
    required this.entry,
    required this.llmState,
    required this.onReanalyze,
    required this.onCorrect,
  });

  final DiaryEntry entry;
  final DetailLlmState llmState;
  final VoidCallback onReanalyze;
  final VoidCallback onCorrect;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final scheme = Theme.of(context).colorScheme;
    final isRunning = llmState.phase == DetailLlmPhase.running;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: isRunning
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  backgroundColor: scheme.surfaceContainerHighest,
                  color: scheme.primary,
                ),
                const SizedBox(height: 8),
                const Text(
                  'AI 분석 중...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReanalyze,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                    label: const Text('AI 재분석'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onCorrect,
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: Text(entry.correctedText != null ? '재보정' : '보정하기'),
                  ),
                ),
              ],
            ),
    );
  }
}
