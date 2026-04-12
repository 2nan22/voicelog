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
    required TResult Function() alreadyExists,
    required TResult Function(
            double progress, int receivedBytes, int totalBytes)
        downloading,
    required TResult Function() done,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? checking,
    TResult? Function()? alreadyExists,
    TResult? Function(double progress, int receivedBytes, int totalBytes)?
        downloading,
    TResult? Function()? done,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? checking,
    TResult Function()? alreadyExists,
    TResult Function(double progress, int receivedBytes, int totalBytes)?
        downloading,
    TResult Function()? done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ModelDownloadIdle value) idle,
    required TResult Function(ModelDownloadChecking value) checking,
    required TResult Function(ModelDownloadAlreadyExists value) alreadyExists,
    required TResult Function(ModelDownloading value) downloading,
    required TResult Function(ModelDownloadDone value) done,
    required TResult Function(ModelDownloadError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ModelDownloadIdle value)? idle,
    TResult? Function(ModelDownloadChecking value)? checking,
    TResult? Function(ModelDownloadAlreadyExists value)? alreadyExists,
    TResult? Function(ModelDownloading value)? downloading,
    TResult? Function(ModelDownloadDone value)? done,
    TResult? Function(ModelDownloadError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ModelDownloadIdle value)? idle,
    TResult Function(ModelDownloadChecking value)? checking,
    TResult Function(ModelDownloadAlreadyExists value)? alreadyExists,
    TResult Function(ModelDownloading value)? downloading,
    TResult Function(ModelDownloadDone value)? done,
    TResult Function(ModelDownloadError value)? error,
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
    required TResult Function() alreadyExists,
    required TResult Function(
            double progress, int receivedBytes, int totalBytes)
        downloading,
    required TResult Function() done,
    required TResult Function(String message) error,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? checking,
    TResult? Function()? alreadyExists,
    TResult? Function(double progress, int receivedBytes, int totalBytes)?
        downloading,
    TResult? Function()? done,
    TResult? Function(String message)? error,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? checking,
    TResult Function()? alreadyExists,
    TResult Function(double progress, int receivedBytes, int totalBytes)?
        downloading,
    TResult Function()? done,
    TResult Function(String message)? error,
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
    required TResult Function(ModelDownloadAlreadyExists value) alreadyExists,
    required TResult Function(ModelDownloading value) downloading,
    required TResult Function(ModelDownloadDone value) done,
    required TResult Function(ModelDownloadError value) error,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ModelDownloadIdle value)? idle,
    TResult? Function(ModelDownloadChecking value)? checking,
    TResult? Function(ModelDownloadAlreadyExists value)? alreadyExists,
    TResult? Function(ModelDownloading value)? downloading,
    TResult? Function(ModelDownloadDone value)? done,
    TResult? Function(ModelDownloadError value)? error,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ModelDownloadIdle value)? idle,
    TResult Function(ModelDownloadChecking value)? checking,
    TResult Function(ModelDownloadAlreadyExists value)? alreadyExists,
    TResult Function(ModelDownloading value)? downloading,
    TResult Function(ModelDownloadDone value)? done,
    TResult Function(ModelDownloadError value)? error,
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
    required TResult Function() alreadyExists,
    required TResult Function(
            double progress, int receivedBytes, int totalBytes)
        downloading,
    required TResult Function() done,
    required TResult Function(String message) error,
  }) {
    return checking();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? checking,
    TResult? Function()? alreadyExists,
    TResult? Function(double progress, int receivedBytes, int totalBytes)?
        downloading,
    TResult? Function()? done,
    TResult? Function(String message)? error,
  }) {
    return checking?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? checking,
    TResult Function()? alreadyExists,
    TResult Function(double progress, int receivedBytes, int totalBytes)?
        downloading,
    TResult Function()? done,
    TResult Function(String message)? error,
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
    required TResult Function(ModelDownloadAlreadyExists value) alreadyExists,
    required TResult Function(ModelDownloading value) downloading,
    required TResult Function(ModelDownloadDone value) done,
    required TResult Function(ModelDownloadError value) error,
  }) {
    return checking(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ModelDownloadIdle value)? idle,
    TResult? Function(ModelDownloadChecking value)? checking,
    TResult? Function(ModelDownloadAlreadyExists value)? alreadyExists,
    TResult? Function(ModelDownloading value)? downloading,
    TResult? Function(ModelDownloadDone value)? done,
    TResult? Function(ModelDownloadError value)? error,
  }) {
    return checking?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ModelDownloadIdle value)? idle,
    TResult Function(ModelDownloadChecking value)? checking,
    TResult Function(ModelDownloadAlreadyExists value)? alreadyExists,
    TResult Function(ModelDownloading value)? downloading,
    TResult Function(ModelDownloadDone value)? done,
    TResult Function(ModelDownloadError value)? error,
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
abstract class _$$ModelDownloadAlreadyExistsImplCopyWith<$Res> {
  factory _$$ModelDownloadAlreadyExistsImplCopyWith(
          _$ModelDownloadAlreadyExistsImpl value,
          $Res Function(_$ModelDownloadAlreadyExistsImpl) then) =
      __$$ModelDownloadAlreadyExistsImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ModelDownloadAlreadyExistsImplCopyWithImpl<$Res>
    extends _$ModelDownloadStateCopyWithImpl<$Res,
        _$ModelDownloadAlreadyExistsImpl>
    implements _$$ModelDownloadAlreadyExistsImplCopyWith<$Res> {
  __$$ModelDownloadAlreadyExistsImplCopyWithImpl(
      _$ModelDownloadAlreadyExistsImpl _value,
      $Res Function(_$ModelDownloadAlreadyExistsImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ModelDownloadAlreadyExistsImpl implements ModelDownloadAlreadyExists {
  const _$ModelDownloadAlreadyExistsImpl();

  @override
  String toString() {
    return 'ModelDownloadState.alreadyExists()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelDownloadAlreadyExistsImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() checking,
    required TResult Function() alreadyExists,
    required TResult Function(
            double progress, int receivedBytes, int totalBytes)
        downloading,
    required TResult Function() done,
    required TResult Function(String message) error,
  }) {
    return alreadyExists();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? checking,
    TResult? Function()? alreadyExists,
    TResult? Function(double progress, int receivedBytes, int totalBytes)?
        downloading,
    TResult? Function()? done,
    TResult? Function(String message)? error,
  }) {
    return alreadyExists?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? checking,
    TResult Function()? alreadyExists,
    TResult Function(double progress, int receivedBytes, int totalBytes)?
        downloading,
    TResult Function()? done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (alreadyExists != null) {
      return alreadyExists();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ModelDownloadIdle value) idle,
    required TResult Function(ModelDownloadChecking value) checking,
    required TResult Function(ModelDownloadAlreadyExists value) alreadyExists,
    required TResult Function(ModelDownloading value) downloading,
    required TResult Function(ModelDownloadDone value) done,
    required TResult Function(ModelDownloadError value) error,
  }) {
    return alreadyExists(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ModelDownloadIdle value)? idle,
    TResult? Function(ModelDownloadChecking value)? checking,
    TResult? Function(ModelDownloadAlreadyExists value)? alreadyExists,
    TResult? Function(ModelDownloading value)? downloading,
    TResult? Function(ModelDownloadDone value)? done,
    TResult? Function(ModelDownloadError value)? error,
  }) {
    return alreadyExists?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ModelDownloadIdle value)? idle,
    TResult Function(ModelDownloadChecking value)? checking,
    TResult Function(ModelDownloadAlreadyExists value)? alreadyExists,
    TResult Function(ModelDownloading value)? downloading,
    TResult Function(ModelDownloadDone value)? done,
    TResult Function(ModelDownloadError value)? error,
    required TResult orElse(),
  }) {
    if (alreadyExists != null) {
      return alreadyExists(this);
    }
    return orElse();
  }
}

