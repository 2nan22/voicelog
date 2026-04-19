// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_entry_document.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDiaryEntryDocumentCollection on Isar {
  IsarCollection<DiaryEntryDocument> get diaryEntryDocuments =>
      this.collection();
}

const DiaryEntryDocumentSchema = CollectionSchema(
  name: r'DiaryEntryDocument',
  id: 863059995185405619,
  properties: {
    r'correctedText': PropertySchema(
      id: 0,
      name: r'correctedText',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'emotion': PropertySchema(
      id: 2,
      name: r'emotion',
      type: IsarType.string,
    ),
    r'people': PropertySchema(
      id: 3,
      name: r'people',
      type: IsarType.stringList,
    ),
    r'places': PropertySchema(
      id: 4,
      name: r'places',
      type: IsarType.stringList,
    ),
    r'rawText': PropertySchema(
      id: 5,
      name: r'rawText',
      type: IsarType.string,
    ),
    r'tags': PropertySchema(
      id: 6,
      name: r'tags',
      type: IsarType.stringList,
    ),
    r'title': PropertySchema(
      id: 7,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _diaryEntryDocumentEstimateSize,
  serialize: _diaryEntryDocumentSerialize,
  deserialize: _diaryEntryDocumentDeserialize,
  deserializeProp: _diaryEntryDocumentDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _diaryEntryDocumentGetId,
  getLinks: _diaryEntryDocumentGetLinks,
  attach: _diaryEntryDocumentAttach,
  version: '3.1.0+1',
);

int _diaryEntryDocumentEstimateSize(
  DiaryEntryDocument object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.correctedText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.emotion.length * 3;
  bytesCount += 3 + object.people.length * 3;
  {
    for (var i = 0; i < object.people.length; i++) {
      final value = object.people[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.places.length * 3;
  {
    for (var i = 0; i < object.places.length; i++) {
      final value = object.places[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.rawText.length * 3;
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _diaryEntryDocumentSerialize(
  DiaryEntryDocument object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.correctedText);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.emotion);
  writer.writeStringList(offsets[3], object.people);
  writer.writeStringList(offsets[4], object.places);
  writer.writeString(offsets[5], object.rawText);
  writer.writeStringList(offsets[6], object.tags);
  writer.writeString(offsets[7], object.title);
}

DiaryEntryDocument _diaryEntryDocumentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DiaryEntryDocument();
  object.correctedText = reader.readStringOrNull(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.emotion = reader.readString(offsets[2]);
  object.id = id;
  object.people = reader.readStringList(offsets[3]) ?? [];
  object.places = reader.readStringList(offsets[4]) ?? [];
  object.rawText = reader.readString(offsets[5]);
  object.tags = reader.readStringList(offsets[6]) ?? [];
  object.title = reader.readString(offsets[7]);
  return object;
}

P _diaryEntryDocumentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _diaryEntryDocumentGetId(DiaryEntryDocument object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _diaryEntryDocumentGetLinks(
    DiaryEntryDocument object) {
  return [];
}

void _diaryEntryDocumentAttach(
    IsarCollection<dynamic> col, Id id, DiaryEntryDocument object) {
  object.id = id;
}

extension DiaryEntryDocumentQueryWhereSort
    on QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QWhere> {
  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DiaryEntryDocumentQueryWhere
    on QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QWhereClause> {
  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DiaryEntryDocumentQueryFilter
    on QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QFilterCondition> {
  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      correctedTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'correctedText',
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      correctedTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'correctedText',
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      correctedTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      correctedTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correctedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      correctedTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correctedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      correctedTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correctedText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      correctedTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'correctedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      correctedTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'correctedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      correctedTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'correctedText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      correctedTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'correctedText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      correctedTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correctedText',
        value: '',
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      correctedTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'correctedText',
        value: '',
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      emotionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emotion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      emotionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'emotion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      emotionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'emotion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      emotionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'emotion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      emotionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'emotion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      emotionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'emotion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      emotionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'emotion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      emotionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'emotion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      emotionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emotion',
        value: '',
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      emotionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'emotion',
        value: '',
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      peopleElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'people',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      peopleElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'people',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      peopleElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'people',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      peopleElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'people',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      peopleElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'people',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      peopleElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'people',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      peopleElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'people',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      peopleElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'people',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      peopleElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'people',
        value: '',
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      peopleElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'people',
        value: '',
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      peopleLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'people',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      peopleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'people',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      peopleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'people',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      peopleLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'people',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      peopleLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'people',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      peopleLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'people',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      placesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'places',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      placesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'places',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      placesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'places',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      placesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'places',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      placesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'places',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      placesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'places',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      placesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'places',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      placesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'places',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      placesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'places',
        value: '',
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      placesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'places',
        value: '',
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      placesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'places',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      placesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'places',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      placesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'places',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      placesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'places',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      placesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'places',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      placesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'places',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      rawTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      rawTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      rawTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      rawTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rawText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      rawTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      rawTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      rawTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rawText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      rawTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rawText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      rawTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawText',
        value: '',
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      rawTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rawText',
        value: '',
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      tagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      tagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      tagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      tagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      tagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension DiaryEntryDocumentQueryObject
    on QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QFilterCondition> {}

extension DiaryEntryDocumentQueryLinks
    on QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QFilterCondition> {}

extension DiaryEntryDocumentQuerySortBy
    on QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QSortBy> {
  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      sortByCorrectedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedText', Sort.asc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      sortByCorrectedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedText', Sort.desc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      sortByEmotion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emotion', Sort.asc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      sortByEmotionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emotion', Sort.desc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      sortByRawText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawText', Sort.asc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      sortByRawTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawText', Sort.desc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension DiaryEntryDocumentQuerySortThenBy
    on QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QSortThenBy> {
  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      thenByCorrectedText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedText', Sort.asc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      thenByCorrectedTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correctedText', Sort.desc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      thenByEmotion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emotion', Sort.asc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      thenByEmotionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emotion', Sort.desc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      thenByRawText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawText', Sort.asc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      thenByRawTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawText', Sort.desc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension DiaryEntryDocumentQueryWhereDistinct
    on QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QDistinct> {
  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QDistinct>
      distinctByCorrectedText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correctedText',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QDistinct>
      distinctByEmotion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emotion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QDistinct>
      distinctByPeople() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'people');
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QDistinct>
      distinctByPlaces() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'places');
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QDistinct>
      distinctByRawText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QDistinct>
      distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension DiaryEntryDocumentQueryProperty
    on QueryBuilder<DiaryEntryDocument, DiaryEntryDocument, QQueryProperty> {
  QueryBuilder<DiaryEntryDocument, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DiaryEntryDocument, String?, QQueryOperations>
      correctedTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correctedText');
    });
  }

  QueryBuilder<DiaryEntryDocument, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DiaryEntryDocument, String, QQueryOperations> emotionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emotion');
    });
  }

  QueryBuilder<DiaryEntryDocument, List<String>, QQueryOperations>
      peopleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'people');
    });
  }

  QueryBuilder<DiaryEntryDocument, List<String>, QQueryOperations>
      placesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'places');
    });
  }

  QueryBuilder<DiaryEntryDocument, String, QQueryOperations> rawTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawText');
    });
  }

  QueryBuilder<DiaryEntryDocument, List<String>, QQueryOperations>
      tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<DiaryEntryDocument, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
