import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/dimensions.dart';
import 'package:voicelog_ai/core/constants/routes.dart';
import 'package:voicelog_ai/core/constants/strings.dart';
import 'package:voicelog_ai/core/extensions/datetime_ext.dart';
import 'package:voicelog_ai/core/widgets/loading_shimmer.dart';
import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';
import 'package:voicelog_ai/features/diary/presentation/widgets/diary_card.dart';

/// 날짜별 그룹핑된 일기 목록 화면 (Shell body).
///
/// Scaffold는 MainShell이 소유. 이 위젯은 body만 반환한다.
class DiaryListBody extends ConsumerStatefulWidget {
  const DiaryListBody({super.key});

  @override
  ConsumerState<DiaryListBody> createState() => _DiaryListBodyState();
}

class _DiaryListBodyState extends ConsumerState<DiaryListBody> {
  @override
  void initState() {
    super.initState();
    // BackdropFilter + SliverPersistentHeader(pinned) 조합이 Android 첫 프레임에서
    // 컴포지팅 레이어를 구성하지 못해 화면이 비어 보이는 Flutter 이슈.
    // 첫 프레임 완료 후 강제 리빌드로 해결.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final diariesAsync = ref.watch(diaryListNotifierProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // 고정 글래스 상단 네비게이션
            SliverPersistentHeader(
              pinned: true,
              delegate: _GlassNavDelegate(topPadding: topPadding),
            ),
            // 히어로 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                child: _HeroSection(),
              ),
            ),
            // 통계 벤토 카드
            diariesAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: _StatsBentoLoading(),
                ),
              ),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox(height: 8)),
              data: (entries) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: _StatsBento(entries: entries),
                ),
              ),
            ),
            // 날짜 그룹 일기 목록
            diariesAsync.when(
              loading: () => SliverList.builder(
                itemCount: 3,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: LoadingShimmer(height: 130, borderRadius: 20),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      '오류가 발생했어요: $e',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF414754),
                      ),
                    ),
                  ),
                ),
              ),
              data: (entries) => entries.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          AppStrings.noEntries,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF414754),
                          ),
                        ),
                      ),
                    )
                  : _buildGroupedList(context, entries),
            ),
            // 하단 nav 높이만큼 여백
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
        // FAB — Stack 하단 우측에 배치 (Scaffold 외부이므로 floatingActionButton 사용 불가)
        Positioned(
          right: 20,
          bottom: 100, // 하단 탭 높이(64) + 여백
          child: _GradientFab(
            onTap: () => context.push(AppRoutes.diaryRecord),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupedList(BuildContext context, List<DiaryEntry> entries) {
    // 최신순 정렬 후 날짜별 그룹핑
    final sorted = [...entries]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final grouped = <String, List<DiaryEntry>>{};
    for (final entry in sorted) {
      grouped.putIfAbsent(entry.createdAt.toRelativeDate(), () => []).add(entry);
    }
    final keys = grouped.keys.toList();

    return SliverList.builder(
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final dateKey = keys[index];
        final dayEntries = grouped[dateKey]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                dateKey,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...dayEntries.map((e) => DiaryCard(entry: e)),
          ],
        );
      },
    );
  }
}

// ─── 히어로 섹션 ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '나의 기록',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: const Color(0xFF191C1E),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '오늘 하루를 당신의 목소리로 담아보세요.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF414754).withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ─── 고정 글래스 상단 네비게이션 ──────────────────────────────────────────────

class _GlassNavDelegate extends SliverPersistentHeaderDelegate {
  const _GlassNavDelegate({required this.topPadding});

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
          padding: EdgeInsets.only(top: topPadding, left: 24, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Color(0xFF191C1E),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined, size: 26),
                color: const Color(0xFF0059B9),
                tooltip: '프로필',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_GlassNavDelegate old) => old.topPadding != topPadding;
}

// ─── 통계 벤토 ────────────────────────────────────────────────────────────────

class _StatsBento extends StatelessWidget {
  const _StatsBento({required this.entries});

  final List<DiaryEntry> entries;

  int get _thisMonthCount {
    final now = DateTime.now();
    return entries
        .where((e) => e.createdAt.year == now.year && e.createdAt.month == now.month)
        .length;
  }

  String get _topEmotion {
    if (entries.isEmpty) return '—';
    final counts = <String, int>{};
    for (final e in entries) {
      counts[e.emotion] = (counts[e.emotion] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BentoCard(
            icon: Icons.calendar_today_rounded,
            iconColor: Theme.of(context).colorScheme.primary,
            cardColor: Colors.white,
            label: '이번 달 기록',
            value: '$_thisMonthCount 건',
            valueColor: const Color(0xFF191C1E),
            labelColor: const Color(0xFF414754),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _BentoCard(
            icon: Icons.psychology_rounded,
            iconColor: Colors.white,
            cardColor: Theme.of(context).colorScheme.primary,
            label: '가장 많이 느낀 감정',
            value: _topEmotion,
            valueColor: Colors.white,
            labelColor: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.icon,
    required this.iconColor,
    required this.cardColor,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.labelColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color cardColor;
  final String label;
  final String value;
  final Color valueColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(AppDimensions.paddingMedium + 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F191C1E),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const Spacer(),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsBentoLoading extends StatelessWidget {
  const _StatsBentoLoading();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: LoadingShimmer(height: 140, borderRadius: AppDimensions.borderRadiusLg)),
        SizedBox(width: 16),
        Expanded(child: LoadingShimmer(height: 140, borderRadius: AppDimensions.borderRadiusLg)),
      ],
    );
  }
}

// ─── 그라디언트 FAB ────────────────────────────────────────────────────────────

class _GradientFab extends StatelessWidget {
  const _GradientFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.mic_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}
