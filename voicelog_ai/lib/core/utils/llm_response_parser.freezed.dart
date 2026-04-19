// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'llm_response_parser.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LlmMetadataResult {
  String get title => throw _privateConstructorUsedError;
  String get emotion => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  List<String> get people => throw _privateConstructorUsedError;
  List<String> get places => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LlmMetadataResultCopyWith<LlmMetadataResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LlmMetadataResultCopyWith<$Res> {
  factory $LlmMetadataResultCopyWith(
          LlmMetadataResult value, $Res Function(LlmMetadataResult) then) =
      _$LlmMetadataResultCopyWithImpl<$Res, LlmMetadataResult>;
  @useResult
  $Res call(
      {String title,
      String emotion,
      List<String> tags,
      List<String> people,
      List<String> places});
}

/// @nodoc
class _$LlmMetadataResultCopyWithImpl<$Res, $Val extends LlmMetadataResult>
    implements $LlmMetadataResultCopyWith<$Res> {
  _$LlmMetadataResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? emotion = null,
    Object? tags = null,
    Object? people = null,
    Object? places = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      emotion: null == emotion
          ? _value.emotion
          : emotion // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      people: null == people
          ? _value.people
          : people // ignore: cast_nullable_to_non_nullable
              as List<String>,
      places: null == places
          ? _value.places
          : places // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LlmMetadataResultImplCopyWith<$Res>
    implements $LlmMetadataResultCopyWith<$Res> {
  factory _$$LlmMetadataResultImplCopyWith(_$LlmMetadataResultImpl value,
          $Res Function(_$LlmMetadataResultImpl) then) =
      __$$LlmMetadataResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String emotion,
      List<String> tags,
      List<String> people,
      List<String> places});
}

/// @nodoc
class __$$LlmMetadataResultImplCopyWithImpl<$Res>
    extends _$LlmMetadataResultCopyWithImpl<$Res, _$LlmMetadataResultImpl>
    implements _$$LlmMetadataResultImplCopyWith<$Res> {
  __$$LlmMetadataResultImplCopyWithImpl(_$LlmMetadataResultImpl _value,
      $Res Function(_$LlmMetadataResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? emotion = null,
    Object? tags = null,
    Object? people = null,
    Object? places = null,
  }) {
    return _then(_$LlmMetadataResultImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      emotion: null == emotion
          ? _value.emotion
          : emotion // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      people: null == people
          ? _value._people
          : people // ignore: cast_nullable_to_non_nullable
              as List<String>,
      places: null == places
          ? _value._places
          : places // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$LlmMetadataResultImpl implements _LlmMetadataResult {
  const _$LlmMetadataResultImpl(
      {required this.title,
      required this.emotion,
      required final List<String> tags,
      required final List<String> people,
      required final List<String> places})
      : _tags = tags,
        _people = people,
        _places = places;

  @override
  final String title;
  @override
  final String emotion;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<String> _people;
  @override
  List<String> get people {
    if (_people is EqualUnmodifiableListView) return _people;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_people);
  }

  final List<String> _places;
  @override
  List<String> get places {
    if (_places is EqualUnmodifiableListView) return _places;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_places);
  }

  @override
  String toString() {
    return 'LlmMetadataResult(title: $title, emotion: $emotion, tags: $tags, people: $people, places: $places)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LlmMetadataResultImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.emotion, emotion) || other.emotion == emotion) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(other._people, _people) &&
            const DeepCollectionEquality().equals(other._places, _places));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      emotion,
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_people),
      const DeepCollectionEquality().hash(_places));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LlmMetadataResultImplCopyWith<_$LlmMetadataResultImpl> get copyWith =>
      __$$LlmMetadataResultImplCopyWithImpl<_$LlmMetadataResultImpl>(
          this, _$identity);
}

abstract class _LlmMetadataResult implements LlmMetadataResult {
  const factory _LlmMetadataResult(
      {required final String title,
      required final String emotion,
      required final List<String> tags,
      required final List<String> people,
      required final List<String> places}) = _$LlmMetadataResultImpl;

  @override
  String get title;
  @override
  String get emotion;
  @override
  List<String> get tags;
  @override
  List<String> get people;
  @override
  List<String> get places;
  @override
  @JsonKey(ignore: true)
  _$$LlmMetadataResultImplCopyWith<_$LlmMetadataResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
