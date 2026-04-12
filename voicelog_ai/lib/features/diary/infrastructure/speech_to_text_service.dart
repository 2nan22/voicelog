import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voicelog_ai/core/utils/logger.dart';

/// 플랫폼 네이티브 STT 엔진 래퍼.
/// Android: 네이티브 Speech Recognition
/// iOS: SFSpeechRecognizer
class SpeechToTextService {
  final SpeechToText _stt = SpeechToText();
  bool _isInitialized = false;

  /// startListening() 호출 시 등록되는 오류 콜백.
  /// permanent=true 이면 해당 listen 세션이 완전히 종료된 것이다.
  void Function(String errorMsg, bool permanent)? _listeningErrorCallback;

  /// startListening() 호출 시 등록되는 상태 콜백.
  /// 'listening', 'notListening', 'done' 등의 상태값을 전달한다.
  void Function(String status)? _statusCallback;

  bool get isInitialized => _isInitialized;

  /// STT 엔진 초기화 및 권한 요청.
  /// 반환값: 권한 허용 여부
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _stt.initialize(
        onError: _onError,
        onStatus: (status) {
          AppLogger.info('STT 상태: $status');
          if (status == 'notListening') {
            AppLogger.info('STT notListening — onResult 발생 여부는 콜백 로그 확인');
          }
          _statusCallback?.call(status);
        },
      );
      return _isInitialized;
    } catch (e) {
      AppLogger.error('STT 초기화 실패', e);
      return false;
    }
  }

  /// 음성 인식 시작.
  /// [onResult]: 인식 결과 콜백 (중간 결과 포함)
  /// [onAmplitude]: 마이크 음량 레벨 콜백 (0.0 ~ 1.0 정규화)
  /// [onError]: STT 오류 콜백. permanent=true 이면 세션이 완전히 종료된 것이다.
  /// [onStatus]: STT 상태 변화 콜백. 'listening'·'notListening'·'done' 등을 전달한다.
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    void Function(double amplitude)? onAmplitude,
    void Function(String errorMsg, bool permanent)? onError,
    void Function(String status)? onStatus,
  }) async {
    _listeningErrorCallback = onError;
    _statusCallback = onStatus;
    if (!_isInitialized) {
      AppLogger.warn('STT가 초기화되지 않았습니다.');
      return;
    }
    await _stt.listen(
      onResult: (result) {
        AppLogger.info(
          'STT onResult: words="${result.recognizedWords}" '
          'final=${result.finalResult} '
          'confidence=${result.alternates.firstOrNull?.confidence}',
        );
        onResult(result.recognizedWords, result.finalResult);
      },
      onSoundLevelChange: onAmplitude == null
          ? null
          : (double level) {
              // level: -2.0 ~ 10.0 (dB 상대값) → 0.0 ~ 1.0 정규화
              final normalized = ((level + 2.0) / 12.0).clamp(0.0, 1.0);
              onAmplitude(normalized);
            },
      localeId: 'ko_KR',
      listenFor: const Duration(seconds: 60), // 최대 60초 세션
      pauseFor: const Duration(seconds: 8),   // 8초 침묵 시 자동 중지
      listenOptions: SpeechListenOptions(
        cancelOnError: false,
        listenMode: ListenMode.dictation,     // 연속 받아쓰기 모드 (Samsung 타임아웃 연장)
        partialResults: true,                 // 중간 결과 활성화
      ),
    );
  }

  Future<void> stopListening() async {
    _listeningErrorCallback = null;
    _statusCallback = null;
    await _stt.stop();
  }

  Future<void> cancelListening() async {
    _listeningErrorCallback = null;
    _statusCallback = null;
    await _stt.cancel();
  }

  void _onError(SpeechRecognitionError error) {
    AppLogger.error('STT 오류: ${error.errorMsg} (permanent: ${error.permanent})');
    _listeningErrorCallback?.call(error.errorMsg, error.permanent);
  }

  void dispose() {
    _listeningErrorCallback = null;
    _stt.cancel();
  }
}
