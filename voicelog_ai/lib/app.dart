import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voicelog_ai/core/constants/strings.dart';
import 'package:voicelog_ai/core/router/app_router.dart';
import 'package:voicelog_ai/core/theme/app_theme.dart';

class VoicelogApp extends ConsumerWidget {
  const VoicelogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: AppStrings.appName,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
