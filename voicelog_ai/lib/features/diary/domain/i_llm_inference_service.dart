/// MediaPipe LLM 추론 서비스 인터페이스.
///
/// 구현체는 [infrastructure/llm_inference_service.dart] 참조.
/// 테스트에서는 이 인터페이스를 Mock으로 대체한다.
abstract class ILlmInferenceService {
  /// 추론 엔진이 초기화되어 사용 가능한지 여부.
  bool get isReady;

  /// 모델을 로드하고 추론 엔진을 초기화한다.
  ///
  /// 이미 초기화된 경우 즉시 반환한다.
  /// 모델 파일이 없거나 초기화에 실패하면 예외를 던진다.
  Future<void> initialize();

  /// [prompt]에 대한 추론 결과를 청크 단위 스트리밍으로 반환한다.
  ///
  /// [isReady]가 false인 경우 [StateError]를 emit하는 에러 스트림을 반환한다.
  Stream<String> generateStream(String prompt);

  /// [prompt]에 대한 추론 결과를 완전히 생성한 후 반환한다.
  ///
  /// [isReady]가 false인 경우 [StateError]를 던진다.
  Future<String> generate(String prompt);

  /// 추론 엔진을 해제하고 메모리를 반환한다.
  ///
  /// 일기 저장 완료 직후 반드시 호출한다.
  /// 해제 후 [generateStream] 또는 [generate] 호출 시 [StateError].
  void dispose();
}
