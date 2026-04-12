# Session 15 — 버그 수정 (LocaleDataException · LLM 타임아웃 · 모델 자동 다운로드)

## 목표
실기기(S23 FE) 테스트에서 발견된 두 가지 버그를 수정한다.

| 번호 | 증상 | 근본 원인 |
|------|------|-----------|
| #1 | 메인 화면 하단에 `LocaleDataException` 오류 표시 | `DateFormat(..., 'ko')` 사용 전 `initializeDateFormatting` 미호출 |
| #2 | 녹음 후 "AI 처리가 지연되고 있어요" 다이얼로그 | 기기에 모델 파일 없음 → 추론 시도 → 30초 타임아웃 발생. 모델 자동 다운로드 로직 미구현 |

## 참고 규칙 파일
- `.claude/rules/flutter_conventions.md` (async/await 에러 처리)
- `.claude/rules/mediapipe_llm.md` (§7 오류 처리, 모델 파일 없음 처리)
- `.claude/rules/state_management.md` (FutureProvider / AsyncNotifier)

---

## 꼭지 1 — Bug #1: LocaleDataException 수정

### 원인 분석

`lib/core/extensions/datetime_ext.dart` 의 `toKoreanTime()`이
`DateFormat('a h:mm', 'ko')` 를 사용한다.
`intl` 패키지에서 영어 이외의 locale을 쓰려면
앱 시작 시 `initializeDateFormatting(<locale>)` 를 **반드시 먼저** 호출해야 한다.
현재 `main.dart`는 이 호출 없이 바로 `runApp()`한다.

### 작업 내용

1. **`lib/main.dart`** — `async main()` + `initializeDateFormatting` 추가

   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:intl/date_symbol_data_local.dart';

   import 'package:voicelog_ai/app.dart';

   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     // 한국어 DateFormat('a h:mm', 'ko') 사용 전 locale 데이터 초기화 필수.
     // 미호출 시 LocaleDataException 발생.
     await initializeDateFormatting('ko_KR', null);
     runApp(const ProviderScope(child: VoicelogApp()));
   }
   ```

2. `flutter analyze` 오류 없음 확인
3. `flutter run` 후 메인 화면 하단 `LocaleDataException` 사라짐 확인

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 1]
fix(main): 한국어 locale 데이터 초기화 누락으로 인한 LocaleDataException 수정

- main()을 async로 변경
- initializeDateFormatting('ko_KR') 호출 — toKoreanTime()의 DateFormat 'ko' locale 사용 전 필수

다음 꼭지(Bug #2 진단 및 모델 존재 여부 체크)를 진행할까요?
---
```

---

## 꼭지 2 — Bug #2 진단: 모델 파일 체크 + 에러 메시지 명확화

### 원인 분석

현재 `llm_inference_service.dart`의 `initialize()` 흐름:

```
1. _getModelPath() → {AppDocuments}/models/gemma-2b-it-cpu-int4.bin 경로 반환
2. LlmInferenceEngine(gpu options) 생성 → 내부적으로 생성자 성공 (모델 파일 유효성 검사 지연)
3. _isReady = true 설정
4. SplashScreen: llmWarmUpProvider = AsyncData → diaryList 이동
5. 녹음 완료 후 service.generateStream(prompt) 호출
6. 엔진이 실제 추론 시 모델 파일이 없음을 감지 → 내부 예외 or hang
7. 30초 타임아웃 → "AI 처리 지연" 다이얼로그
```

### 작업 내용

1. **`lib/features/diary/infrastructure/llm_inference_service.dart`**
   — `initialize()` 앞에 모델 파일 존재 여부 사전 검사 추가

   ```dart
   @override
   Future<void> initialize() async {
     if (_isReady) return;

     final modelPath = await _getModelPath();

     // ── 모델 파일 존재 여부 사전 검사 ──────────────────────────────
     // 파일 없이 LlmInferenceEngine을 생성하면 생성자는 성공하지만
     // 실제 추론 시 hang 또는 크래시가 발생한다 (mediapipe_genai 0.0.1 동작).
     // 여기서 명시적으로 확인하여 "모델 없음" 에러를 즉시 반환한다.
     final modelFile = File(modelPath);
     if (!modelFile.existsSync()) {
       AppLogger.error('모델 파일 없음: $modelPath', null);
       throw FileSystemException('모델 파일이 없습니다. 다운로드가 필요합니다.', modelPath);
     }
     // ────────────────────────────────────────────────────────────────

     await _initWithFallback(modelPath);
   }
   ```

   필요한 import 추가:
   ```dart
   import 'dart:io';
   ```

