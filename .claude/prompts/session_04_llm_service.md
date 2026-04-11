# Session 04 — MediaPipe LLM 서비스 및 SplashScreen

## 목표
MediaPipe LLM 서비스를 구현하고, 앱 시작 시 모델을 preload하는 SplashScreen을 작성한다.
이 세션이 끝나면 앱 시작 시 LLM warm-up이 이루어지고 일기 목록 화면으로 전환된다.

## 참고 규칙 파일
- `.claude/rules/mediapipe_llm.md` (생명주기, delegate, 에러 처리)
- `.claude/rules/performance.md` (Isolate, warm-up, 발열 관리)
- `.claude/rules/state_management.md` (keepAlive Provider)

> **사전 확인 사항**
> - `mediapipe_genai_flutter` 최신 패키지명·버전을 pub.dev에서 확인 후 `pubspec.yaml`에 추가
> - 모델 파일 경로: 앱 첫 실행 시 다운로드 → `getApplicationDocumentsDirectory()/models/gemma-2b-it-cpu-int4.bin`

---

## 꼭지 1 — LLM 서비스 인터페이스 및 구현체

### 작업 내용

1. `pubspec.yaml`에 `mediapipe_genai_flutter` 추가 후 `flutter pub get` 실행
   - pub.dev에서 정확한 패키지명과 최신 버전 확인 (2026 기준 Google 공식 패키지)

2. `lib/features/diary/domain/i_llm_inference_service.dart` 작성

   ```dart
   /// MediaPipe LLM 추론 서비스 인터페이스.
   abstract class ILlmInferenceService {
     bool get isReady;
     Future<void> initialize();
     Stream<String> generateStream(String prompt);
     Future<String> generate(String prompt);
     void dispose();
   }
   ```

3. `lib/features/diary/infrastructure/llm_inference_service.dart` 작성

   - 플랫폼별 Delegate 분기 (Android: GPU, iOS: Core ML, fallback: CPU)
   - GPU 초기화 실패 시 CPU로 자동 재시도
   - 중복 초기화 방지 (`_isReady` 가드)
   - 모든 오류는 `AppLogger.error()`로 로컬 기록

   ```dart
   import 'dart:io';
   import 'package:voicelog_ai/core/utils/logger.dart';
   import 'package:voicelog_ai/features/diary/domain/i_llm_inference_service.dart';
   // import mediapipe_genai_flutter 패키지

   class MediaPipeLlmInferenceService implements ILlmInferenceService {
     dynamic _llmInference; // LlmInference 타입 (패키지 확인 후 교체)
     bool _isReady = false;

     @override
     bool get isReady => _isReady;

     @override
     Future<void> initialize() async {
       if (_isReady) return;
       final modelPath = await _getModelPath();
       try {
         final delegate = _selectDelegate();
         _llmInference = await _createInference(modelPath, delegate);
         _isReady = true;
         AppLogger.info('LLM 초기화 완료 (delegate: $delegate)');
       } catch (e) {
         // GPU/CoreML 실패 시 CPU fallback
         AppLogger.warn('Delegate 초기화 실패, CPU fallback: $e');
         try {
           _llmInference = await _createInference(modelPath, null /* CPU */);
           _isReady = true;
         } catch (fallbackError) {
           AppLogger.error('LLM CPU fallback도 실패', fallbackError);
           rethrow;
         }
       }
     }

     // _selectDelegate(), _getModelPath(), _createInference() 구현
     // 실제 mediapipe API에 맞게 작성

     @override
     void dispose() {
       _llmInference?.close();
       _llmInference = null;
       _isReady = false;
       AppLogger.info('LLM 세션 해제 완료');
     }
   }
   ```

   > `generateStream()`, `generate()` 구현은 mediapipe_genai_flutter API에 맞게 작성한다.
   > 패키지 API가 다를 경우 실제 API에 맞게 수정하고 주석으로 이유를 남긴다.

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 1]
feat(diary/infrastructure): ILlmInferenceService 인터페이스 및 MediaPipe 구현체 작성

- ILlmInferenceService: 추론 서비스 추상 인터페이스
- MediaPipeLlmInferenceService: Android GPU / iOS CoreML / CPU fallback 분기
- 중복 초기화 방지, 에러 로컬 로그 기록

