# Session 11 — 테스트 작성

## 목표
핵심 로직 단위 테스트, Mock 클래스, 위젯 테스트를 작성하고 커버리지를 확인한다.

## 참고 규칙 파일
- `.claude/rules/testing.md` (테스트 전략, Mock 정책, 커버리지 목표)
- `.claude/rules/state_management.md` (ProviderContainer 테스트 패턴)

---

## 꼭지 1 — LlmResponseParser 단위 테스트 + DiaryEntry 모델 테스트

### 작업 내용

1. `test/unit/utils/llm_response_parser_test.dart` 작성

   ```dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:voicelog_ai/core/utils/llm_response_parser.dart';

   void main() {
     group('LlmResponseParser', () {
       test('정상 응답 — 보정본·감정·태그 파싱', () {
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

       test('태그 누락 시 빈 목록 반환', () {
         final result = LlmResponseParser.parse('[보정본] 내용\n[감정] 슬픔');
         expect(result.tags, isEmpty);
       });

       test('빈 문자열 입력 — 기본값 반환 (예외 없음)', () {
         final result = LlmResponseParser.parse('');
         expect(result.correctedText, '');
         expect(result.emotion, '평온');
         expect(result.tags, isEmpty);
       });

       test('태그 공백 trim 처리', () {
         final result = LlmResponseParser.parse('[태그] #태그1 ,  #태그2 , #태그3');
         expect(result.tags, ['#태그1', '#태그2', '#태그3']);
       });
     });
   }
   ```

2. `test/unit/domain/diary_entry_test.dart` 작성

   ```dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';

   void main() {
     group('DiaryEntry', () {
       test('DiaryEntry.create() — createdAt이 현재 시각으로 설정됨', () {
         final before = DateTime.now().subtract(const Duration(seconds: 1));
         final entry = DiaryEntry.create(
           rawText: '원문',
           correctedText: '보정본',
           emotion: '기쁨',
           tags: ['#태그1'],
         );
         expect(entry.createdAt.isAfter(before), isTrue);
         expect(entry.rawText, '원문');
         expect(entry.emotion, '기쁨');
       });

       test('copyWith으로 emotion 변경', () {
         final entry = DiaryEntry.create(
           rawText: '원문',
           correctedText: '보정본',
           emotion: '기쁨',
           tags: [],
         );
         final updated = entry.copyWith(emotion: '슬픔');
         expect(updated.emotion, '슬픔');
         expect(updated.rawText, '원문'); // 나머지는 유지
       });
     });
   }
   ```

3. `flutter test test/unit/` 실행 후 전체 통과 확인

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 1]
test: LlmResponseParser 단위 테스트 및 DiaryEntry 모델 테스트 추가

- llm_response_parser_test.dart: 정상/누락/빈 입력/공백 trim 5개 케이스
- diary_entry_test.dart: create() createdAt, copyWith 동작 검증
- flutter test 전체 통과