abstract class ModelDownloadAlreadyExists implements ModelDownloadState {
  const factory ModelDownloadAlreadyExists() = _$ModelDownloadAlreadyExistsImpl;
}

/// @nodoc
abstract class _$$ModelDownloadingImplCopyWith<$Res> {
  factory _$$ModelDownloadingImplCopyWith(_$ModelDownloadingImpl value,
          $Res Function(_$ModelDownloadingImpl) then) =
      __$$ModelDownloadingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({double progress, int receivedBytes, int totalBytes});
}

/// @nodoc
class __$$ModelDownloadingImplCopyWithImpl<$Res>
    extends _$ModelDownloadStateCopyWithImpl<$Res, _$ModelDownloadingImpl>
    implements _$$ModelDownloadingImplCopyWith<$Res> {
  __$$ModelDownloadingImplCopyWithImpl(_$ModelDownloadingImpl _value,
      $Res Function(_$ModelDownloadingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? progress = null,
    Object? receivedBytes = null,
    Object? totalBytes = null,
  }) {
    return _then(_$ModelDownloadingImpl(
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      receivedBytes: null == receivedBytes
          ? _value.receivedBytes
          : receivedBytes // ignore: cast_nullable_to_non_nullable
              as int,
      totalBytes: null == totalBytes
          ? _value.totalBytes
          : totalBytes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ModelDownloadingImpl implements ModelDownloading {
  const _$ModelDownloadingImpl(
      {required this.progress,
      required this.receivedBytes,
      required this.totalBytes});

  @override
  final double progress;
// 0.0 ~ 1.0
  @override
  final int receivedBytes;
  @override
  final int totalBytes;

  @override
  String toString() {
    return 'ModelDownloadState.downloading(progress: $progress, receivedBytes: $receivedBytes, totalBytes: $totalBytes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelDownloadingImpl &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.receivedBytes, receivedBytes) ||
                other.receivedBytes == receivedBytes) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, progress, receivedBytes, totalBytes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelDownloadingImplCopyWith<_$ModelDownloadingImpl> get copyWith =>
      __$$ModelDownloadingImplCopyWithImpl<_$ModelDownloadingImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() checking,
    required TResult Function() alreadyExists,
    required TResult Function(
            double progress, int receivedBytes, int totalBytes)
        downloading,
    required TResult Function() done,
    required TResult Function(String message) error,
  }) {
    return downloading(progress, receivedBytes, totalBytes);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? checking,
    TResult? Function()? alreadyExists,
    TResult? Function(double progress, int receivedBytes, int totalBytes)?
        downloading,
    TResult? Function()? done,
    TResult? Function(String message)? error,
  }) {
    return downloading?.call(progress, receivedBytes, totalBytes);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? checking,
    TResult Function()? alreadyExists,
    TResult Function(double progress, int receivedBytes, int totalBytes)?
        downloading,
    TResult Function()? done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (downloading != null) {
      return downloading(progress, receivedBytes, totalBytes);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ModelDownloadIdle value) idle,
    required TResult Function(ModelDownloadChecking value) checking,
    required TResult Function(ModelDownloadAlreadyExists value) alreadyExists,
    required TResult Function(ModelDownloading value) downloading,
    required TResult Function(ModelDownloadDone value) done,
    required TResult Function(ModelDownloadError value) error,
  }) {
    return downloading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ModelDownloadIdle value)? idle,
    TResult? Function(ModelDownloadChecking value)? checking,
    TResult? Function(ModelDownloadAlreadyExists value)? alreadyExists,
    TResult? Function(ModelDownloading value)? downloading,
    TResult? Function(ModelDownloadDone value)? done,
    TResult? Function(ModelDownloadError value)? error,
  }) {
    return downloading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ModelDownloadIdle value)? idle,
    TResult Function(ModelDownloadChecking value)? checking,
    TResult Function(ModelDownloadAlreadyExists value)? alreadyExists,
    TResult Function(ModelDownloading value)? downloading,
    TResult Function(ModelDownloadDone value)? done,
    TResult Function(ModelDownloadError value)? error,
    required TResult orElse(),
  }) {
    if (downloading != null) {
      return downloading(this);
    }
    return orElse();
  }
}

