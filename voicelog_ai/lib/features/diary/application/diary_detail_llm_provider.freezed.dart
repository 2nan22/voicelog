// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diary_detail_llm_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DetailLlmState {
  DetailLlmPhase get phase => throw _privateConstructorUsedError;
  String get accumulated => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DetailLlmStateCopyWith<DetailLlmState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetailLlmStateCopyWith<$Res> {
  factory $DetailLlmStateCopyWith(
          DetailLlmState value, $Res Function(DetailLlmState) then) =
      _$DetailLlmStateCopyWithImpl<$Res, DetailLlmState>;
  @useResult
  $Res call({DetailLlmPhase phase, String accumulated});
}

/// @nodoc
class _$DetailLlmStateCopyWithImpl<$Res, $Val extends DetailLlmState>
    implements $DetailLlmStateCopyWith<$Res> {
  _$DetailLlmStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phase = null,
    Object? accumulated = null,
  }) {
    return _then(_value.copyWith(
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as DetailLlmPhase,
      accumulated: null == accumulated
          ? _value.accumulated
          : accumulated // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DetailLlmStateImplCopyWith<$Res>
    implements $DetailLlmStateCopyWith<$Res> {
  factory _$$DetailLlmStateImplCopyWith(_$DetailLlmStateImpl value,
          $Res Function(_$DetailLlmStateImpl) then) =
      __$$DetailLlmStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DetailLlmPhase phase, String accumulated});
}

/// @nodoc
class __$$DetailLlmStateImplCopyWithImpl<$Res>
    extends _$DetailLlmStateCopyWithImpl<$Res, _$DetailLlmStateImpl>
    implements _$$DetailLlmStateImplCopyWith<$Res> {
  __$$DetailLlmStateImplCopyWithImpl(
      _$DetailLlmStateImpl _value, $Res Function(_$DetailLlmStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phase = null,
    Object? accumulated = null,
  }) {
    return _then(_$DetailLlmStateImpl(
      phase: null == phase
          ? _value.phase
          : phase // ignore: cast_nullable_to_non_nullable
              as DetailLlmPhase,
      accumulated: null == accumulated
          ? _value.accumulated
          : accumulated // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DetailLlmStateImpl implements _DetailLlmState {
  const _$DetailLlmStateImpl(
      {this.phase = DetailLlmPhase.idle, this.accumulated = ''});

  @override
  @JsonKey()
  final DetailLlmPhase phase;
  @override
  @JsonKey()
  final String accumulated;

  @override
  String toString() {
    return 'DetailLlmState(phase: $phase, accumulated: $accumulated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DetailLlmStateImpl &&
            (identical(other.phase, phase) || other.phase == phase) &&
            (identical(other.accumulated, accumulated) ||
                other.accumulated == accumulated));
  }

  @override
  int get hashCode => Object.hash(runtimeType, phase, accumulated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DetailLlmStateImplCopyWith<_$DetailLlmStateImpl> get copyWith =>
      __$$DetailLlmStateImplCopyWithImpl<_$DetailLlmStateImpl>(
          this, _$identity);
}

abstract class _DetailLlmState implements DetailLlmState {
  const factory _DetailLlmState(
      {final DetailLlmPhase phase,
      final String accumulated}) = _$DetailLlmStateImpl;

  @override
  DetailLlmPhase get phase;
  @override
  String get accumulated;
  @override
  @JsonKey(ignore: true)
  _$$DetailLlmStateImplCopyWith<_$DetailLlmStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
