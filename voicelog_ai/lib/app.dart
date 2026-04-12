import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voicelog_ai/core/constants/strings.dart';
import 'package:voicelog_ai/core/router/app_router.dart';
import 'package:voicelog_ai/core/theme/app_theme.dart';
import 'package:voicelog_ai/core/utils/app_lifecycle_observer.dart';
import 'package:voicelog_ai/features/diary/application/llm_provider.dart';

class VoicelogApp extends ConsumerStatefulWidget {
  const VoicelogApp({super.key});

  @override
  ConsumerState<VoicelogApp> createState() => _VoicelogAppState();
}

class _VoicelogAppState extends ConsumerState<VoicelogApp> {
  late final AppLifecycleObserver _observer;

  @override
  void initState() {
    super.initState();
    _observer = AppLifecycleObserver(ref.read(llmInferenceServiceProvider));
    WidgetsBinding.instance.addObserver(_observer);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_observer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
