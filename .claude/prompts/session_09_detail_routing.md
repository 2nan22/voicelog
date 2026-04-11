# Session 09 — 상세 화면 + 라우팅 완성 + 앱 생명주기 관리

## 목표
일기 상세 화면 구현, go_router로 전체 화면을 연결하고, 백그라운드 진입 시 LLM 세션을 안전하게 해제한다.

## 참고 규칙 파일
- `.claude/rules/architecture.md` (라우팅 상수 위치)
- `.claude/rules/mediapipe_llm.md` (생명주기 관리)
- `.claude/rules/ui_ux.md` (Material 3, 다크 모드)

## UI 디자인 참고

작업 전 아래 파일을 반드시 읽는다.

- 디자인 시스템: `.claude/stitch/v0.0.1-20260411/seoul_minimalist/DESIGN.md`
- 화면 목업 (HTML): `.claude/stitch/v0.0.1-20260411/diary_detail_screen_new/code.html`
- 화면 스크린샷: `.claude/stitch/v0.0.1-20260411/diary_detail_screen_new/screen.png`

상세 화면의 헤더, 일기 본문 레이아웃, 감정·태그 배치는 HTML 목업 기준으로 구현한다.

---

## 꼭지 1 — DiaryDetailScreen

### 작업 내용

1. `lib/features/diary/presentation/screens/diary_detail_screen.dart` 작성

   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:go_router/go_router.dart';
   import 'package:voicelog_ai/core/constants/dimensions.dart';
   import 'package:voicelog_ai/core/constants/strings.dart';
   import 'package:voicelog_ai/core/widgets/emotion_chip.dart';
   import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';
   import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';

   class DiaryDetailScreen extends ConsumerWidget {
     final int entryId;

     const DiaryDetailScreen({super.key, required this.entryId});

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final diariesAsync = ref.watch(diaryListNotifierProvider);

       return diariesAsync.when(
         loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
         error: (e, _) => Scaffold(body: Center(child: Text('오류: $e'))),
         data: (entries) {
           final entry = entries.firstWhere(
             (e) => e.id == entryId,
             orElse: () => throw Exception('일기를 찾을 수 없습니다.'),
           );
           return _DiaryDetailBody(entry: entry);
         },
       );
     }
   }

   class _DiaryDetailBody extends ConsumerWidget {
     final DiaryEntry entry;

     const _DiaryDetailBody({required this.entry});

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       return Scaffold(
         appBar: AppBar(
           title: Text(entry.createdAt.toKoreanDate()),
           actions: [
             IconButton(
               icon: const Icon(Icons.delete_outline),
               tooltip: AppStrings.deleteDiary,
               onPressed: () => _confirmDelete(context, ref),
             ),
           ],
         ),
         body: SingleChildScrollView(
           padding: const EdgeInsets.all(AppDimensions.paddingLarge),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               // 감정 칩 + 시간
               Row(
                 children: [
                   EmotionChip(emotion: entry.emotion),
                   const Spacer(),
                   Text(
                     entry.createdAt.toKoreanTime(),
                     style: Theme.of(context).textTheme.bodySmall,
                   ),
                 ],
               ),
               const SizedBox(height: AppDimensions.paddingMedium),
               // 태그
               Wrap(
                 spacing: 8,
                 children: entry.tags
                     .map((t) => Chip(label: Text(t)))
                     .toList(),
               ),
               const Divider(height: AppDimensions.paddingXLarge),
               // 보정된 일기 본문
               Text(
                 entry.correctedText,
                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                   height: 1.8, // 줄 간격
                 ),
               ),
               const SizedBox(height: AppDimensions.paddingXLarge),
               // 원문 접기/펼치기
               _OriginalTextSection(rawText: entry.rawText),
             ],
           ),
         ),
       );
     }

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
               child: Text(AppStrings.deleteDiary),
             ),
           ],
         ),
       );
       if (confirmed == true) {
         await ref.read(diaryListNotifierProvider.notifier).deleteEntry(entry.id);
         if (context.mounted) context.pop();
       }
     }
   }

   class _OriginalTextSection extends StatefulWidget {
     final String rawText;
     const _OriginalTextSection({required this.rawText});

     @override
     State<_OriginalTextSection> createState() => _OriginalTextSectionState();
   }

   class _OriginalTextSectionState extends State<_OriginalTextSection> {
     bool _expanded = false;

     @override
     Widget build(BuildContext context) {
       return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           TextButton.icon(
             onPressed: () => setState(() => _expanded = !_expanded),
             icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
             label: Text(_expanded ? '원문 숨기기' : '원문 보기'),
           ),
           if (_expanded)
             Text(
               widget.rawText,
               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                 color: Theme.of(context).colorScheme.outline,
               ),
             ),
         ],
       );
     }
   }
   ```

   > **Google Stitch 참고**: 일기 본문 폰트 크기, 줄 간격, 구분선 스타일을 Stitch 디자인에 맞게 조정한다.

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 1]
feat(diary/presentation): DiaryDetailScreen — 본문·감정·태그·삭제 기능

- 보정 텍스트 본문 (줄 간격 1.8)
- EmotionChip + 태그 Chip + 시간 표시
- 삭제 확인 다이얼로그 + DiaryListNotifier.deleteEntry 연동
- 원문 접기/펼치기 섹션

다음 꼭지(go_router 라우팅 완성)를 진행할까요?
---
```

