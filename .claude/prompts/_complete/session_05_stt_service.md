# Session 05 — STT 서비스 및 녹음 상태 관리

## 목표
speech_to_text 패키지로 STT 서비스를 구현하고, 녹음 상태를 Riverpod으로 관리한다.
이 세션이 끝나면 마이크 권한 요청 및 음성 인식 시작/중지가 동작한다.

## 참고 규칙 파일
- `.claude/rules/flutter_conventions.md` (async 에러 처리)
- `.claude/rules/state_management.md` (Notifier 패턴)

---

## 꼭지 1 — STT 서비스 클래스 구현

### 작업 내용

1. `lib/features/diary/infrastructure/speech_to_text_service.dart` 작성

   ```dart
   import 'package:speech_to_text/speech_recognition_error.dart';
   import 'package:speech_to_text/speech_to_text.dart';
   import 'package:voicelog_ai/core/utils/logger.dart';

   /// 플랫폼 네이티브 STT 엔진 래퍼.
   /// Android: 네이티브 Speech Recognition
   /// iOS: SFSpeechRecognizer
   class SpeechToTextService {
     final SpeechToText _stt = SpeechToText();
     bool _isInitialized = false;

     bool get isInitialized => _isInitialized;

     /// STT 엔진 초기화 및 권한 요청.
     /// 반환값: 권한 허용 여부
     Future<bool> initialize() async {
       if (_isInitialized) return true;
       try {
         _isInitialized = await _stt.initialize(
           onError: _onError,
           onStatus: (status) => AppLogger.info('STT 상태: $status'),
         );
         return _isInitialized;
       } catch (e) {
         AppLogger.error('STT 초기화 실패', e);
         return false;
       }
     }

     /// 음성 인식 시작.
     /// [onResult]: 인식 결과 콜백 (중간 결과 포함)
     Future<void> startListening({
       required void Function(String text, bool isFinal) onResult,
     }) async {
       if (!_isInitialized) {
         AppLogger.warn('STT가 초기화되지 않았습니다.');
         return;
       }
       await _stt.listen(
         onResult: (result) => onResult(
           result.recognizedWords,
           result.finalResult,
         ),
         localeId: 'ko_KR',
         pauseFor: const Duration(seconds: 3), // 3초 침묵 시 자동 중지
       );
     }

     Future<void> stopListening() async {
       await _stt.stop();
     }

     Future<void> cancelListening() async {
       await _stt.cancel();
     }

     void _onError(SpeechRecognitionError error) {
       AppLogger.error('STT 오류: ${error.errorMsg} (permanent: ${error.permanent})');
     }

     void dispose() {
       _stt.cancel();
     }
   }
   ```

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 1]
feat(diary/infrastructure): SpeechToTextService 구현

- speech_to_text 패키지 기반 네이티브 STT 래퍼
- 초기화/권한 요청, 시작/중지/취소, 에러 로깅
- 한국어(ko_KR) 로케일, 3초 침묵 시 자동 중지

다음 꼭지(Android/iOS 권한 설정)를 진행할까요?
---
```

---

## 꼭지 2 — 플랫폼 권한 설정

### 작업 내용

1. **Android** — `android/app/src/main/AndroidManifest.xml` 수정
   `<uses-permission>` 태그를 `<manifest>` 바로 하위에 추가한다.

   ```xml
   <uses-permission android:name="android.permission.RECORD_AUDIO"/>
   <uses-permission android:name="android.permission.INTERNET"/>
   ```

2. **iOS** — `ios/Runner/Info.plist` 수정
   `<dict>` 내부에 아래 키 추가

   ```xml
   <key>NSSpeechRecognitionUsageDescription</key>
   <string>음성 일기 녹음을 위해 음성 인식 권한이 필요합니다.</string>
   <key>NSMicrophoneUsageDescription</key>
   <string>음성 일기 녹음을 위해 마이크 접근 권한이 필요합니다.</string>
   ```

3. Android 에뮬레이터 또는 실기기에서 `flutter run` 후 마이크 권한 다이얼로그 노출 확인

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 2]
chore: Android/iOS 마이크 및 음성 인식 권한 설정

- AndroidManifest.xml: RECORD_AUDIO, INTERNET 권한 추가
- Info.plist: NSMicrophoneUsageDescription, NSSpeechRecognitionUsageDescription 추가

다음 꼭지(STT Provider + 녹음 상태 Notifier)를 진행할까요?
---
```

---

## 꼭지 3 — STT Provider 및 녹음 상태 Notifier

### 작업 내용

1. `lib/features/diary/application/diary_record_provider.dart` 작성

   ```dart
   import 'package:riverpod_annotation/riverpod_annotation.dart';
   import 'package:voicelog_ai/features/diary/infrastructure/speech_to_text_service.dart';

   part 'diary_record_provider.g.dart';

   enum RecordingState { idle, recording, processing, done, error }

   /// STT 서비스 Provider
   @Riverpod(keepAlive: true)
   SpeechToTextService speechToTextService(SpeechToTextServiceRef ref) {
     final service = SpeechToTextService();
     ref.onDispose(service.dispose);
     return service;
   }

   /// 녹음 상태 Notifier
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

   /// STT 인식 텍스트 Notifier (중간 결과 + 최종 결과)
   @riverpod
   class SttTextNotifier extends _$SttTextNotifier {
     @override
     String build() => '';

     void update(String text) => state = text;
     void clear() => state = '';
   }
   ```

2. `build_runner` 실행

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. `flutter analyze` 오류 없음 확인

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 3]
feat(diary/application): STT Provider 및 RecordingState Notifier 구현

- speechToTextServiceProvider: keepAlive STT 서비스
- DiaryRecordNotifier: idle/recording/processing/done/error 상태 관리
- SttTextNotifier: STT 중간·최종 인식 텍스트 상태

Session 05 완료. Session 06으로 넘어가려면 session_06_record_screen.md 파일을 참고하세요.
---
```
