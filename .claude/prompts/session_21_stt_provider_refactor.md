# Session 21 — STT 콜백 Application 레이어 이동 리팩토링

## 현재 상태 (session 20 종료 기준)

브랜치: `feat/init-20260411`

STT 동작은 확인됨 (`onResult: words="안녕하세요" final=true confidence=0.8`).
그러나 3가지 이슈가 남아있음:

### 이슈 1: 실시간 텍스트 미출력
STT `onResult(final=false)` 콜백이 도착하는 시점에 `_MicButtonState`가 이미
`mounted=false`라서 `sttNotifier.update(text)` 미실행 → UI 갱신 없음.

### 이슈 2: 말하는 중 혼자 녹음 멈춤 (Samsung STT 자동 종료)
Samsung Galaxy S23 FE의 네이티브 STT가 짧은 침묵(~1-2초) 후 자동 세션 종료.
`pauseFor: 8초` 설정을 무시함. `done` 상태에서 자동 재시작 로직이 있으나
`mounted=false`로 차단되어 재시작 안 됨.

### 이슈 3: 보정 완료 후 저장/완료 버튼 동작 안함
`onResult(final=true)` + `onStatus(done)` 콜백 모두 `mounted=false`로 차단
→ `startProcessing()` 미호출 → LLM 미실행 → `parsedResult == null`
→ `_onSave()` early return.

### 공통 근본 원인: `mounted=false`에서 콜백 전체 차단

로그 근거:
```
onStatus 핸들러 진입: notListening, mounted=false
onStatus 핸들러 진입: done, mounted=false
```

현재 구조에서 STT 콜백은 `_MicButtonState`에 등록됨.
`_MicButtonState`는 `RecordingState.done` 전환 시 `_buildCenterButton()`이
`MicButton → _RoundButton`으로 교체되어 dispose됨.
그런데 STT `done` 콜백이 도달하기 전에 이미 dispose된 상태가 발생함.

현재 코드의 문제:
```dart
// mic_button.dart — onResult
if (!mounted) return;          // ← Provider 업데이트도 모두 차단
sttNotifier.update(text);      //   실행 안 됨
notifier.startProcessing();    //   실행 안 됨

// mic_button.dart — onStatus
if (!mounted) return;          // ← startProcessing도 차단
notifier.startProcessing();    //   실행 안 됨
```

---

## 리팩토링 목표

STT 콜백 처리 로직을 `_MicButtonState` (Presentation 레이어) 에서
`SttCallbackHandler` (Application 레이어) 로 이동.

- `_MicButtonState`는 버튼 탭 이벤트 + 애니메이션(pulse ring)만 담당
- STT 결과 처리, 상태 전환, 자동 재시작 로직은 위젯 lifecycle과 무관한 Provider에서 처리
- `mounted=false` 문제 원천 차단

---

## 시나리오별 프로세스 흐름 (리팩토링 후)

### 시나리오 A: 정상 녹음 → LLM 처리 → 저장

```
[사용자: 마이크 버튼 탭]
_MicButtonState._onTap()
  └─ state == idle
       ├─ sttService.initialize() → 권한 획득
       ├─ handler.startSession()  ← SttCallbackHandler에 세션 위임
       │    └─ sttService.startListening(onResult: handler._onResult, ...)
       ├─ notifier.startRecording()
       └─ _startPulse()

[STT 엔진: 중간 결과 도착]
SttCallbackHandler._onResult(text="안녕", isFinal=false)
  └─ sttTextNotifier.update("안녕")  ← UI 즉시 갱신 (mounted 무관)

[STT 엔진: 최종 결과 도착]
SttCallbackHandler._onResult(text="안녕하세요", isFinal=true)
  ├─ sttTextNotifier.update("안녕하세요")
  └─ diaryRecordNotifier.startProcessing()  ← LLM 흐름 트리거

[ref.listen → processing 감지]
DiaryRecordScreen._runLLMFlow("안녕하세요")
  └─ LLM 스트리밍 → appendChunk → finalize → finishRecording → done

[사용자: 저장 버튼 탭]
_onSave()
  ├─ parsedResult != null → DiaryEntry 생성
  └─ diaryList.addEntry() → context.go(diaryList)
```

### 시나리오 B: Samsung STT 자동 종료 → 자동 재시작

```
[STT 엔진: 짧은 침묵 후 자동 종료]
SttCallbackHandler._onStatus(status="done")
  ├─ currentState == recording (상태 확인)
  ├─ currentText.isEmpty
  └─ 자동 재시작: 300ms 후 sttService.startListening() 재호출
       └─ (시나리오 A로 이어짐)
```

### 시나리오 C: Samsung STT 자동 종료 + 부분 결과 있음 → LLM 처리

