import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';
import 'package:voicelog_ai/features/diary/application/diary_repository_provider.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';
import '../../mocks/mock_diary_repository.dart';

void main() {
  group('DiaryListNotifier', () {
    late ProviderContainer container;
    late MockDiaryRepository mockRepo;

    setUp(() {
      mockRepo = MockDiaryRepository();
      container = ProviderContainer(
        overrides: [
          diaryRepositoryProvider.overrideWith((_) async => mockRepo),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('초기 상태 — 빈 목록 반환', () async {
      final entries = await container.read(diaryListNotifierProvider.future);
      expect(entries, isEmpty);
    });

    test('addEntry 후 목록에 항목 추가됨', () async {
      final notifier = container.read(diaryListNotifierProvider.notifier);
      final entry = DiaryEntry.create(
        rawText: '원문',
        correctedText: '보정본',
        emotion: '기쁨',
        tags: ['#태그'],
      );

      await notifier.addEntry(entry);

      final entries = await container.read(diaryListNotifierProvider.future);
      expect(entries, contains(entry));
    });

    test('deleteEntry 후 목록에서 항목 제거됨', () async {
      // 먼저 저장
      const testId = 42;
      final entry = DiaryEntry(
        id: testId,
        rawText: '원문',
        correctedText: '보정본',
        emotion: '평온',
        tags: [],
        createdAt: DateTime.now(),
      );
      await mockRepo.save(entry);

      final notifier = container.read(diaryListNotifierProvider.notifier);
      await notifier.deleteEntry(testId);

      final entries = await container.read(diaryListNotifierProvider.future);
      expect(entries.any((e) => e.id == testId), isFalse);
    });
  });
}
