// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiaryEntryImpl _$$DiaryEntryImplFromJson(Map<String, dynamic> json) =>
    _$DiaryEntryImpl(
      id: (json['id'] as num).toInt(),
      rawText: json['rawText'] as String,
      title: json['title'] as String,
      emotion: json['emotion'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      people: (json['people'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      places: (json['places'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      correctedText: json['correctedText'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$DiaryEntryImplToJson(_$DiaryEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rawText': instance.rawText,
      'title': instance.title,
      'emotion': instance.emotion,
      'tags': instance.tags,
      'people': instance.people,
      'places': instance.places,
      'correctedText': instance.correctedText,
      'createdAt': instance.createdAt.toIso8601String(),
    };
