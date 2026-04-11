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
mixin _$LlmParsedResult {
  String get correctedText => throw _privateConstructorUsedError;
  String get emotion => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LlmParsedResultCopyWith<LlmParsedResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LlmParsedResultCopyWith<$Res> {
  factory $LlmParsedResultCopyWith(
          LlmParsedResult value, $Res Function(LlmParsedResult) then) =
      _$LlmParsedResultCopyWithImpl<$Res, LlmParsedResult>;
  @useResult
  $Res call({String correctedText, String emotion, List<String> tags});
}

/// @nodoc
class _$LlmParsedResultCopyWithImpl<$Res, $Val extends LlmParsedResult>
    implements $LlmParsedResultCopyWith<$Res> {
  _$LlmParsedResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? correctedText = null,
    Object? emotion = null,
    Object? tags = null,
  }) {
    return _then(_value.copyWith(
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LlmParsedResultImplCopyWith<$Res>
    implements $LlmParsedResultCopyWith<$Res> {
  factory _$$LlmParsedResultImplCopyWith(_$LlmParsedResultImpl value,
          $Res Function(_$LlmParsedResultImpl) then) =
      __$$LlmParsedResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String correctedText, String emotion, List<String> tags});
}

/// @nodoc
class __$$LlmParsedResultImplCopyWithImpl<$Res>
    extends _$LlmParsedResultCopyWithImpl<$Res, _$LlmParsedResultImpl>
    implements _$$LlmParsedResultImplCopyWith<$Res> {
  __$$LlmParsedResultImplCopyWithImpl(
      _$LlmParsedResultImpl _value, $Res Function(_$LlmParsedResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? correctedText = null,
    Object? emotion = null,
    Object? tags = null,
  }) {
    return _then(_$LlmParsedResultImpl(
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
    ));
  }
}

/// @nodoc

class _$LlmParsedResultImpl implements _LlmParsedResult {
  const _$LlmParsedResultImpl(
      {required this.correctedText,
      required this.emotion,
      required final List<String> tags})
      : _tags = tags;

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
  String toString() {
    return 'LlmParsedResult(correctedText: $correctedText, emotion: $emotion, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LlmParsedResultImpl &&
            (identical(other.correctedText, correctedText) ||
                other.correctedText == correctedText) &&
            (identical(other.emotion, emotion) || other.emotion == emotion) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @override
  int get hashCode => Object.hash(runtimeType, correctedText, emotion,
      const DeepCollectionEquality().hash(_tags));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LlmParsedResultImplCopyWith<_$LlmParsedResultImpl> get copyWith =>
      __$$LlmParsedResultImplCopyWithImpl<_$LlmParsedResultImpl>(
          this, _$identity);
}

abstract class _LlmParsedResult implements LlmParsedResult {
  const factory _LlmParsedResult(
      {required final String correctedText,
      required final String emotion,
      required final List<String> tags}) = _$LlmParsedResultImpl;

  @override
  String get correctedText;
  @override
  String get emotion;
  @override
  List<String> get tags;
  @override
  @JsonKey(ignore: true)
  _$$LlmParsedResultImplCopyWith<_$LlmParsedResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