다음 꼭지(LLM Provider + warm-up Provider)를 진행할까요?
---
```

---

## 꼭지 2 — LLM Provider 및 Warm-up Provider

### 작업 내용

1. `lib/features/diary/application/llm_provider.dart` 작성

   ```dart
   import 'package:riverpod_annotation/riverpod_annotation.dart';
   import 'package:voicelog_ai/features/diary/domain/i_llm_inference_service.dart';
   import 'package:voicelog_ai/features/diary/infrastructure/llm_inference_service.dart';

   part 'llm_provider.g.dart';

   /// LLM 서비스 싱글톤 Provider (앱 생명주기 동안 유지)
   @Riverpod(keepAlive: true)
   ILlmInferenceService llmInferenceService(LlmInferenceServiceRef ref) {
     final service = MediaPipeLlmInferenceService();
     ref.onDispose(service.dispose);
     return service;
   }

   /// LLM 모델 초기화 및 warm-up Provider
   @Riverpod(keepAlive: true)
   Future<void> llmWarmUp(LlmWarmUpRef ref) async {
     final service = ref.watch(llmInferenceServiceProvider);
     await service.initialize();
   }

   /// STT 텍스트 → LLM 스트리밍 응답 Provider
   @riverpod
   Stream<String> llmStream(LlmStreamRef ref, String rawText) {
     final service = ref.watch(llmInferenceServiceProvider);
     if (!service.isReady) {
       return Stream.error(StateError('LLM 서비스가 아직 준비되지 않았습니다.'));
     }
     final prompt = _buildPrompt(rawText);
     return service.generateStream(prompt);
   }

   String _buildPrompt(String rawText) {
     // prompts.dart의 kDiaryProcessingPrompt 사용
     // import 추가 필요
     return ''; // TODO: kDiaryProcessingPrompt.replaceAll('{raw_text}', rawText)
   }
   ```

2. `build_runner` 실행

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 2]
feat(diary/application): LLM Provider 및 warm-up Provider 구현

- llmInferenceServiceProvider: keepAlive 싱글톤, ref.onDispose 연결
- llmWarmUpProvider: 앱 시작 시 모델 초기화
- llmStreamProvider: STT 텍스트 → 스트리밍 응답
- build_runner 코드 생성 완료

다음 꼭지(SplashScreen)를 진행할까요?
---
```

---

## 꼭지 3 — SplashScreen 구현

### 작업 내용

1. `lib/features/diary/presentation/screens/splash_screen.dart` 작성

   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:go_router/go_router.dart';
   import 'package:voicelog_ai/core/constants/routes.dart';
   import 'package:voicelog_ai/core/constants/strings.dart';
   import 'package:voicelog_ai/features/diary/application/llm_provider.dart';

   class SplashScreen extends ConsumerWidget {
     const SplashScreen({super.key});

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final warmUpAsync = ref.watch(llmWarmUpProvider);

       // warm-up 완료 시 일기 목록으로 이동
       ref.listen(llmWarmUpProvider, (_, next) {
         if (next is AsyncData) {
           context.go(AppRoutes.diaryList);
         }
       });

       return Scaffold(
         body: Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               // 앱 로고 (Session 02 테마 적용)
               Icon(
                 Icons.mic,
                 size: 64,
                 color: Theme.of(context).colorScheme.primary,
               ),
               const SizedBox(height: 24),
               Text(
                 AppStrings.appName,
                 style: Theme.of(context).textTheme.headlineMedium,
               ),
               const SizedBox(height: 32),
               warmUpAsync.when(
                 loading: () => Column(
                   children: [
                     const LinearProgressIndicator(),
                     const SizedBox(height: 12),
                     Text(
                       AppStrings.splashLoading,
                       style: Theme.of(context).textTheme.bodyMedium,
                     ),
                   ],
                 ),
                 data: (_) => const SizedBox.shrink(),
                 error: (e, _) => Text(
                   '초기화 실패: $e',
                   style: TextStyle(
                     color: Theme.of(context).colorScheme.error,
                   ),
                 ),
               ),
             ],
           ),
         ),
       );
     }
   }
   ```

2. `lib/app.dart`의 임시 홈을 `SplashScreen`으로 교체 (go_router는 Session 09에서 완성)

3. `flutter analyze` 오류 없음 확인

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 3]
feat(diary/presentation): SplashScreen — LLM warm-up 연동 및 로딩 UI 구현

- SplashScreen: llmWarmUpProvider 상태에 따른 로딩/에러 UI
- warm-up 완료 시 diaryList 화면으로 자동 이동
- app.dart 임시 홈을 SplashScreen으로 교체

Session 04 완료. Session 05로 넘어가려면 session_05_stt_service.md 파일을 참고하세요.
---
```
