import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:voicelog_ai/core/constants/routes.dart';
import 'package:voicelog_ai/features/diary/presentation/screens/diary_detail_screen.dart';
import 'package:voicelog_ai/features/diary/presentation/screens/diary_list_screen.dart';
import 'package:voicelog_ai/features/diary/presentation/screens/diary_record_screen.dart';
import 'package:voicelog_ai/features/diary/presentation/screens/splash_screen.dart';
import 'package:voicelog_ai/features/settings/presentation/screens/settings_screen.dart';

part 'app_router.g.dart';

/// 앱 전체 라우팅 Provider.
///
/// keepAlive: true — 앱 생명주기 동안 GoRouter 인스턴스를 유지한다.
/// 네비게이션 스택 상태가 Provider 재빌드로 초기화되지 않도록 한다.
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
        path: AppRoutes.diaryList,
        builder: (_, __) => const DiaryListScreen(),
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
    ],
  );
}
