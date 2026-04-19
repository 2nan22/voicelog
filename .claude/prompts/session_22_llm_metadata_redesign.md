# Session 22 — LLM 메타데이터 추출 재설계 + 저장 버그 수정

## 현재 상태 (session 21 종료 기준)

브랜치: `feat/init-20260411`

STT 콜백이 Application 레이어(`SttCallbackHandler`)로 이동 완료.
실시간 텍스트 표시(이슈 1) 해결 확인.

### 남은 버그: 저장 버튼 동작 안 함

`parsedResult == null` → `_onSave()` early return.

**근본 원인**: 현재 LLM 프롬프트는 `[보정본]/[감정]/[태그]` 형식을 요구하지만,
Qwen2.5 모델의 실제 출력이 이 형식을 따르지 않아 파싱 실패.

---

## 새로운 LLM 처리 흐름

```
[녹음 완료]
  STT 원본 텍스트 확정 → 화면에 항상 표시

[자동] 메타데이터 추출 LLM (항상 실행, kMetadataExtractionPrompt)
  → 제목, 감정, 태그(키워드), 인물, 장소 추출
  → 완료 후 저장 버튼 활성화

[옵션] 문맥 보정 LLM (설정에서 on/off, kCorrectionPrompt)
  → 보정본 생성
  → 원본 vs 보정본 나란히 표시
  → 사용자가 어느 쪽을 저장할지 선택 (선택 후 저장)

[상세 화면]
  저장된 일기에서도 "AI 재분석" (메타데이터 재추출) 가능
  보정이 안 된 일기는 "보정하기" 버튼 표시
```

---

## 변경 파일 목록

| 파일 | 변경 내용 |
|------|-----------|
| `lib/features/diary/domain/diary_entry.dart` | `title`, `people`, `places` 추가; `correctedText` → `String?` |
| `lib/features/diary/infrastructure/diary_entry_document.dart` | 동일 필드 추가; fromDomain/toDomain 수정 |
| `lib/features/diary/infrastructure/diary_repository.dart` | 변경 없음 (문서 변환만) |
| `lib/features/settings/domain/app_settings.dart` | `correctionEnabled` 추가 |
| `lib/features/settings/infrastructure/app_settings_document.dart` | 동일 |
| `lib/core/constants/prompts.dart` | 프롬프트 2종 교체 |
| `lib/core/utils/llm_response_parser.dart` | 파서 완전 재작성 |
| `lib/features/diary/application/diary_process_provider.dart` | 2-phase 처리 상태로 확장 |
| `lib/features/diary/presentation/screens/diary_record_screen.dart` | UI + 저장 로직 개편 |
| `lib/features/diary/presentation/screens/diary_detail_screen.dart` | 재처리 버튼 추가 |
| `lib/features/settings/presentation/screens/settings_screen.dart` | 보정 토글 추가 |
| `*.g.dart`, `*.freezed.dart` | build_runner 재생성 |

---

## 꼭지 1: 도메인 모델 확장

### diary_entry.dart

```dart
@freezed
class DiaryEntry with _$DiaryEntry {
  const factory DiaryEntry({
    required int id,
    required String rawText,
    required String title,           // LLM 추출 제목
    required String emotion,
    required List<String> tags,
    @Default([]) List<String> people,  // LLM 추출 인물
    @Default([]) List<String> places,  // LLM 추출 장소
    String? correctedText,           // 보정 선택 시에만 (null = 미보정)
    required DateTime createdAt,
  }) = _DiaryEntry;

  factory DiaryEntry.fromJson(Map<String, dynamic> json) =>
      _$DiaryEntryFromJson(json);

  factory DiaryEntry.create({
    required String rawText,
    required String title,
    required String emotion,
    required List<String> tags,
    List<String> people = const [],
    List<String> places = const [],
    String? correctedText,
  }) =>
      DiaryEntry(
        id: -1,
        rawText: rawText,
        title: title,
        emotion: emotion,
        tags: tags,
        people: people,
        places: places,
        correctedText: correctedText,
        createdAt: DateTime.now(),
      );
}
```

### diary_entry_document.dart

Isar 스키마 변경 시 기존 데이터 보존을 위해 신규 필드는 빈 문자열/빈 목록 기본값으로 처리한다.

