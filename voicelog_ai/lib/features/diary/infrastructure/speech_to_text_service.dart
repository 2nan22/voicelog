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
  /// [onAmplitude]: 마이크 음량 레벨 콜백 (0.0 ~ 1.0 정규화)
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    void Function(double amplitude)? onAmplitude,
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
      onSoundLevelChange: onAmplitude == null
          ? null
          : (double level) {
              // level: -2.0 ~ 10.0 (dB 상대값) → 0.0 ~ 1.0 정규화
              final normalized = ((level + 2.0) / 12.0).clamp(0.0, 1.0);
              onAmplitude(normalized);
            },
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
