import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

/// LLM 보정 시 적용할 문체.
enum WritingStyle {
  diary,  // 일기체 — 자연스러운 독백 (기본값)
  memo,   // 메모체 — 간결·핵심 요약
  letter, // 편지체 — 감성적·따뜻한 표현
}

/// 앱 설정 도메인 모델 (불변, 순수 Dart).
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(false) bool isDarkMode,
    @Default(WritingStyle.diary) WritingStyle writingStyle,
    @Default(false) bool correctionEnabled,
  }) = _AppSettings;
}