```dart
@Collection()
class DiaryEntryDocument {
  Id id = Isar.autoIncrement;
  late String rawText;
  late String title;            // 신규
  late String emotion;
  late List<String> tags;
  late List<String> people;     // 신규
  late List<String> places;     // 신규
  String? correctedText;        // nullable로 변경
  late DateTime createdAt;

  DiaryEntry toDomain() => DiaryEntry(
        id: id,
        rawText: rawText,
        title: title.isEmpty ? '제목 없음' : title,
        emotion: emotion.isEmpty ? '평온' : emotion,
        tags: tags,
        people: people,
        places: places,
        correctedText: correctedText?.isEmpty == true ? null : correctedText,
        createdAt: createdAt,
      );

  static DiaryEntryDocument fromDomain(DiaryEntry entry) {
    final doc = DiaryEntryDocument()
      ..rawText = entry.rawText
      ..title = entry.title
      ..emotion = entry.emotion
      ..tags = entry.tags
      ..people = entry.people
      ..places = entry.places
      ..correctedText = entry.correctedText
      ..createdAt = entry.createdAt;
    if (entry.id > 0) doc.id = entry.id;
    return doc;
  }
}
```

**주의**: Isar는 컬렉션 스키마 변경 시 내부적으로 re-index한다. 기존 데이터의
신규 필드는 Dart 기본값(`late`이면 빈 문자열, nullable이면 null)으로 설정된다.
앱 첫 실행 시 기존 일기의 `title`, `people`, `places`는 기본값으로 표시된다.

### app_settings.dart

```dart
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(false) bool isDarkMode,
    @Default(WritingStyle.diary) WritingStyle writingStyle,
    @Default(false) bool correctionEnabled,  // 신규: 문맥 보정 여부
  }) = _AppSettings;
}
```

`app_settings_document.dart`에도 동일 필드(`correctionEnabled`) 추가.

build_runner 실행:
```bash
cd voicelog_ai && dart run build_runner build --delete-conflicting-outputs
```

커밋 메시지:
```
feat(domain): DiaryEntry 메타데이터 필드 추가, 보정 설정 옵션 추가

title, people, places 필드 추가; correctedText optional로 변경.
AppSettings에 correctionEnabled 토글 추가.
Isar 문서 스키마 동기화.
```

---

## 꼭지 2: 프롬프트 & 파서 개편

### prompts.dart — 기존 kDiaryProcessingPrompt 교체

```dart
/// 메타데이터 추출 프롬프트 — 항상 실행. 보정 없이 구조화 정보만 추출.
/// {raw_text} 자리에 STT 원문을 치환한다.
const String kMetadataExtractionPrompt = '''
<|im_start|>user
아래 음성 일기 텍스트에서 정보를 추출하세요.
응답은 반드시 아래 형식만 사용하고 설명을 추가하지 마세요.

[제목] 한 줄 제목 (20자 이내)
[감정] 기쁨 또는 슬픔 또는 평온 또는 화남 중 하나
[태그] #키워드1, #키워드2, #키워드3
[인물] 이름1, 이름2 (없으면 없음)
[장소] 장소1, 장소2 (없으면 없음)

텍스트: {raw_text}<|im_end|>
<|im_start|>assistant
''';

/// 문맥 보정 프롬프트 — 설정에서 활성화 시에만 실행.
/// {style_instruction} 과 {raw_text} 를 치환한다.
const String kCorrectionPrompt = '''
<|im_start|>user
아래 음성 일기 텍스트를 {style_instruction} 수정하세요.
오탈자와 어색한 표현만 최소한으로 수정하고 내용은 바꾸지 마세요.
[보정본] 태그로 시작해서 보정된 텍스트만 출력하세요.

[보정본] 보정된 내용...

텍스트: {raw_text}<|im_end|>
<|im_start|>assistant
''';
```

### llm_response_parser.dart — 완전 재작성

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'llm_response_parser.freezed.dart';

/// 메타데이터 추출 결과
@freezed
class LlmMetadataResult with _$LlmMetadataResult {
  const factory LlmMetadataResult({
    required String title,
    required String emotion,
    required List<String> tags,
    required List<String> people,
    required List<String> places,
  }) = _LlmMetadataResult;
}

class LlmResponseParser {
  LlmResponseParser._();

  /// 메타데이터 추출 응답 파싱. 파싱 실패 시 기본값 반환.
  static LlmMetadataResult parseMetadata(String raw) {
    String _extract(String tag) {
      final m = RegExp('\\[$tag\\]\\s*(.+)', dotAll: false).firstMatch(raw);
      return m?.group(1)?.trim() ?? '';
    }

    List<String> _list(String tag) {
      final val = _extract(tag);
      if (val.isEmpty || val == '없음') return [];
      return val.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }

    return LlmMetadataResult(
      title: _extract('제목').isEmpty ? '제목 없음' : _extract('제목'),
      emotion: _validEmotion(_extract('감정')),
      tags: _list('태그'),
      people: _list('인물'),
      places: _list('장소'),
    );
  }

