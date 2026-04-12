// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_document.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingsDocumentCollection on Isar {
  IsarCollection<AppSettingsDocument> get appSettingsDocuments =>
      this.collection();
}

const AppSettingsDocumentSchema = CollectionSchema(
  name: r'AppSettingsDocument',
  id: -4072782798708323131,
  properties: {
    r'isDarkMode': PropertySchema(
      id: 0,
      name: r'isDarkMode',
      type: IsarType.bool,
    )
  },
  estimateSize: _appSettingsDocumentEstimateSize,
  serialize: _appSettingsDocumentSerialize,
  deserialize: _appSettingsDocumentDeserialize,
  deserializeProp: _appSettingsDocumentDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appSettingsDocumentGetId,
  getLinks: _appSettingsDocumentGetLinks,
  attach: _appSettingsDocumentAttach,
  version: '3.1.0+1',
);

int _appSettingsDocumentEstimateSize(
  AppSettingsDocument object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _appSettingsDocumentSerialize(
  AppSettingsDocument object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isDarkMode);
}

AppSettingsDocument _appSettingsDocumentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettingsDocument();
  object.id = id;
  object.isDarkMode = reader.readBool(offsets[0]);
  return object;
}

P _appSettingsDocumentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appSettingsDocumentGetId(AppSettingsDocument object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appSettingsDocumentGetLinks(
    AppSettingsDocument object) {
  return [];
}

void _appSettingsDocumentAttach(
    IsarCollection<dynamic> col, Id id, AppSettingsDocument object) {
  object.id = id;
}

extension AppSettingsDocumentQueryWhereSort
    on QueryBuilder<AppSettingsDocument, AppSettingsDocument, QWhere> {
  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingsDocumentQueryWhere
    on QueryBuilder<AppSettingsDocument, AppSettingsDocument, QWhereClause> {
  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QAfterWhereClause>
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

  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QAfterWhereClause>
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

extension AppSettingsDocumentQueryFilter on QueryBuilder<AppSettingsDocument,
    AppSettingsDocument, QFilterCondition> {
  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QAfterFilterCondition>
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

  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QAfterFilterCondition>
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

  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QAfterFilterCondition>
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

  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QAfterFilterCondition>
      isDarkModeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDarkMode',
        value: value,
      ));
    });
  }
}

extension AppSettingsDocumentQueryObject on QueryBuilder<AppSettingsDocument,
    AppSettingsDocument, QFilterCondition> {}

extension AppSettingsDocumentQueryLinks on QueryBuilder<AppSettingsDocument,
    AppSettingsDocument, QFilterCondition> {}

extension AppSettingsDocumentQuerySortBy
    on QueryBuilder<AppSettingsDocument, AppSettingsDocument, QSortBy> {
  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QAfterSortBy>
      sortByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QAfterSortBy>
      sortByIsDarkModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.desc);
    });
  }
}

extension AppSettingsDocumentQuerySortThenBy
    on QueryBuilder<AppSettingsDocument, AppSettingsDocument, QSortThenBy> {
  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QAfterSortBy>
      thenByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QAfterSortBy>
      thenByIsDarkModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDarkMode', Sort.desc);
    });
  }
}

extension AppSettingsDocumentQueryWhereDistinct
    on QueryBuilder<AppSettingsDocument, AppSettingsDocument, QDistinct> {
  QueryBuilder<AppSettingsDocument, AppSettingsDocument, QDistinct>
      distinctByIsDarkMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDarkMode');
    });
  }
}

extension AppSettingsDocumentQueryProperty
    on QueryBuilder<AppSettingsDocument, AppSettingsDocument, QQueryProperty> {
  QueryBuilder<AppSettingsDocument, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppSettingsDocument, bool, QQueryOperations>
      isDarkModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDarkMode');
    });
  }
}
