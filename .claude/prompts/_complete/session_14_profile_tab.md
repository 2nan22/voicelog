# Session 14 — Profile 탭 (앱 통계 · 모델 정보 · 데이터 관리)

## 목표
사용자 통계, 온디바이스 LLM 모델 정보, 데이터 관리(전체 삭제) 기능을
담은 ProfileScreen을 구현한다. 외부 계정 없이 완전 로컬 정보만 표시한다.

## 참고 규칙 파일
- `.claude/rules/architecture.md` (레이어 의존성 방향)
- `.claude/rules/state_management.md` (FutureProvider 패턴)
- `.claude/rules/flutter_conventions.md` (async/await 에러 처리)
- `.claude/rules/ui_ux.md` (Material 3 색상, 위젯 규칙)

## 사전 조건
- Session 12 완료 (ShellRoute + MainShell)
- `IDiaryRepository.deleteAll()` 이미 구현돼 있음

---

## 꼭지 1 — ProfileScreen 기본 구조 + 앱 통계

### 작업 내용

1. **`lib/features/diary/application/profile_provider.dart`** 신규 작성

   ```dart
   import 'package:riverpod_annotation/riverpod_annotation.dart';
   import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';

   part 'profile_provider.g.dart';

   /// 프로필 화면에서 사용하는 앱 통계 집계.
   @riverpod
   Future<AppStats> appStats(AppStatsRef ref) async {
     final entries = await ref.watch(diaryListNotifierProvider.future);

     final totalEntries = entries.length;
     final totalWords = entries.fold<int>(
       0,
       (sum, e) => sum + e.correctedText.split(RegExp(r'\s+')).length,
     );

     // 연속 기록 일수 (writingStreakProvider와 동일 로직 — 중복 계산 허용, 의존성 단순화)
     final dates = entries
         .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
         .toSet()
         .toList()
       ..sort((a, b) => b.compareTo(a));

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

     final firstEntry = entries.isEmpty
         ? null
         : entries.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);

     return AppStats(
       totalEntries: totalEntries,
       totalWords: totalWords,
       streak: streak,
       firstEntryDate: firstEntry?.createdAt,
     );
   }

   class AppStats {
     const AppStats({
       required this.totalEntries,
       required this.totalWords,
       required this.streak,
       this.firstEntryDate,
     });

     final int totalEntries;
     final int totalWords;
     final int streak;
     final DateTime? firstEntryDate;
   }
   ```