2. **`lib/features/diary/presentation/screens/splash_screen.dart`**
   — 초기화 실패 시 에러 메시지에 "모델 다운로드 필요" 안내 추가
   및 **재시도 버튼** 표시

   ```dart
   error: (error, _) => _ErrorMessage(
     context: context,
     error: error,
   ),
   ```

   `_ErrorMessage` 위젯 수정:
   ```dart
   class _ErrorMessage extends StatelessWidget {
     const _ErrorMessage({required this.context, required this.error});

     final BuildContext context;
     final Object error;

     @override
     Widget build(BuildContext _) {
       final isModelMissing = error.toString().contains('모델 파일이 없습니다');

       return Padding(
         padding: const EdgeInsets.symmetric(horizontal: 32),
         child: Column(
           children: [
             Icon(
               isModelMissing ? Icons.download_rounded : Icons.error_outline_rounded,
               size: 48,
               color: isModelMissing
                   ? Theme.of(context).colorScheme.primary
                   : Theme.of(context).colorScheme.error,
             ),
             const SizedBox(height: 12),
             Text(
               isModelMissing
                   ? 'AI 모델을 다운로드해야 합니다.\n(약 1.5 GB, Wi-Fi 권장)'
                   : '초기화 실패: $error',
               textAlign: TextAlign.center,
               style: TextStyle(
                 color: isModelMissing
                     ? Theme.of(context).colorScheme.onSurface
                     : Theme.of(context).colorScheme.error,
               ),
             ),
           ],
         ),
       );
     }
   }
   ```

3. `flutter run` 후 모델 파일 없는 상태에서 SplashScreen에 명확한 "다운로드 필요" 안내 표시 확인

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 2]
fix(llm): 모델 파일 부재 시 즉시 FileSystemException 발생으로 타임아웃 우회

- initialize(): File.existsSync() 사전 검사 추가 — hang 대신 즉시 에러 반환
- SplashScreen._ErrorMessage: 모델 부재 시 다운로드 안내 메시지 분기

다음 꼭지(모델 자동 다운로드 로직)를 진행할까요?
---
```

---

## 꼭지 3 — 모델 자동 다운로드 (SplashScreen 통합)

### 설계 개요

```
앱 최초 실행
  ↓
SplashScreen 진입
  ↓
모델 파일 존재 여부 확인 (ModelDownloadNotifier)
  ├─ 있음 → llmWarmUp() → diaryList 이동
  └─ 없음 → 다운로드 시작 (진행률 UI 표시)
              ↓
           다운로드 완료 → llmWarmUp() → diaryList 이동
              ↓
           실패 → 재시도 버튼 표시
```

### 작업 내용

#### 1. `lib/core/constants/prompts.dart` (또는 별도 `model_config.dart`) — 모델 다운로드 URL 상수 추가

`lib/core/constants/prompts.dart` 하단에 추가:

```dart
// ── 모델 다운로드 설정 ────────────────────────────────────────────────────────
/// Gemma 2B IT INT4 — MediaPipe CPU 추론용 모델
/// 출처: https://ai.google.dev/edge/mediapipe/solutions/genai/llm_inference/android
/// 파일 크기: 약 1.5 GB
const String kModelDownloadUrl =
    'https://storage.googleapis.com/mediapipe-models/llm_inference/gemma-2b-it-cpu-int4/float32/1/gemma-2b-it-cpu-int4.bin';
const String kModelFileName = 'gemma-2b-it-cpu-int4.bin';
const String kModelSubDir   = 'models';
```

> **주의**: URL은 Google AI Edge 공식 문서에서 재확인 후 업데이트.
> 다운로드 전 실제 URL 유효성 확인 권장:
> `curl -I <URL>` 로 200 OK 응답 확인.

---

#### 2. `lib/features/diary/application/model_download_notifier.dart` 신규 작성

```dart
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:voicelog_ai/core/constants/prompts.dart';
import 'package:voicelog_ai/core/utils/logger.dart';

part 'model_download_notifier.freezed.dart';
part 'model_download_notifier.g.dart';

