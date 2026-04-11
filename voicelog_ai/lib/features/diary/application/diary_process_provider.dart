import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:voicelog_ai/core/utils/llm_response_parser.dart';

part 'diary_process_provider.freezed.dart';
part 'diary_process_provider.g.dart';

/// LLM 스트리밍 처리 상태.
///
/// [rawAccumulated]: 스트리밍 중 LLM 출력 누적 원문
/// [parsedResult]: [태그] 섹션 감지 후 또는 finalize() 호출 시 파싱된 결과
@freezed
class DiaryProcessState with _$DiaryProcessState {
  const factory DiaryProcessState({
    @Default('') String rawAccumulated,
    LlmParsedResult? parsedResult,
  }) = _DiaryProcessState;
}

/// LLM 스트림 청크를 누적하고 파싱 결과를 보유하는 Notifier.
///
/// 사용 흐름:
/// 1. [reset] — 처리 시작 전 초기화
/// 2. [appendChunk] — 스트리밍 청크마다 호출
/// 3. [finalize] — 스트림 완료 후 최종 파싱 (스트림 중 [태그] 미감지 시 fallback)
@riverpod
class DiaryProcessNotifier extends _$DiaryProcessNotifier {
  @override
  DiaryProcessState build() => const DiaryProcessState();

  /// 스트리밍 청크를 누적한다. [태그] 섹션 감지 시 즉시 파싱한다.
  void appendChunk(String chunk) {
    final newRaw = state.rawAccumulated + chunk;
    if (newRaw.contains('[태그]')) {
      state = state.copyWith(
        rawAccumulated: newRaw,
        parsedResult: LlmResponseParser.parse(newRaw),
      );
    } else {
      state = state.copyWith(rawAccumulated: newRaw);
    }
  }

  /// 스트림 완료 후 전체 누적 텍스트를 파싱한다.
  void finalize() {
    state = state.copyWith(
      parsedResult: LlmResponseParser.parse(state.rawAccumulated),
    );
  }

  /// 상태를 초기화한다.
  void reset() => state = const DiaryProcessState();
}