2. `build_runner` 실행

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **`lib/features/diary/presentation/screens/profile_screen.dart`** 신규 작성 (기본 구조 + 통계 섹션)

   ```dart
   import 'dart:ui';
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:go_router/go_router.dart';
   import 'package:voicelog_ai/core/constants/routes.dart';
   import 'package:voicelog_ai/core/widgets/loading_shimmer.dart';
   import 'package:voicelog_ai/features/diary/application/profile_provider.dart';
   import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';
   import 'package:voicelog_ai/features/diary/application/diary_repository_provider.dart';

   class ProfileScreen extends ConsumerStatefulWidget {
     const ProfileScreen({super.key});
     @override
     ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
   }

   class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
       final statsAsync = ref.watch(appStatsProvider);

       return CustomScrollView(
         slivers: [
           SliverPersistentHeader(
             pinned: true,
             delegate: _ProfileHeaderDelegate(topPadding: topPadding),
           ),
           SliverToBoxAdapter(
             child: Padding(
               padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   // ── 아바타 + 타이틀
                   _AvatarSection(),
                   const SizedBox(height: 28),
                   // ── 통계 그리드
                   Text(
                     '나의 기록',
                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
                       fontWeight: FontWeight.w800,
                       color: const Color(0xFF191C1E),
                     ),
                   ),
                   const SizedBox(height: 12),
                   statsAsync.when(
                     loading: () => const LoadingShimmer(height: 140, borderRadius: 24),
                     error: (_, __) => const SizedBox.shrink(),
                     data: (stats) => _StatsGrid(stats: stats),
                   ),
                   const SizedBox(height: 28),
                   // ── 앱 & 모델 정보
                   Text(
                     '앱 정보',
                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
                       fontWeight: FontWeight.w800,
                       color: const Color(0xFF191C1E),
                     ),
                   ),
                   const SizedBox(height: 12),
                   _AppInfoSection(),
                   const SizedBox(height: 28),
                   // ── 데이터 관리
                   Text(
                     '데이터 관리',
                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
                       fontWeight: FontWeight.w800,
                       color: const Color(0xFF191C1E),
                     ),
                   ),
                   const SizedBox(height: 12),
                   _DataManagementSection(),
                   const SizedBox(height: 12),
                   // ── 설정 이동
                   _SettingsLink(),
                   const SizedBox(height: 120),
                 ],
               ),
             ),
           ),
         ],
       );
     }
   }

   // ─── 아바타 섹션 ──────────────────────────────────────────────────────────────

   class _AvatarSection extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return Row(
         children: [
           Container(
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
             ),
             child: const Icon(Icons.mic_rounded, color: Colors.white, size: 28),
           ),
           const SizedBox(width: 16),
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 '나의 음성 일기',
                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
                   fontWeight: FontWeight.w800,
                   color: const Color(0xFF191C1E),
                 ),
               ),
               const SizedBox(height: 2),
               Text(
                 '온디바이스 AI · 완전 비공개',
                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
                   color: const Color(0xFF9AA0B0),
                 ),
               ),
             ],
           ),
         ],
       );
     }
   }

   // ─── 통계 그리드 ──────────────────────────────────────────────────────────────

   class _StatsGrid extends StatelessWidget {
     const _StatsGrid({required this.stats});
     final AppStats stats;

     @override
     Widget build(BuildContext context) {
       return Row(
         children: [
           Expanded(
             child: _StatCard(
               value: '${stats.totalEntries}',
               unit: '편',
               label: '총 기록',
               icon: Icons.book_outlined,
             ),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: _StatCard(
               value: '${stats.totalWords}',
               unit: '어절',
               label: '총 단어',
               icon: Icons.text_fields_rounded,
             ),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: _StatCard(
               value: '${stats.streak}',
               unit: '일',
               label: '스트릭',
               icon: Icons.local_fire_department_rounded,
               highlight: stats.streak > 0,
             ),
           ),
         ],
       );
     }
   }

   class _StatCard extends StatelessWidget {
     const _StatCard({
       required this.value,
       required this.unit,
       required this.label,
       required this.icon,
       this.highlight = false,
     });

     final String value;
     final String unit;
     final String label;
     final IconData icon;
     final bool highlight;

     @override
     Widget build(BuildContext context) {
       final color = highlight
           ? Theme.of(context).colorScheme.primary
           : const Color(0xFF414754);

       return Container(
         padding: const EdgeInsets.all(16),
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(20),
           boxShadow: const [
             BoxShadow(
               color: Color(0x0F191C1E),
               blurRadius: 16,
               offset: Offset(0, 6),
             ),
           ],
         ),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Icon(icon, color: color, size: 22),
             const SizedBox(height: 10),
             RichText(
               text: TextSpan(
                 children: [
                   TextSpan(
                     text: value,
                     style: TextStyle(
                       fontSize: 22,
                       fontWeight: FontWeight.w800,
                       color: color,
                     ),
                   ),
                   TextSpan(
                     text: unit,
                     style: TextStyle(
                       fontSize: 11,
                       fontWeight: FontWeight.w600,
                       color: color.withValues(alpha: 0.6),
                     ),
                   ),
                 ],
               ),
             ),
             Text(
               label,
               style: Theme.of(context).textTheme.labelSmall?.copyWith(
                 color: const Color(0xFF9AA0B0),
               ),
             ),
           ],
         ),
       );
     }
   }

   // ─── 앱 정보 섹션 ─────────────────────────────────────────────────────────────

   class _AppInfoSection extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return Container(
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(20),
           boxShadow: const [
             BoxShadow(
               color: Color(0x0F191C1E),
               blurRadius: 16,
               offset: Offset(0, 6),
             ),
           ],
         ),
         child: Column(
           children: [
             _InfoRow(
               icon: Icons.memory_rounded,
               label: 'AI 모델',
               value: 'Gemma 2 2B INT4',
             ),
             const Divider(height: 1, indent: 56),
             _InfoRow(
               icon: Icons.shield_outlined,
               label: '개인정보 보호',
               value: '기기 내 완전 처리',
             ),
             const Divider(height: 1, indent: 56),
             _InfoRow(
               icon: Icons.info_outline_rounded,
               label: '버전',
               value: '0.1.0',
             ),
           ],
         ),
       );
     }
   }

   class _InfoRow extends StatelessWidget {
     const _InfoRow({
       required this.icon,
       required this.label,
       required this.value,
     });

     final IconData icon;
     final String label;
     final String value;

     @override
     Widget build(BuildContext context) {
       return Padding(
         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
         child: Row(
           children: [
             Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
             const SizedBox(width: 16),
             Expanded(
               child: Text(
                 label,
                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                   color: const Color(0xFF414754),
                 ),
               ),
             ),
             Text(
               value,
               style: Theme.of(context).textTheme.bodySmall?.copyWith(
                 color: const Color(0xFF9AA0B0),
                 fontWeight: FontWeight.w600,
               ),
             ),
           ],
         ),
       );
     }
   }
   ```

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 1]
feat(profile): ProfileScreen — 앱 통계 그리드 + 모델 정보 섹션