/// 모델 다운로드 상태.
@freezed
class ModelDownloadState with _$ModelDownloadState {
  const factory ModelDownloadState.idle()                          = ModelDownloadIdle;
  const factory ModelDownloadState.checking()                      = ModelDownloadChecking;
  const factory ModelDownloadState.alreadyExists()                 = ModelDownloadAlreadyExists;
  const factory ModelDownloadState.downloading({
    required double progress,   // 0.0 ~ 1.0
    required int receivedBytes,
    required int totalBytes,
  })                                                               = ModelDownloading;
  const factory ModelDownloadState.done()                          = ModelDownloadDone;
  const factory ModelDownloadState.error({required String message}) = ModelDownloadError;
}

@riverpod
class ModelDownloadNotifier extends _$ModelDownloadNotifier {
  @override
  ModelDownloadState build() => const ModelDownloadState.idle();

  /// 모델 파일 존재 여부를 확인하고, 없으면 다운로드한다.
  /// 완료 시 [ModelDownloadState.done] 또는 [ModelDownloadState.alreadyExists] emit.
  Future<void> ensureModelReady() async {
    state = const ModelDownloadState.checking();

    try {
      final modelPath = await _getModelPath();
      final modelFile = File(modelPath);

      if (modelFile.existsSync() && modelFile.lengthSync() > 0) {
        AppLogger.info('모델 파일 이미 존재: $modelPath');
        state = const ModelDownloadState.alreadyExists();
        return;
      }

      AppLogger.info('모델 파일 없음. 다운로드 시작: $kModelDownloadUrl');
      await _download(modelFile);
    } catch (e) {
      AppLogger.error('모델 다운로드 실패', e);
      state = ModelDownloadState.error(message: e.toString());
    }
  }

  Future<void> _download(File destFile) async {
    // models 디렉터리 생성
    await destFile.parent.create(recursive: true);

    final tmpFile = File('${destFile.path}.tmp');

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(kModelDownloadUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('다운로드 실패 (HTTP ${response.statusCode})');
      }

      final totalBytes = response.contentLength;
      int receivedBytes = 0;

      final sink = tmpFile.openWrite();
      await for (final chunk in response) {
        sink.add(chunk);
        receivedBytes += chunk.length;

        if (totalBytes > 0) {
          state = ModelDownloadState.downloading(
            progress: receivedBytes / totalBytes,
            receivedBytes: receivedBytes,
            totalBytes: totalBytes,
          );
        }
      }
      await sink.flush();
      await sink.close();

      // tmp → 최종 경로로 이동 (원자적 rename)
      await tmpFile.rename(destFile.path);
      AppLogger.info('모델 다운로드 완료: ${destFile.path}');
      state = const ModelDownloadState.done();
    } catch (e) {
      // 실패 시 tmp 파일 정리
      if (tmpFile.existsSync()) await tmpFile.delete();
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<String> _getModelPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$kModelSubDir/$kModelFileName';
  }

