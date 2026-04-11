import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:voicelog_ai/core/constants/prompts.dart';
import 'package:voicelog_ai/features/diary/domain/i_llm_inference_service.dart';
import 'package:voicelog_ai/features/diary/infrastructure/llm_inference_service.dart';

part 'llm_provider.g.dart';

/// LLM 서비스 싱글톤 Provider (앱 생명주기 동안 유지).
///
/// [MediaPipeLlmInferenceService]를 [ILlmInferenceService]로 제공한다.
/// [ref.onDispose]에서 자동으로 [ILlmInferenceService.dispose]를 호출한다.
@Riverpod(keepAlive: true)
ILlmInferenceService llmInferenceService(LlmInferenceServiceRef ref) {
  final service = MediaPipeLlmInferenceService();
  ref.onDispose(service.dispose);
  return service;
}

/// LLM 모델 초기화(warm-up) Provider.
///
/// SplashScreen에서 watch하여 앱 시작 시 1회 모델을 로드한다.
/// 완료 시 AsyncData<void>, 실패 시 AsyncError를 emit한다.
@Riverpod(keepAlive: true)
Future<void> llmWarmUp(LlmWarmUpRef ref) async {
  final service = ref.watch(llmInferenceServiceProvider);
  await service.initialize();
}

/// STT 원문 텍스트 → LLM 스트리밍 응답 Provider.
///
/// [rawText]를 프롬프트 템플릿에 치환하여 [ILlmInferenceService.generateStream]에 전달한다.
/// 스트림 구독 취소 시 스트리밍이 중단된다.
@riverpod
Stream<String> llmStream(LlmStreamRef ref, String rawText) {
  final service = ref.watch(llmInferenceServiceProvider);
  if (!service.isReady) {
    return Stream.error(
      StateError('LLM 서비스가 아직 준비되지 않았습니다. warm-up을 먼저 완료하세요.'),
    );
  }
  final prompt = kDiaryProcessingPrompt.replaceAll('{raw_text}', rawText);
  return service.generateStream(prompt);
}
