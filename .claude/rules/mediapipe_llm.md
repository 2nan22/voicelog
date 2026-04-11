# MediaPipe LLM 통합 규칙

## 1. 모델 정보

| 항목 | 값 |
|------|-----|
| 모델 | Gemma 2 2B INT4 양자화 |
| 파일명 | `gemma-2b-it-cpu-int4.bin` |
| 저장 위치 | 앱 내부 스토리지 (path_provider로 접근) |
| 최초 다운로드 | 앱 최초 실행 시 다운로드 후 로컬 캐싱 (첫 다운로드는 예외적으로 네트워크 허용) |

---

## 2. LlmInferenceService 구현 원칙

### 싱글톤 관리

`LlmInferenceService`는 Riverpod Provider를 통해 앱 전체에서 하나의 인스턴스만 유지한다.

```dart
// lib/features/diary/infrastructure/llm_inference_service.dart

abstract class ILlmInferenceService {
  Future<void> initialize();
  Stream<String> generateStream(String prompt);
  Future<String> generate(String prompt);
  bool get isReady;
  void dispose();
}

class MediaPipeLlmInferenceService implements ILlmInferenceService {
  LlmInference? _llmInference;
  bool _isReady = false;

  @override
  bool get isReady => _isReady;

  @override
  Future<void> initialize() async {
    if (_isReady) return; // 중복 초기화 방지

    final modelPath = await _getModelPath();
    final options = LlmInferenceOptions(
      modelPath: modelPath,
      maxTokens: 1024,
      topK: 40,
      temperature: 0.8,
      randomSeed: 101,
    );

    _llmInference = await LlmInference.createFromOptions(options);
    _isReady = true;
  }

  @override
  Stream<String> generateStream(String prompt) {
    assert(_isReady, 'initialize()를 먼저 호출해야 합니다.');
    return _llmInference!.generateResponseStream(prompt);
  }

  @override
  Future<String> generate(String prompt) async {
    assert(_isReady, 'initialize()를 먼저 호출해야 합니다.');
    return await _llmInference!.generateResponse(prompt);
  }

  @override
  void dispose() {
    _llmInference?.close();
    _llmInference = null;
    _isReady = false;
  }
}
```

---

## 3. 생명주기 관리 (필수 준수)

```
앱 시작 (SplashScreen)
  └─ initialize() 호출 → warm-up 완료 대기
       ↓
일기 화면 진입
  └─ isReady 확인 후 UI 활성화
       ↓
음성 인식 완료
  └─ generateStream() 호출 → 스트리밍 출력
       ↓
일기 저장 완료
  └─ dispose() 호출 → 메모리 즉시 해제
```

### 규칙

- `initialize()`는 `SplashScreen`의 `initState` 또는 Riverpod `FutureProvider`에서 **앱 시작 시 1회** 호출
- **일기 저장 완료 즉시 `dispose()` 호출** — 절대 지연 금지
- 다음 녹음 시 `initialize()`를 다시 호출하여 재초기화
- `dispose()` 후 `generateStream()` 호출 시 `StateError` throw — Provider에서 guard 처리 필수

---

## 4. 플랫폼별 Delegate 설정

```dart
Future<LlmInferenceOptions> _buildOptions(String modelPath) async {
  if (Platform.isAndroid) {
    // Android: GPU 우선, 실패 시 CPU fallback
    return LlmInferenceOptions(
      modelPath: modelPath,
      delegate: LlmInferenceDelegate.gpu,  // Adreno GPU (S23 FE)
      maxTokens: 1024,
    );
  } else if (Platform.isIOS) {
    // iOS: Core ML delegate 사용
    return LlmInferenceOptions(
      modelPath: modelPath,
      delegate: LlmInferenceDelegate.coreMl,
      maxTokens: 1024,
    );
  }
  // fallback: CPU
  return LlmInferenceOptions(modelPath: modelPath, maxTokens: 1024);
}
```

- Android GPU delegate 초기화 실패 시 → CPU로 자동 fallback하여 재시도
- iOS Core ML 미지원 기기(구형) → CPU fallback
- Fallback 발생 시 로컬 로그에 기록 (외부 전송 금지)

---

## 5. 스트리밍 응답 처리

```dart
// application 레이어에서 스트림 소비 예시
Stream<String> streamDiaryProcessing(String rawText) async* {
  final prompt = kDiaryProcessingPrompt.replaceAll('{raw_text}', rawText);

  await for (final chunk in _llmService.generateStream(prompt)) {
    yield chunk;
  }
}
```

- `StreamController` 직접 사용보다 `async*` 제너레이터 사용 권장
- 스트림은 `StreamProvider`로 Riverpod에 노출
- 스트리밍 중 화면 이탈 시 `ref.onDispose`에서 스트림 구독 취소

---

## 6. LLM 응답 파싱

파싱 로직은 `lib/core/utils/llm_response_parser.dart`에 순수 함수로 분리한다.

```dart
// llm_response_parser.dart

class LlmResponseParser {
  /// [보정본], [감정], [태그] 섹션을 파싱하여 구조체 반환
  static LlmParsedResult parse(String rawResponse) {
    final correctedMatch = RegExp(r'\[보정본\](.*?)(?=\[감정\])', dotAll: true)
        .firstMatch(rawResponse);
    final emotionMatch = RegExp(r'\[감정\]\s*(\S+)').firstMatch(rawResponse);
    final tagsMatch = RegExp(r'\[태그\]\s*(.+)').firstMatch(rawResponse);

    return LlmParsedResult(
      correctedText: correctedMatch?.group(1)?.trim() ?? '',
      emotion: emotionMatch?.group(1)?.trim() ?? '평온',
      tags: tagsMatch?.group(1)?.split(',').map((t) => t.trim()).toList() ?? [],
    );
  }
}
```

- 파서는 순수 함수여야 한다 (부수효과 없음)
- 파싱 실패 시 기본값 반환 (null 반환 금지)
- 파서는 반드시 unit test로 커버

---

## 7. 오류 처리

| 오류 상황 | 처리 방법 |
|----------|-----------|
| OOM (OutOfMemoryError) | 로컬 로그 기록 → 사용자에게 "메모리 부족" 다이얼로그 표시 |
| 모델 파일 없음 | 다운로드 화면으로 이동 |
| 추론 타임아웃 (30초 초과) | 취소 후 "처리 지연" 안내 |
| Delegate 초기화 실패 | CPU fallback 후 로컬 로그 기록 |

- `Sentry`, `Firebase Crashlytics` 등 외부 크래시 리포팅 도구 사용 금지
- 모든 오류는 `lib/core/utils/logger.dart`를 통해 기기 로컬에만 기록

---

## 8. 프롬프트 관리

- 프롬프트 템플릿은 **반드시** `lib/core/constants/prompts.dart`에서만 정의
- 프롬프트를 코드 여러 곳에 inline으로 작성 금지
- 변수 치환은 `String.replaceAll()` 사용 (템플릿 엔진 라이브러리 도입 금지)
- 프롬프트 변경 시 관련 파싱 로직(`llm_response_parser.dart`)도 함께 검토
