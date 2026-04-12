# Session 20 — STT 근본 원인 디버깅 및 수정

## 현재 상태 (session 19 종료 기준)

브랜치: `feat/init-20260411`

### 증상
Samsung Galaxy S23 FE 실기기 테스트에서:
- 마이크 버튼 탭 → STT 상태: `listening → notListening → done`
- `onResult` 콜백이 **단 한 번도** 안 불림 (partial도, final도)
- `onError` 콜백도 안 불림
- 텍스트 표시 없음, LLM 처리도 없음
- STT 세션이 2~3초 만에 스스로 종료됨

### 이전 세션들에서 시도한 것
1. `record` 패키지(MediaRecorder)를 STT보다 먼저 시작 → `error_speech_timeout` 발생 확인
2. STT를 먼저 시작해 마이크 선점 → `error_speech_timeout`는 사라짐, but `done` 즉시
3. `record` 패키지 오디오 녹음 비활성화(코드 레벨) → 여전히 `done` 즉시
4. `pauseFor: 3s → 8s`, `listenFor: 60s`, `cancelOnError: false` 추가
5. `onStatus('done')` 핸들러 + auto-restart 로직 추가
   - 그러나 auto-restart 로그도 찍히지 않음 → `onStatus` 콜백이 실행은 되나 auto-restart 분기에 못 들어감

### 핵심 가설 (다음 세션에서 검증)

**가설 A: `audioplayers` 패키지 Audio Session 충돌**
`diary_record_screen.dart`에 `AudioPlayer()`가 아직 살아있다.
`audioplayers` 패키지가 생성 시점에 Android audio focus나 audio session을 건드리면
SpeechRecognizer가 오디오를 받지 못할 수 있다.
`_recordedFilePath`는 항상 null이라 재생 기능은 완전히 불가 상태임에도 인스턴스가 살아있다.

**가설 B: Samsung SpeechRecognizer 기동 타임아웃**
Samsung Galaxy는 SpeechRecognizer가 음성 시작 감지 전에 자체 타임아웃을 갖는다.
`speech_to_text` 패키지의 기본 `ListenMode.confirmation`은 단발성 발화 인식 모드이며
타임아웃이 짧을 수 있다. `ListenMode.dictation`으로 바꾸면 연속 받아쓰기 모드가 된다.

**가설 C: 한국어 로케일(`ko_KR`) 문제**
`ko_KR` 모델이 오프라인으로 없거나 초기화 실패 시 결과 없이 `done`으로 끝날 수 있다.
로케일 없이 테스트해보면 원인을 좁힐 수 있다.

---

## 해야 할 작업 (우선순위 순)

### 꼭지 1: `record`·`audioplayers` 완전 제거

**파일**: `lib/features/diary/presentation/screens/diary_record_screen.dart`

`_DiaryRecordScreenState`에서 아래를 전부 제거:
- `final _audioRecorder = AudioRecorder();`
- `final _audioPlayer = AudioPlayer();`
- `String? _recordedFilePath;`
- `bool _isPlaying;`
- `late final StreamSubscription<PlayerState> _playerStateSub;`
- `_playerStateSub` 관련 `initState` 코드
- `unawaited(_audioRecorder.dispose())`, `unawaited(_audioPlayer.dispose())`
- `_togglePlayback()`, `_doTogglePlayback()`
- `onPlayback: _recordedFilePath != null ? _togglePlayback : null` → `onPlayback: null`
- `_ControlsRow`의 `isPlaying` 파라미터와 관련 로직
- import `package:record/record.dart`, `package:audioplayers/audioplayers.dart`

재생 버튼(done 상태 center 버튼)은 `onPlayback: null`로 비활성 상태로 남겨둔다.

### 꼭지 2: STT 파라미터 최적화

**파일**: `lib/features/diary/infrastructure/speech_to_text_service.dart`

```dart
await _stt.listen(
  onResult: ...,
  onSoundLevelChange: ...,
  localeId: 'ko_KR',
  listenFor: const Duration(seconds: 60),
  pauseFor: const Duration(seconds: 8),
  cancelOnError: false,
  listenMode: ListenMode.dictation,  // 추가: 연속 받아쓰기 모드
  partialResults: true,              // 명시: 중간 결과 활성화
);
```

또한 `onStatus`에서 `'notListening'` 상태도 로깅 강화:
```dart
onStatus: (status) {
  AppLogger.info('STT 상태: $status');
  if (status == 'notListening') {
    AppLogger.info('STT notListening — onResult 발생 여부는 콜백 로그 확인');
  }
  _statusCallback?.call(status);
},
```

### 꼭지 3: `onResult` 호출 여부 진단 로깅

**파일**: `lib/features/diary/infrastructure/speech_to_text_service.dart`

`startListening()`에서 `onResult` 래핑:
```dart
onResult: (result) {
  AppLogger.info(
    'STT onResult: words="${result.recognizedWords}" '
    'final=${result.finalResult} '
    'confidence=${result.alternates?.firstOrNull?.confidence}',
  );
  onResult(result.recognizedWords, result.finalResult);
},
```

이 로그가 실기기 테스트에서 한 번도 안 나오면 → Android SpeechRecognizer 자체가 결과를 주지 않는 것
나오는데 텍스트가 비어있으면 → 인식은 했지만 결과가 없는 것 (로케일 문제 가능성)

### 꼭지 4: `onStatus` auto-restart 디버깅

**파일**: `lib/features/diary/presentation/widgets/mic_button.dart`

`onStatus` 핸들러 진입 여부 확인 로그 추가:
```dart
onStatus: (status) async {
  AppLogger.info('onStatus 핸들러 진입: $status, mounted=$mounted');
  if (!mounted) return;
  if (status != 'done') return;

  final currentState = ref.read(diaryRecordNotifierProvider);
  AppLogger.info('onStatus done: state=$currentState');
  if (currentState != RecordingState.recording) return;
  // ... 나머지 코드
},
```

---

## 관련 파일 경로

| 파일 | 역할 |
|------|------|
| `lib/features/diary/presentation/screens/diary_record_screen.dart` | 녹음 화면 — AudioPlayer/AudioRecorder 제거 대상 |
| `lib/features/diary/infrastructure/speech_to_text_service.dart` | STT 서비스 — listenMode, 로깅 추가 |
| `lib/features/diary/presentation/widgets/mic_button.dart` | 마이크 버튼 — onStatus 디버깅 로그 |
| `lib/features/diary/application/diary_record_provider.dart` | RecordingState, STT Provider |

## 기술 배경: Android SpeechRecognizer 동작

- `SpeechRecognizer.startListening()` 호출 후 상태 순서:
  - `onReadyForSpeech` → `onBeginningOfSpeech` → `onEndOfSpeech` → `onResults`
  - `speech_to_text` 매핑: `listening` → (말하면 onResult partial) → `notListening` → `done` + onResult final
- `notListening`이 `onResult` 없이 빠르게 오면 → Android가 발화 없다고 판단
- Samsung 기기는 Google Speech Services 대신 자체 엔진을 쓰는 경우 있음
- `ListenMode.dictation` = `RecognizerIntent.EXTRA_DICTATION_MODE = true` → 긴 발화 허용, 타임아웃 연장

## 성공 판단 기준

1. `[INFO] STT onResult: words="..." final=false` 로그가 실시간으로 나와야 함
2. 말을 멈추면 `final=true` 로그 + UI에 텍스트 표시
3. MicButton 정지 탭 → LLM processing → 보정 텍스트 표시
