// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model_download_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ModelDownloadState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() checking,
    required TResult Function() exists,
    required TResult Function(String modelPath) missing,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? checking,
    TResult? Function()? exists,
    TResult? Function(String modelPath)? missing,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? checking,
    TResult Function()? exists,
    TResult Function(String modelPath)? missing,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ModelDownloadIdle value) idle,
    required TResult Function(ModelDownloadChecking value) checking,
    required TResult Function(ModelDownloadExists value) exists,
    required TResult Function(ModelDownloadMissing value) missing,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ModelDownloadIdle value)? idle,
    TResult? Function(ModelDownloadChecking value)? checking,
    TResult? Function(ModelDownloadExists value)? exists,
    TResult? Function(ModelDownloadMissing value)? missing,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ModelDownloadIdle value)? idle,
    TResult Function(ModelDownloadChecking value)? checking,
    TResult Function(ModelDownloadExists value)? exists,
    TResult Function(ModelDownloadMissing value)? missing,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModelDownloadStateCopyWith<$Res> {
  factory $ModelDownloadStateCopyWith(
          ModelDownloadState value, $Res Function(ModelDownloadState) then) =
      _$ModelDownloadStateCopyWithImpl<$Res, ModelDownloadState>;
}

/// @nodoc
class _$ModelDownloadStateCopyWithImpl<$Res, $Val extends ModelDownloadState>
    implements $ModelDownloadStateCopyWith<$Res> {
  _$ModelDownloadStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$ModelDownloadIdleImplCopyWith<$Res> {
  factory _$$ModelDownloadIdleImplCopyWith(_$ModelDownloadIdleImpl value,
          $Res Function(_$ModelDownloadIdleImpl) then) =
      __$$ModelDownloadIdleImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ModelDownloadIdleImplCopyWithImpl<$Res>
    extends _$ModelDownloadStateCopyWithImpl<$Res, _$ModelDownloadIdleImpl>
    implements _$$ModelDownloadIdleImplCopyWith<$Res> {
  __$$ModelDownloadIdleImplCopyWithImpl(_$ModelDownloadIdleImpl _value,
      $Res Function(_$ModelDownloadIdleImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ModelDownloadIdleImpl implements ModelDownloadIdle {
  const _$ModelDownloadIdleImpl();

  @override
  String toString() {
    return 'ModelDownloadState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ModelDownloadIdleImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() checking,
    required TResult Function() exists,
    required TResult Function(String modelPath) missing,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? checking,
    TResult? Function()? exists,
    TResult? Function(String modelPath)? missing,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? checking,
    TResult Function()? exists,
    TResult Function(String modelPath)? missing,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ModelDownloadIdle value) idle,
    required TResult Function(ModelDownloadChecking value) checking,
    required TResult Function(ModelDownloadExists value) exists,
    required TResult Function(ModelDownloadMissing value) missing,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ModelDownloadIdle value)? idle,
    TResult? Function(ModelDownloadChecking value)? checking,
    TResult? Function(ModelDownloadExists value)? exists,
    TResult? Function(ModelDownloadMissing value)? missing,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ModelDownloadIdle value)? idle,
    TResult Function(ModelDownloadChecking value)? checking,
    TResult Function(ModelDownloadExists value)? exists,
    TResult Function(ModelDownloadMissing value)? missing,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class ModelDownloadIdle implements ModelDownloadState {
  const factory ModelDownloadIdle() = _$ModelDownloadIdleImpl;
}

/// @nodoc
abstract class _$$ModelDownloadCheckingImplCopyWith<$Res> {
  factory _$$ModelDownloadCheckingImplCopyWith(
          _$ModelDownloadCheckingImpl value,
          $Res Function(_$ModelDownloadCheckingImpl) then) =
      __$$ModelDownloadCheckingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ModelDownloadCheckingImplCopyWithImpl<$Res>
    extends _$ModelDownloadStateCopyWithImpl<$Res, _$ModelDownloadCheckingImpl>
    implements _$$ModelDownloadCheckingImplCopyWith<$Res> {
  __$$ModelDownloadCheckingImplCopyWithImpl(_$ModelDownloadCheckingImpl _value,
      $Res Function(_$ModelDownloadCheckingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ModelDownloadCheckingImpl implements ModelDownloadChecking {
  const _$ModelDownloadCheckingImpl();

  @override
  String toString() {
    return 'ModelDownloadState.checking()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelDownloadCheckingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() checking,
    required TResult Function() exists,
    required TResult Function(String modelPath) missing,
  }) {
    return checking();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? checking,
    TResult? Function()? exists,
    TResult? Function(String modelPath)? missing,
  }) {
    return checking?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? checking,
    TResult Function()? exists,
    TResult Function(String modelPath)? missing,
    required TResult orElse(),
  }) {
    if (checking != null) {
      return checking();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ModelDownloadIdle value) idle,
    required TResult Function(ModelDownloadChecking value) checking,
    required TResult Function(ModelDownloadExists value) exists,
    required TResult Function(ModelDownloadMissing value) missing,
  }) {
    return checking(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ModelDownloadIdle value)? idle,
    TResult? Function(ModelDownloadChecking value)? checking,
    TResult? Function(ModelDownloadExists value)? exists,
    TResult? Function(ModelDownloadMissing value)? missing,
  }) {
    return checking?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ModelDownloadIdle value)? idle,
    TResult Function(ModelDownloadChecking value)? checking,
    TResult Function(ModelDownloadExists value)? exists,
    TResult Function(ModelDownloadMissing value)? missing,
    required TResult orElse(),
  }) {
    if (checking != null) {
      return checking(this);
    }
    return orElse();
  }
}

abstract class ModelDownloadChecking implements ModelDownloadState {
  const factory ModelDownloadChecking() = _$ModelDownloadCheckingImpl;
}

/// @nodoc
abstract class _$$ModelDownloadExistsImplCopyWith<$Res> {
  factory _$$ModelDownloadExistsImplCopyWith(_$ModelDownloadExistsImpl value,
          $Res Function(_$ModelDownloadExistsImpl) then) =
      __$$ModelDownloadExistsImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ModelDownloadExistsImplCopyWithImpl<$Res>
    extends _$ModelDownloadStateCopyWithImpl<$Res, _$ModelDownloadExistsImpl>
    implements _$$ModelDownloadExistsImplCopyWith<$Res> {
  __$$ModelDownloadExistsImplCopyWithImpl(_$ModelDownloadExistsImpl _value,
      $Res Function(_$ModelDownloadExistsImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ModelDownloadExistsImpl implements ModelDownloadExists {
  const _$ModelDownloadExistsImpl();

  @override
  String toString() {
    return 'ModelDownloadState.exists()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelDownloadExistsImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() checking,
    required TResult Function() exists,
    required TResult Function(String modelPath) missing,
  }) {
    return exists();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? checking,
    TResult? Function()? exists,
    TResult? Function(String modelPath)? missing,
  }) {
    return exists?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? checking,
    TResult Function()? exists,
    TResult Function(String modelPath)? missing,
    required TResult orElse(),
  }) {
    if (exists != null) {
      return exists();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ModelDownloadIdle value) idle,
    required TResult Function(ModelDownloadChecking value) checking,
    required TResult Function(ModelDownloadExists value) exists,
    required TResult Function(ModelDownloadMissing value) missing,
  }) {
    return exists(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ModelDownloadIdle value)? idle,
    TResult? Function(ModelDownloadChecking value)? checking,
    TResult? Function(ModelDownloadExists value)? exists,
    TResult? Function(ModelDownloadMissing value)? missing,
  }) {
    return exists?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ModelDownloadIdle value)? idle,
    TResult Function(ModelDownloadChecking value)? checking,
    TResult Function(ModelDownloadExists value)? exists,
    TResult Function(ModelDownloadMissing value)? missing,
    required TResult orElse(),
  }) {
    if (exists != null) {
      return exists(this);
    }
    return orElse();
  }
}

