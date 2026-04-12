import 'package:isar/isar.dart';

part 'app_settings_document.g.dart';

/// Isar 저장용 설정 스키마.
/// domain의 AppSettings와 분리하여 의존성 방향 규칙을 준수한다.
/// 단일 레코드 (id=0 고정).
@Collection()
class AppSettingsDocument {
  Id id = 0;
  bool isDarkMode = false;

  /// WritingStyle enum index 값으로 저장 (0=diary, 1=memo, 2=letter).
  @Index()
  int writingStyleIndex = 0;
}