- appStatsProvider: 총 기록·단어·스트릭 집계
- _StatsGrid: 3분할 통계 카드 (스트릭 강조 하이라이트)
- _AppInfoSection: 모델명·개인정보·버전 InfoRow
- BackdropFilter 첫 프레임 해결 (addPostFrameCallback)

다음 꼭지(데이터 관리 + 설정 링크)를 진행할까요?
---
```

---

## 꼭지 2 — 데이터 관리 + 설정 링크 완성

### 작업 내용

1. `profile_screen.dart`에 **`_DataManagementSection`** 및 **`_SettingsLink`** 위젯 추가

   ```dart
   // ─── 데이터 관리 섹션 ─────────────────────────────────────────────────────────

   class _DataManagementSection extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       return Container(
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(20),
           boxShadow: const [
             BoxShadow(
               color: Color(0x0F191C1E),
               blurRadius: 16,
               offset: Offset(0, 6),
             ),
           ],
         ),
         child: InkWell(
           borderRadius: BorderRadius.circular(20),
           onTap: () => _confirmDeleteAll(context, ref),
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
             child: Row(
               children: [
                 Icon(
                   Icons.delete_outline_rounded,
                   size: 20,
                   color: Theme.of(context).colorScheme.error,
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: Text(
                     '모든 일기 삭제',
                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                       color: Theme.of(context).colorScheme.error,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                 ),
                 Icon(
                   Icons.chevron_right_rounded,
                   color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
                 ),
               ],
             ),
           ),
         ),
       );
     }

     Future<void> _confirmDeleteAll(BuildContext context, WidgetRef ref) async {
       final confirmed = await showDialog<bool>(
         context: context,
         builder: (ctx) => AlertDialog(
           title: const Text('모든 일기 삭제'),
           content: const Text('저장된 모든 일기가 영구적으로 삭제됩니다.\n이 작업은 되돌릴 수 없어요.'),
           actions: [
             TextButton(
               onPressed: () => Navigator.of(ctx).pop(false),
               child: const Text('취소'),
             ),
             TextButton(
               onPressed: () => Navigator.of(ctx).pop(true),
               style: TextButton.styleFrom(
                 foregroundColor: Theme.of(ctx).colorScheme.error,
               ),
               child: const Text('삭제'),
             ),
           ],
         ),
       );

       if (confirmed != true) return;

       try {
         final repo = await ref.read(diaryRepositoryProvider.future);
         await repo.deleteAll();
         ref.invalidate(diaryListNotifierProvider);
         if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('모든 일기가 삭제됐어요.')),
           );
         }
       } catch (e) {
         if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('삭제 실패: $e')),
           );
         }
       }
     }
   }

   // ─── 설정 링크 ────────────────────────────────────────────────────────────────

   class _SettingsLink extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return Container(
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(20),
           boxShadow: const [
             BoxShadow(
               color: Color(0x0F191C1E),
               blurRadius: 16,
               offset: Offset(0, 6),
             ),
           ],
         ),
         child: InkWell(
           borderRadius: BorderRadius.circular(20),
           onTap: () => context.push(AppRoutes.settings),
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
             child: Row(
               children: [
                 Icon(
                   Icons.settings_outlined,
                   size: 20,
                   color: Theme.of(context).colorScheme.primary,
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: Text(
                     '앱 설정',
                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                       color: const Color(0xFF414754),
                     ),
                   ),
                 ),
                 Icon(
                   Icons.chevron_right_rounded,
                   color: const Color(0xFF9AA0B0),
                 ),
               ],
             ),
           ),
         ),
       );
     }
   }

   // ─── 상단 헤더 ────────────────────────────────────────────────────────────────

   class _ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
     const _ProfileHeaderDelegate({required this.topPadding});
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
               '프로필',
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
     bool shouldRebuild(_ProfileHeaderDelegate old) => old.topPadding != topPadding;
   }
   ```

2. `flutter analyze` 오류 없음 확인
3. `flutter run` 후 다음 항목 수동 검증
   - Profile 탭 탭 → 통계 카드 정상 표시
   - '모든 일기 삭제' → 확인 다이얼로그 → 삭제 후 Home 탭 목록 비워짐
   - '앱 설정' → SettingsScreen 이동

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 2]
feat(profile): 데이터 전체 삭제 + 설정 링크 완성

- _DataManagementSection: 삭제 확인 다이얼로그 + deleteAll() 호출
- _SettingsLink: SettingsScreen 이동
- 삭제 후 diaryListNotifierProvider.invalidate로 전체 목록 갱신

Session 14 완료. 하단 탭 4개 (Home·Logs·Insight·Profile) 전부 구현 완료!
---
```