abstract class ModelDownloading implements ModelDownloadState {
  const factory ModelDownloading(
      {required final double progress,
      required final int receivedBytes,
      required final int totalBytes}) = _$ModelDownloadingImpl;

  double get progress; // 0.0 ~ 1.0
  int get receivedBytes;
  int get totalBytes;
  @JsonKey(ignore: true)
  _$$ModelDownloadingImplCopyWith<_$ModelDownloadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ModelDownloadDoneImplCopyWith<$Res> {
  factory _$$ModelDownloadDoneImplCopyWith(_$ModelDownloadDoneImpl value,
          $Res Function(_$ModelDownloadDoneImpl) then) =
      __$$ModelDownloadDoneImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ModelDownloadDoneImplCopyWithImpl<$Res>
    extends _$ModelDownloadStateCopyWithImpl<$Res, _$ModelDownloadDoneImpl>
    implements _$$ModelDownloadDoneImplCopyWith<$Res> {
  __$$ModelDownloadDoneImplCopyWithImpl(_$ModelDownloadDoneImpl _value,
      $Res Function(_$ModelDownloadDoneImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ModelDownloadDoneImpl implements ModelDownloadDone {
  const _$ModelDownloadDoneImpl();

  @override
  String toString() {
    return 'ModelDownloadState.done()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ModelDownloadDoneImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() checking,
    required TResult Function() alreadyExists,
    required TResult Function(
            double progress, int receivedBytes, int totalBytes)
        downloading,
    required TResult Function() done,
    required TResult Function(String message) error,
  }) {
    return done();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? checking,
    TResult? Function()? alreadyExists,
    TResult? Function(double progress, int receivedBytes, int totalBytes)?
        downloading,
    TResult? Function()? done,
    TResult? Function(String message)? error,
  }) {
    return done?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? checking,
    TResult Function()? alreadyExists,
    TResult Function(double progress, int receivedBytes, int totalBytes)?
        downloading,
    TResult Function()? done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (done != null) {
      return done();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ModelDownloadIdle value) idle,
    required TResult Function(ModelDownloadChecking value) checking,
    required TResult Function(ModelDownloadAlreadyExists value) alreadyExists,
    required TResult Function(ModelDownloading value) downloading,
    required TResult Function(ModelDownloadDone value) done,
    required TResult Function(ModelDownloadError value) error,
  }) {
    return done(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ModelDownloadIdle value)? idle,
    TResult? Function(ModelDownloadChecking value)? checking,
    TResult? Function(ModelDownloadAlreadyExists value)? alreadyExists,
    TResult? Function(ModelDownloading value)? downloading,
    TResult? Function(ModelDownloadDone value)? done,
    TResult? Function(ModelDownloadError value)? error,
  }) {
    return done?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ModelDownloadIdle value)? idle,
    TResult Function(ModelDownloadChecking value)? checking,
    TResult Function(ModelDownloadAlreadyExists value)? alreadyExists,
    TResult Function(ModelDownloading value)? downloading,
    TResult Function(ModelDownloadDone value)? done,
    TResult Function(ModelDownloadError value)? error,
    required TResult orElse(),
  }) {
    if (done != null) {
      return done(this);
    }
    return orElse();
  }
}

