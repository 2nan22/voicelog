# Session 16 — 녹음 화면 개선 · 홈 캘린더 · UI 변경 준비

## 목표

| 항목 | 내용 |
|------|------|
| 녹음 화면 | STT/LLM 결과 분리 표시, 감정·태그 뱃지 재배치, 문체 선택, 파형 마이크 연동, 버튼 재설계, 녹음 재생 |
| 홈 화면 | 일기 목록 → 캘린더 뷰로 교체 (날짜 칸에 감정 표시) |
| UI 변경 준비 | Stitch 등 외부 툴 연동 시 참고할 파일 목록 정리 |

> **디자인 일괄 변경(꼭지 UI 일괄 교체)은 Session 17 이후** 별도 진행 예정.
> 이번 세션은 기능·구조 변경에 집중하며, 기존 스타일과 자연스럽게 어울리도록 구현한다.

## 참고 규칙 파일
- `.claude/rules/architecture.md`
- `.claude/rules/state_management.md`
- `.claude/rules/flutter_conventions.md`
- `.claude/rules/ui_ux.md`
- `.claude/rules/performance.md`

## 사전 조건
- Session 14 완료 (Profile 탭)
- `AppSettings` 도메인 모델: `isDarkMode` 필드만 존재

---

## 꼭지 1 — 문체 선택 설정 추가

### 배경

LLM 보정 시 일기를 어떤 문체로 수정할지 사용자가 선택할 수 있어야 한다.
설정 화면에서 선택한 문체가 LLM 프롬프트에 반영된다.

### 수정 파일 목록

| 파일 | 작업 |
|------|------|
| `lib/features/settings/domain/app_settings.dart` | `WritingStyle` enum + `writingStyle` 필드 추가 |
| `lib/features/settings/infrastructure/app_settings_document.dart` | Isar 문서에 `writingStyle` int 필드 추가 |
| `lib/features/settings/application/settings_provider.dart` | `setWritingStyle()` 메서드 추가 |
| `lib/features/settings/presentation/screens/settings_screen.dart` | 문체 선택 UI 섹션 추가 |
| `lib/core/constants/prompts.dart` | 문체별 프롬프트 상수 추가 |
| `lib/features/diary/application/llm_provider.dart` | 설정값을 프롬프트에 반영 |

### 작업 내용

#### 1. `app_settings.dart` — WritingStyle enum + 필드

```dart
/// LLM 보정 시 적용할 문체.
enum WritingStyle {
  diary,   // 일기체 — 자연스러운 독백 (기본값)
  memo,    // 메모체 — 간결·핵심 요약
  letter,  // 편지체 — 감성적·따뜻한 표현
}

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(false) bool isDarkMode,
    @Default(WritingStyle.diary) WritingStyle writingStyle,
  }) = _AppSettings;
}
```

#### 2. `app_settings_document.dart` — Isar 필드 추가

```dart
// writingStyle을 int로 저장 (enum index)
@Index()
int writingStyleIndex = 0;
```

`AppSettings` ↔ `AppSettingsDocument` 변환 로직에서
`WritingStyle.values[doc.writingStyleIndex]` 로 읽고,
`settings.writingStyle.index` 로 쓴다.

#### 3. `prompts.dart` — 문체별 프롬프트 상수

```dart
/// 문체별 보정 지시문. kDiaryProcessingPrompt의 {style_instruction} 자리에 치환.
const Map<WritingStyle, String> kWritingStyleInstructions = {
  WritingStyle.diary:  '자연스러운 1인칭 독백 일기체로',
  WritingStyle.memo:   '핵심만 간결하게 메모체로',
  WritingStyle.letter: '따뜻하고 감성적인 편지체로',
};

const String kDiaryProcessingPrompt = '''
<|im_start|>user
당신은 일기 정리 비서입니다. 아래 텍스트를 {style_instruction} 수정하고,
감정(기쁨/슬픔/평온/화남)과 키워드 3개를 추출하세요.
응답 형식:
[보정본] 내용...
[감정] 감정값
[태그] #키워드1, #키워드2, #키워드3

입력: {raw_text}<|im_end|>
<|im_start|>assistant
''';
```