---

## 꼭지 2 — go_router 라우팅 완성

### 작업 내용

1. `lib/core/router/app_router.dart` 작성

   ```dart
   import 'package:go_router/go_router.dart';
   import 'package:riverpod_annotation/riverpod_annotation.dart';
   import 'package:voicelog_ai/core/constants/routes.dart';
   import 'package:voicelog_ai/features/diary/presentation/screens/diary_detail_screen.dart';
   import 'package:voicelog_ai/features/diary/presentation/screens/diary_list_screen.dart';
   import 'package:voicelog_ai/features/diary/presentation/screens/diary_record_screen.dart';
   import 'package:voicelog_ai/features/diary/presentation/screens/splash_screen.dart';
   import 'package:voicelog_ai/features/settings/presentation/screens/settings_screen.dart';

   part 'app_router.g.dart';

   @riverpod
   GoRouter appRouter(AppRouterRef ref) {
     return GoRouter(
       initialLocation: AppRoutes.splash,
       routes: [
         GoRoute(
           path: AppRoutes.splash,
           builder: (_, __) => const SplashScreen(),
         ),
         GoRoute(
           path: AppRoutes.diaryList,
           builder: (_, __) => const DiaryListScreen(),
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
       ],
     );
   }
   ```

2. `lib/app.dart`의 `MaterialApp`을 `MaterialApp.router`로 교체

   ```dart
   @override
   Widget build(BuildContext context, WidgetRef ref) {
     final router = ref.watch(appRouterProvider);
     return MaterialApp.router(
       title: AppStrings.appName,
       theme: buildLightTheme(),
       darkTheme: buildDarkTheme(),
       themeMode: ThemeMode.system,
       routerConfig: router,
     );
   }
   ```

3. `build_runner` 실행 후 `flutter analyze` 확인

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 2]
feat(core/router): go_router 전체 라우팅 완성

- AppRouter: splash/diaryList/diaryRecord/diaryDetail/settings 5개 라우트
- app.dart: MaterialApp.router + appRouterProvider 연결
- build_runner 코드 생성 완료

다음 꼭지(앱 생명주기 관리)를 진행할까요?
---
```

---

## 꼭지 3 — 앱 생명주기 관리 (백그라운드 LLM 해제)

### 작업 내용

1. `lib/core/utils/app_lifecycle_observer.dart` 작성

   ```dart
   import 'package:flutter/material.dart';
   import 'package:voicelog_ai/core/utils/logger.dart';
   import 'package:voicelog_ai/features/diary/domain/i_llm_inference_service.dart';

   /// 앱 백그라운드 진입 시 LLM 세션을 즉시 해제하는 생명주기 옵저버.
   class AppLifecycleObserver extends WidgetsBindingObserver {
     final ILlmInferenceService llmService;

     AppLifecycleObserver(this.llmService);

     @override
     void didChangeAppLifecycleState(AppLifecycleState state) {
       if (state == AppLifecycleState.paused) {
         AppLogger.info('앱 백그라운드 진입 → LLM 세션 해제');
         llmService.dispose();
       }
     }
   }
   ```

2. `lib/app.dart`를 `ConsumerStatefulWidget`으로 변경하여 옵저버 등록

   ```dart
   class VoicelogApp extends ConsumerStatefulWidget {
     const VoicelogApp({super.key});

     @override
     ConsumerState<VoicelogApp> createState() => _VoicelogAppState();
   }

   class _VoicelogAppState extends ConsumerState<VoicelogApp> {
     AppLifecycleObserver? _observer;

     @override
     void initState() {
       super.initState();
       final llmService = ref.read(llmInferenceServiceProvider);
       _observer = AppLifecycleObserver(llmService);
       WidgetsBinding.instance.addObserver(_observer!);
     }

     @override
     void dispose() {
       if (_observer != null) {
         WidgetsBinding.instance.removeObserver(_observer!);
       }
       super.dispose();
     }

     @override
     Widget build(BuildContext context) { /* 기존 MaterialApp.router */ }
   }
   ```

3. `flutter analyze` 오류 없음 확인
4. 실기기에서 앱 홈 버튼 → 다시 열기 시 정상 동작 확인

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 3]
feat(core): AppLifecycleObserver — 백그라운드 진입 시 LLM 세션 자동 해제

- AppLifecycleObserver: paused 상태 감지 → llmService.dispose()
- app.dart: ConsumerStatefulWidget으로 변경, 옵저버 등록/해제

Session 09 완료. Session 10으로 넘어가려면 session_10_settings.md 파일을 참고하세요.
---
```
