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

/// 마이크 실시간 진폭 버퍼 (WaveformWidget 연동).
///
/// [add]로 최신 진폭값(0.0 ~ 1.0)을 추가하며 최대 40개를 유지한다.
/// 오래된 값은 자동으로 제거되어 슬라이딩 윈도우로 동작한다.
@riverpod
class AmplitudesNotifier extends _$AmplitudesNotifier {
  static const _maxCount = 40;

  @override
  List<double> build() => const [];

  void add(double value) {
    final updated = [...state, value];
    if (updated.length > _maxCount) updated.removeAt(0);
    state = updated;
  }

  void clear() => state = const [];
}
