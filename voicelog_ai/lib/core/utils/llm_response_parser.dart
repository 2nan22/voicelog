import 'package:freezed_annotation/freezed_annotation.dart';

part 'llm_response_parser.freezed.dart';

/// 메타데이터 추출 결과
@freezed
class LlmMetadataResult with _$LlmMetadataResult {
  const factory LlmMetadataResult({
    required String title,
    required String emotion,
    required List<String> tags,
    required List<String> people,
    required List<String> places,
  }) = _LlmMetadataResult;
}

class LlmResponseParser {
  LlmResponseParser._();

  /// 메타데이터 추출 응답 파싱. 파싱 실패 시 기본값 반환.
  static LlmMetadataResult parseMetadata(String raw) {
    String extract(String tag) {
      final m = RegExp('\\[$tag\\]\\s*(.+)', dotAll: false).firstMatch(raw);
      return m?.group(1)?.trim() ?? '';
    }

    List<String> toList(String tag) {
      final val = extract(tag);
      if (val.isEmpty || val == '없음') return [];
      return val.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }

    final title = extract('제목');
    return LlmMetadataResult(
      title: title.isEmpty ? '제목 없음' : title,
      emotion: _validEmotion(extract('감정')),
      tags: toList('태그'),
      people: toList('인물'),
      places: toList('장소'),
    );
  }

  /// 보정본 응답 파싱. [보정본] 태그 이후 텍스트 반환.
  static String parseCorrectedText(String raw) {
    final m = RegExp(r'\[보정본\]\s*(.+)', dotAll: true).firstMatch(raw);
    return m?.group(1)?.trim() ?? '';
  }

  static String _validEmotion(String raw) {
    const valid = ['기쁨', '슬픔', '평온', '화남'];
    return valid.contains(raw) ? raw : '평온';
  }
}
