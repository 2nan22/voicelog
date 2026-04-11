# Session 08 — 일기 저장 및 목록 화면

## 목표
일기를 Isar DB에 저장하고, 날짜별로 그룹핑된 목록 화면을 구현한다.

## 참고 규칙 파일
- `.claude/rules/state_management.md` (AsyncNotifier, invalidateSelf)
- `.claude/rules/performance.md` (ListView.builder 의무)
- `.claude/rules/flutter_conventions.md` (async 에러 처리)

## UI 디자인 참고

작업 전 아래 파일을 반드시 읽는다.

- 디자인 시스템: `.claude/stitch/v0.0.1-20260411/seoul_minimalist/DESIGN.md`
- 화면 목업 (HTML): `.claude/stitch/v0.0.1-20260411/diary_list_screen_new/code.html`
- 화면 스크린샷: `.claude/stitch/v0.0.1-20260411/diary_list_screen_new/screen.png`

일기 카드 레이아웃, 날짜 헤더, 감정 색상 인디케이터는 HTML 목업 기준으로 구현한다.

---

## 꼭지 1 — 일기 저장 로직 및 DiaryListNotifier

### 작업 내용

1. `lib/features/diary/application/diary_list_provider.dart` 작성

   ```dart
   import 'package:riverpod_annotation/riverpod_annotation.dart';
   import 'package:voicelog_ai/core/utils/logger.dart';
   import 'package:voicelog_ai/features/diary/application/diary_repository_provider.dart';
   import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';

   part 'diary_list_provider.g.dart';

   @riverpod
   class DiaryListNotifier extends _$DiaryListNotifier {
     @override
     Future<List<DiaryEntry>> build() async {
       final repo = await ref.watch(diaryRepositoryProvider.future);
       return repo.findAll();
     }

     Future<void> addEntry(DiaryEntry entry) async {
       try {
         final repo = await ref.read(diaryRepositoryProvider.future);
         await repo.save(entry);
         ref.invalidateSelf();
       } catch (e) {
         AppLogger.error('일기 저장 실패', e);
         rethrow;
       }
     }

     Future<void> deleteEntry(int id) async {
       try {
         final repo = await ref.read(diaryRepositoryProvider.future);
         await repo.delete(id);
         ref.invalidateSelf();
       } catch (e) {
         AppLogger.error('일기 삭제 실패', e);
         rethrow;
       }
     }
   }
   ```

2. `DiaryRecordScreen._onSave()` 완성
   - `DiaryProcessNotifier`의 파싱 결과 + `sttTextNotifier`의 원문으로 `DiaryEntry.create()` 호출
   - `DiaryListNotifier.addEntry()` 호출
   - 저장 완료 후 `llmInferenceService.dispose()` 호출 (메모리 해제)
   - 저장 완료 후 일기 목록 화면으로 이동

   ```dart
   Future<void> _onSave() async {
     final parsed = ref.read(diaryProcessNotifierProvider);
     final rawText = ref.read(sttTextNotifierProvider);
     if (parsed == null) return;

     final entry = DiaryEntry.create(
       rawText: rawText,
       correctedText: parsed.correctedText,
       emotion: parsed.emotion,
       tags: parsed.tags,
     );

     await ref.read(diaryListNotifierProvider.notifier).addEntry(entry);

     // LLM 세션 즉시 해제 (발열·메모리 관리)
     ref.read(llmInferenceServiceProvider).dispose();

     if (mounted) context.go(AppRoutes.diaryList);
   }
   ```

3. `build_runner` 실행

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 1]
feat(diary): 일기 저장 로직 및 DiaryListNotifier 구현

- DiaryListNotifier: findAll/addEntry/deleteEntry (AsyncNotifier)
- DiaryRecordScreen._onSave(): 파싱 결과 저장 + LLM dispose + 목록 이동

