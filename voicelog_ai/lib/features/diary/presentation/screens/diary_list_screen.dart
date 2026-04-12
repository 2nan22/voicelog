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
            color: const Color(0xFF414754),
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
                  color: const Color(0xFF414754).withValues(alpha: 0.6),
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

// ─── 고정 글래스 상단 네비게이션 ──────────────────────────────────────────────
// SliverPersistentHeaderDelegate 대신 일반 위젯으로 구현.
// SliverPersistentHeader(pinned) + BackdropFilter는 ShellRoute 탭 전환 후
// semantics.parentDataDirty assertion + touch 이벤트 차단을 유발한다.

class _GlassNavWidget extends StatelessWidget {
  const _GlassNavWidget({required this.topPadding});

  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: topPadding + 64,
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
