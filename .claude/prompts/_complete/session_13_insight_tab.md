# Session 13 — Insight 탭 (감정 통계 · 스트릭)

## 목표
저장된 일기 데이터를 분석해 감정 분포 도넛 차트, 연속 기록 스트릭,
태그 빈도를 시각화하는 InsightScreen을 구현한다.
외부 차트 라이브러리 없이 `CustomPainter`로 직접 구현한다.

## 참고 규칙 파일
- `.claude/rules/flutter_conventions.md` (CustomPainter.shouldRepaint 규칙)
- `.claude/rules/performance.md` (RepaintBoundary로 파형 위젯 격리)
- `.claude/rules/ui_ux.md` (AppColors 감정 색상 시스템)
- `.claude/rules/state_management.md` (FutureProvider 패턴)

## 사전 조건
- Session 12 완료 (ShellRoute 및 MainShell 구현)
- `lib/features/diary/application/diary_list_provider.dart`의 `diaryListNotifierProvider` 사용

---

## 꼭지 1 — 감정 분포 도넛 차트

### 작업 내용

1. **`lib/features/diary/application/insight_provider.dart`** 신규 작성

   ```dart
   import 'package:riverpod_annotation/riverpod_annotation.dart';
   import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';
   import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';

   part 'insight_provider.g.dart';

   /// 감정별 카운트 맵. 예: {'기쁨': 5, '슬픔': 2, '평온': 8, '화남': 1}
   @riverpod
   Future<Map<String, int>> emotionCounts(EmotionCountsRef ref) async {
     final entries = await ref.watch(diaryListNotifierProvider.future);
     final counts = <String, int>{};
     for (final e in entries) {
       counts[e.emotion] = (counts[e.emotion] ?? 0) + 1;
     }
     return counts;
   }

   /// 연속 기록 스트릭 (오늘 기준 연속 작성 일수).
   @riverpod
   Future<int> writingStreak(WritingStreakRef ref) async {
     final entries = await ref.watch(diaryListNotifierProvider.future);
     if (entries.isEmpty) return 0;

     final dates = entries
         .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
         .toSet()
         .toList()
       ..sort((a, b) => b.compareTo(a)); // 최신순 정렬

     int streak = 0;
     DateTime cursor = DateTime.now();
     cursor = DateTime(cursor.year, cursor.month, cursor.day);

     for (final date in dates) {
       if (date == cursor || date == cursor.subtract(const Duration(days: 1))) {
         streak++;
         cursor = date;
       } else {
         break;
       }
     }
     return streak;
   }

   /// 태그 빈도 Top 5. 예: [('#산책', 7), ('#친구', 4), ...]
   @riverpod
   Future<List<(String, int)>> topTags(TopTagsRef ref) async {
     final entries = await ref.watch(diaryListNotifierProvider.future);
     final counts = <String, int>{};
     for (final e in entries) {
       for (final tag in e.tags) {
         counts[tag] = (counts[tag] ?? 0) + 1;
       }
     }
     final sorted = counts.entries.toList()
       ..sort((a, b) => b.value.compareTo(a.value));
     return sorted.take(5).map((e) => (e.key, e.value)).toList();
   }
   ```

