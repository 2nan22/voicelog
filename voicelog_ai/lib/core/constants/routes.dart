class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';

  // ShellRoute 탭 라우트
  static const String diaryList = '/';
  static const String logs      = '/logs';
  static const String insight   = '/insight';
  static const String profile   = '/profile';

  // Shell 외부 라우트
  static const String diaryRecord = '/record';
  static const String diaryDetail = '/diary/:id';
  static const String settings    = '/settings';
}
