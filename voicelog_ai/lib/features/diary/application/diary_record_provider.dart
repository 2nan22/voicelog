import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:voicelog_ai/core/utils/logger.dart';
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

/// STT 콜백을 처리하는 Application 레이어 핸들러.
/// _MicButtonState와 무관하게 Provider에서 직접 상태를 전환한다.
@Riverpod(keepAlive: true)
class SttCallbackHandler extends _$SttCallbackHandler {
  bool _isAutoRestarting = false;
  bool _isCancelled = false;

  @override
  void build() {}

  /// STT 세션을 시작하고 콜백을 자신에게 바인딩한다.
  Future<void> startSession() async {
    _isAutoRestarting = false;
    _isCancelled = false;

    final sttService = ref.read(speechToTextServiceProvider);
    await sttService.startListening(
      onResult: _onResult,
      onAmplitude: _onAmplitude,
      onError: _onError,
      onStatus: _onStatus,
    );
  }

  /// 세션을 명시적으로 취소한다 (자동 재시작 방지).
  void cancelSession() {
    _isCancelled = true;
    _isAutoRestarting = false;
  }

  void _onResult(String text, bool isFinal) {
    if (_isCancelled) return;
    final sttNotifier = ref.read(sttTextNotifierProvider.notifier);
    final notifier = ref.read(diaryRecordNotifierProvider.notifier);

    if (text.isNotEmpty) {
      sttNotifier.update(text);
    }
    if (isFinal && text.isNotEmpty) {
      notifier.startProcessing();
    }
  }

  void _onAmplitude(double amp) {
    if (_isCancelled) return;
    ref.read(amplitudesNotifierProvider.notifier).add(amp);
  }

  void _onError(String errorMsg, bool permanent) {
    if (!permanent) return;
    if (_isCancelled) return;

    final notifier = ref.read(diaryRecordNotifierProvider.notifier);
    final currentText = ref.read(sttTextNotifierProvider);
    if (currentText.isNotEmpty) {
      notifier.startProcessing();
    } else {
      notifier.setError();
    }
  }

  Future<void> _onStatus(String status) async {
    AppLogger.info('SttCallbackHandler onStatus: $status');
    if (status != 'done') return;
    if (_isCancelled) return;

    final currentState = ref.read(diaryRecordNotifierProvider);
    if (currentState != RecordingState.recording) return;

    final currentText = ref.read(sttTextNotifierProvider);
    if (currentText.isNotEmpty) {
      ref.read(diaryRecordNotifierProvider.notifier).startProcessing();
    } else if (!_isAutoRestarting) {
      _isAutoRestarting = true;
      AppLogger.info('STT done (결과 없음) → 자동 재시작');
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (_isCancelled) return;
      if (ref.read(diaryRecordNotifierProvider) == RecordingState.recording) {
        _isAutoRestarting = false;
        await startSession();
      }
    }
  }
}