  /// 보정본 응답 파싱. [보정본] 태그 이후 텍스트 반환.
  static String parseCorrectedText(String raw) {
    final m = RegExp(r'\[보정본\]\s*(.+)', dotAll: true).firstMatch(raw);
    return m?.group(1)?.trim() ?? '';
  }

  static String _validEmotion(String raw) {
    const valid = ['기쁨', '슬픔', '평온', '화남'];
    return valid.contains(raw) ? raw : '평온';
  }
}
```

build_runner 실행 (freezed 재생성).

커밋 메시지:
```
feat(llm): 메타데이터 추출/보정 프롬프트 분리, 파서 재작성

kMetadataExtractionPrompt (제목·감정·태그·인물·장소) 신규.
kCorrectionPrompt (보정본) 신규.
LlmResponseParser — parseMetadata / parseCorrectedText 로 분리.
기존 kDiaryProcessingPrompt 제거.
```

---

## 꼭지 3: DiaryProcessProvider 개편 + 저장 버그 수정

### diary_process_provider.dart — 2-phase 처리

```dart
enum LlmPhase { idle, metadata, correction, done }

@freezed
class DiaryProcessState with _$DiaryProcessState {
  const factory DiaryProcessState({
    @Default(LlmPhase.idle) LlmPhase phase,
    @Default('') String rawAccumulated,   // 현재 스트리밍 중인 LLM 원문
    LlmMetadataResult? metadataResult,    // 메타데이터 추출 완료 시
    String? correctedText,                // 보정 완료 시
  }) = _DiaryProcessState;
}

@riverpod
class DiaryProcessNotifier extends _$DiaryProcessNotifier {
  @override
  DiaryProcessState build() => const DiaryProcessState();

  void startMetadata() => state = state.copyWith(
        phase: LlmPhase.metadata,
        rawAccumulated: '',
      );

  void startCorrection() => state = state.copyWith(
        phase: LlmPhase.correction,
        rawAccumulated: '',
      );

  void appendChunk(String chunk) {
    final newRaw = state.rawAccumulated + chunk;
    // 메타데이터 단계: [장소] 섹션 감지 시 즉시 파싱 시도
    if (state.phase == LlmPhase.metadata && newRaw.contains('[장소]')) {
      state = state.copyWith(
        rawAccumulated: newRaw,
        metadataResult: LlmResponseParser.parseMetadata(newRaw),
      );
    } else {
      state = state.copyWith(rawAccumulated: newRaw);
    }
  }

  void finalizeMetadata() {
    state = state.copyWith(
      metadataResult: LlmResponseParser.parseMetadata(state.rawAccumulated),
      phase: LlmPhase.done,
    );
  }

  void finalizeCorrection() {
    state = state.copyWith(
      correctedText: LlmResponseParser.parseCorrectedText(state.rawAccumulated),
      phase: LlmPhase.done,
    );
  }

