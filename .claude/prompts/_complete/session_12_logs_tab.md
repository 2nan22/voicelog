# Session 12 — Logs 탭 + ShellRoute 탭 네비게이션

## 목표
go_router `ShellRoute`로 공통 하단 탭 네비를 분리하고,
음성 일기를 월별 타임라인으로 보여주는 Logs 화면을 구현한다.

## 참고 규칙 파일
- `.claude/rules/architecture.md` (라우팅 §6 ShellRoute)
- `.claude/rules/state_management.md` (ref.watch 패턴)
- `.claude/rules/performance.md` (ListView.builder 의무)
- `.claude/rules/ui_ux.md` (Material 3, 색상 시스템)

---

## 꼭지 1 — ShellRoute 리팩토링 (공통 하단 탭 네비 분리)

### 배경
현재 `_GlassBottomNav`가 `DiaryListScreen` 내부에 종속돼 있어
다른 탭 화면에서 공유할 수 없다.
`ShellRoute`를 도입해 Shell이 Scaffold + 하단 탭 네비를 소유하고,
각 탭 화면은 Scaffold 없이 body만 반환하도록 리팩토링한다.

### 작업 내용

1. **`lib/core/constants/routes.dart`** — 탭 라우트 상수 추가

   ```dart
   class AppRoutes {
     static const splash  = '/splash';
     // Shell 탭 라우트
     static const diaryList = '/';
     static const logs       = '/logs';
     static const insight    = '/insight';
     static const profile    = '/profile';
     // Shell 외부 라우트
     static const diaryRecord = '/record';
     static const diaryDetail = '/diary/:id';
     static const settings    = '/settings';
   }
   ```

2. **`lib/core/widgets/main_shell.dart`** — ShellRoute용 Shell 위젯 신규 작성

   ```dart
   import 'dart:ui';
   import 'package:flutter/material.dart';
   import 'package:go_router/go_router.dart';
   import 'package:voicelog_ai/core/constants/routes.dart';

   /// ShellRoute의 Shell 위젯.
   /// 하단 탭 네비를 소유하고, [child]로 현재 탭 화면 body를 받는다.
   class MainShell extends StatelessWidget {
     const MainShell({super.key, required this.child});

     final Widget child;

     @override
     Widget build(BuildContext context) {
       final location = GoRouterState.of(context).uri.path;
       return Scaffold(
         extendBody: true,
         backgroundColor: const Color(0xFFF2F4F6),
         body: child,
         bottomNavigationBar: _GlassBottomNav(location: location),
       );
     }
   }

   class _GlassBottomNav extends StatelessWidget {
     const _GlassBottomNav({required this.location});
     final String location;

     @override
     Widget build(BuildContext context) {
       final bottomPadding = MediaQuery.of(context).padding.bottom;
       return ClipRRect(
         borderRadius: const BorderRadius.only(
           topLeft: Radius.circular(40),
           topRight: Radius.circular(40),
         ),
         child: BackdropFilter(
           filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
           child: Container(
             height: 64 + bottomPadding,
             color: Colors.white.withValues(alpha: 0.80),
             padding: EdgeInsets.only(bottom: bottomPadding),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
               children: [
                 _NavItem(
                   icon: Icons.home_max_outlined,
                   label: 'Home',
                   isActive: location == AppRoutes.diaryList,
                   onTap: () => context.go(AppRoutes.diaryList),
                 ),
                 _NavItem(
                   icon: Icons.mic_rounded,
                   label: 'Logs',
                   isActive: location == AppRoutes.logs,
                   onTap: () => context.go(AppRoutes.logs),
                 ),
                 _NavItem(
                   icon: Icons.analytics_outlined,
                   label: 'Insight',
                   isActive: location == AppRoutes.insight,
                   onTap: () => context.go(AppRoutes.insight),
                 ),
                 _NavItem(
                   icon: Icons.person_outline_rounded,
                   label: 'Profile',
                   isActive: location == AppRoutes.profile,
                   onTap: () => context.go(AppRoutes.profile),
                 ),
               ],
             ),
           ),
         ),
       );
     }
   }

   class _NavItem extends StatelessWidget {
     const _NavItem({
       required this.icon,
       required this.label,
       required this.isActive,
       required this.onTap,
     });

     final IconData icon;
     final String label;
     final bool isActive;
     final VoidCallback onTap;

     @override
     Widget build(BuildContext context) {
       final color = isActive
           ? Theme.of(context).colorScheme.primary
           : const Color(0xFF9AA0B0);
       return GestureDetector(
         onTap: onTap,
         behavior: HitTestBehavior.opaque,
         child: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Icon(icon, color: color, size: 24),
               const SizedBox(height: 2),
               Text(
                 label,
                 style: TextStyle(
                   fontSize: 9,
                   fontWeight: FontWeight.w700,
                   color: color,
                   letterSpacing: 0.8,
                 ),
               ),
             ],
           ),
         ),
       );
     }
   }
   ```

