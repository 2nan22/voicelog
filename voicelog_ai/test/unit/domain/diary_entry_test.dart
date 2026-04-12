import 'package:flutter_test/flutter_test.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';

void main() {
  group('DiaryEntry', () {
    test('DiaryEntry.create() — createdAt이 현재 시각으로 설정됨', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final entry = DiaryEntry.create(
        rawText: '원문',
        correctedText: '보정본',
        emotion: '기쁨',
        tags: ['#태그1'],
      );
      expect(entry.createdAt.isAfter(before), isTrue);
      expect(entry.rawText, '원문');
      expect(entry.emotion, '기쁨');
    });

    test('DiaryEntry.create() — id는 -1로 설정됨 (DB 저장 전)', () {
      final entry = DiaryEntry.create(
        rawText: '원문',
        correctedText: '보정본',
        emotion: '평온',
        tags: [],
      );
      expect(entry.id, -1);
    });

    test('copyWith으로 emotion 변경', () {
      final entry = DiaryEntry.create(
        rawText: '원문',
        correctedText: '보정본',
        emotion: '기쁨',
        tags: [],
      );
      final updated = entry.copyWith(emotion: '슬픔');
      expect(updated.emotion, '슬픔');
      expect(updated.rawText, '원문'); // 나머지는 유지
    });

    test('copyWith으로 tags 변경', () {
      final entry = DiaryEntry.create(
        rawText: '원문',
        correctedText: '보정본',
        emotion: '기쁨',
        tags: ['#기존'],
      );
      final updated = entry.copyWith(tags: ['#새태그1', '#새태그2']);
      expect(updated.tags, ['#새태그1', '#새태그2']);
      expect(updated.emotion, '기쁨'); // 나머지는 유지
    });
  });
}