abstract class ModelDownloadExists implements ModelDownloadState {
  const factory ModelDownloadExists() = _$ModelDownloadExistsImpl;
}

/// @nodoc
abstract class _$$ModelDownloadMissingImplCopyWith<$Res> {
  factory _$$ModelDownloadMissingImplCopyWith(_$ModelDownloadMissingImpl value,
          $Res Function(_$ModelDownloadMissingImpl) then) =
      __$$ModelDownloadMissingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String modelPath});
}

/// @nodoc
class __$$ModelDownloadMissingImplCopyWithImpl<$Res>
    extends _$ModelDownloadStateCopyWithImpl<$Res, _$ModelDownloadMissingImpl>
    implements _$$ModelDownloadMissingImplCopyWith<$Res> {
  __$$ModelDownloadMissingImplCopyWithImpl(_$ModelDownloadMissingImpl _value,
      $Res Function(_$ModelDownloadMissingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? modelPath = null,
  }) {
    return _then(_$ModelDownloadMissingImpl(
      modelPath: null == modelPath
          ? _value.modelPath
          : modelPath // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ModelDownloadMissingImpl implements ModelDownloadMissing {
  const _$ModelDownloadMissingImpl({required this.modelPath});

  @override
  final String modelPath;

  @override
  String toString() {
    return 'ModelDownloadState.missing(modelPath: $modelPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelDownloadMissingImpl &&
            (identical(other.modelPath, modelPath) ||
                other.modelPath == modelPath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, modelPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelDownloadMissingImplCopyWith<_$ModelDownloadMissingImpl>
      get copyWith =>
          __$$ModelDownloadMissingImplCopyWithImpl<_$ModelDownloadMissingImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() checking,
    required TResult Function() exists,
    required TResult Function(String modelPath) missing,
  }) {
    return missing(modelPath);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? checking,
    TResult? Function()? exists,
    TResult? Function(String modelPath)? missing,
  }) {
    return missing?.call(modelPath);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? checking,
    TResult Function()? exists,
    TResult Function(String modelPath)? missing,
    required TResult orElse(),
  }) {
    if (missing != null) {
      return missing(modelPath);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ModelDownloadIdle value) idle,
    required TResult Function(ModelDownloadChecking value) checking,
    required TResult Function(ModelDownloadExists value) exists,
    required TResult Function(ModelDownloadMissing value) missing,
  }) {
    return missing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ModelDownloadIdle value)? idle,
    TResult? Function(ModelDownloadChecking value)? checking,
    TResult? Function(ModelDownloadExists value)? exists,
    TResult? Function(ModelDownloadMissing value)? missing,
  }) {
    return missing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ModelDownloadIdle value)? idle,
    TResult Function(ModelDownloadChecking value)? checking,
    TResult Function(ModelDownloadExists value)? exists,
    TResult Function(ModelDownloadMissing value)? missing,
    required TResult orElse(),
  }) {
    if (missing != null) {
      return missing(this);
    }
    return orElse();
  }
}

abstract class ModelDownloadMissing implements ModelDownloadState {
  const factory ModelDownloadMissing({required final String modelPath}) =
      _$ModelDownloadMissingImpl;

  String get modelPath;
  @JsonKey(ignore: true)
  _$$ModelDownloadMissingImplCopyWith<_$ModelDownloadMissingImpl>
      get copyWith => throw _privateConstructorUsedError;
}
