import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:voicelog_ai/features/diary/infrastructure/speech_to_text_service.dart';

part 'diary_record_provider.g.dart';

enum RecordingState { idle, recording, processing, done, error }

/// STT 서비스 Provider
@Riverpod(keepAlive: true)
SpeechToTextService speechToTextService(SpeechToTextServiceRef ref) {
  final service = SpeechToTextService();
  ref.onDispose(service.dispose);
  return service;
}

/// 녹음 상태 Notifier
@riverpod
class DiaryRecordNotifier extends _$DiaryRecordNotifier {
  @override
  RecordingState build() => RecordingState.idle;

  void startRecording() => state = RecordingState.recording;
  void startProcessing() => state = RecordingState.processing;
  void finishRecording() => state = RecordingState.done;
  void setError() => state = RecordingState.error;
  void reset() => state = RecordingState.idle;
}

/// STT 인식 텍스트 Notifier (중간 결과 + 최종 결과)
@riverpod
class SttTextNotifier extends _$SttTextNotifier {
  @override
  String build() => '';

  void update(String text) => state = text;
  void clear() => state = '';
}
