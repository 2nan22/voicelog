import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:voicelog_ai/core/utils/llm_response_parser.dart';

part 'diary_process_provider.freezed.dart';
part 'diary_process_provider.g.dart';

enum LlmPhase { idle, metadata, correction, done }

/// LLM 2-phase 처리 상태.
///
/// [phase]: 현재 처리 단계
/// [rawAccumulated]: 현재 스트리밍 중인 LLM 출력 누적 원문
/// [metadataResult]: 메타데이터 추출 완료 시 설정
/// [correctedText]: 보정 완료 시 설정
@freezed
class DiaryProcessState with _$DiaryProcessState {
  const factory DiaryProcessState({
    @Default(LlmPhase.idle) LlmPhase phase,
    @Default('') String rawAccumulated,
    LlmMetadataResult? metadataResult,
    String? correctedText,
  }) = _DiaryProcessState;
}

@riverpod
class DiaryProcessNotifier extends _$DiaryProcessNotifier {
  @override
  DiaryProcessState build() => const DiaryProcessState();

  void startMetadata() => state = state.copyWith(
        phase: LlmPhase.metadata,
        rawAccumulated: '',
      );

  void startCorrection() => state = state.copyWith(
        phase: LlmPhase.correction,
        rawAccumulated: '',
      );

  /// 스트리밍 청크를 누적한다.
  /// 메타데이터 단계에서 [장소] 섹션 감지 시 즉시 파싱한다.
  void appendChunk(String chunk) {
    final newRaw = state.rawAccumulated + chunk;
    if (state.phase == LlmPhase.metadata && newRaw.contains('[장소]')) {
      state = state.copyWith(
        rawAccumulated: newRaw,
        metadataResult: LlmResponseParser.parseMetadata(newRaw),
      );
    } else {
      state = state.copyWith(rawAccumulated: newRaw);
    }
  }

  /// 메타데이터 스트림 완료 후 전체 누적 텍스트를 최종 파싱한다.
  void finalizeMetadata() {
    state = state.copyWith(
      metadataResult: LlmResponseParser.parseMetadata(state.rawAccumulated),
      phase: LlmPhase.done,
    );
  }

  /// 보정 스트림 완료 후 전체 누적 텍스트를 최종 파싱한다.
  void finalizeCorrection() {
    state = state.copyWith(
      correctedText: LlmResponseParser.parseCorrectedText(state.rawAccumulated),
      phase: LlmPhase.done,
    );
  }

  void reset() => state = const DiaryProcessState();
}