```
[STT 엔진: 중간 결과 후 자동 종료]
SttCallbackHandler._onStatus(status="done")
  ├─ currentState == recording
  ├─ currentText.isNotEmpty ("안녕하세요")
  └─ diaryRecordNotifier.startProcessing()
       └─ LLM 흐름 (시나리오 A의 processing 단계로 이어짐)
```

### 시나리오 D: 사용자 수동 중지 (■ 버튼 탭)

```
[사용자: 중지 버튼 탭]
_onFinishRecording()
  ├─ handler.cancelSession()   ← 자동 재시작 방지 플래그 설정
  ├─ sttService.stopListening()
  └─ notifier.startProcessing()
```

### 시나리오 E: 삭제/재녹음

```
[사용자: 삭제 버튼 탭]
_onDelete()
  ├─ handler.cancelSession()
  ├─ sttService.cancelListening()
  ├─ diaryRecordNotifier.reset()
  ├─ sttTextNotifier.clear()
  └─ diaryProcessNotifier.reset()
```

### 시나리오 F: STT 오류 (permanent)

```
[STT 엔진: permanent 오류]
SttCallbackHandler._onError(permanent=true)
  ├─ currentText.isNotEmpty → startProcessing()
  └─ currentText.isEmpty    → setError()
```

---

## 변경 파일 목록

| 파일 | 변경 내용 |
|------|-----------|
| `lib/features/diary/application/diary_record_provider.dart` | `SttCallbackHandler` 추가 (새 클래스) |
| `lib/features/diary/presentation/widgets/mic_button.dart` | `_beginListening()` 제거, handler 위임으로 교체 |
| `lib/features/diary/presentation/screens/diary_record_screen.dart` | `_onDelete`, `_finishRecordingAsync`에 cancelSession 추가 |
| `lib/features/diary/application/diary_record_provider.g.dart` | build_runner 재생성 |

---

## 꼭지 1: `SttCallbackHandler` 구현

**파일**: `lib/features/diary/application/diary_record_provider.dart`

`SttCallbackHandler` 클래스를 파일 맨 아래에 추가한다.
`@Riverpod(keepAlive: true)`로 선언하여 위젯 lifecycle과 무관하게 유지.

```dart
/// STT 콜백을 처리하는 Application 레이어 핸들러.
/// _MicButtonState와 무관하게 Provider에서 직접 상태를 전환한다.
@Riverpod(keepAlive: true)
class SttCallbackHandler extends _$SttCallbackHandler {
  bool _isAutoRestarting = false;
  bool _isCancelled = false;

  @override
  void build() {}

  /// STT 세션을 시작하고 콜백을 자신에게 바인딩한다.
  Future<void> startSession() async {
    _isAutoRestarting = false;
    _isCancelled = false;

    final sttService = ref.read(speechToTextServiceProvider);
    await sttService.startListening(
      onResult: _onResult,
      onAmplitude: _onAmplitude,
      onError: _onError,
      onStatus: _onStatus,
    );
  }

  /// 세션을 명시적으로 취소한다 (자동 재시작 방지).
  void cancelSession() {
    _isCancelled = true;
    _isAutoRestarting = false;
  }

  void _onResult(String text, bool isFinal) {
    if (_isCancelled) return;
    final sttNotifier = ref.read(sttTextNotifierProvider.notifier);
    final notifier = ref.read(diaryRecordNotifierProvider.notifier);

    if (text.isNotEmpty) {
      sttNotifier.update(text);
    }
    if (isFinal && text.isNotEmpty) {
      notifier.startProcessing();
    }
  }

  void _onAmplitude(double amp) {
    if (_isCancelled) return;
    ref.read(amplitudesNotifierProvider.notifier).add(amp);
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

    final currentText = ref.read(sttTextNotifierProvider);
    if (currentText.isNotEmpty) {
      ref.read(diaryRecordNotifierProvider.notifier).startProcessing();
    } else if (!_isAutoRestarting) {
      _isAutoRestarting = true;
      AppLogger.info('STT done (결과 없음) → 자동 재시작');
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

build_runner 실행:
```bash
cd voicelog_ai && dart run build_runner build --delete-conflicting-outputs
```

커밋 메시지:
```
feat(stt): SttCallbackHandler Application 레이어 추가

