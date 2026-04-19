# Session 23 — STT 수동 종료 + 녹음 화면 UI 버그 수정

## 목표

1. 녹음이 말이 끊기면 자동 종료되는 문제 수정 — 버튼으로만 종료, 무음 15초 자동 종료 추가
2. RecordScreen 헤딩 텍스트 오류·저장 버튼 미동작 버그 수정

---

## 현재 상태

브랜치: `feat/init-20260411`

| 꼭지 | 내용 | 상태 | 커밋 |
|------|------|------|------|
| 꼭지 1 | STT 수동 종료 + 무음 타이머 | 🔲 미완료 | — |
| 꼭지 2 | 헤딩·서브텍스트 버그 + 저장 버튼 버그 수정 | 🔲 미완료 | — |

---

## 근본 원인 분석

### STT 자동 종료 원인

`speech_to_text` 패키지는 발화가 잠시 끊기면 자동으로 세션을 종료한다.
현재 `SttCallbackHandler._onResult(isFinal: true)` 및 `_onStatus('done')` 양쪽에서
`startProcessing()`을 호출하는 구조여서 말이 멈추는 순간 녹음이 종료된다.

```
[발화 잠깐 멈춤]
  → STT 엔진: isFinal=true 콜백 OR status='done' 콜백
  → startProcessing() 호출 → RecordingState.processing
  → 녹음 종료
```

### 저장 버튼 미동작 / metadataResult null 원인

`_onResult(isFinal)` + `_onStatus('done')` 두 경로가 거의 동시에
`startProcessing()`을 호출하는 경쟁 조건(race condition)이 존재한다.

```
[첫 번째 startProcessing()]
  → ref.listen 트리거 → processNotifier.reset() → _runLLMFlow() 시작

[두 번째 startProcessing() (수십ms 후)]
  → ref.listen 트리거 → processNotifier.reset() 재호출
  → 진행 중이던 LLM 상태 초기화 → metadataResult = null 로 되돌아감

[_runLLMFlow() 완료]
  → finalizeMetadata() → metadataResult 설정 (하지만 두 번째 reset이 이미 덮어씌운 경우)
  → finishRecording() → RecordingState.done

[결과]
  - 헤딩: "보정이 완료되었습니다" (RecordingState.done)
  - 컨테이너: "AI가 분석 중이에요..." (metadataResult == null)
  - 저장 버튼: onSave() → if (metadataResult == null) return; → 무동작
```

---

## 꼭지 1: STT 수동 종료 + 무음 15초 자동 종료

### 변경 파일

`lib/features/diary/application/diary_record_provider.dart` — `SttCallbackHandler` 수정

### 새 설계 원칙

- `_onResult(isFinal: true)` → **텍스트만 업데이트**, `startProcessing()` 호출 금지
- `_onStatus('done')` → **항상 재시작** (텍스트 유무 무관)
- `startProcessing()` 호출 경로를 **하나**로 통일:
  1. 사용자가 정지 버튼 누름 (`_finishRecordingAsync`)
  2. 무음 타이머 15초 만료 (`_onSilenceTimeout`)

### SttCallbackHandler 수정 코드

