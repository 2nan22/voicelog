import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';
import 'package:voicelog_ai/features/diary/domain/i_diary_repository.dart';

class MockDiaryRepository implements IDiaryRepository {
  final List<DiaryEntry> _entries = [];

  @override
  Future<List<DiaryEntry>> findAll() async => List.unmodifiable(_entries);

  @override
  Future<DiaryEntry?> findById(int id) async =>
      _entries.where((e) => e.id == id).firstOrNull;

  @override
  Future<void> save(DiaryEntry entry) async => _entries.add(entry);

  @override
  Future<void> delete(int id) async =>
      _entries.removeWhere((e) => e.id == id);

  @override
  Future<void> deleteAll() async => _entries.clear();
}