  void reset() => state = const DiaryProcessState();
}
```

### diary_record_screen.dart — `_runLLMFlow()` 수정 (저장 버그 수정)

```dart
Future<void> _runLLMFlow(String rawText) async {
  final service = ref.read(llmInferenceServiceProvider);
  final processNotifier = ref.read(diaryProcessNotifierProvider.notifier);
  final correctionEnabled =
      ref.read(settingsNotifierProvider).valueOrNull?.correctionEnabled ?? false;

  if (!service.isReady) {
    try {
      await service.initialize();
    } catch (e) {
      if (!mounted) return;
      ref.read(diaryRecordNotifierProvider.notifier).setError();
      return;
    }
  }

  // Phase 1: 메타데이터 추출
  try {
    processNotifier.startMetadata();
    final prompt = kMetadataExtractionPrompt.replaceAll('{raw_text}', rawText);
    await for (final chunk in service.generateStream(prompt)) {
      if (!mounted) return;
      processNotifier.appendChunk(chunk);
    }
    processNotifier.finalizeMetadata();
    _inferenceTimer?.cancel();
  } catch (e) {
    if (!mounted) return;
    _inferenceTimer?.cancel();
    AppLogger.error('메타데이터 추출 실패', e);
    ref.read(diaryRecordNotifierProvider.notifier).setError();
    return;
  }

  // Phase 2: 문맥 보정 (설정 활성화 시)
  if (correctionEnabled && mounted) {
    try {
      final settingsAsync = ref.read(settingsNotifierProvider);
      final writingStyle = settingsAsync.valueOrNull?.writingStyle ?? WritingStyle.diary;
      final styleInstruction =
          kWritingStyleInstructions[writingStyle] ?? kWritingStyleInstructions[WritingStyle.diary]!;
      processNotifier.startCorrection();
      final prompt = kCorrectionPrompt
          .replaceAll('{style_instruction}', styleInstruction)
          .replaceAll('{raw_text}', rawText);
      await for (final chunk in service.generateStream(prompt)) {
        if (!mounted) return;
        processNotifier.appendChunk(chunk);
      }
      processNotifier.finalizeCorrection();
    } catch (e) {
      AppLogger.error('문맥 보정 실패', e);
      // 보정 실패는 치명적이지 않음 — 메타데이터로 계속 진행
    }
  }

  if (!mounted) return;
  ref.read(diaryRecordNotifierProvider.notifier).finishRecording();
}
```

### `_onSave()` 수정 — metadataResult 기반으로 변경

```dart
Future<void> _onSave({bool useCorrection = false}) async {
  final processState = ref.read(diaryProcessNotifierProvider);
  final metadataResult = processState.metadataResult;
  if (metadataResult == null) return;  // 메타데이터 미완료 시 저장 불가

  final rawText = ref.read(sttTextNotifierProvider);
  final correctedText = useCorrection ? processState.correctedText : null;

  final entry = DiaryEntry.create(
    rawText: rawText,
    title: metadataResult.title,
    emotion: metadataResult.emotion,
    tags: metadataResult.tags,
    people: metadataResult.people,
    places: metadataResult.places,
    correctedText: correctedText,
  );

  try {
    await ref.read(diaryListNotifierProvider.notifier).addEntry(entry);
    if (!mounted) return;
    ref.read(llmInferenceServiceProvider).dispose();
    ref.read(diaryRecordNotifierProvider.notifier).reset();
    ref.read(sttTextNotifierProvider.notifier).clear();
    ref.read(diaryProcessNotifierProvider.notifier).reset();
    context.go(AppRoutes.diaryList);
  } catch (e) {
    AppLogger.error('일기 저장 실패', e);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('저장에 실패했어요. 다시 시도해 주세요.')),
    );
  }
}
```

build_runner 실행.

커밋 메시지:
```
fix(process): DiaryProcessProvider 2-phase 구조 개편 + 저장 버그 수정