  /// 실패 후 재시도
  Future<void> retry() => ensureModelReady();
}
```

---

#### 3. `lib/features/diary/presentation/screens/splash_screen.dart` 전면 수정

현재 SplashScreen은 `llmWarmUpProvider`만 watch한다.
모델 다운로드 단계를 앞에 추가한다.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/routes.dart';
import 'package:voicelog_ai/core/constants/strings.dart';
import 'package:voicelog_ai/features/diary/application/llm_provider.dart';
import 'package:voicelog_ai/features/diary/application/model_download_notifier.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(modelDownloadNotifierProvider);
    final warmUpAsync   = ref.watch(llmWarmUpProvider);

    // ── 최초 1회 모델 확인/다운로드 트리거 ─────────────────────────
    ref.listen<ModelDownloadState>(modelDownloadNotifierProvider, (prev, next) {
      // 다운로드 완료(또는 이미 존재) → llmWarmUp이 자동으로 실행됨
    });

    // 앱 시작 시 모델 확인 시작 (idle 상태일 때만)
    if (downloadState is ModelDownloadIdle) {
      // build 이후 첫 프레임에서 실행
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(modelDownloadNotifierProvider.notifier).ensureModelReady();
      });
    }

    // ── warm-up 완료 시 목록 화면으로 이동 ─────────────────────────
    ref.listen<AsyncValue<void>>(llmWarmUpProvider, (_, next) {
      if (next is AsyncData) context.go(AppRoutes.diaryList);
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              // ── 상태별 UI ────────────────────────────────────────
              downloadState.when(
                idle: () => const _StatusText('준비 중...'),
                checking: () => const _StatusText('모델 파일 확인 중...'),
                alreadyExists: () => _WarmUpSection(warmUpAsync: warmUpAsync),
                downloading: (progress, received, total) =>
                    _DownloadSection(progress: progress, received: received, total: total),
                done: () => _WarmUpSection(warmUpAsync: warmUpAsync),
                error: (message) => _ErrorSection(
                  message: message,
                  onRetry: () =>
                      ref.read(modelDownloadNotifierProvider.notifier).retry(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 상태별 서브 위젯 ─────────────────────────────────────────────────────────

class _StatusText extends StatelessWidget {
  const _StatusText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const CircularProgressIndicator(),
      const SizedBox(height: 16),
      Text(text, style: Theme.of(context).textTheme.bodyMedium),
    ],
  );
}

/// 다운로드 진행률 UI
class _DownloadSection extends StatelessWidget {
  const _DownloadSection({
    required this.progress,
    required this.received,
    required this.total,
  });

  final double progress;
  final int received;
  final int total;

  String _formatMb(int bytes) => '${(bytes / 1024 / 1024).toStringAsFixed(0)} MB';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            'AI 모델 다운로드 중...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Wi-Fi 환경을 권장합니다 (약 1.5 GB)',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            total > 0
                ? '${_formatMb(received)} / ${_formatMb(total)} (${(progress * 100).round()}%)'
                : '${_formatMb(received)} 수신 중...',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

/// 다운로드 완료 후 LLM warm-up 상태 표시
class _WarmUpSection extends StatelessWidget {
  const _WarmUpSection({required this.warmUpAsync});
  final AsyncValue<void> warmUpAsync;

  @override
  Widget build(BuildContext context) => warmUpAsync.when(
    loading: () => Column(
      children: [
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.splashLoading,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
    data: (_) => const SizedBox.shrink(),
    error: (e, _) => _ErrorSection(
      message: '엔진 초기화 실패: $e',
      onRetry: null,
    ),
  );
}

/// 에러 + 재시도 버튼
class _ErrorSection extends StatelessWidget {
  const _ErrorSection({required this.message, required this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Column(
      children: [
        Icon(Icons.error_outline_rounded,
          size: 48, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('다시 시도'),
          ),
        ],
      ],
    ),
  );
}
```

---

#### 4. `build_runner` 실행

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

`model_download_notifier.freezed.dart` 와 `model_download_notifier.g.dart` 생성 확인.

---

#### 5. 실기기 검증 체크리스트

- [ ] 앱 최초 설치 → SplashScreen에 "다운로드 중..." + 진행률 표시
- [ ] 다운로드 완료 → "AI 엔진을 준비하고 있어요..." → 메인 화면 이동
- [ ] 앱 재실행 → "모델 파일 확인 중..." → 즉시 warm-up → 메인 화면 이동
- [ ] 네트워크 오프 상태에서 최초 실행 → 에러 + "다시 시도" 버튼 표시
- [ ] 다운로드 도중 앱 종료 → 재실행 시 `.tmp` 파일 무시하고 처음부터 재다운로드
- [ ] 녹음 → STT → LLM 처리 → "AI 처리 지연" 다이얼로그 **미발생** 확인

> **다운로드 URL 검증**:
> 빌드 전 터미널에서 반드시 확인:
> ```bash
> curl -I "https://storage.googleapis.com/mediapipe-models/llm_inference/gemma-2b-it-cpu-int4/float32/1/gemma-2b-it-cpu-int4.bin"
> ```
> HTTP 200이 아니면 Google AI Edge 공식 문서에서 최신 URL 확인 후 `kModelDownloadUrl` 상수 업데이트.

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 3]
feat(model): 앱 최초 실행 시 LLM 모델 자동 다운로드 구현

- ModelDownloadNotifier: idle→checking→downloading→done 상태 머신
  - dart:io HttpClient 사용 (외부 패키지 추가 없음)
  - tmp 파일 → rename 원자적 저장 (중간 실패 시 오염 방지)
- SplashScreen 전면 수정: 다운로드 → warm-up → 목록 이동 통합 흐름
- 진행률 LinearProgressIndicator (수신 MB / 전체 MB)
- 에러 시 "다시 시도" FilledButton 표시

Session 15 완료.
---
```
