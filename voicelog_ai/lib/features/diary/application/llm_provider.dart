import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:voicelog_ai/features/diary/domain/i_llm_inference_service.dart';
import 'package:voicelog_ai/features/diary/infrastructure/llm_inference_service.dart';

part 'llm_provider.g.dart';

/// LLM 서비스 싱글톤 Provider (앱 생명주기 동안 유지).
@Riverpod(keepAlive: true)
ILlmInferenceService llmInferenceService(LlmInferenceServiceRef ref) {
  final service = MethodChannelLlmInferenceService();
  ref.onDispose(service.dispose);
  return service;
}

/// LLM 모델 초기화(warm-up) Provider.
///
/// SplashScreen에서 watch하여 앱 시작 시 1회 모델을 로드한다.
@Riverpod(keepAlive: true)
Future<void> llmWarmUp(LlmWarmUpRef ref) async {
  final service = ref.watch(llmInferenceServiceProvider);
  await service.initialize();
}