#### 4. `llm_provider.dart` — 프롬프트 치환

`diary_record_screen.dart`의 `_runLLMFlow` 또는 `llm_provider.dart`에서
설정값을 읽어 `{style_instruction}` 치환:

```dart
final settings = await ref.read(settingsProvider.future);
final styleInstruction =
    kWritingStyleInstructions[settings.writingStyle] ?? kWritingStyleInstructions[WritingStyle.diary]!;
final prompt = kDiaryProcessingPrompt
    .replaceAll('{style_instruction}', styleInstruction)
    .replaceAll('{raw_text}', rawText);
```

#### 5. `settings_screen.dart` — 문체 선택 UI

기존 다크 모드 섹션 아래에 문체 선택 `SegmentedButton` 추가:

```dart
// 문체 선택 섹션
SegmentedButton<WritingStyle>(
  segments: const [
    ButtonSegment(value: WritingStyle.diary,  label: Text('일기체')),
    ButtonSegment(value: WritingStyle.memo,   label: Text('메모체')),
    ButtonSegment(value: WritingStyle.letter, label: Text('편지체')),
  ],
  selected: {settings.writingStyle},
  onSelectionChanged: (value) =>
      ref.read(settingsNotifierProvider.notifier).setWritingStyle(value.first),
);
```

#### 6. `build_runner` 실행

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 1]
feat(settings): LLM 보정 문체 선택 기능 추가 (일기체·메모체·편지체)

- WritingStyle enum + AppSettings.writingStyle 필드
- kWritingStyleInstructions: 문체별 프롬프트 지시문 상수
- kDiaryProcessingPrompt: {style_instruction} 치환 포인트 추가
- SettingsScreen: SegmentedButton 문체 선택 UI
- llm 프롬프트 생성 시 설정값 반영

다음 꼭지(녹음 화면 STT/LLM 결과 분리 + 버튼 재설계)를 진행할까요?
---
```

---

## 꼭지 2 — 녹음 화면: STT/LLM 결과 분리 표시 + 버튼 재설계

### 배경 및 현재 상태

**현재 구조** (`diary_record_screen.dart`):
- `_DiaryContentCard`: STT 원문과 LLM 스트리밍 텍스트가 한 카드 안에 혼재 (STT가 processing 시 흐려짐)
- `DiaryResultWidget`: 감정 칩 + 태그 칩이 콘텐츠 카드 바깥 별도 위치
- `_ControlsRow`: [삭제] [마이크] [체크(?)] — 체크 버튼 역할 불명확

**변경 목표**:
- STT 원문 카드 / LLM 보정 결과 카드를 시각적으로 분리
- 감정·태그 뱃지를 LLM 결과 카드 내부에 포함 (보정 텍스트 아래)
- 버튼 상태별 역할 명확화:
  - `idle` → 마이크 버튼만 활성 (시작)
  - `recording` → [삭제] [마이크=중지] [완료체크]
  - `processing` → 버튼 비활성 (처리 중 인디케이터)
  - `done` → [재녹음] [마이크=재생▶] [저장]

### 수정 파일 목록

| 파일 | 작업 |
|------|------|
| `lib/features/diary/presentation/screens/diary_record_screen.dart` | `_DiaryContentCard` 분리, `_ControlsRow` 재설계 |
| `lib/features/diary/presentation/widgets/diary_result_widget.dart` | 감정·태그 뱃지를 카드 내부에 통합 |
| `lib/core/constants/strings.dart` | 버튼 tooltip 문자열 추가 |

### 작업 내용

#### 1. 콘텐츠 영역 분리

`_ScrollableContent` → `_DiaryContentCard` 대신 두 개의 카드로 교체:

```
_SttCard        — STT 원문 카드
  └─ 항상 표시. 녹음 중 실시간 갱신. processing/done 시 회색 dimmed.

