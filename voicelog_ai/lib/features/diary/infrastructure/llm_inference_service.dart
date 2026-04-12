import 'dart:io';

import 'package:mediapipe_genai/mediapipe_genai.dart';
import 'package:path_provider/path_provider.dart';

import 'package:voicelog_ai/core/constants/prompts.dart';
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

  // 모델 파일명은 prompts.dart의 kModelFileName / kModelSubDir 상수를 사용한다.

  @override
  bool get isReady => _isReady;

  @override
  Future<void> initialize() async {
    if (_isReady) return; // 중복 초기화 방지

    final modelPath = await _getModelPath();

    // ── 모델 파일 존재 여부 사전 검사 ──────────────────────────────
    // 파일 없이 LlmInferenceEngine을 생성하면 생성자는 성공하지만
    // 실제 추론 시 hang 또는 크래시가 발생한다 (mediapipe_genai 0.0.1 동작).
    // 여기서 명시적으로 확인하여 "모델 없음" 에러를 즉시 반환한다.
    final modelFile = File(modelPath);
    if (!modelFile.existsSync()) {
      AppLogger.error('모델 파일 없음: $modelPath', null);
      throw FileSystemException('모델 파일이 없습니다. 다운로드가 필요합니다.', modelPath);
    }
    // ────────────────────────────────────────────────────────────────

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
            maxTokens: 1024,
            topK: 40,
            temperature: 0.8,
            sequenceBatchSize: 1, // 단일 대화 세션 기준
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

    // CPU fallback — cacheDir: 컴파일된 모델 캐시 저장 경로
    final cacheDir = await _getCacheDir();
    try {
      _engine = LlmInferenceEngine(
        LlmInferenceOptions.cpu(
          modelPath: modelPath,
          cacheDir: cacheDir,
          maxTokens: 1024,
          topK: 40,
          temperature: 0.8,
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
    return '${dir.path}/$kModelSubDir/$kModelFileName';
  }

  /// CPU 모드에서 컴파일된 모델 캐시를 저장할 디렉터리 경로를 반환한다.
  Future<String> _getCacheDir() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$kModelSubDir/cache';
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
    // _engine.dispose()는 내부 _endResponse()를 호출하여 _responseController를 null로 리셋한다.
    // 이를 호출하지 않으면 스트림 중도 취소 후 재호출 시 assertion 에러 발생:
    //   'Should not call generateResponse while previous controller is still active.'
    _engine?.dispose();
    _engine = null;
    _isReady = false;
    AppLogger.info('LLM 세션 해제 완료');
  }
}
