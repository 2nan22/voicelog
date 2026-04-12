import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/routes.dart';
import 'package:voicelog_ai/core/extensions/datetime_ext.dart';
import 'package:voicelog_ai/core/theme/app_colors.dart';
import 'package:voicelog_ai/core/widgets/loading_shimmer.dart';
import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';

/// 전체 기록을 월별로 그룹핑한 순수 타임라인 화면 (Shell body).
class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  @override
  void initState() {
    super.initState();
    // BackdropFilter + SliverPersistentHeader(pinned) 첫 프레임 이슈 회피
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final diariesAsync = ref.watch(diaryListNotifierProvider);

    return CustomScrollView(
      slivers: [
        // 글래스 상단 헤더
        SliverPersistentHeader(
          pinned: true,
          delegate: _LogsHeaderDelegate(topPadding: topPadding),
        ),
        // 월별 타임라인
        diariesAsync.when(
          loading: () => SliverList.builder(
            itemCount: 4,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: LoadingShimmer(height: 80, borderRadius: 16),
            ),
          ),
          error: (e, _) => SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('오류: $e'),
              ),
            ),
          ),
          data: (entries) => entries.isEmpty
              ? const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('아직 기록이 없어요.')),
                )
              : _buildTimeline(context, entries),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context, List<DiaryEntry> entries) {
    // 최신순 정렬 후 월(yyyy년 M월)별 그룹핑
    final sorted = [...entries]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final grouped = <String, List<DiaryEntry>>{};
    for (final e in sorted) {
      final key = '${e.createdAt.year}년 ${e.createdAt.month}월';
      grouped.putIfAbsent(key, () => []).add(e);
    }
    final months = grouped.keys.toList();

    return SliverList.builder(
      itemCount: months.length,
      itemBuilder: (context, idx) {
        final month = months[idx];
        final monthEntries = grouped[month]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
              child: Row(
                children: [
                  Text(
                    month,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF191C1E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${monthEntries.length}개',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...monthEntries.map((e) => _TimelineItem(entry: e)),
          ],
        );
      },
    );
  }
}

// ─── 타임라인 아이템 ──────────────────────────────────────────────────────────

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.entry});

  final DiaryEntry entry;

  Color get _emotionColor => switch (entry.emotion) {
    '기쁨' => AppColors.emotionJoy,
    '슬픔' => AppColors.emotionSadness,
    '평온' => AppColors.emotionCalm,
    '화남' => AppColors.emotionAnger,
    _ => AppColors.emotionCalm,
  };

  String get _emotionEmoji => switch (entry.emotion) {
    '기쁨' => '😊',
    '슬픔' => '😢',
    '평온' => '😌',
    '화남' => '😡',
    _ => '😌',
  };

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 타임라인 선 + 감정 원형
          SizedBox(
            width: 52,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: _emotionColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: _emotionColor, width: 1.5),
                  ),
                  child: Center(
                    child: Text(_emotionEmoji, style: const TextStyle(fontSize: 16)),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.only(left: 25),
                    color: const Color(0xFFE4E7EF),
                  ),
                ),
              ],
            ),
          ),
          // 카드 내용
          Expanded(
            child: GestureDetector(
              onTap: () => context.push(
                AppRoutes.diaryDetail.replaceFirst(':id', '${entry.id}'),
              ),
              child: Container(
                margin: const EdgeInsets.only(right: 24, bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A191C1E),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.createdAt.toKoreanTime(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF9AA0B0),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.correctedText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF191C1E),
                        height: 1.5,
                      ),
                    ),
                    if (entry.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: entry.tags
                            .take(3)
                            .map(
                              (t) => Text(
                                t,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 상단 헤더 ────────────────────────────────────────────────────────────────

class _LogsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _LogsHeaderDelegate({required this.topPadding});

  final double topPadding;

  @override
  double get minExtent => topPadding + 64;
  @override
  double get maxExtent => topPadding + 64;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: const Color(0xFFF8F9FB).withValues(alpha: 0.75),
          padding: EdgeInsets.only(top: topPadding, left: 24, right: 24),
          alignment: Alignment.centerLeft,
          child: const Text(
            '기록',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: Color(0xFF191C1E),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_LogsHeaderDelegate old) => old.topPadding != topPadding;
}
