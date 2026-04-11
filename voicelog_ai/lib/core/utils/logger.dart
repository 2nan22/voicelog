import 'package:flutter/foundation.dart';

/// 기기 로컬에만 출력하는 로거. 외부 전송 금지.
class AppLogger {
  AppLogger._();

  static void info(String message) {
    if (kDebugMode) debugPrint('[INFO] $message');
  }

  static void warn(String message) {
    if (kDebugMode) debugPrint('[WARN] $message');
  }

  static void error(String message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('  error: $error');
      if (stack != null) debugPrint('  stack: $stack');
    }
  }
}
