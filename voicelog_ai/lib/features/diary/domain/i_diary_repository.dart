import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';

/// 일기 저장소 추상 인터페이스.
/// infrastructure 레이어의 Isar 구현체가 이를 구현한다.
abstract class IDiaryRepository {
  Future<List<DiaryEntry>> findAll();
  Future<DiaryEntry?> findById(int id);
  Future<void> save(DiaryEntry entry);
  Future<void> delete(int id);
  Future<void> deleteAll();
}
