import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:voicelog_ai/core/constants/routes.dart';
import 'package:voicelog_ai/core/widgets/main_shell.dart';
import 'package:voicelog_ai/features/diary/presentation/screens/diary_detail_screen.dart';
import 'package:voicelog_ai/features/diary/presentation/screens/diary_list_screen.dart';
import 'package:voicelog_ai/features/diary/presentation/screens/diary_record_screen.dart';
import 'package:voicelog_ai/features/diary/presentation/screens/insight_screen.dart';
import 'package:voicelog_ai/features/diary/presentation/screens/logs_screen.dart';
import 'package:voicelog_ai/features/diary/presentation/screens/profile_screen.dart';
import 'package:voicelog_ai/features/diary/presentation/screens/splash_screen.dart';
import 'package:voicelog_ai/features/settings/presentation/screens/settings_screen.dart';

part 'app_router.g.dart';

/// 앱 전체 라우팅 Provider.
///
/// keepAlive: true — 앱 생명주기 동안 GoRouter 인스턴스를 유지한다.
/// ShellRoute로 공통 하단 탭 네비를 분리한다.
@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.diaryRecord,
        builder: (_, __) => const DiaryRecordScreen(),
      ),
      GoRoute(
        path: AppRoutes.diaryDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return DiaryDetailScreen(entryId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.diaryList,
            builder: (_, __) => const DiaryListBody(),
          ),
          GoRoute(
            path: AppRoutes.logs,
            builder: (_, __) => const LogsScreen(),
          ),
          GoRoute(
            path: AppRoutes.insight,
            builder: (_, __) => const InsightScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
