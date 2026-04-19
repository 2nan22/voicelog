import 'package:isar/isar.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';

part 'diary_entry_document.g.dart';

/// Isar 저장용 스키마 클래스.
/// domain의 DiaryEntry와 분리하여 의존성 방향 규칙을 준수한다.
@Collection()
class DiaryEntryDocument {
  Id id = Isar.autoIncrement;
  late String rawText;
  late String title;
  late String emotion;
  late List<String> tags;
  late List<String> people;
  late List<String> places;
  String? correctedText;
  late DateTime createdAt;

  /// Isar 문서 → 도메인 모델 변환
  DiaryEntry toDomain() => DiaryEntry(
        id: id,
        rawText: rawText,
        title: title.isEmpty ? '제목 없음' : title,
        emotion: emotion.isEmpty ? '평온' : emotion,
        tags: tags,
        people: people,
        places: places,
        correctedText: correctedText?.isEmpty == true ? null : correctedText,
        createdAt: createdAt,
      );

  /// 도메인 모델 → Isar 문서 변환
  static DiaryEntryDocument fromDomain(DiaryEntry entry) {
    final doc = DiaryEntryDocument()
      ..rawText = entry.rawText
      ..title = entry.title
      ..emotion = entry.emotion
      ..tags = entry.tags
      ..people = entry.people
      ..places = entry.places
      ..correctedText = entry.correctedText
      ..createdAt = entry.createdAt;
    if (entry.id > 0) doc.id = entry.id;
    return doc;
  }
}