STT 콜백 처리 로직을 _MicButtonState에서 분리.
keepAlive Provider로 선언하여 위젯 lifecycle과 무관하게
상태 전환 및 자동 재시작을 처리한다.
```

---

## 꼭지 2: `_MicButtonState` 단순화 + Screen 연동

### mic_button.dart

**제거할 코드**
- `bool _isAutoRestarting = false;` 인스턴스 변수 (line 29)
- `_beginListening()` 메서드 전체 (line 70~137)

**수정할 코드: `_onTap()`**

```dart
Future<void> _onTap() async {
  final state = ref.read(diaryRecordNotifierProvider);
  final sttService = ref.read(speechToTextServiceProvider);
  final notifier = ref.read(diaryRecordNotifierProvider.notifier);
  final handler = ref.read(sttCallbackHandlerProvider.notifier);

  try {
    if (state == RecordingState.idle) {
      final granted = await sttService.initialize();
      if (!mounted) return;
      if (!granted) return;

      notifier.startRecording();
      _startPulse();
      await handler.startSession();
    } else if (state == RecordingState.recording) {
      handler.cancelSession();
      await sttService.stopListening();
      notifier.startProcessing();
      _stopPulse();
    }
  } catch (e) {
    notifier.setError();
    _stopPulse();
  }
}
```

### diary_record_screen.dart — `_onDelete()`

```dart
void _onDelete() {
  _inferenceTimer?.cancel();
  ref.read(sttCallbackHandlerProvider.notifier).cancelSession();  // ← 추가
  if (ref.read(diaryRecordNotifierProvider) == RecordingState.processing) {
    ref.read(llmInferenceServiceProvider).dispose();
  }
  try {
    ref.read(speechToTextServiceProvider).cancelListening();
  } catch (_) {}
  ref.read(diaryRecordNotifierProvider.notifier).reset();
  ref.read(sttTextNotifierProvider.notifier).clear();
  ref.read(diaryProcessNotifierProvider.notifier).reset();
  ref.read(amplitudesNotifierProvider.notifier).clear();
  _stopTimer();
  setState(() => _elapsedSeconds = 0);
}
```

### diary_record_screen.dart — `_finishRecordingAsync()`

```dart
Future<void> _finishRecordingAsync() async {
  final sttService = ref.read(speechToTextServiceProvider);
  final notifier = ref.read(diaryRecordNotifierProvider.notifier);
  ref.read(sttCallbackHandlerProvider.notifier).cancelSession();  // ← 추가
  try {
    await sttService.stopListening();
    notifier.startProcessing();
  } catch (e) {
    AppLogger.error('STT 중지 실패', e);
    notifier.setError();
  }
}
```

커밋 메시지:
```
refactor(mic): _MicButtonState STT 콜백 로직 제거 — handler 위임으로 교체

_beginListening(), _isAutoRestarting 제거.
_onTap()은 버튼 탭 이벤트 + pulse 애니메이션만 담당.
STT 결과 처리는 SttCallbackHandler에서 전담.
_onDelete, _finishRecordingAsync에 cancelSession 추가.
```

---

## 꼭지 3: 실기기 검증

실기기(Samsung Galaxy S23 FE)에서 아래 시나리오를 순서대로 테스트한다.

### 체크리스트

- [ ] **이슈 1**: 말하는 동안 글래스 컨테이너에 STT 텍스트가 실시간으로 표시됨
- [ ] **이슈 2**: 짧게 말한 뒤 침묵 → 자동 재시작 로그 출력 → 계속 녹음 가능
  - 로그: `SttCallbackHandler onStatus: done` → `STT done (결과 없음) → 자동 재시작`
- [ ] **이슈 3**: 보정 완료(done) 상태에서 저장 버튼 탭 → 일기 목록으로 이동
- [ ] 말하다가 ■ 중지 버튼 탭 → processing → LLM 결과 표시
- [ ] 삭제 버튼 탭 → idle 상태 복귀

### 예상 정상 로그 흐름

```
[INFO] SttCallbackHandler onStatus: listening
[INFO] STT onResult: words="안녕하세요" final=false
[INFO] STT onResult: words="안녕하세요 오늘은" final=false
...
[INFO] STT onResult: words="안녕하세요 오늘은 좋은 날씨네요" final=true
[INFO] SttCallbackHandler onStatus: done
→ startProcessing() 호출 → LLM 흐름 시작
```

자동 재시작 시나리오:
```
[INFO] SttCallbackHandler onStatus: done
[INFO] STT done (결과 없음) → 자동 재시작
[INFO] SttCallbackHandler onStatus: listening
[INFO] STT onResult: words="계속 말할게요" final=false
...
```

---

## 관련 파일 경로

| 파일 | 역할 | 변경 여부 |
|------|------|-----------|
| `lib/features/diary/application/diary_record_provider.dart` | **SttCallbackHandler 추가** | 수정 |
| `lib/features/diary/application/diary_record_provider.g.dart` | build_runner 생성 파일 | 재생성 |
| `lib/features/diary/presentation/widgets/mic_button.dart` | **_beginListening 제거**, handler 위임 | 수정 |
| `lib/features/diary/presentation/screens/diary_record_screen.dart` | `_onDelete`, `_finishRecordingAsync` cancelSession 추가 | 수정 |

---

## 성공 판단 기준

1. 말하는 동안 글래스 컨테이너에 텍스트 실시간 표시
2. 짧게 말하고 침묵해도 STT가 계속 대기 (자동 재시작)
3. 보정 완료 후 저장 버튼 → 일기 목록 이동
4. `mounted=false` 관련 콜백 차단 로그 미발생
