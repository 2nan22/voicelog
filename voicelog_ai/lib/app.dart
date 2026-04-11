import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/routes.dart';
import 'package:voicelog_ai/core/constants/strings.dart';
import 'package:voicelog_ai/core/theme/app_theme.dart';
import 'package:voicelog_ai/features/diary/presentation/screens/diary_record_screen.dart';
import 'package:voicelog_ai/features/diary/presentation/screens/splash_screen.dart';

// 일기 목록 화면 임시 플레이스홀더 (Session 07 이후 구현 예정)
class _DiaryListPlaceholder extends StatelessWidget {
  const _DiaryListPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('일기 목록 (구현 예정)'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.diaryRecord),
              icon: const Icon(Icons.mic),
              label: const Text('녹음 화면 테스트'),
            ),
          ],
        ),
      ),
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
    GoRoute(
      path: AppRoutes.diaryRecord,
      builder: (context, state) => const DiaryRecordScreen(),
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
