import 'package:isar/isar.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';

part 'diary_entry_document.g.dart';

/// Isar 저장용 스키마 클래스.
/// domain의 DiaryEntry와 분리하여 의존성 방향 규칙을 준수한다.
@Collection()
class DiaryEntryDocument {
  Id id = Isar.autoIncrement;
  late String rawText;
  late String correctedText;
  late String emotion;
  late List<String> tags;
  late DateTime createdAt;

  /// Isar 문서 → 도메인 모델 변환
  DiaryEntry toDomain() => DiaryEntry(
        id: id,
        rawText: rawText,
        correctedText: correctedText,
        emotion: emotion,
        tags: tags,
        createdAt: createdAt,
      );

  /// 도메인 모델 → Isar 문서 변환
  static DiaryEntryDocument fromDomain(DiaryEntry entry) {
    final doc = DiaryEntryDocument()
      ..rawText = entry.rawText
      ..correctedText = entry.correctedText
      ..emotion = entry.emotion
      ..tags = entry.tags
      ..createdAt = entry.createdAt;
    // id가 유효한 경우(기존 항목 업데이트)에만 id를 설정
    if (entry.id > 0) doc.id = entry.id;
    return doc;
  }
}