_LlmResultCard  — LLM 보정 결과 카드
  └─ processing 시작 후 나타남.
     내부 구조:
       ┌─ 보정 텍스트 (StreamingTextWidget)
       ├─ 구분선
       └─ 감정 뱃지 + 태그 뱃지 (DiaryResultWidget 내용 이동)
```

`_SttCard` 구현 포인트:
```dart
class _SttCard extends ConsumerWidget {
  // recordingState가 processing/done이면 opacity 0.45 적용
  // isEmpty이고 idle이면 placeholder 텍스트 표시
}
```

`_LlmResultCard` 구현 포인트:
```dart
class _LlmResultCard extends ConsumerWidget {
  // processState.isProcessingOrDone이 false이면 SizedBox.shrink()
  // 카드 상단: "AI 보정" 레이블 (labelSmall, primary 색상)
  // 중간: StreamingTextWidget
  // 하단: EmotionChip + Wrap(tags)
  //   → 파싱 완료(parsedResult != null) 후에만 표시
}
```

#### 2. 버튼 재설계

`_ControlsRow` 상태별 버튼 구성:

| 상태 | 좌측 버튼 | 중앙 버튼 | 우측 버튼 |
|------|-----------|-----------|-----------|
| idle | 숨김(투명) | 마이크(시작) | 숨김(투명) |
| recording | 삭제(휴지통) | 마이크(중지■) | 완료(체크✓) |
| processing | 삭제(비활성) | 로딩 스피너 | 저장(비활성) |
| done | 재녹음(↩) | ▶ 재생(플레이스홀더, 꼭지3 구현) | 저장(체크✓) |
| error | 재시도(↩) | 마이크 | 숨김 |

`recording` 상태의 우측 "완료(체크✓)" 버튼 동작:
→ STT를 중지하고 즉시 LLM 처리 시작 (현재 마이크 버튼 중지 시와 동일)
→ 기존 마이크 버튼 중지 동작을 이 버튼으로 명시적으로 분리해도 무방

`strings.dart`에 추가:
```dart
static const String btnStopRecording = '녹음 중지';
static const String btnFinishRecording = '처리 시작';
static const String btnReRecord = '다시 녹음';
static const String btnPlayRecording = '녹음 듣기';
static const String btnSave = '저장';
```

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 2]
feat(record): STT/LLM 결과 카드 분리 + 버튼 상태별 역할 명확화

- _SttCard / _LlmResultCard 분리 (기존 _DiaryContentCard 대체)
- 감정·태그 뱃지를 _LlmResultCard 내부로 이동
- _ControlsRow: idle/recording/processing/done 상태별 버튼 구성
  - recording: [삭제] [중지■] [완료✓]
  - done: [재녹음] [▶재생(placeholder)] [저장]

다음 꼭지(파형 마이크 연동 + 녹음 재생)를 진행할까요?
---
```

---

## 꼭지 3 — 녹음 화면: 파형 마이크 연동 + 녹음 재생

### 배경 및 현재 상태

**파형**:
- `WaveformWidget`은 `amplitudes: List<double>` 파라미터를 받지만, 현재 `diary_record_screen.dart`에서 전달하지 않음 → 항상 sin 애니메이션만 표시
- `speech_to_text` 패키지의 `listen(onSoundLevelChange: (double level) {...})` 콜백으로 실시간 dB 레벨(-2.0 ~ 10.0 범위) 수신 가능

**녹음 재생**:
- 현재 음성 파일 저장 기능 없음
- `speech_to_text`는 STT만 하고 오디오 파일을 저장하지 않으므로, 별도 녹음 패키지 필요

### 새 패키지 추가 (`pubspec.yaml`)