```dart
class SttCallbackHandler extends _$SttCallbackHandler {
  bool _isAutoRestarting = false;
  bool _isCancelled = false;
  Timer? _silenceTimer;                          // 신규
  DateTime? _lastSpeechTime;                     // 신규
  static const _silenceThreshold = 0.05;        // 무음 판단 진폭 임계값
  static const _silenceDuration = Duration(seconds: 15);

  @override
  void build() {}

  Future<void> startSession() async {
    _isAutoRestarting = false;
    _isCancelled = false;
    _resetSilenceTimer();                        // 세션 시작 시 타이머 시작

    final sttService = ref.read(speechToTextServiceProvider);
    await sttService.startListening(
      onResult: _onResult,
      onAmplitude: _onAmplitude,
      onError: _onError,
      onStatus: _onStatus,
    );
  }

  void cancelSession() {
    _isCancelled = true;
    _isAutoRestarting = false;
    _silenceTimer?.cancel();                     // 신규: 타이머 해제
    _silenceTimer = null;
  }

  // 무음 타이머 리셋 (음성 감지 시 호출)
  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(_silenceDuration, _onSilenceTimeout);
  }

  // 15초 무음 만료 콜백
  void _onSilenceTimeout() {
    if (_isCancelled) return;
    final currentState = ref.read(diaryRecordNotifierProvider);
    if (currentState != RecordingState.recording) return;

    final currentText = ref.read(sttTextNotifierProvider);
    if (currentText.isNotEmpty) {
      AppLogger.info('무음 ${_silenceDuration.inSeconds}초 초과 → 자동 종료');
      ref.read(diaryRecordNotifierProvider.notifier).startProcessing();
    }
    // 텍스트 없으면 타이머 재시작 (계속 대기)
    else {
      _resetSilenceTimer();
    }
  }

  void _onResult(String text, bool isFinal) {
    if (_isCancelled) return;
    if (text.isNotEmpty) {
      ref.read(sttTextNotifierProvider.notifier).update(text);
      // ← startProcessing() 호출 제거. 텍스트 업데이트만.
    }
  }

  void _onAmplitude(double amp) {
    if (_isCancelled) return;
    ref.read(amplitudesNotifierProvider.notifier).add(amp);
    if (amp > _silenceThreshold) {
      _resetSilenceTimer();                      // 음성 감지 시 타이머 리셋
    }
  }

  void _onError(String errorMsg, bool permanent) {
    if (!permanent) return;
    if (_isCancelled) return;

    final notifier = ref.read(diaryRecordNotifierProvider.notifier);
    final currentText = ref.read(sttTextNotifierProvider);
    if (currentText.isNotEmpty) {
      notifier.startProcessing();
    } else {
      notifier.setError();
    }
  }

  Future<void> _onStatus(String status) async {
    AppLogger.info('SttCallbackHandler onStatus: $status');
    if (status != 'done') return;
    if (_isCancelled) return;

    final currentState = ref.read(diaryRecordNotifierProvider);
    if (currentState != RecordingState.recording) return;

    // 텍스트 유무와 관계없이 항상 재시작 (startProcessing 호출 금지)
    if (!_isAutoRestarting) {
      _isAutoRestarting = true;
      AppLogger.info('STT done → 재시작');
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (_isCancelled) return;
      if (ref.read(diaryRecordNotifierProvider) == RecordingState.recording) {
        _isAutoRestarting = false;
        await startSession();
      }
    }
  }
}
```

### 확인 사항

- 말이 잠깐 끊겨도 녹음이 계속 유지되는지
- 정지 버튼 누르면 즉시 processing 전환되는지
- 말 없이 15초 경과 시 자동 종료되는지

커밋 메시지:
```
fix(stt): STT 수동 종료 전환, 무음 15초 자동 종료 추가

_onResult(isFinal) startProcessing() 호출 제거.
_onStatus('done') → 항상 재시작 (경쟁 조건 제거).
SttCallbackHandler에 무음 타이머(15초) 추가.
```

---

## 꼭지 2: 헤딩·서브텍스트·상태 배지 버그 수정

### 문제 1: 헤딩 텍스트 오류

**현재**:
```dart
RecordingState.processing => 'AI가\n다듬는 중입니다',  // 항상 "다듬는"
RecordingState.done       => '보정이\n완료되었습니다',  // 항상 "보정 완료"
```

**원인**: 보정(correction)은 선택적 기능인데, 헤딩이 항상 "다듬는/보정" 표현을 씀.

**수정**:
- `RecordingState.processing + LlmPhase.correction` → "AI가 다듬는 중입니다"
- `RecordingState.processing + 그 외` → "AI가 분석 중입니다"
- `RecordingState.done + correctionEnabled == true` → "보정이 완료되었습니다"
- `RecordingState.done + correctionEnabled == false` → "분석이 완료되었습니다"

### 문제 2: 저장 버튼 processing 중 비활성화 (UX 혼란)

`_ControlsRow._buildRightButton` — processing 상태:
```dart
RecordingState.processing => const _RoundButton(
    icon: Icons.check_rounded,
    tooltip: AppStrings.btnSave,
    isFilled: true,    // ← onTap 없음 → 항상 비활성
  ),
```

처리 중에는 check 아이콘 대신 **빈 공간**(`SizedBox`)을 표시해 혼란 방지.

### 변경 파일

`lib/features/diary/presentation/screens/diary_record_screen.dart`

### 수정 코드

