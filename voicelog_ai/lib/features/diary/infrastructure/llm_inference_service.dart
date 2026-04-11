import 'dart:io';

import 'package:mediapipe_genai/mediapipe_genai.dart';
import 'package:path_provider/path_provider.dart';

import 'package:voicelog_ai/core/utils/logger.dart';
import 'package:voicelog_ai/features/diary/domain/i_llm_inference_service.dart';

/// MediaPipe LLM 추론 서비스 구현체.
///
/// 플랫폼별 Delegate 전략:
/// - Android : GPU(Adreno) 우선 → CPU fallback
/// - iOS     : GPU(Metal)  우선 → CPU fallback
/// - 기타    : CPU
///
/// mediapipe_genai 0.0.1 기준으로 작성되었습니다.
/// API 변경 시 [LlmInferenceOptions] 팩토리 생성자 파라미터를 재검토하세요.
class MediaPipeLlmInferenceService implements ILlmInferenceService {
  LlmInferenceEngine? _engine;
  bool _isReady = false;

  /// 추론 모델 파일명 (INT4 양자화 CPU 최적화 버전).
  static const String _modelFileName = 'gemma-2b-it-cpu-int4.bin';
  static const String _modelsSubDir = 'models';

  @override
  bool get isReady => _isReady;

  @override
  Future<void> initialize() async {
    if (_isReady) return; // 중복 초기화 방지

    final modelPath = await _getModelPath();
    await _initWithFallback(modelPath);
  }

  /// GPU delegate를 먼저 시도하고, 실패 시 CPU로 fallback한다.
  Future<void> _initWithFallback(String modelPath) async {
    final bool tryGpu = Platform.isAndroid || Platform.isIOS;

    if (tryGpu) {
      try {
        // Android: Adreno GPU / iOS: Metal GPU
        _engine = LlmInferenceEngine(
          LlmInferenceOptions.gpu(
            modelPath: modelPath,
            // maxTokens, topK 등 추가 파라미터는 mediapipe_genai API 업데이트에 따라 조정
          ),
        );
        _isReady = true;
        AppLogger.info('LLM 초기화 완료 (GPU delegate, platform: ${Platform.operatingSystem})');
        return;
      } catch (e) {
        // GPU 초기화 실패는 흔한 케이스 — CPU fallback 진행
        AppLogger.warn('GPU delegate 초기화 실패, CPU fallback 시도: $e');
      }
    }

    // CPU fallback
    try {
      _engine = LlmInferenceEngine(
        LlmInferenceOptions.cpu(
          modelPath: modelPath,
        ),
      );
      _isReady = true;
      AppLogger.info('LLM 초기화 완료 (CPU fallback)');
    } catch (e) {
      AppLogger.error('LLM CPU fallback 초기화 실패', e);
      rethrow;
    }
  }

  /// 모델 파일의 절대 경로를 반환한다.
  ///
  /// 경로: `{ApplicationDocumentsDirectory}/models/gemma-2b-it-cpu-int4.bin`
  /// 모델 파일은 앱 최초 실행 시 다운로드 후 이 위치에 저장된다.
  Future<String> _getModelPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_modelsSubDir/$_modelFileName';
  }

  @override
  Stream<String> generateStream(String prompt) {
    if (!_isReady || _engine == null) {
      return Stream.error(
        StateError('LLM 서비스가 초기화되지 않았습니다. initialize()를 먼저 호출하세요.'),
      );
    }
    return _engine!.generateResponse(prompt);
  }

  @override
  Future<String> generate(String prompt) async {
    if (!_isReady || _engine == null) {
      throw StateError('LLM 서비스가 초기화되지 않았습니다. initialize()를 먼저 호출하세요.');
    }
    final buffer = StringBuffer();
    await for (final chunk in _engine!.generateResponse(prompt)) {
      buffer.write(chunk);
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    // mediapipe_genai 0.0.1 에서 LlmInferenceEngine 명시적 close() 미확인.
    // 엔진 참조를 null로 해제하여 GC 처리. API 업데이트 시 close() 호출 추가 검토.
    _engine = null;
    _isReady = false;
    AppLogger.info('LLM 세션 해제 완료');
  }
}