```yaml
dependencies:
  record: ^5.x          # 마이크 → 로컬 파일 녹음
  audioplayers: ^6.x    # 로컬 파일 재생
```

> 두 패키지 모두 온디바이스 전용, 네트워크 없음 — 온디바이스 원칙 준수.

### Android 권한 (`android/app/src/main/AndroidManifest.xml`)

`record` 패키지는 이미 있는 `RECORD_AUDIO` 권한 외에
`WRITE_EXTERNAL_STORAGE` 없이 앱 내부 경로에 저장 가능 → 추가 권한 불필요.

### 수정 파일 목록

| 파일 | 작업 |
|------|------|
| `pubspec.yaml` | `record`, `audioplayers` 패키지 추가 |
| `lib/features/diary/infrastructure/speech_to_text_service.dart` | `onSoundLevelChange` 콜백 노출 |
| `lib/features/diary/application/diary_record_provider.dart` | `soundLevel` → `amplitudes` 버퍼 관리 |
| `lib/features/diary/presentation/screens/diary_record_screen.dart` | 파형 연동 + 녹음 파일 저장/재생 |

### 작업 내용

#### 1. `speech_to_text_service.dart` — soundLevel 콜백 추가

`startListening()` 내부의 `_stt.listen()` 호출에 콜백 추가:

```dart
_stt.listen(
  onResult: ...,
  onSoundLevelChange: (double level) {
    // level: -2.0 ~ 10.0 (dB 환경 노이즈 기준 상대값)
    // 0.0 ~ 1.0 범위로 정규화 후 콜백 전달
    final normalized = ((level + 2.0) / 12.0).clamp(0.0, 1.0);
    onAmplitude?.call(normalized);
  },
  ...
);
```

서비스 인터페이스(`i_llm_inference_service.dart`와 분리된 STT 인터페이스) 또는
`SpeechToTextService` 클래스에 `void Function(double)? onAmplitude` 프로퍼티 추가.

#### 2. `diary_record_provider.dart` — amplitudes 버퍼

```dart
// RecordingState Notifier 안에 amplitude 큐 관리
final _amplitudeBuffer = Queue<double>();
static const _maxAmplitudeCount = 40; // 파형 바 최대 개수

void addAmplitude(double value) {
  if (_amplitudeBuffer.length >= _maxAmplitudeCount) {
    _amplitudeBuffer.removeFirst();
  }
  _amplitudeBuffer.addLast(value);
  // 별도 Provider로 노출하거나 state에 포함
}

List<double> get amplitudes => _amplitudeBuffer.toList();
```

또는 간결하게 `StateProvider<List<double>>`를 별도로 두고 녹음 시 업데이트.

#### 3. 녹음 파일 저장

`diary_record_screen.dart`의 `_DiaryRecordScreenState`에 `record` 패키지 추가:

```dart
import 'package:record/record.dart';

final _audioRecorder = AudioRecorder();
String? _recordedFilePath;

Future<void> _startAudioRecording() async {
  final dir = await getTemporaryDirectory();
  _recordedFilePath = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
  await _audioRecorder.start(
    const RecordConfig(encoder: AudioEncoder.aacLc),
    path: _recordedFilePath!,
  );
}

Future<void> _stopAudioRecording() async {
  await _audioRecorder.stop();
}
```

`_onStartRecording()` 시 `_startAudioRecording()` 병행 호출,
`_onStopRecording()` 시 `_stopAudioRecording()` 호출.

#### 4. 녹음 파일 재생 (`audioplayers`)

done 상태의 ▶ 재생 버튼 동작:

```dart
import 'package:audioplayers/audioplayers.dart';

final _audioPlayer = AudioPlayer();

Future<void> _togglePlayback() async {
  if (_recordedFilePath == null) return;
  final state = await _audioPlayer.state;
  if (state == PlayerState.playing) {
    await _audioPlayer.pause();
  } else {
    await _audioPlayer.play(DeviceFileSource(_recordedFilePath!));
  }
}
```

