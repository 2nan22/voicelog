# 성능 최적화 규칙

## 1. 기본 원칙

온디바이스 LLM 추론은 메모리·CPU·GPU 자원을 집중 소비한다.
**OOM 방지**와 **발열 제어**가 모든 성능 결정의 최우선 기준이다.

---

## 2. LLM 추론 최적화

### Isolate 분리 (필수)

LLM 추론은 메인 스레드(UI 스레드)와 반드시 분리한다.

```dart
// ❌ 금지: 메인 스레드에서 직접 추론
final result = await llmService.generate(prompt);

// ✅ 권장: Isolate.run()으로 분리
final result = await Isolate.run(() async {
  return await llmService.generate(prompt);
});
```

- `mediapipe_genai_flutter`가 내부적으로 스레드를 분리하는 경우에도, 긴 추론(>3초)은 추가 Isolate 래핑 권장

### 세션 관리 (필수)

```dart
// 일기 저장 완료 직후 반드시 dispose 호출
await diaryRepository.save(entry);
llmService.dispose(); // ← 절대 누락 금지
```

- 추론 세션을 열어둔 채로 다른 화면으로 이동하는 코드 패턴 금지
- `ref.onDispose`에서 dispose 호출로 Riverpod 생명주기와 연결

### 모델 Warm-up

```dart
// SplashScreen에서 앱 시작 시 1회 preload
@riverpod
Future<void> llmWarmUp(LlmWarmUpRef ref) async {
  final service = ref.watch(llmInferenceServiceProvider);
  await service.initialize();
  // warm-up: 빈 프롬프트로 첫 추론 비용 선불 처리
  await service.generate('<start_of_turn>model\n');
}
```

---

## 3. 플랫폼별 Delegate 전략

### Android (Samsung Galaxy S23 FE 기준)

| Delegate | 대상 | 설명 |
|----------|------|------|
| GPU (Adreno) | 기본 | Adreno 740 GPU 활용 |
| NPU/HTA | S 시리즈 일부 | Exynos/Snapdragon NPU 지원 시 |
| CPU (NNAPI) | GPU 실패 fallback | 발열 심할 때 자동 전환 고려 |

### iOS (Apple Silicon 기준)

| Delegate | 대상 | 설명 |
|----------|------|------|
| Core ML | A14 이상 | Neural Engine 활용 |
| Metal | GPU 가속 | Core ML 미지원 시 |
| CPU | Fallback | 구형 기기 |

```dart
// 플랫폼별 delegate 분기 예시
LlmInferenceDelegate _selectDelegate() {
  if (Platform.isAndroid) {
    return LlmInferenceDelegate.gpu;   // Adreno GPU
  } else if (Platform.isIOS) {
    return LlmInferenceDelegate.coreMl; // Neural Engine
  }
  return LlmInferenceDelegate.cpu;
}
```

---

## 4. 메모리 관리

### 이미지·에셋

- **포맷**: WebP 전용 (PNG, JPEG 금지 — 신규 에셋에 한함)
- **크기 제한**: 개별 에셋 파일 100KB 이하
- **캐싱**: `CachedNetworkImage` 대신 로컬 에셋만 사용 (온디바이스 원칙)

### 리스트 렌더링

```dart
// ❌ 금지: ListView (모든 아이템을 메모리에 올림)
ListView(children: diaries.map((d) => DiaryCard(d)).toList())

// ✅ 필수: ListView.builder (뷰포트 밖 아이템은 메모리 해제)
ListView.builder(
  itemCount: diaries.length,
  itemBuilder: (context, index) => DiaryCard(diaries[index]),
)
```

- 50개 이상 아이템 목록은 `ListView.builder` 또는 `SliverList.builder` 의무 사용

### 불필요한 리빌드 방지

```dart
// ConsumerWidget 사용 시 필요한 값만 watch
// ❌ 전체 상태 watch
final state = ref.watch(diaryRecordNotifierProvider);

// ✅ 필요한 필드만 select
final isRecording = ref.watch(
  diaryRecordNotifierProvider.select((s) => s == RecordingState.recording),
);
```

---

## 5. 발열 및 배터리 관리

### 연속 추론 경고

```dart
// 30초 이상 연속 추론 시 경고 다이얼로그 표시
const kMaxInferenceDurationSeconds = 30;

Timer? _inferenceTimer;

void _startInferenceTimer(BuildContext context) {
  _inferenceTimer = Timer(
    const Duration(seconds: kMaxInferenceDurationSeconds),
    () => _showOverheatWarning(context),
  );
}
```

### 추론 완료 후 절전 패턴

- LLM 추론 완료 직후 `dispose()` 호출 → 다음 녹음 전까지 모델 언로드 상태 유지
- 백그라운드 진입 시 (`AppLifecycleState.paused`) LLM 세션 강제 종료

```dart
// AppLifecycleObserver 구현
class _AppLifecycleObserver extends WidgetsBindingObserver {
  final ILlmInferenceService llmService;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      llmService.dispose(); // 백그라운드 진입 시 즉시 해제
    }
  }
}
```

---

## 6. Flutter 렌더링 최적화

| 규칙 | 이유 |
|------|------|
| `const` 생성자 최대한 활용 | 불필요한 위젯 재생성 방지 |
| `RepaintBoundary`로 파형 위젯 격리 | 60fps 유지 |
| `CustomPainter.shouldRepaint()` 정확히 구현 | 파형 애니메이션 과도한 repaint 방지 |
| `Opacity` 위젯 대신 `FadeTransition` | GPU 레이어 재사용 |

---

## 7. 빌드 최적화

- 릴리즈 빌드: `flutter build apk --release --split-per-abi` (arm64-v8a 우선)
- ProGuard/R8 난독화: `minifyEnabled true` (Android)
- 모델 파일은 에셋에 포함하지 않고 첫 실행 시 다운로드 후 로컬 캐싱 (앱 사이즈 절감)

---

## 8. 성능 측정 기준 (S23 FE 타겟)

| 지표 | 목표값 |
|------|--------|
| 앱 콜드 스타트 → 녹음 준비 완료 | 3초 이하 |
| LLM 추론 시작 → 첫 토큰 출력 | 2초 이하 |
| 일기 저장 후 메모리 복귀 | 500MB 이하 (LLM 세션 해제 후) |
| 60fps 유지 (리스트 스크롤) | 드롭 없음 |
