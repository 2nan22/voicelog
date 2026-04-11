import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/routes.dart';
import 'package:voicelog_ai/core/constants/strings.dart';
import 'package:voicelog_ai/core/theme/app_theme.dart';
import 'package:voicelog_ai/features/diary/presentation/screens/splash_screen.dart';

// 일기 목록 화면 임시 플레이스홀더 (Session 06에서 구현 예정)
class _DiaryListPlaceholder extends StatelessWidget {
  const _DiaryListPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('일기 목록 (구현 예정)')),
    );
  }
}

final _router = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.diaryList,
      builder: (context, state) => const _DiaryListPlaceholder(),
    ),
  ],
);

class VoicelogApp extends ConsumerWidget {
  const VoicelogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppStrings.appName,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
