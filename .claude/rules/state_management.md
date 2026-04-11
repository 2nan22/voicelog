# 상태 관리 규칙 (Riverpod 2.x)

## 1. 기본 원칙

- **패키지**: `flutter_riverpod` + `riverpod_annotation` (코드 생성 방식 의무화)
- `ChangeNotifier`, `BLoC`, `GetX`, `Provider` 패키지 사용 금지
- `@riverpod` 어노테이션으로 코드 생성 방식만 사용 (`StateNotifierProvider()` 직접 생성 금지)
- 코드 생성 후 생성된 파일(`*.g.dart`)은 git에 포함

---

## 2. Provider 종류별 사용 기준

| Provider 종류 | 사용 상황 | 예시 |
|--------------|-----------|------|
| `@riverpod` (FutureProvider) | 비동기 단건 조회, 초기화 | LLM 모델 로딩, DB 조회 |
| `@riverpod` (StreamProvider) | 연속 데이터 스트림 | LLM 스트리밍 응답 |
| `@Riverpod(keepAlive: true)` | 앱 생명주기 동안 유지 | LLM 서비스 인스턴스 |
| `@riverpod` class (Notifier) | 변경 가능한 상태 목록 | 일기 목록, 녹음 상태 |

---

## 3. Provider 정의 패턴

### 비동기 단건 조회 (FutureProvider)

```dart
// diary_list_provider.dart
part 'diary_list_provider.g.dart';

@riverpod
Future<List<DiaryEntry>> diaryList(DiaryListRef ref) async {
  final repository = ref.watch(diaryRepositoryProvider);
  return repository.findAll();
}
```

### 변경 가능한 상태 (AsyncNotifier)

```dart
@riverpod
class DiaryListNotifier extends _$DiaryListNotifier {
  @override
  Future<List<DiaryEntry>> build() async {
    final repository = ref.watch(diaryRepositoryProvider);
    return repository.findAll();
  }

  Future<void> addEntry(DiaryEntry entry) async {
    final repository = ref.read(diaryRepositoryProvider);
    await repository.save(entry);
    ref.invalidateSelf(); // 목록 갱신
  }

  Future<void> deleteEntry(Id id) async {
    final repository = ref.read(diaryRepositoryProvider);
    await repository.delete(id);
    ref.invalidateSelf();
  }
}
```

### LLM 스트리밍 (StreamProvider)

```dart
@riverpod
Stream<String> llmStream(LlmStreamRef ref, String rawText) {
  final service = ref.watch(llmInferenceServiceProvider);
  final prompt = kDiaryProcessingPrompt.replaceAll('{raw_text}', rawText);
  return service.generateStream(prompt);
}
```

### 앱 생명주기 유지 서비스 (keepAlive)

```dart
@Riverpod(keepAlive: true)
ILlmInferenceService llmInferenceService(LlmInferenceServiceRef ref) {
  final service = MediaPipeLlmInferenceService();
  ref.onDispose(service.dispose);
  return service;
}
```

---

## 4. ref 사용 규칙

| 메서드 | 사용 위치 | 목적 |
|--------|-----------|------|
| `ref.watch()` | `build()` 메서드 내부, ConsumerWidget.build 내부 | 상태 변경 감지·리빌드 트리거 |
| `ref.read()` | 이벤트 핸들러, `onPressed`, async 함수 내부 | 일회성 읽기·메서드 호출 |
| `ref.listen()` | `build()` 내부 | 상태 변경 시 사이드 이펙트 (SnackBar 등) |
| `ref.invalidateSelf()` | Notifier 내부 | 자신의 상태 강제 갱신 |
| `ref.invalidate(provider)` | 다른 Provider 갱신 필요 시 | 외부 Provider 강제 갱신 |

```dart
// Good — ref.watch는 build 내부에서만
@override
Widget build(BuildContext context, WidgetRef ref) {
  final diaries = ref.watch(diaryListNotifierProvider);
  // ...
}

// Good — ref.read는 이벤트 핸들러에서만
void _onSave(WidgetRef ref) {
  ref.read(diaryListNotifierProvider.notifier).addEntry(entry);
}

// Bad — build 외부에서 ref.watch 사용
void someMethod(WidgetRef ref) {
  final diaries = ref.watch(diaryListNotifierProvider); // 금지!
}
```

---

## 5. 녹음 상태 관리 패턴

```dart
enum RecordingState { idle, recording, processing, done, error }

@riverpod
class DiaryRecordNotifier extends _$DiaryRecordNotifier {
  @override
  RecordingState build() => RecordingState.idle;

  void startRecording() => state = RecordingState.recording;
  void startProcessing() => state = RecordingState.processing;
  void finishRecording() => state = RecordingState.done;
  void setError() => state = RecordingState.error;
  void reset() => state = RecordingState.idle;
}
```

---

## 6. 에러 상태 처리

`AsyncValue`의 패턴 매칭으로 로딩·에러·데이터 상태를 처리한다.

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final diariesAsync = ref.watch(diaryListNotifierProvider);

  return diariesAsync.when(
    loading: () => const LoadingShimmer(),
    error: (error, stack) => ErrorWidget(message: error.toString()),
    data: (diaries) => DiaryListView(diaries: diaries),
  );
}
```

---

## 7. Provider 파일 구조

- Provider 파일은 해당 feature의 `application/` 폴더에만 위치
- 파일명은 `[기능명]_provider.dart` 형식
- 하나의 파일에 관련 Provider들을 묶어서 정의 (과도한 파일 분리 금지)
- `part '*.g.dart'` 선언은 파일 상단에 위치

---

## 8. 금지 패턴

```dart
// 금지: Provider 직접 생성
final diaryListProvider = StateNotifierProvider<DiaryListNotifier, List<DiaryEntry>>(
  (ref) => DiaryListNotifier(),
);

// 금지: BuildContext를 Provider에 전달
ref.read(someProvider(context));

// 금지: Provider 외부에서 상태 직접 변경
(ref.read(diaryListProvider) as DiaryListNotifier).entries.add(entry);

// 금지: 전역 변수로 상태 관리
List<DiaryEntry> globalDiaries = [];
```