2. `build_runner` 실행

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **`lib/features/diary/presentation/widgets/emotion_donut_chart.dart`** 신규 작성

   ```dart
   import 'dart:math';
   import 'package:flutter/material.dart';
   import 'package:voicelog_ai/core/theme/app_colors.dart';

   /// 감정 분포 도넛 차트 (CustomPainter 구현).
   class EmotionDonutChart extends StatelessWidget {
     const EmotionDonutChart({super.key, required this.counts});

     /// 감정 이름 → 건수 맵
     final Map<String, int> counts;

     static const _emotions = ['기쁨', '평온', '슬픔', '화남'];
     static const _colors = [
       AppColors.emotionJoy,
       AppColors.emotionCalm,
       AppColors.emotionSadness,
       AppColors.emotionAnger,
     ];

     @override
     Widget build(BuildContext context) {
       final total = counts.values.fold(0, (a, b) => a + b);
       if (total == 0) {
         return const SizedBox(
           height: 180,
           child: Center(child: Text('아직 데이터가 없어요.')),
         );
       }

       return RepaintBoundary(
         child: CustomPaint(
           size: const Size(180, 180),
           painter: _DonutPainter(counts: counts, total: total),
         ),
       );
     }
   }

   class _DonutPainter extends CustomPainter {
     const _DonutPainter({required this.counts, required this.total});

     final Map<String, int> counts;
     final int total;

     static const _emotions = ['기쁨', '평온', '슬픔', '화남'];
     static const _colors = [
       AppColors.emotionJoy,
       AppColors.emotionCalm,
       AppColors.emotionSadness,
       AppColors.emotionAnger,
     ];

     @override
     void paint(Canvas canvas, Size size) {
       final center = Offset(size.width / 2, size.height / 2);
       final radius = size.width / 2;
       const strokeWidth = 28.0;
       const gapAngle = 0.04; // 세그먼트 간 간격 (라디안)

       double startAngle = -pi / 2; // 12시 방향 시작

       for (int i = 0; i < _emotions.length; i++) {
         final emotion = _emotions[i];
         final count = counts[emotion] ?? 0;
         if (count == 0) continue;

         final sweepAngle = (count / total) * 2 * pi - gapAngle;
         final paint = Paint()
           ..color = _colors[i]
           ..style = PaintingStyle.stroke
           ..strokeWidth = strokeWidth
           ..strokeCap = StrokeCap.round;

         canvas.drawArc(
           Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
           startAngle + gapAngle / 2,
           sweepAngle,
           false,
           paint,
         );
         startAngle += sweepAngle + gapAngle;
       }

       // 중앙 총 건수 텍스트
       final textPainter = TextPainter(
         text: TextSpan(
           children: [
             TextSpan(
               text: '$total',
               style: const TextStyle(
                 fontSize: 28,
                 fontWeight: FontWeight.w800,
                 color: Color(0xFF191C1E),
               ),
             ),
             const TextSpan(
               text: '\n건',
               style: TextStyle(
                 fontSize: 12,
                 fontWeight: FontWeight.w500,
                 color: Color(0xFF9AA0B0),
               ),
             ),
           ],
         ),
         textAlign: TextAlign.center,
         textDirection: TextDirection.ltr,
       );
       textPainter.layout();
       textPainter.paint(
         canvas,
         center - Offset(textPainter.width / 2, textPainter.height / 2),
       );
     }

     @override
     bool shouldRepaint(_DonutPainter old) =>
         old.counts != counts || old.total != total;
   }
   ```

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 1]
feat(insight): InsightProvider 3종 + EmotionDonutChart CustomPainter

- emotionCountsProvider: 감정별 카운트
- writingStreakProvider: 연속 기록 일수
- topTagsProvider: 태그 빈도 Top 5
- EmotionDonutChart: 도넛형 차트 CustomPainter (RepaintBoundary 격리)

다음 꼭지(InsightScreen 조립)를 진행할까요?
---
```

---

## 꼭지 2 — InsightScreen 조립 (스트릭 · 태그 · 차트 통합)

### 작업 내용

1. **`lib/features/diary/presentation/screens/insight_screen.dart`** 신규 작성

   ```dart
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
       final emotionAsync  = ref.watch(emotionCountsProvider);
       final streakAsync   = ref.watch(writingStreakProvider);
       final topTagsAsync  = ref.watch(topTagsProvider);

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
     static const _emojis   = ['😊', '😌', '😢', '😡'];
     static const _colors   = [
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

     @override double get minExtent => topPadding + 64;
     @override double get maxExtent => topPadding + 64;

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
   ```

2. `flutter analyze` 오류 없음 확인
3. `flutter run` 후 Insight 탭 → 도넛 차트·스트릭·태그 정상 표시 확인

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 2]
feat(insight): InsightScreen — 감정 도넛 차트·스트릭·태그 빈도 통합

- StreakCard: 그라디언트 배경, 연속 일수 표시
- EmotionSection: 도넛 차트 + 감정별 LinearProgressIndicator 범례
- TagSection: Top 5 태그 막대 비율 시각화
- BackdropFilter 첫 프레임 이슈 해결 (addPostFrameCallback)

Session 13 완료.
다음 단계: session_14_profile_tab.md 참조
---
```