#### `_DiaryRecordScreenState.build()` 에 LlmPhase 추가

```dart
// build() 상단에 추가
final llmPhase = ref.watch(
  diaryProcessNotifierProvider.select((s) => s.phase),
);
```

#### `_headingText` 시그니처 변경

```dart
String _headingText(
  RecordingState state,
  LlmPhase llmPhase,
  bool correctionEnabled,
) =>
    switch (state) {
      RecordingState.idle      => '오늘의 목소리를\n담아보세요',
      RecordingState.recording => '생각을 기록하고\n있습니다',
      RecordingState.processing => llmPhase == LlmPhase.correction
          ? 'AI가\n다듬는 중입니다'
          : 'AI가\n분석 중입니다',
      RecordingState.done      => correctionEnabled
          ? '보정이\n완료되었습니다'
          : '분석이\n완료되었습니다',
      RecordingState.error     => '문제가\n발생했어요',
    };
```

#### `_subtitleText` 시그니처 변경

```dart
String _subtitleText(RecordingState state, LlmPhase llmPhase) =>
    switch (state) {
      RecordingState.idle      => '마이크 버튼을 눌러 시작하세요',
      RecordingState.recording => '자연스럽게 말씀해 주세요. AI가 경청하고 있습니다.',
      RecordingState.processing => llmPhase == LlmPhase.correction
          ? '문장을 다듬고 있어요'
          : 'AI가 내용을 분석하고 있어요',
      RecordingState.done      => '일기를 저장하거나 다시 녹음할 수 있어요',
      RecordingState.error     => '다시 시도해 보세요',
    };
```

#### build() 안에서 메서드 호출 인자 추가

```dart
Text(
  _headingText(recordingState, llmPhase, correctionEnabled),
  ...
),
Text(
  _subtitleText(recordingState, llmPhase),
  ...
),
```

#### `_ControlsRow._buildRightButton` — processing 중 버튼 숨김

```dart
RecordingState.processing => const SizedBox(width: 64, height: 64),
```

#### `_RecordingStateBadge` — processing 배지 텍스트를 LlmPhase로 분리

`_RecordingStateBadge`가 `LlmPhase`를 받도록 수정:

```dart
class _RecordingStateBadge extends StatelessWidget {
  const _RecordingStateBadge({required this.state, required this.llmPhase});

  final RecordingState state;
  final LlmPhase llmPhase;
  ...
  final (Color bg, Color fg, IconData icon, String label) = switch (state) {
    RecordingState.recording  => (..., '실시간 녹음 중'),
    RecordingState.processing => llmPhase == LlmPhase.correction
        ? (..., 'AI 보정 중')
        : (..., 'AI 분석 중'),
    RecordingState.done       => (..., '완료'),
    _                         => (..., ''),
  };
}
```

build()에서 호출:
```dart
_RecordingStateBadge(state: recordingState, llmPhase: llmPhase),
```

커밋 메시지:
```
fix(ui): RecordScreen 헤딩·배지 텍스트 분석/보정 단계 분리

LlmPhase 기반으로 헤딩·서브텍스트·배지 텍스트 분기.
processing 상태 우측 버튼 SizedBox로 교체(비활성 check 아이콘 혼란 방지).
correctionEnabled=false 시 done 헤딩 "분석이 완료되었습니다"로 수정.
```

---

## 관련 파일 경로

| 파일 | 변경 내용 |
|------|-----------|
| `lib/features/diary/application/diary_record_provider.dart` | SttCallbackHandler — 무음 타이머, _onResult/_onStatus 수정 |
| `lib/features/diary/presentation/screens/diary_record_screen.dart` | 헤딩/서브텍스트/배지 LlmPhase 분기, processing 버튼 숨김 |

---

## 성공 판단 기준

1. 말이 잠깐 멈춰도 녹음 화면이 유지되어야 함
2. 정지 버튼 누를 때만 "AI 분석 중" 전환
3. 말 없이 15초 방치 → 자동으로 AI 분석 시작
4. 메타데이터 분석 중 → 헤딩 "AI가 분석 중입니다"
5. 보정 활성화 + 보정 중 → 헤딩 "AI가 다듬는 중입니다"
6. 분석 완료 (보정 비활성) → 헤딩 "분석이 완료되었습니다"
7. 저장 버튼 탭 → 일기 목록 이동 (정상 동작)
