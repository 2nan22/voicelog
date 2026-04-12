import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:voicelog_ai/core/utils/logger.dart';
import 'package:voicelog_ai/features/diary/application/diary_repository_provider.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';

part 'diary_list_provider.g.dart';

@riverpod
class DiaryListNotifier extends _$DiaryListNotifier {
  @override
  Future<List<DiaryEntry>> build() async {
    final repo = await ref.watch(diaryRepositoryProvider.future);
    return repo.findAll();
  }

  Future<void> addEntry(DiaryEntry entry) async {
    try {
      final repo = await ref.read(diaryRepositoryProvider.future);
      await repo.save(entry);
      ref.invalidateSelf();
    } catch (e) {
      AppLogger.error('일기 저장 실패', e);
      rethrow;
    }
  }

  Future<void> deleteEntry(int id) async {
    try {
      final repo = await ref.read(diaryRepositoryProvider.future);
      await repo.delete(id);
      ref.invalidateSelf();
    } catch (e) {
      AppLogger.error('일기 삭제 실패', e);
      rethrow;
    }
  }
}