LlmPhase(metadata/correction/done) 상태 추가.
_runLLMFlow(): 메타데이터 추출 → (옵션) 보정 2단계 처리.
_onSave(): parsedResult 대신 metadataResult 기반으로 수정.
저장 버튼 동작 안 하는 버그 근본 수정.
```

---

## 꼭지 4: RecordScreen UI 개편

### `_GlassSttContainer` 내 LLM 결과 표시 개편

**done 상태 UI 구성 (보정 비활성화 시)**:
```
[STT 원본 텍스트]
──────────────────
📝 AI 분석 결과
  제목: [제목]
  감정: [감정 칩]
  태그: [#태그1] [#태그2] [#태그3]
  인물: 홍길동, 이영희  (있을 때만)
  장소: 카페, 공원      (있을 때만)
```

**done 상태 UI 구성 (보정 활성화 시)**:
```
[원본 / 보정본] 탭 or 나란히 표시
  상단: STT 원본 텍스트
  하단: 보정된 텍스트 (스트리밍 또는 완료)
  [원본으로 저장] [보정본으로 저장] 버튼
```

**구현 포인트**:
- `_GlassSttContainer`를 `_GlassSttContent` (STT 원본 표시) + `_MetadataResultCard` (메타데이터) + `_CorrectionCard` (보정, 옵션) 3개 위젯으로 분리
- `metadataResult != null`이 되는 순간 `_MetadataResultCard` 표시 (processing 중에도)
- 보정 완료 시 `_CorrectionCard` 추가 표시
- 저장 버튼: `metadataResult != null`이면 활성화
  - 보정 미사용: 바로 `_onSave(useCorrection: false)`
  - 보정 사용: `[원본으로 저장]` / `[보정본으로 저장]` 2개 버튼

### `_GlassHeader` 수정

- 보정 비활성화 + done: 기존처럼 상단 "저장" 텍스트 버튼
- 보정 활성화 + done: 저장 버튼 숨기고 본문의 2개 버튼으로 대체

### `settings_screen.dart` — 보정 토글 추가

```dart
// 보정 기능 섹션 추가
SwitchListTile(
  title: const Text('문맥 보정'),
  subtitle: const Text('AI가 오탈자와 어색한 표현을 최소한으로 수정합니다'),
  value: settings.correctionEnabled,
  onChanged: (v) => ref.read(settingsNotifierProvider.notifier).setCorrectionEnabled(v),
),
```

`SettingsNotifier`에 `setCorrectionEnabled(bool)` 메서드 추가.

커밋 메시지:
```
feat(ui): RecordScreen 메타데이터 결과 카드 + 보정 선택 UI

STT 원본 고정 표시, 메타데이터 결과 카드(제목/감정/태그/인물/장소) 추가.
보정 활성화 시 원본/보정본 나란히 표시 및 선택 저장.
설정 화면에 문맥 보정 토글 추가.
```

---

## 꼭지 5: DetailScreen LLM 재처리

### 재처리 흐름

```
[DiaryDetailScreen]
  ├─ "AI 재분석" 버튼 — 메타데이터만 재추출 (title/emotion/tags/people/places 업데이트)
  └─ "보정하기" 버튼 — correctedText가 null일 때만 표시, 보정 실행 후 저장
```

### 구현 방식

`DiaryDetailScreen`에서 재처리는 `DiaryDetailLlmNotifier` (별도 Riverpod 패밀리 Provider, entryId 매개변수)를 통해 처리한다.

```dart
enum DetailLlmState { idle, running, done, error }

@riverpod
class DiaryDetailLlmNotifier extends _$DiaryDetailLlmNotifier {
  @override
  DetailLlmState build(int entryId) => DetailLlmState.idle;

  Future<void> reExtractMetadata(DiaryEntry entry) async { ... }
  Future<void> runCorrection(DiaryEntry entry, WritingStyle style) async { ... }
}
```

재처리 완료 후 `diaryListNotifierProvider.notifier.updateEntry(updatedEntry)` 호출.
`updateEntry` 메서드가 없으면 `DiaryListNotifier`에 추가.

### 상세 화면 UI

```
[상단 헤더]
  제목: [추출된 제목 or '제목 없음']
  
[본문]
  - 원본 STT 텍스트 (항상 표시)
  - 보정본 (correctedText != null인 경우만)
  - 감정 칩 + 태그 칩 + 인물 + 장소
  
[하단 액션]
  ┌─────────────────────────────────────┐
  │  [AI 재분석]  [보정하기 / 재보정]   │
  └─────────────────────────────────────┘
```

커밋 메시지:
```
feat(detail): 상세 화면 AI 재분석·보정 기능 추가

DiaryDetailLlmNotifier — 메타데이터 재추출 + 보정 실행.
DiaryListNotifier.updateEntry() 추가.
상세 화면 하단에 재분석/보정 버튼 표시.
```

---

## 관련 파일 경로

| 파일 | 역할 |
|------|------|
| `lib/features/diary/domain/diary_entry.dart` | 도메인 모델 |
| `lib/features/diary/infrastructure/diary_entry_document.dart` | Isar 스키마 |
| `lib/features/settings/domain/app_settings.dart` | 설정 모델 |
| `lib/core/constants/prompts.dart` | LLM 프롬프트 상수 |
| `lib/core/utils/llm_response_parser.dart` | 파서 |
| `lib/features/diary/application/diary_process_provider.dart` | LLM 처리 상태 |
| `lib/features/diary/application/diary_list_provider.dart` | updateEntry 추가 필요 |
| `lib/features/diary/presentation/screens/diary_record_screen.dart` | 녹음 화면 |
| `lib/features/diary/presentation/screens/diary_detail_screen.dart` | 상세 화면 |
| `lib/features/settings/presentation/screens/settings_screen.dart` | 설정 화면 |
| `lib/features/settings/application/settings_provider.dart` | 설정 Notifier |

---

## 성공 판단 기준

1. 녹음 완료 후 LLM이 제목·감정·태그·인물·장소를 추출하여 화면에 표시
2. 저장 버튼 탭 → 일기 목록 이동 (버그 수정 확인)
3. 설정에서 보정 활성화 → 원본/보정본 선택 저장
4. 상세 화면에서 "AI 재분석" 탭 → 메타데이터 갱신 후 저장