`dispose()`에서 `_audioRecorder.dispose()`, `_audioPlayer.dispose()` 호출 필수.

#### 5. `WaveformWidget` 연동

```dart
WaveformWidget(
  isRecording: recordingState == RecordingState.recording,
  amplitudes: ref.watch(amplitudesProvider), // 실시간 갱신
),
```

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 3]
feat(record): 실시간 마이크 파형 연동 + 녹음 파일 저장·재생 기능 추가

- speech_to_text onSoundLevelChange → 0~1 정규화 → amplitudes 버퍼
- WaveformWidget에 실시간 amplitude 데이터 전달 (sin 애니메이션 대체)
- record 패키지: STT와 병행 m4a 파일 녹음 저장
- audioplayers 패키지: done 상태 ▶재생 버튼 동작 구현

다음 꼭지(홈 화면 캘린더 변경)를 진행할까요?
---
```

---

## 꼭지 4 — 홈 화면: 캘린더 뷰로 변경

### 배경 및 현재 상태

- `diary_list_screen.dart` (398줄): `SliverList.builder`로 일기 카드 목록 표시
- 일기 목록은 Logs 탭(`logs_screen.dart`)에서도 월별 타임라인으로 제공되어 중복
- 홈 탭은 캘린더로 교체하여 날짜 기반 탐색 + 감정 시각화 제공

### 새 패키지 추가

```yaml
dependencies:
  table_calendar: ^3.x    # 캘린더 위젯
```

### 수정 파일 목록

| 파일 | 작업 |
|------|------|
| `pubspec.yaml` | `table_calendar` 추가 |
| `lib/features/diary/presentation/screens/diary_list_screen.dart` | 캘린더 뷰로 전면 교체 |
| `lib/features/diary/application/diary_list_provider.dart` | 날짜별 일기 맵 파생 Provider 추가 |

### 작업 내용

#### 1. `diary_list_provider.dart` — 날짜별 일기 맵 추가

```dart
/// 날짜(연·월·일만) → 해당 날의 일기 목록 맵.
/// 캘린더 이벤트 마커 및 선택 날짜 목록에 사용.
@riverpod
Future<Map<DateTime, List<DiaryEntry>>> diaryByDate(DiaryByDateRef ref) async {
  final entries = await ref.watch(diaryListNotifierProvider.future);
  final map = <DateTime, List<DiaryEntry>>{};
  for (final e in entries) {
    final day = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
    map.putIfAbsent(day, () => []).add(e);
  }
  return map;
}
```

#### 2. `diary_list_screen.dart` — 캘린더 뷰

전체 구조:
```
CustomScrollView
  ├─ SliverPersistentHeader (기존 글래스 헤더 유지)
  └─ SliverToBoxAdapter
       ├─ TableCalendar (월간 캘린더)
       │    - 각 날짜 칸 하단에 감정 색상 점(dot) 마커 표시
       │    - 일기가 있는 날: 감정에 해당하는 AppColors 점 1개
       │    - 복수 일기: 최대 3개 점
       └─ 선택된 날짜의 일기 카드 목록 (SliverList → 캘린더 아래 표시)
```

캘린더 감정 마커 로직:
```dart
// eventLoader: 해당 날짜의 DiaryEntry 목록 반환
eventLoader: (day) {
  final key = DateTime(day.year, day.month, day.day);
  return diaryByDate[key] ?? [];
},

