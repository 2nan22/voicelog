# Flutter 코드 컨벤션

## 1. 코드 스타일 기준

- **린터**: `flutter_lints` 패키지 기준 준수 (`analysis_options.yaml` 설정)
- **줄 길이**: 최대 120자
- **들여쓰기**: 스페이스 2칸 (탭 금지)
- **후행 쉼표**: 다중 인자·요소 나열 시 마지막 항목에 반드시 후행 쉼표 추가 (자동 포맷 최적화)

```dart
// Good
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('hello'),
      Text('world'),  // 후행 쉼표
    ],
  );
}
```

---

## 2. 네이밍 규칙

| 대상 | 규칙 | 예시 |
|------|------|------|
| 클래스, Enum, Typedef | `UpperCamelCase` | `DiaryEntry`, `EmotionType` |
| 변수, 함수, 메서드 | `lowerCamelCase` | `rawText`, `processEntry()` |
| 상수 (`const`) | `lowerCamelCase` with `k` prefix | `kDiaryProcessingPrompt` |
| 파일, 폴더 | `snake_case` | `diary_entry.dart`, `diary_list_screen.dart` |
| private 멤버 | `_` 접두사 | `_controller`, `_isRecording` |
| Riverpod Provider | `lowerCamelCase` + `Provider` suffix | `diaryListProvider`, `llmStreamProvider` |

---

## 3. 불변 데이터 모델 (freezed 의무화)

도메인 모델은 반드시 `freezed` 패키지로 불변 클래스로 정의한다.

```dart
// diary_entry.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';

part 'diary_entry.freezed.dart';
part 'diary_entry.g.dart';

@freezed
@Collection()
class DiaryEntry with _$DiaryEntry {
  const DiaryEntry._(); // Isar 커스텀 메서드용

  const factory DiaryEntry({
    required Id id,
    required String rawText,
    required String correctedText,
    required String emotion,
    required List<String> tags,
    required DateTime createdAt,
  }) = _DiaryEntry;

  factory DiaryEntry.fromJson(Map<String, dynamic> json) =>
      _$DiaryEntryFromJson(json);
}
```

---

## 4. Import 순서

반드시 다음 순서로 import를 작성하고, 각 그룹 사이에 빈 줄을 넣는다.

```dart
// 1. dart 표준 라이브러리
import 'dart:async';

// 2. flutter 패키지
import 'package:flutter/material.dart';

// 3. pub.dev 서드파티 패키지
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// 4. 프로젝트 내부 패키지 (상대경로 금지, package: 경로 사용)
import 'package:voicelog_ai/core/constants/prompts.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';
```

---

## 5. async/await 에러 핸들링

- `Future`를 반환하는 모든 함수는 `try/catch`로 에러 처리 필수
- `catchError`는 가독성이 낮으므로 사용 금지
- 에러는 로컬 로그 기록 후 사용자에게 `SnackBar` 또는 `AlertDialog`로 안내

```dart
// Good
Future<void> saveEntry(DiaryEntry entry) async {
  try {
    await _repository.save(entry);
  } on IsarError catch (e) {
    _logger.error('DB 저장 실패: $e');
    rethrow;
  } catch (e) {
    _logger.error('예상치 못한 오류: $e');
    rethrow;
  }
}

// Bad — catchError 사용 금지
future.catchError((e) => print(e));
```

---

## 6. Isolate 사용 패턴

무거운 연산(LLM 추론, 대용량 파일 파싱)은 반드시 `Isolate` 또는 `compute()`로 분리한다.

```dart
// compute() 사용 예시 (단순 함수)
final result = await compute(_parseResponse, rawResponse);

// Isolate.run() 사용 예시 (Dart 2.19+)
final result = await Isolate.run(() => heavyParsing(data));
```

---

## 7. 위젯 분리 원칙

- `build()` 메서드가 50줄을 넘기면 별도 위젯으로 분리
- 재사용 가능한 위젯은 `lib/core/widgets/` 또는 해당 feature의 `presentation/widgets/`에 분리
- `StatefulWidget`보다 `ConsumerWidget` (Riverpod) 사용 우선
- `setState`는 순수 애니메이션 컨트롤러 용도 외 사용 금지

---

## 8. 문자열 처리

- 하드코딩 문자열 금지 (UI 표시 텍스트는 `lib/core/constants/strings.dart`에 상수 정의)
- 문자열 보간 시 중괄호 사용: `'안녕, ${user.name}!'` (단일 변수도 중괄호 권장)
- 다국어 지원이 필요한 텍스트는 `intl` 패키지 `AppLocalizations` 사용

---

## 9. 주석 규칙

- public API (클래스, 메서드, 프로퍼티)에는 `///` doc comment 작성
- 자명한 코드에 설명 주석 추가 금지
- 복잡한 비즈니스 로직(프롬프트 파싱, delegate 분기 등)에만 `//` 인라인 주석 허용

```dart
/// 음성 인식 결과를 LLM에 전달하여 보정된 일기 엔트리를 반환한다.
///
/// [rawText]가 빈 문자열이면 즉시 예외를 던진다.
Future<DiaryEntry> processVoiceInput(String rawText) async { ... }
```