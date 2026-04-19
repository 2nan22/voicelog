// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diary_process_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DiaryProcessState {
  LlmPhase get phase => throw _privateConstructorUsedError;
  String get rawAccumulated => throw _privateConstructorUsedError;
  LlmMetadataResult? get metadataResult => throw _privateConstructorUsedError;
  String? get correctedText => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DiaryProcessStateCopyWith<DiaryProcessState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiaryProcessStateCopyWith<$Res> {
  factory $DiaryProcessStateCopyWith(
          DiaryProcessState value, $Res Function(DiaryProcessState) then) =
      _$DiaryProcessStateCopyWithImpl<$Res, DiaryProcessState>;
  @useResult
  $Res call(
      {LlmPhase phase,
      String rawAccumulated,
      LlmMetadataResult? metadataResult,
      String? correctedText});

  $LlmMetadataResultCopyWith<$Res>? get metadataResult;
}

/// @nodoc
class _$DiaryProcessStateCopyWithImpl<$Res, $Val extends DiaryProcessState>
    implements $DiaryProcessStateCopyWith<$Res> {
  _$DiaryProcessStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phase = null,
    Object? rawAccumulated = null,
    Object? metadataResult = freezed,
    Object? correctedText = freezed,
  }) {
    return _then(_value.copyWith(
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as LlmPhase,
      rawAccumulated: null == rawAccumulated
          ? _value.rawAccumulated
          : rawAccumulated // ignore: cast_nullable_to_non_nullable
              as String,
      metadataResult: freezed == metadataResult
          ? _value.metadataResult
          : metadataResult // ignore: cast_nullable_to_non_nullable
              as LlmMetadataResult?,
      correctedText: freezed == correctedText
          ? _value.correctedText
          : correctedText // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $LlmMetadataResultCopyWith<$Res>? get metadataResult {
    if (_value.metadataResult == null) {
      return null;
    }

    return $LlmMetadataResultCopyWith<$Res>(_value.metadataResult!, (value) {
      return _then(_value.copyWith(metadataResult: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DiaryProcessStateImplCopyWith<$Res>
    implements $DiaryProcessStateCopyWith<$Res> {
  factory _$$DiaryProcessStateImplCopyWith(_$DiaryProcessStateImpl value,
          $Res Function(_$DiaryProcessStateImpl) then) =
      __$$DiaryProcessStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {LlmPhase phase,
      String rawAccumulated,
      LlmMetadataResult? metadataResult,
      String? correctedText});

  @override
  $LlmMetadataResultCopyWith<$Res>? get metadataResult;
}

/// @nodoc
class __$$DiaryProcessStateImplCopyWithImpl<$Res>
    extends _$DiaryProcessStateCopyWithImpl<$Res, _$DiaryProcessStateImpl>
    implements _$$DiaryProcessStateImplCopyWith<$Res> {
  __$$DiaryProcessStateImplCopyWithImpl(_$DiaryProcessStateImpl _value,
      $Res Function(_$DiaryProcessStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phase = null,
    Object? rawAccumulated = null,
    Object? metadataResult = freezed,
    Object? correctedText = freezed,
  }) {
    return _then(_$DiaryProcessStateImpl(
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as LlmPhase,
      rawAccumulated: null == rawAccumulated
          ? _value.rawAccumulated
          : rawAccumulated // ignore: cast_nullable_to_non_nullable
              as String,
      metadataResult: freezed == metadataResult
          ? _value.metadataResult
          : metadataResult // ignore: cast_nullable_to_non_nullable
              as LlmMetadataResult?,
      correctedText: freezed == correctedText
          ? _value.correctedText
          : correctedText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$DiaryProcessStateImpl implements _DiaryProcessState {
  const _$DiaryProcessStateImpl(
      {this.phase = LlmPhase.idle,
      this.rawAccumulated = '',
      this.metadataResult,
      this.correctedText});

  @override
  @JsonKey()
  final LlmPhase phase;
  @override
  @JsonKey()
  final String rawAccumulated;
  @override
  final LlmMetadataResult? metadataResult;
  @override
  final String? correctedText;

  @override
  String toString() {
    return 'DiaryProcessState(phase: $phase, rawAccumulated: $rawAccumulated, metadataResult: $metadataResult, correctedText: $correctedText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiaryProcessStateImpl &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.rawAccumulated, rawAccumulated) ||
                other.rawAccumulated == rawAccumulated) &&
            (identical(other.metadataResult, metadataResult) ||
                other.metadataResult == metadataResult) &&
            (identical(other.correctedText, correctedText) ||
                other.correctedText == correctedText));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, phase, rawAccumulated, metadataResult, correctedText);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DiaryProcessStateImplCopyWith<_$DiaryProcessStateImpl> get copyWith =>
      __$$DiaryProcessStateImplCopyWithImpl<_$DiaryProcessStateImpl>(
          this, _$identity);
}

abstract class _DiaryProcessState implements DiaryProcessState {
  const factory _DiaryProcessState(
      {final LlmPhase phase,
      final String rawAccumulated,
      final LlmMetadataResult? metadataResult,
      final String? correctedText}) = _$DiaryProcessStateImpl;

  @override
  LlmPhase get phase;
  @override
  String get rawAccumulated;
  @override
  LlmMetadataResult? get metadataResult;
  @override
  String? get correctedText;
  @override
  @JsonKey(ignore: true)
  _$$DiaryProcessStateImplCopyWith<_$DiaryProcessStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