// calendarBuilders.markerBuilder: 감정별 색상 점 렌더링
markerBuilder: (context, date, events) {
  if (events.isEmpty) return const SizedBox.shrink();
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: events.take(3).map((e) {
      final entry = e as DiaryEntry;
      return Container(
        width: 6, height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _emotionColor(entry.emotion),
        ),
      );
    }).toList(),
  );
},
```

선택된 날짜 일기 목록: 캘린더 아래 `AnimatedSwitcher`로 부드럽게 전환.

#### 3. build_runner 실행

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 4]
feat(home): 홈 화면 일기 목록 → 캘린더 뷰로 교체

- diaryByDateProvider: 날짜별 DiaryEntry 맵 파생 Provider
- TableCalendar 도입: 감정 색상 점 마커, 날짜 선택 시 하단 일기 목록 표시
- 기존 SliverList 목록 제거 (Logs 탭과 중복 기능 정리)

Session 16 완료.
---
```

---

## [참고] UI 일괄 변경 시 참고 파일 목록

> Stitch, v0, Figma-to-Flutter 등 외부 툴로 UI를 교체할 때 이 목록의 파일을 대상으로 작업한다.
> 각 파일의 역할과 교체 범위를 미리 파악해 충돌을 방지한다.

### 탭별 화면 파일

| 탭 / 화면 | 파일 경로 | 교체 범위 |
|-----------|-----------|-----------|
| 홈 (캘린더) | `lib/features/diary/presentation/screens/diary_list_screen.dart` | 전체 레이아웃 |
| Logs | `lib/features/diary/presentation/screens/logs_screen.dart` | 전체 레이아웃 |
| Insight | `lib/features/diary/presentation/screens/insight_screen.dart` | 전체 레이아웃 |
| Profile | `lib/features/diary/presentation/screens/profile_screen.dart` | 전체 레이아웃 |
| 녹음 화면 | `lib/features/diary/presentation/screens/diary_record_screen.dart` | 전체 레이아웃 |
| 상세 화면 | `lib/features/diary/presentation/screens/diary_detail_screen.dart` | 전체 레이아웃 |
| 설정 화면 | `lib/features/settings/presentation/screens/settings_screen.dart` | 전체 레이아웃 |
| 스플래시 | `lib/features/diary/presentation/screens/splash_screen.dart` | 전체 레이아웃 |

### 공유 UI 컴포넌트

| 컴포넌트 | 파일 경로 | 교체 범위 |
|----------|-----------|-----------|
| 하단 탭 내비게이션 | `lib/core/widgets/main_shell.dart` | `NavigationBar` 스타일 |
| 감정 칩 | `lib/core/widgets/emotion_chip.dart` | 색상·형태 |
| 로딩 shimmer | `lib/core/widgets/loading_shimmer.dart` | 형태 |
| 일기 카드 | `lib/features/diary/presentation/widgets/diary_card.dart` | 카드 레이아웃 |
| 마이크 버튼 | `lib/features/diary/presentation/widgets/mic_button.dart` | 버튼 디자인 |
| 파형 위젯 | `lib/features/diary/presentation/widgets/waveform_widget.dart` | 파형 스타일 |
| 스트리밍 텍스트 | `lib/features/diary/presentation/widgets/streaming_text_widget.dart` | 텍스트 스타일 |
| 감정 도넛 차트 | `lib/features/diary/presentation/widgets/emotion_donut_chart.dart` | 차트 스타일 |

### 테마·스타일 파일

| 역할 | 파일 경로 | 교체 범위 |
|------|-----------|-----------|
| 색상 팔레트 | `lib/core/theme/app_colors.dart` | 시드 컬러, 감정 색상 |
| Material 3 테마 | `lib/core/theme/app_theme.dart` | Light/Dark 테마 전체 |
| 간격·크기 상수 | `lib/core/constants/dimensions.dart` | padding, borderRadius, 버튼 크기 |
| 폰트 | `pubspec.yaml` > `fonts:` 섹션 + `app_theme.dart` | fontFamily |

### 라우팅 (교체 불필요, 참고용)

| 역할 | 파일 경로 |
|------|-----------|
| 라우트 상수 | `lib/core/constants/routes.dart` |
| go_router 설정 | `lib/core/router/app_router.dart` |
| 앱 진입점 | `lib/app.dart` |
