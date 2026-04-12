import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:voicelog_ai/core/constants/routes.dart';
import 'package:voicelog_ai/core/constants/strings.dart';
import 'package:voicelog_ai/core/theme/app_colors.dart';
import 'package:voicelog_ai/core/widgets/loading_shimmer.dart';
import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';
import 'package:voicelog_ai/features/diary/presentation/widgets/diary_card.dart';

/// 월간 캘린더 기반 홈 화면 (Shell body).
///
/// Scaffold는 MainShell이 소유. 이 위젯은 body만 반환한다.
///
/// 주의: SliverPersistentHeader(pinned) + BackdropFilter 조합은
/// ShellRoute 탭 전환 후 semantics.parentDataDirty assertion을 유발하여
/// 렌더링 트리가 dirty 상태로 남고 touch 이벤트가 완전히 차단된다.
/// 따라서 고정 헤더는 Stack + Positioned 패턴으로 구현한다.
class DiaryListBody extends ConsumerStatefulWidget {
  const DiaryListBody({super.key});

  @override
  ConsumerState<DiaryListBody> createState() => _DiaryListBodyState();
}

class _DiaryListBodyState extends ConsumerState<DiaryListBody> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Color _emotionColor(String emotion) => switch (emotion) {
    '기쁨' => AppColors.emotionJoy,
    '슬픔' => AppColors.emotionSadness,
    '화남' => AppColors.emotionAnger,
    _     => AppColors.emotionCalm,
  };

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final diaryByDateAsync = ref.watch(diaryByDateProvider);
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // 고정 헤더 높이만큼 상단 여백
            SliverToBoxAdapter(child: SizedBox(height: topPadding + 64)),
            // 월간 캘린더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: diaryByDateAsync.when(
                  loading: () => _buildCalendar(context, scheme, const {}),
                  error: (_, __) => _buildCalendar(context, scheme, const {}),
                  data: (diaryByDate) => _buildCalendar(context, scheme, diaryByDate),
                ),
              ),
            ),
            // 퀵 인사이트 벤토 그리드
            SliverToBoxAdapter(
              child: diaryByDateAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (diaryByDate) => _QuickInsightBento(diaryByDate: diaryByDate),
              ),
            ),
            // 선택한 날의 일기 목록
            SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(
                  key: ValueKey(_selectedDay),
                  child: _buildSelectedDayContent(context, diaryByDateAsync),
                ),
              ),
            ),
            // 하단 nav 높이만큼 여백
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
        // 글래스 고정 헤더 (SliverPersistentHeader 대체)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _GlassNavWidget(topPadding: topPadding),
        ),
        // FAB — Stack 하단 우측에 배치
        Positioned(
          right: 20,
          bottom: 100,
          child: _GradientFab(onTap: () => context.push(AppRoutes.diaryRecord)),
        ),
      ],
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    ColorScheme scheme,
    Map<DateTime, List<DiaryEntry>> diaryByDate,
  ) {
    return TableCalendar<DiaryEntry>(
      locale: 'ko_KR',
      firstDay: DateTime(2020),
      lastDay: DateTime(2100),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() => _focusedDay = focusedDay);
      },
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: '월'},
      eventLoader: (day) {
        final key = DateTime(day.year, day.month, day.day);
        return diaryByDate[key] ?? [];
      },
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
        ),
        selectedDecoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
        ),
        // markerBuilder로 직접 렌더링하므로 기본 마커 비활성화
        markerDecoration: const BoxDecoration(),
        markersMaxCount: 0,
      ),
      calendarBuilders: CalendarBuilders<DiaryEntry>(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: events.take(3).map((entry) {
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _emotionColor(entry.emotion),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedDayContent(
    BuildContext context,
    AsyncValue<Map<DateTime, List<DiaryEntry>>> diaryByDateAsync,
  ) {
    if (_selectedDay == null) return const SizedBox.shrink();

    return diaryByDateAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: LoadingShimmer(height: 130, borderRadius: 20),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          '오류가 발생했어요: $e',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ),
      data: (diaryByDate) {
        final key = DateTime(
          _selectedDay!.year,
          _selectedDay!.month,
          _selectedDay!.day,
        );
        final entries = diaryByDate[key] ?? [];
        if (entries.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                '이 날의 일기가 없어요',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
              child: Text(
                '${_selectedDay!.year}년 ${_selectedDay!.month}월 ${_selectedDay!.day}일',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...entries.map((e) => DiaryCard(entry: e)),
          ],
        );
      },
    );
  }
}

// ─── 퀵 인사이트 벤토 ────────────────────────────────────────────────────────

class _QuickInsightBento extends StatelessWidget {
  const _QuickInsightBento({required this.diaryByDate});

  final Map<DateTime, List<DiaryEntry>> diaryByDate;

  /// 오늘부터 역방향으로 연속 기록 일수를 계산
  int get _streakDays {
    int streak = 0;
    DateTime day = DateTime.now();
    while (true) {
      final key = DateTime(day.year, day.month, day.day);
      if (diaryByDate.containsKey(key)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// 최근 7일 중 가장 많이 기록된 감정 반환
  String get _weeklyEmotion {
    final now = DateTime.now();
    final counts = <String, int>{};
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final key = DateTime(day.year, day.month, day.day);
      final entries = diaryByDate[key] ?? [];
      for (final e in entries) {
        counts[e.emotion] = (counts[e.emotion] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return '—';
    return counts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final streak = _streakDays;
    final emotion = _weeklyEmotion;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 연속 기록 카드
          Expanded(
            child: _InsightCard(
              backgroundColor: scheme.primary,
              icon: Icons.bolt_rounded,
              iconColor: Colors.white,
              label: '연속 기록',
              value: streak > 0 ? '$streak일째' : '기록 없음',
              description: streak > 0 ? '지금의 흐름을 놓치지 마세요!' : '오늘 첫 기록을 남겨보세요',
              textColor: Colors.white,
              labelColor: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 12),
          // 이번 주 기분 카드
          Expanded(
            child: _InsightCard(
              backgroundColor: Colors.white,
              icon: Icons.psychology_rounded,
              iconColor: scheme.primary,
              label: '이번 주 기분',
              value: emotion,
              description: null,
              textColor: AppColors.onSurface,
              labelColor: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.description,
    required this.textColor,
    required this.labelColor,
  });

  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? description;
  final Color textColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
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
          // 아이콘 + 라벨 행
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 값
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textColor,
              height: 1.1,
            ),
          ),
          // 설명 (옵션)
          if (description != null) ...[
            const SizedBox(height: 6),
            Text(
              description!,
              style: TextStyle(
                fontSize: 12,
                color: textColor.withValues(alpha: 0.75),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── 고정 글래스 상단 네비게이션 ──────────────────────────────────────────────
// SliverPersistentHeaderDelegate 대신 일반 위젯으로 구현.
// SliverPersistentHeader(pinned) + BackdropFilter는 ShellRoute 탭 전환 후
// semantics.parentDataDirty assertion + touch 이벤트 차단을 유발한다.

class _GlassNavWidget extends StatelessWidget {
  const _GlassNavWidget({required this.topPadding});

  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: topPadding + 64,
          color: Colors.white.withValues(alpha: 0.8),
          padding: EdgeInsets.only(top: topPadding, left: 24, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 앱명 — Primary 색상 좌측 정렬
              Text(
                AppStrings.appName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: scheme.primary,
                ),
              ),
              // 프로필 아바타 (32px 원형)
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainer,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 18,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
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
