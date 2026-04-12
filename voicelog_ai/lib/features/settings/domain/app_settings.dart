import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

/// 앱 설정 도메인 모델 (불변, 순수 Dart).
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(false) bool isDarkMode,
  }) = _AppSettings;
}
