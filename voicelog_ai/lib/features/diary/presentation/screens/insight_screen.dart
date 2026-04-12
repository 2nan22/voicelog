import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voicelog_ai/core/theme/app_colors.dart';
import 'package:voicelog_ai/core/widgets/loading_shimmer.dart';
import 'package:voicelog_ai/features/diary/application/insight_provider.dart';
import 'package:voicelog_ai/features/diary/presentation/widgets/emotion_donut_chart.dart';

class InsightScreen extends ConsumerStatefulWidget {
  const InsightScreen({super.key});

  @override
  ConsumerState<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends ConsumerState<InsightScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final emotionAsync = ref.watch(emotionCountsProvider);
    final streakAsync = ref.watch(writingStreakProvider);
    final topTagsAsync = ref.watch(topTagsProvider);

    return CustomScrollView(
      slivers: [
        // 상단 헤더
        SliverPersistentHeader(
          pinned: true,
          delegate: _InsightHeaderDelegate(topPadding: topPadding),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 스트릭 카드
                streakAsync.when(
                  loading: () => const LoadingShimmer(height: 80, borderRadius: 20),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (streak) => _StreakCard(streak: streak),
                ),
                const SizedBox(height: 20),
                // ── 감정 분포 섹션
                Text(
                  '감정 분포',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF191C1E),
                  ),
                ),
                const SizedBox(height: 16),
                emotionAsync.when(
                  loading: () => const LoadingShimmer(height: 200, borderRadius: 24),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (counts) => _EmotionSection(counts: counts),
                ),
                const SizedBox(height: 24),
                // ── 자주 쓴 태그
                Text(
                  '자주 쓴 태그',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF191C1E),
                  ),
                ),
                const SizedBox(height: 12),
                topTagsAsync.when(
                  loading: () => const LoadingShimmer(height: 120, borderRadius: 20),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (tags) => _TagSection(tags: tags),
                ),
                const SizedBox(height: 120), // 하단 탭 여백
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── 스트릭 카드 ──────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak일 연속 기록 중',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                streak == 0 ? '오늘 첫 기록을 남겨보세요!' : '잘하고 있어요, 계속해요!',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 감정 분포 섹션 ───────────────────────────────────────────────────────────

class _EmotionSection extends StatelessWidget {
  const _EmotionSection({required this.counts});
  final Map<String, int> counts;

  static const _emotions = ['기쁨', '평온', '슬픔', '화남'];
  static const _emojis = ['😊', '😌', '😢', '😡'];
  static const _colors = [
    AppColors.emotionJoy,
    AppColors.emotionCalm,
    AppColors.emotionSadness,
    AppColors.emotionAnger,
  ];

  @override
  Widget build(BuildContext context) {
    final total = counts.values.fold(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F191C1E),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // 도넛 차트
          EmotionDonutChart(counts: counts),
          const SizedBox(width: 20),
          // 범례
          Expanded(
            child: Column(
              children: List.generate(_emotions.length, (i) {
                final count = counts[_emotions[i]] ?? 0;
                final pct = total == 0 ? 0.0 : count / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(_emojis[i], style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _emotions[i],
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${(pct * 100).round()}%',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _colors[i],
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: _colors[i].withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation(_colors[i]),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 태그 섹션 ────────────────────────────────────────────────────────────────

class _TagSection extends StatelessWidget {
  const _TagSection({required this.tags});
  final List<(String, int)> tags;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return Text(
        '태그가 없어요.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF9AA0B0),
        ),
      );
    }
    final maxCount = tags.first.$2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F191C1E),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: tags.map((tagCount) {
          final tag = tagCount.$1;
          final count = tagCount.$2;
          final ratio = count / maxCount;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    tag,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).colorScheme.primary,
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF9AA0B0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── 상단 헤더 ────────────────────────────────────────────────────────────────

class _InsightHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _InsightHeaderDelegate({required this.topPadding});
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
            '인사이트',
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
  bool shouldRebuild(_InsightHeaderDelegate old) => old.topPadding != topPadding;
}