다음 꼭지(Mock 클래스 작성)를 진행할까요?
---
```

---

## 꼭지 2 — Mock 클래스 작성

### 작업 내용

1. `test/mocks/mock_llm_inference_service.dart` 작성

   ```dart
   import 'package:voicelog_ai/features/diary/domain/i_llm_inference_service.dart';

   class MockLlmInferenceService implements ILlmInferenceService {
     String mockResponse = '''
   [보정본] 오늘은 즐거운 하루였다.
   [감정] 기쁨
   [태그] #산책, #친구, #날씨
     ''';

     bool _isReady = false;

     @override
     bool get isReady => _isReady;

     @override
     Future<void> initialize() async => _isReady = true;

     @override
     Stream<String> generateStream(String prompt) async* {
       for (final chunk in mockResponse.split(' ')) {
         yield '$chunk ';
         await Future.delayed(const Duration(milliseconds: 10));
       }
     }

     @override
     Future<String> generate(String prompt) async => mockResponse;

     @override
     void dispose() => _isReady = false;
   }
   ```

2. `test/mocks/mock_diary_repository.dart` 작성

   ```dart
   import 'package:isar/isar.dart';
   import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';
   import 'package:voicelog_ai/features/diary/domain/i_diary_repository.dart';

   class MockDiaryRepository implements IDiaryRepository {
     final List<DiaryEntry> _entries = [];

     @override
     Future<List<DiaryEntry>> findAll() async => List.unmodifiable(_entries);

     @override
     Future<DiaryEntry?> findById(Id id) async =>
         _entries.where((e) => e.id == id).firstOrNull;

     @override
     Future<void> save(DiaryEntry entry) async => _entries.add(entry);

     @override
     Future<void> delete(Id id) async =>
         _entries.removeWhere((e) => e.id == id);

     @override
     Future<void> deleteAll() async => _entries.clear();
   }
   ```

3. `test/unit/application/diary_list_notifier_test.dart` 작성
   - `ProviderContainer` + `MockDiaryRepository`로 `DiaryListNotifier` 테스트

   ```dart
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:flutter_test/flutter_test.dart';
   import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';
   import 'package:voicelog_ai/features/diary/application/diary_repository_provider.dart';
   import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';
   import '../../mocks/mock_diary_repository.dart';

   void main() {
     group('DiaryListNotifier', () {
       late ProviderContainer container;
       late MockDiaryRepository mockRepo;

       setUp(() {
         mockRepo = MockDiaryRepository();
         container = ProviderContainer(
           overrides: [
             diaryRepositoryProvider.overrideWith((_) async => mockRepo),
           ],
         );
       });

       tearDown(() => container.dispose());

       test('addEntry 후 목록에 항목 추가됨', () async {
         final notifier = container.read(diaryListNotifierProvider.notifier);
         final entry = DiaryEntry.create(
           rawText: '원문',
           correctedText: '보정본',
           emotion: '기쁨',
           tags: ['#태그'],
         );

         await notifier.addEntry(entry);

         final entries = await container.read(diaryListNotifierProvider.future);
         expect(entries, contains(entry));
       });
     });
   }
   ```

4. `flutter test test/unit/` 실행 후 전체 통과 확인

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 2]
test: Mock 클래스 및 DiaryListNotifier Provider 테스트 추가

- MockLlmInferenceService: 스트리밍 시뮬레이션, isReady 토글
- MockDiaryRepository: 인메모리 CRUD 구현
- diary_list_notifier_test: ProviderContainer + Mock으로 addEntry 검증

다음 꼭지(Widget 테스트)를 진행할까요?
---
```

---

## 꼭지 3 — Widget 테스트

### 작업 내용

1. `test/widget/emotion_chip_test.dart` 작성

   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_test/flutter_test.dart';
   import 'package:voicelog_ai/core/widgets/emotion_chip.dart';

   void main() {
     group('EmotionChip', () {
       Widget buildChip(String emotion) => MaterialApp(
             home: Scaffold(body: EmotionChip(emotion: emotion)),
           );

       testWidgets('기쁨 칩 렌더링 — 텍스트 포함', (tester) async {
         await tester.pumpWidget(buildChip('기쁨'));
         expect(find.text('😊 기쁨'), findsOneWidget);
       });

       testWidgets('슬픔 칩 렌더링 — 텍스트 포함', (tester) async {
         await tester.pumpWidget(buildChip('슬픔'));
         expect(find.text('😢 슬픔'), findsOneWidget);
       });

       testWidgets('알 수 없는 감정 — 기본값 렌더링', (tester) async {
         await tester.pumpWidget(buildChip('unknown'));
         expect(find.byType(Chip), findsOneWidget); // 오류 없이 렌더링됨
       });
     });
   }
   ```

2. `flutter test test/widget/` 실행 후 전체 통과 확인

3. 커버리지 측정

   ```bash
   flutter test --coverage
   # lcov 설치 후
   genhtml coverage/lcov.info -o coverage/html
   open coverage/html/index.html
   ```

4. 목표 커버리지 확인
   - domain/utils: 90% 이상
   - application: 80% 이상
   - 미달 레이어는 추가 테스트 케이스 작성

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 3]
test: EmotionChip 위젯 테스트 및 커버리지 측정

- emotion_chip_test.dart: 기쁨/슬픔/unknown 3개 케이스
- 전체 flutter test 통과 확인
- 커버리지 측정 및 목표치(domain 90%, application 80%) 확인

Session 11 완료. 전체 MVP 구현 완료!
다음 단계: S23 FE 실기기 테스트 (testing.md 내 실기기 체크리스트 참조)
---
```
