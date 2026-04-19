// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppSettings {
  bool get isDarkMode => throw _privateConstructorUsedError;
  WritingStyle get writingStyle => throw _privateConstructorUsedError;
  bool get correctionEnabled => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppSettingsCopyWith<AppSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsCopyWith<$Res> {
  factory $AppSettingsCopyWith(
          AppSettings value, $Res Function(AppSettings) then) =
      _$AppSettingsCopyWithImpl<$Res, AppSettings>;
  @useResult
  $Res call(
      {bool isDarkMode, WritingStyle writingStyle, bool correctionEnabled});
}

/// @nodoc
class _$AppSettingsCopyWithImpl<$Res, $Val extends AppSettings>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isDarkMode = null,
    Object? writingStyle = null,
    Object? correctionEnabled = null,
  }) {
    return _then(_value.copyWith(
      isDarkMode: null == isDarkMode
          ? _value.isDarkMode
          : isDarkMode // ignore: cast_nullable_to_non_nullable
              as bool,
      writingStyle: null == writingStyle
          ? _value.writingStyle
          : writingStyle // ignore: cast_nullable_to_non_nullable
              as WritingStyle,
      correctionEnabled: null == correctionEnabled
          ? _value.correctionEnabled
          : correctionEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppSettingsImplCopyWith<$Res>
    implements $AppSettingsCopyWith<$Res> {
  factory _$$AppSettingsImplCopyWith(
          _$AppSettingsImpl value, $Res Function(_$AppSettingsImpl) then) =
      __$$AppSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isDarkMode, WritingStyle writingStyle, bool correctionEnabled});
}

/// @nodoc
class __$$AppSettingsImplCopyWithImpl<$Res>
    extends _$AppSettingsCopyWithImpl<$Res, _$AppSettingsImpl>
    implements _$$AppSettingsImplCopyWith<$Res> {
  __$$AppSettingsImplCopyWithImpl(
      _$AppSettingsImpl _value, $Res Function(_$AppSettingsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isDarkMode = null,
    Object? writingStyle = null,
    Object? correctionEnabled = null,
  }) {
    return _then(_$AppSettingsImpl(
      isDarkMode: null == isDarkMode
          ? _value.isDarkMode
          : isDarkMode // ignore: cast_nullable_to_non_nullable
              as bool,
      writingStyle: null == writingStyle
          ? _value.writingStyle
          : writingStyle // ignore: cast_nullable_to_non_nullable
              as WritingStyle,
      correctionEnabled: null == correctionEnabled
          ? _value.correctionEnabled
          : correctionEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$AppSettingsImpl implements _AppSettings {
  const _$AppSettingsImpl(
      {this.isDarkMode = false,
      this.writingStyle = WritingStyle.diary,
      this.correctionEnabled = false});

  @override
  @JsonKey()
  final bool isDarkMode;
  @override
  @JsonKey()
  final WritingStyle writingStyle;
  @override
  @JsonKey()
  final bool correctionEnabled;

  @override
  String toString() {
    return 'AppSettings(isDarkMode: $isDarkMode, writingStyle: $writingStyle, correctionEnabled: $correctionEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsImpl &&
            (identical(other.isDarkMode, isDarkMode) ||
                other.isDarkMode == isDarkMode) &&
            (identical(other.writingStyle, writingStyle) ||
                other.writingStyle == writingStyle) &&
            (identical(other.correctionEnabled, correctionEnabled) ||
                other.correctionEnabled == correctionEnabled));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isDarkMode, writingStyle, correctionEnabled);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      __$$AppSettingsImplCopyWithImpl<_$AppSettingsImpl>(this, _$identity);
}

abstract class _AppSettings implements AppSettings {
  const factory _AppSettings(
      {final bool isDarkMode,
      final WritingStyle writingStyle,
      final bool correctionEnabled}) = _$AppSettingsImpl;

  @override
  bool get isDarkMode;
  @override
  WritingStyle get writingStyle;
  @override
  bool get correctionEnabled;
  @override
  @JsonKey(ignore: true)
  _$$AppSettingsImplCopyWith<_$AppSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