다음 꼭지(DiaryListScreen)를 진행할까요?
---
```

---

## 꼭지 2 — DiaryListScreen (목록 화면)

### 작업 내용

1. `lib/features/diary/presentation/screens/diary_list_screen.dart` 작성

   - `CustomScrollView` + `SliverAppBar` (스크롤 시 축소)
   - 날짜별 그룹핑: `DateTimeFormatExt.toRelativeDate()`로 헤더 생성
   - `SliverList.builder` 사용 (ListView.builder 대신 Sliver로 통합)
   - 새 일기 작성 FAB

   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:go_router/go_router.dart';
   import 'package:voicelog_ai/core/constants/routes.dart';
   import 'package:voicelog_ai/core/constants/strings.dart';
   import 'package:voicelog_ai/core/widgets/loading_shimmer.dart';
   import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';
   import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';
   import 'package:voicelog_ai/features/diary/presentation/widgets/diary_card.dart';

   class DiaryListScreen extends ConsumerWidget {
     const DiaryListScreen({super.key});

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final diariesAsync = ref.watch(diaryListNotifierProvider);

       return Scaffold(
         body: CustomScrollView(
           slivers: [
             SliverAppBar.large(
               title: const Text(AppStrings.appName),
               actions: [
                 IconButton(
                   icon: const Icon(Icons.settings_outlined),
                   onPressed: () => context.push(AppRoutes.settings),
                   tooltip: '설정',
                 ),
               ],
             ),
             diariesAsync.when(
               loading: () => SliverList.builder(
                 itemCount: 5,
                 itemBuilder: (_, __) => const Padding(
                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   child: LoadingShimmer(),
                 ),
               ),
               error: (e, _) => SliverToBoxAdapter(
                 child: Center(child: Text('오류: $e')),
               ),
               data: (entries) => entries.isEmpty
                   ? SliverFillRemaining(
                       child: Center(
                         child: Text(
                           AppStrings.noEntries,
                           style: Theme.of(context).textTheme.bodyLarge,
                         ),
                       ),
                     )
                   : _buildGroupedList(context, entries),
             ),
           ],
         ),
         floatingActionButton: FloatingActionButton.extended(
           onPressed: () => context.push(AppRoutes.diaryRecord),
           icon: const Icon(Icons.mic),
           label: const Text('녹음'),
         ),
       );
     }

     Widget _buildGroupedList(BuildContext context, List<DiaryEntry> entries) {
       // 날짜별 그룹핑 로직
       final Map<String, List<DiaryEntry>> grouped = {};
       for (final entry in entries) {
         final key = entry.createdAt.toRelativeDate();
         grouped.putIfAbsent(key, () => []).add(entry);
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
                 padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                 child: Text(
                   dateKey,
                   style: Theme.of(context).textTheme.titleSmall?.copyWith(
                     color: Theme.of(context).colorScheme.primary,
                     fontWeight: FontWeight.w700,
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
   ```

   > **Google Stitch 참고**: SliverAppBar 높이, FAB 위치, 날짜 헤더 스타일을 Stitch 디자인에 맞게 조정한다.

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 2]
feat(diary/presentation): DiaryListScreen — 날짜별 그룹 목록 화면

- CustomScrollView + SliverAppBar.large (스크롤 축소)
- 날짜별 그룹핑 + toRelativeDate() 헤더
- 로딩: LoadingShimmer 5개 / 빈 목록: 안내 텍스트
- 새 일기 FAB

다음 꼭지(DiaryCard 위젯)를 진행할까요?
---
```

---

## 꼭지 3 — DiaryCard 위젯

### 작업 내용

1. `lib/features/diary/presentation/widgets/diary_card.dart` 작성

   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:go_router/go_router.dart';
   import 'package:voicelog_ai/core/constants/dimensions.dart';
   import 'package:voicelog_ai/core/constants/routes.dart';
   import 'package:voicelog_ai/core/theme/app_colors.dart';
   import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';
   import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';

   class DiaryCard extends ConsumerWidget {
     final DiaryEntry entry;

     const DiaryCard({super.key, required this.entry});

     Color _emotionColor() => switch (entry.emotion) {
       '기쁨' => AppColors.emotionJoy,
       '슬픔' => AppColors.emotionSadness,
       '평온' => AppColors.emotionCalm,
       '화남' => AppColors.emotionAnger,
       _     => AppColors.emotionCalm,
     };

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       return Padding(
         padding: const EdgeInsets.symmetric(
           horizontal: AppDimensions.paddingMedium,
           vertical: AppDimensions.paddingSmall / 2,
         ),
         child: Card(
           elevation: AppDimensions.cardElevation,
           child: InkWell(
             borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
             onTap: () => context.push(
               AppRoutes.diaryDetail.replaceFirst(':id', '${entry.id}'),
             ),
             child: Padding(
               padding: const EdgeInsets.all(AppDimensions.paddingMedium),
               child: Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   // 감정 컬러 인디케이터
                   Container(
                     width: 4,
                     height: 60,
                     decoration: BoxDecoration(
                       color: _emotionColor(),
                       borderRadius: BorderRadius.circular(2),
                     ),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           entry.correctedText,
                           maxLines: 2,
                           overflow: TextOverflow.ellipsis,
                           style: Theme.of(context).textTheme.bodyMedium,
                         ),
                         const SizedBox(height: 8),
                         Wrap(
                           spacing: 4,
                           children: entry.tags
                               .take(3)
                               .map((t) => Text(
                                     t,
                                     style: Theme.of(context)
                                         .textTheme
                                         .labelSmall
                                         ?.copyWith(
                                           color: Theme.of(context)
                                               .colorScheme
                                               .primary,
                                         ),
                                   ))
                               .toList(),
                         ),
                       ],
                     ),
                   ),
                   Text(
                     entry.createdAt.toKoreanTime(),
                     style: Theme.of(context).textTheme.labelSmall,
                   ),
                 ],
               ),
             ),
           ),
         ),
       );
     }
   }
   ```

2. `flutter analyze` 오류 없음 확인
3. `flutter run` 후 목록 화면에서 저장된 일기 카드 확인

   > **Google Stitch 참고**: 카드 높이, 감정 인디케이터 두께·위치, 텍스트 크기를 Stitch 디자인에 맞게 조정한다.

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 3]
feat(diary/presentation): DiaryCard 위젯 — 감정 컬러 인디케이터 + 요약 카드

- 감정별 왼쪽 컬러 바 인디케이터
- 보정 텍스트 2줄 요약 + 태그 3개 표시
- 시간 표시 (toKoreanTime)
- 상세 화면으로 InkWell 탭 이동 연결

Session 08 완료. Session 09로 넘어가려면 session_09_detail_routing.md 파일을 참고하세요.
---
```
