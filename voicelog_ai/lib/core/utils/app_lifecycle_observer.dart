import 'package:flutter/material.dart';

import 'package:voicelog_ai/core/utils/logger.dart';
import 'package:voicelog_ai/features/diary/domain/i_llm_inference_service.dart';

/// 앱 백그라운드 진입 시 LLM 세션을 즉시 해제하는 생명주기 옵저버.
///
/// [AppLifecycleState.paused] 감지 → [ILlmInferenceService.dispose] 호출.
/// [VoicelogApp]의 initState/dispose에서 [WidgetsBinding]에 등록·해제한다.
class AppLifecycleObserver extends WidgetsBindingObserver {
  AppLifecycleObserver(this._llmService);

  final ILlmInferenceService _llmService;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AppLogger.info('앱 백그라운드 진입 → LLM 세션 해제');
      _llmService.dispose();
    }
  }
}
