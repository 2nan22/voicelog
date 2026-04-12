import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:voicelog_ai/core/constants/prompts.dart';
import 'package:voicelog_ai/core/utils/logger.dart';
import 'package:voicelog_ai/features/diary/domain/i_llm_inference_service.dart';

/// Android MediaPipe Tasks GenAI SDK를 MethodChannel/EventChannel로 브리지한 구현체.
///
/// Flutter의 mediapipe_genai 패키지(Native Assets 의존)를 완전히 대체한다.
/// Android 측 구현: [LlmInferenceChannel.kt]
///
/// MethodChannel  "voicelog/llm"        : initialize, dispose
/// EventChannel   "voicelog/llm_stream" : 토큰 스트리밍
class MethodChannelLlmInferenceService implements ILlmInferenceService {
  static const _method = MethodChannel('voicelog/llm');
  static const _event = EventChannel('voicelog/llm_stream');

  bool _isReady = false;

  @override
  bool get isReady => _isReady;

  @override
  Future<void> initialize() async {
    if (_isReady) return;

    final modelPath = await _getModelPath();

    // 모델 파일 사전 검사
    if (!File(modelPath).existsSync()) {
      AppLogger.error('모델 파일 없음: $modelPath', null);
      throw FileSystemException('모델 파일이 없습니다. 다운로드가 필요합니다.', modelPath);
    }

    try {
      await _method.invokeMethod<void>('initialize', {'modelPath': modelPath});
      _isReady = true;
      AppLogger.info('LLM 초기화 완료 (Android MediaPipe Tasks GenAI)');
    } on PlatformException catch (e) {
      AppLogger.error('LLM 초기화 실패: ${e.code} — ${e.message}', e);
      rethrow;
    }
  }

  @override
  Stream<String> generateStream(String prompt) {
    if (!_isReady) {
      return Stream.error(
        StateError('LLM 서비스가 초기화되지 않았습니다. initialize()를 먼저 호출하세요.'),
      );
    }
    // EventChannel arguments로 prompt를 전달 → Android onListen에서 수신
    return _event
        .receiveBroadcastStream({'prompt': prompt})
        .map((event) => event as String);
  }

  @override
  Future<String> generate(String prompt) async {
    final buffer = StringBuffer();
    await for (final chunk in generateStream(prompt)) {
      buffer.write(chunk);
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    _method.invokeMethod<void>('dispose').catchError((Object e) {
      AppLogger.warn('LLM dispose 오류: $e');
    });
    _isReady = false;
    AppLogger.info('LLM 세션 해제 완료');
  }

  Future<String> _getModelPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$kModelSubDir/$kModelFileName';
  }
}
