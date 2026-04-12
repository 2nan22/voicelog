import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/routes.dart';
import 'package:voicelog_ai/core/constants/strings.dart';
import 'package:voicelog_ai/core/theme/app_theme.dart';
import 'package:voicelog_ai/features/diary/presentation/screens/diary_list_screen.dart';
import 'package:voicelog_ai/features/diary/presentation/screens/diary_record_screen.dart';
import 'package:voicelog_ai/features/diary/presentation/screens/splash_screen.dart';

// 상세 화면 플레이스홀더 (Session 09에서 구현 예정)
class _DiaryDetailPlaceholder extends StatelessWidget {
  const _DiaryDetailPlaceholder({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('일기 상세')),
      body: Center(child: Text('일기 #$id (구현 예정)')),
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
      builder: (context, state) => const DiaryListScreen(),
    ),
    GoRoute(
      path: AppRoutes.diaryRecord,
      builder: (context, state) => const DiaryRecordScreen(),
    ),
    GoRoute(
      path: AppRoutes.diaryDetail,
      builder: (context, state) => _DiaryDetailPlaceholder(
        id: state.pathParameters['id'] ?? '',
      ),
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
