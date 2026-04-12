import 'package:voicelog_ai/features/diary/domain/i_llm_inference_service.dart';

class MockLlmInferenceService implements ILlmInferenceService {
  String mockResponse = '''
[보정본] 오늘은 즐거운 하루였다.
[감정] 기쁨
[태그] #산책, #친구, #날씨
  ''';

  bool _isReady = false;

  @override
  bool get isReady => _isReady;

  @override
  Future<void> initialize() async => _isReady = true;

  @override
  Stream<String> generateStream(String prompt) async* {
    if (!_isReady) {
      yield* Stream.error(StateError('initialize()를 먼저 호출해야 합니다.'));
      return;
    }
    for (final chunk in mockResponse.split(' ')) {
      yield '$chunk ';
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  @override
  Future<String> generate(String prompt) async {
    if (!_isReady) throw StateError('initialize()를 먼저 호출해야 합니다.');
    return mockResponse;
  }

  @override
  void dispose() => _isReady = false;
}
