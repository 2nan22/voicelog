// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiaryEntryImpl _$$DiaryEntryImplFromJson(Map<String, dynamic> json) =>
    _$DiaryEntryImpl(
      id: (json['id'] as num).toInt(),
      rawText: json['rawText'] as String,
      correctedText: json['correctedText'] as String,
      emotion: json['emotion'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$DiaryEntryImplToJson(_$DiaryEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rawText': instance.rawText,
      'correctedText': instance.correctedText,
      'emotion': instance.emotion,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
    };
