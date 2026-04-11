import 'package:freezed_annotation/freezed_annotation.dart';

part 'llm_response_parser.freezed.dart';

@freezed
class LlmParsedResult with _$LlmParsedResult {
  const factory LlmParsedResult({
    required String correctedText,
    required String emotion,
    required List<String> tags,
  }) = _LlmParsedResult;
}

/// LLM 응답 문자열을 파싱하여 [LlmParsedResult]를 반환한다.
/// 파싱 실패 시 기본값(빈 문자열, '평온', 빈 목록)을 반환한다.
class LlmResponseParser {
  LlmResponseParser._();

  static LlmParsedResult parse(String rawResponse) {
    final correctedMatch =
        RegExp(r'\[보정본\](.*?)(?=\[감정\]|\[태그\]|$)', dotAll: true)
            .firstMatch(rawResponse);
    final emotionMatch =
        RegExp(r'\[감정\]\s*(\S+)').firstMatch(rawResponse);
    final tagsMatch =
        RegExp(r'\[태그\]\s*(.+)').firstMatch(rawResponse);

    return LlmParsedResult(
      correctedText: correctedMatch?.group(1)?.trim() ?? '',
      emotion: emotionMatch?.group(1)?.trim() ?? '평온',
      tags: tagsMatch?.group(1)?.split(',').map((t) => t.trim()).toList() ?? [],
    );
  }
}
