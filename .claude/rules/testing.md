# 테스트 전략 및 Mock 정책

## 1. 테스트 디렉터리 구조

```
test/
├── unit/
│   ├── domain/
│   │   └── diary_entry_test.dart       # 모델 직렬화/역직렬화
│   └── utils/
│       └── llm_response_parser_test.dart # 파싱 로직
├── widget/
│   ├── emotion_chip_test.dart
│   ├── waveform_widget_test.dart
│   └── diary_record_screen_test.dart
└── integration/
    └── diary_flow_test.dart             # 녹음 → LLM → 저장 전체 흐름
```

---

## 2. 테스트 종류별 규칙

### Unit Test (단위 테스트)

**대상**: domain 모델, 유틸리티 함수, 파싱 로직

```dart
// test/unit/utils/llm_response_parser_test.dart

void main() {
  group('LlmResponseParser', () {
    test('정상 응답에서 보정본·감정·태그 파싱', () {
      const response = '''
[보정본] 오늘은 정말 즐거운 하루였다.
[감정] 기쁨
[태그] #산책, #친구, #날씨
      ''';

      final result = LlmResponseParser.parse(response);

      expect(result.correctedText, '오늘은 정말 즐거운 하루였다.');
      expect(result.emotion, '기쁨');
      expect(result.tags, ['#산책', '#친구', '#날씨']);
    });

    test('감정 누락 시 기본값 "평온" 반환', () {
      final result = LlmResponseParser.parse('[보정본] 내용만 있음');
      expect(result.emotion, '평온');
    });
  });
}
```

### Widget Test (위젯 테스트)

**대상**: 개별 위젯 렌더링, Provider 상태에 따른 UI 변화

```dart
// test/widget/emotion_chip_test.dart

void main() {
  testWidgets('EmotionChip — 기쁨 감정 색상 렌더링', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EmotionChip(emotion: '기쁨'))),
    );

    final chip = tester.widget<Container>(find.byType(Container).first);
    // 색상 검증 로직
    expect(find.text('기쁨'), findsOneWidget);
  });
}
```

### Integration Test (통합 테스트)

**대상**: 녹음 → LLM 처리 → 저장 전체 흐름 (Mock LLM 사용)

```dart
// test/integration/diary_flow_test.dart

void main() {
  testWidgets('일기 작성 전체 흐름 — Mock LLM 사용', (tester) async {
    final container = ProviderContainer(
      overrides: [
        llmInferenceServiceProvider.overrideWithValue(MockLlmInferenceService()),
        diaryRepositoryProvider.overrideWithValue(MockDiaryRepository()),
      ],
    );

    // 녹음 시작 → STT 완료 → LLM 처리 → 저장 확인
    // ...
  });
}
```

---

## 3. Mock 정책

### MediaPipe LLM — 반드시 Mock 사용

실 기기 없이 실행되는 테스트에서 `LlmInferenceService`는 반드시 Mock으로 대체한다.
실제 MediaPipe 초기화는 실기기(S23 FE) 환경에서만 가능하다.

```dart
// test/mocks/mock_llm_inference_service.dart

class MockLlmInferenceService implements ILlmInferenceService {
  String mockResponse = '''
[보정본] 오늘은 즐거운 하루였다.
[감정] 기쁨
[태그] #산책, #친구, #날씨
  ''';

  @override
  bool get isReady => true;

  @override
  Future<void> initialize() async {}

  @override
  Stream<String> generateStream(String prompt) async* {
    // 청크 단위 스트리밍 시뮬레이션
    for (final chunk in mockResponse.split(' ')) {
      yield '$chunk ';
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  @override
  Future<String> generate(String prompt) async => mockResponse;

  @override
  void dispose() {}
}
```

### Isar DB — In-Memory Mock 사용

```dart
class MockDiaryRepository implements IDiaryRepository {
  final List<DiaryEntry> _entries = [];

  @override
  Future<List<DiaryEntry>> findAll() async => List.unmodifiable(_entries);

  @override
  Future<void> save(DiaryEntry entry) async => _entries.add(entry);

  @override
  Future<void> delete(Id id) async => _entries.removeWhere((e) => e.id == id);
}
```

### speech_to_text — 직접 Mock 금지

STT는 네이티브 엔진 의존성이 높아 Widget/Unit 테스트에서 직접 호출 금지.
STT Provider를 Mock으로 override하여 미리 설정된 텍스트 반환.

---

## 4. Riverpod 테스트 패턴

```dart
// ProviderContainer로 Provider 직접 테스트
void main() {
  test('diaryListNotifier — 항목 추가 후 목록 반영', () async {
    final container = ProviderContainer(
      overrides: [
        diaryRepositoryProvider.overrideWithValue(MockDiaryRepository()),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(diaryListNotifierProvider.notifier);
    await notifier.addEntry(testEntry);

    final entries = await container.read(diaryListNotifierProvider.future);
    expect(entries, contains(testEntry));
  });
}
```

---

## 5. 커버리지 목표

| 레이어 | 목표 커버리지 | 비고 |
|--------|-------------|------|
| domain (모델, 파서) | 90% 이상 | 핵심 로직 집중 검증 |
| application (Provider) | 80% 이상 | 상태 변이 시나리오 |
| presentation (위젯) | 60% 이상 | 주요 화면 렌더링 검증 |
| infrastructure (서비스) | Mock 기반 검증 | 실기기 테스트는 별도 |

---

## 6. 실기기 테스트 (S23 FE)

다음 항목은 **단위/통합 테스트로 대체 불가**하며, 반드시 S23 FE 실기기에서 수동 검증한다.

- [ ] MediaPipe LLM 모델 로딩 및 추론 (GPU delegate 활성화 확인)
- [ ] 네이티브 STT 음성 인식 정확도
- [ ] 메모리 사용량 (LLM 추론 전/후 500MB 이하 복귀)
- [ ] 발열 및 배터리 소모율 (30초 이상 추론 테스트)
- [ ] iOS Core ML delegate (Apple 기기에서 별도 검증)

---

## 7. 테스트 실행 명령

```bash
# 전체 테스트 실행
flutter test

# 커버리지 포함
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# 특정 파일만
flutter test test/unit/utils/llm_response_parser_test.dart

# 통합 테스트 (실기기/에뮬레이터 필요)
flutter test integration_test/diary_flow_test.dart
```