abstract class ModelDownloadDone implements ModelDownloadState {
  const factory ModelDownloadDone() = _$ModelDownloadDoneImpl;
}

/// @nodoc
abstract class _$$ModelDownloadErrorImplCopyWith<$Res> {
  factory _$$ModelDownloadErrorImplCopyWith(_$ModelDownloadErrorImpl value,
          $Res Function(_$ModelDownloadErrorImpl) then) =
      __$$ModelDownloadErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ModelDownloadErrorImplCopyWithImpl<$Res>
    extends _$ModelDownloadStateCopyWithImpl<$Res, _$ModelDownloadErrorImpl>
    implements _$$ModelDownloadErrorImplCopyWith<$Res> {
  __$$ModelDownloadErrorImplCopyWithImpl(_$ModelDownloadErrorImpl _value,
      $Res Function(_$ModelDownloadErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ModelDownloadErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ModelDownloadErrorImpl implements ModelDownloadError {
  const _$ModelDownloadErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'ModelDownloadState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelDownloadErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelDownloadErrorImplCopyWith<_$ModelDownloadErrorImpl> get copyWith =>
      __$$ModelDownloadErrorImplCopyWithImpl<_$ModelDownloadErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() checking,
    required TResult Function() alreadyExists,
    required TResult Function(
            double progress, int receivedBytes, int totalBytes)
        downloading,
    required TResult Function() done,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? checking,
    TResult? Function()? alreadyExists,
    TResult? Function(double progress, int receivedBytes, int totalBytes)?
        downloading,
    TResult? Function()? done,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? checking,
    TResult Function()? alreadyExists,
    TResult Function(double progress, int receivedBytes, int totalBytes)?
        downloading,
    TResult Function()? done,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ModelDownloadIdle value) idle,
    required TResult Function(ModelDownloadChecking value) checking,
    required TResult Function(ModelDownloadAlreadyExists value) alreadyExists,
    required TResult Function(ModelDownloading value) downloading,
    required TResult Function(ModelDownloadDone value) done,
    required TResult Function(ModelDownloadError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ModelDownloadIdle value)? idle,
    TResult? Function(ModelDownloadChecking value)? checking,
    TResult? Function(ModelDownloadAlreadyExists value)? alreadyExists,
    TResult? Function(ModelDownloading value)? downloading,
    TResult? Function(ModelDownloadDone value)? done,
    TResult? Function(ModelDownloadError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ModelDownloadIdle value)? idle,
    TResult Function(ModelDownloadChecking value)? checking,
    TResult Function(ModelDownloadAlreadyExists value)? alreadyExists,
    TResult Function(ModelDownloading value)? downloading,
    TResult Function(ModelDownloadDone value)? done,
    TResult Function(ModelDownloadError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ModelDownloadError implements ModelDownloadState {
  const factory ModelDownloadError({required final String message}) =
      _$ModelDownloadErrorImpl;

  String get message;
  @JsonKey(ignore: true)
  _$$ModelDownloadErrorImplCopyWith<_$ModelDownloadErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
