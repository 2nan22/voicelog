import 'package:freezed_annotation/freezed_annotation.dart';

part 'diary_entry.freezed.dart';
part 'diary_entry.g.dart';

/// 일기 도메인 모델. 순수 Dart 불변 객체 (isar 의존성 없음).
@freezed
class DiaryEntry with _$DiaryEntry {
  const factory DiaryEntry({
    required int id,
    required String rawText,
    required String correctedText,
    required String emotion,
    required List<String> tags,
    required DateTime createdAt,
  }) = _DiaryEntry;

  factory DiaryEntry.fromJson(Map<String, dynamic> json) =>
      _$DiaryEntryFromJson(json);

  /// 새 일기 엔트리 생성 팩토리 메서드 (id는 DB 저장 후 부여)
  factory DiaryEntry.create({
    required String rawText,
    required String correctedText,
    required String emotion,
    required List<String> tags,
  }) =>
      DiaryEntry(
        id: -1,
        rawText: rawText,
        correctedText: correctedText,
        emotion: emotion,
        tags: tags,
        createdAt: DateTime.now(),
      );
}