3. **`lib/core/router/app_router.dart`** — ShellRoute 구조로 수정

   ```dart
   @Riverpod(keepAlive: true)
   GoRouter appRouter(AppRouterRef ref) {
     return GoRouter(
       initialLocation: AppRoutes.splash,
       routes: [
         GoRoute(
           path: AppRoutes.splash,
           builder: (_, __) => const SplashScreen(),
         ),
         GoRoute(
           path: AppRoutes.diaryRecord,
           builder: (_, __) => const DiaryRecordScreen(),
         ),
         GoRoute(
           path: AppRoutes.diaryDetail,
           builder: (context, state) {
             final id = int.parse(state.pathParameters['id']!);
             return DiaryDetailScreen(entryId: id);
           },
         ),
         GoRoute(
           path: AppRoutes.settings,
           builder: (_, __) => const SettingsScreen(),
         ),
         ShellRoute(
           builder: (context, state, child) => MainShell(child: child),
           routes: [
             GoRoute(
               path: AppRoutes.diaryList,
               builder: (_, __) => const DiaryListBody(),
             ),
             GoRoute(
               path: AppRoutes.logs,
               builder: (_, __) => const LogsScreen(),
             ),
             GoRoute(
               path: AppRoutes.insight,
               builder: (_, __) => const InsightScreen(),
             ),
             GoRoute(
               path: AppRoutes.profile,
               builder: (_, __) => const ProfileScreen(),
             ),
           ],
         ),
       ],
     );
   }
   ```

4. **`lib/features/diary/presentation/screens/diary_list_screen.dart`** — 리팩토링
   - `DiaryListScreen` → `DiaryListBody`로 클래스명 변경
   - `Scaffold` 제거 (Shell이 소유), `extendBody` 제거
   - `_GlassBottomNav` 제거 (MainShell로 이동)
   - `floatingActionButton` → `Scaffold` 밖에서 표현할 수 없으므로, `Stack`으로 본문에 FAB 직접 배치
   - `addPostFrameCallback` setState 유지 (BackdropFilter 첫 프레임 이슈)

   ```dart
   class DiaryListBody extends ConsumerStatefulWidget {
     const DiaryListBody({super.key});
     @override
     ConsumerState<DiaryListBody> createState() => _DiaryListBodyState();
   }

   class _DiaryListBodyState extends ConsumerState<DiaryListBody> {
     @override
     void initState() {
       super.initState();
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
               // 상단 글래스 네비 (기존 유지)
               SliverPersistentHeader(
                 pinned: true,
                 delegate: _GlassNavDelegate(topPadding: topPadding),
               ),
               // ... 기존 히어로 섹션, 벤토, 목록 Sliver 그대로
             ],
           ),
           // FAB — Stack 하단 우측에 배치
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
   }
   ```

5. `app_router.g.dart` 재생성 — `build_runner` 실행

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

6. `flutter analyze` 오류 없음 확인

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 1]
refactor(router): ShellRoute 도입 — 공통 하단 탭 네비 MainShell 분리

- MainShell: ShellRoute Shell 위젯, GlassBottomNav 소유
- AppRoutes: logs/insight/profile 탭 라우트 추가
- DiaryListScreen → DiaryListBody 리팩토링 (Scaffold 제거)
- app_router.dart: ShellRoute 구조로 전환

다음 꼭지(LogsScreen)를 진행할까요?
---
```

---

## 꼭지 2 — LogsScreen (월별 타임라인)

### 작업 내용

1. **`lib/features/diary/presentation/screens/logs_screen.dart`** 신규 작성

   Home의 DiaryListBody가 날짜별 그룹·통계 벤토 중심이라면,
   Logs는 **전체 기록을 월별로 그룹핑한 순수 타임라인**이다.

   ```dart
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

   class LogsScreen extends ConsumerStatefulWidget {
     const LogsScreen({super.key});
     @override
     ConsumerState<LogsScreen> createState() => _LogsScreenState();
   }

   class _LogsScreenState extends ConsumerState<LogsScreen> {
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
       // 최신순 정렬 후 월(yyyy-MM)별 그룹핑
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
       _     => AppColors.emotionCalm,
     };

     String get _emotionEmoji => switch (entry.emotion) {
       '기쁨' => '😊',
       '슬픔' => '😢',
       '평온' => '😌',
       '화남' => '😡',
       _     => '😌',
     };

     @override
     Widget build(BuildContext context) {
       return IntrinsicHeight(
         child: Row(
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
             // 타임라인 선 + 점
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
                     child: Center(child: Text(_emotionEmoji, style: const TextStyle(fontSize: 16))),
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
                               .map((t) => Text(
                                     t,
                                     style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                       color: Theme.of(context).colorScheme.primary,
                                     ),
                                   ))
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
   ```

2. `flutter analyze` 오류 없음 확인
3. `flutter run` 후 Logs 탭 탭 시 타임라인 정상 진입 확인

---

### 커밋 메시지 출력 후 대기

```
---
feat(logs): LogsScreen — 월별 타임라인 뷰

- 월 그룹 헤더 + 기록 건수 배지
- 감정 이모지 원형 + 수직 타임라인 선
- 카드 탭 시 상세 화면 이동
- BackdropFilter 첫 프레임 이슈 addPostFrameCallback 적용

Session 12 완료.
다음 단계: session_13_insight_tab.md 참조
---
```
