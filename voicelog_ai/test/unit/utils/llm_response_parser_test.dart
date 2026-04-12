import 'package:flutter_test/flutter_test.dart';
import 'package:voicelog_ai/core/utils/llm_response_parser.dart';

void main() {
  group('LlmResponseParser', () {
    test('정상 응답 — 보정본·감정·태그 파싱', () {
      const response = '''
[보정본] 오늘은 정말 즐거운 하루였다.
[감정] 기쁨
[태그] #산책, #친구, #날씨
      ''';
      final result = LlmResponseParser.parse(response);
      expect(result.correctedText, '오늘은 정말 즐거운 하루였다.');
      expect(result.emotion, '기쁨');
      expect(result.tags, ['#산책', '#친구', '#날씨']);
    });

    test('감정 누락 시 기본값 "평온" 반환', () {
      final result = LlmResponseParser.parse('[보정본] 내용만 있음');
      expect(result.emotion, '평온');
    });

    test('태그 누락 시 빈 목록 반환', () {
      final result = LlmResponseParser.parse('[보정본] 내용\n[감정] 슬픔');
      expect(result.tags, isEmpty);
    });

    test('빈 문자열 입력 — 기본값 반환 (예외 없음)', () {
      final result = LlmResponseParser.parse('');
      expect(result.correctedText, '');
      expect(result.emotion, '평온');
      expect(result.tags, isEmpty);
    });

    test('태그 공백 trim 처리', () {
      final result =
          LlmResponseParser.parse('[태그] #태그1 ,  #태그2 , #태그3');
      expect(result.tags, ['#태그1', '#태그2', '#태그3']);
    });
  });
}
