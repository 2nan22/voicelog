import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:voicelog_ai/core/utils/logger.dart';
import 'package:voicelog_ai/features/diary/application/diary_repository_provider.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';

part 'diary_list_provider.g.dart';

/// 날짜(연·월·일만) → 해당 날의 DiaryEntry 목록 맵.
/// 캘린더 이벤트 마커 및 선택 날짜 목록에 사용.
@riverpod
Future<Map<DateTime, List<DiaryEntry>>> diaryByDate(DiaryByDateRef ref) async {
  final entries = await ref.watch(diaryListNotifierProvider.future);
  final map = <DateTime, List<DiaryEntry>>{};
  for (final e in entries) {
    final day = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
    map.putIfAbsent(day, () => []).add(e);
  }
  return map;
}

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

  Future<void> updateEntry(DiaryEntry entry) async {
    try {
      final repo = await ref.read(diaryRepositoryProvider.future);
      await repo.save(entry);
      ref.invalidateSelf();
    } catch (e) {
      AppLogger.error('일기 업데이트 실패', e);
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
