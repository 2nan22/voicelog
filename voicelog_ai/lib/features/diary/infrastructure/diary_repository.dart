import 'package:isar/isar.dart';
import 'package:voicelog_ai/core/utils/logger.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';
import 'package:voicelog_ai/features/diary/domain/i_diary_repository.dart';
import 'package:voicelog_ai/features/diary/infrastructure/diary_entry_document.dart';

class IsarDiaryRepository implements IDiaryRepository {
  IsarDiaryRepository(this._isar);

  final Isar _isar;

  @override
  Future<List<DiaryEntry>> findAll() async {
    final docs = await _isar.diaryEntryDocuments
        .where()
        .sortByCreatedAtDesc()
        .findAll();
    return docs.map((d) => d.toDomain()).toList();
  }

  @override
  Future<DiaryEntry?> findById(int id) async {
    final doc = await _isar.diaryEntryDocuments.get(id);
    return doc?.toDomain();
  }

  @override
  Future<void> save(DiaryEntry entry) async {
    try {
      final doc = DiaryEntryDocument.fromDomain(entry);
      await _isar.writeTxn(() => _isar.diaryEntryDocuments.put(doc));
    } on IsarError catch (e) {
      AppLogger.error('DiaryEntry 저장 실패', e);
      rethrow;
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      await _isar.writeTxn(() => _isar.diaryEntryDocuments.delete(id));
    } on IsarError catch (e) {
      AppLogger.error('DiaryEntry 삭제 실패', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteAll() async {
    await _isar.writeTxn(() => _isar.diaryEntryDocuments.clear());
  }
}
