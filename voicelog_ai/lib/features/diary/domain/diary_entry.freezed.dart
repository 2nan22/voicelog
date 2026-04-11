// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diary_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DiaryEntry _$DiaryEntryFromJson(Map<String, dynamic> json) {
  return _DiaryEntry.fromJson(json);
}

/// @nodoc
mixin _$DiaryEntry {
  int get id => throw _privateConstructorUsedError;
  String get rawText => throw _privateConstructorUsedError;
  String get correctedText => throw _privateConstructorUsedError;
  String get emotion => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DiaryEntryCopyWith<DiaryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiaryEntryCopyWith<$Res> {
  factory $DiaryEntryCopyWith(
          DiaryEntry value, $Res Function(DiaryEntry) then) =
      _$DiaryEntryCopyWithImpl<$Res, DiaryEntry>;
  @useResult
  $Res call(
      {int id,
      String rawText,
      String correctedText,
      String emotion,
      List<String> tags,
      DateTime createdAt});
}

/// @nodoc
class _$DiaryEntryCopyWithImpl<$Res, $Val extends DiaryEntry>
    implements $DiaryEntryCopyWith<$Res> {
  _$DiaryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rawText = null,
    Object? correctedText = null,
    Object? emotion = null,
    Object? tags = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      rawText: null == rawText
          ? _value.rawText
          : rawText // ignore: cast_nullable_to_non_nullable
              as String,
      correctedText: null == correctedText
          ? _value.correctedText
          : correctedText // ignore: cast_nullable_to_non_nullable
              as String,
      emotion: null == emotion
          ? _value.emotion
          : emotion // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiaryEntryImplCopyWith<$Res>
    implements $DiaryEntryCopyWith<$Res> {
  factory _$$DiaryEntryImplCopyWith(
          _$DiaryEntryImpl value, $Res Function(_$DiaryEntryImpl) then) =
      __$$DiaryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String rawText,
      String correctedText,
      String emotion,
      List<String> tags,
      DateTime createdAt});
}

/// @nodoc
class __$$DiaryEntryImplCopyWithImpl<$Res>
    extends _$DiaryEntryCopyWithImpl<$Res, _$DiaryEntryImpl>
    implements _$$DiaryEntryImplCopyWith<$Res> {
  __$$DiaryEntryImplCopyWithImpl(
      _$DiaryEntryImpl _value, $Res Function(_$DiaryEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rawText = null,
    Object? correctedText = null,
    Object? emotion = null,
    Object? tags = null,
    Object? createdAt = null,
  }) {
    return _then(_$DiaryEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      rawText: null == rawText
          ? _value.rawText
          : rawText // ignore: cast_nullable_to_non_nullable
              as String,
      correctedText: null == correctedText
          ? _value.correctedText
          : correctedText // ignore: cast_nullable_to_non_nullable
              as String,
      emotion: null == emotion
          ? _value.emotion
          : emotion // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiaryEntryImpl implements _DiaryEntry {
  const _$DiaryEntryImpl(
      {required this.id,
      required this.rawText,
      required this.correctedText,
      required this.emotion,
      required final List<String> tags,
      required this.createdAt})
      : _tags = tags;

  factory _$DiaryEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiaryEntryImplFromJson(json);

  @override
  final int id;
  @override
  final String rawText;
  @override
  final String correctedText;
  @override
  final String emotion;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'DiaryEntry(id: $id, rawText: $rawText, correctedText: $correctedText, emotion: $emotion, tags: $tags, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiaryEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rawText, rawText) || other.rawText == rawText) &&
            (identical(other.correctedText, correctedText) ||
                other.correctedText == correctedText) &&
            (identical(other.emotion, emotion) || other.emotion == emotion) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, rawText, correctedText,
      emotion, const DeepCollectionEquality().hash(_tags), createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DiaryEntryImplCopyWith<_$DiaryEntryImpl> get copyWith =>
      __$$DiaryEntryImplCopyWithImpl<_$DiaryEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiaryEntryImplToJson(
      this,
    );
  }
}

abstract class _DiaryEntry implements DiaryEntry {
  const factory _DiaryEntry(
      {required final int id,
      required final String rawText,
      required final String correctedText,
      required final String emotion,
      required final List<String> tags,
      required final DateTime createdAt}) = _$DiaryEntryImpl;

  factory _DiaryEntry.fromJson(Map<String, dynamic> json) =
      _$DiaryEntryImpl.fromJson;

  @override
  int get id;
  @override
  String get rawText;
  @override
  String get correctedText;
  @override
  String get emotion;
  @override
  List<String> get tags;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$DiaryEntryImplCopyWith<_$DiaryEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
