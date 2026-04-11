import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/routes.dart';
import 'package:voicelog_ai/core/constants/strings.dart';
import 'package:voicelog_ai/features/diary/application/llm_provider.dart';

/// 앱 시작 화면.
///
/// [llmWarmUpProvider]를 통해 LLM 모델을 초기화하고,
/// 완료 시 일기 목록 화면([AppRoutes.diaryList])으로 자동 이동한다.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warmUpAsync = ref.watch(llmWarmUpProvider);

    // warm-up 완료 시 일기 목록으로 이동
    ref.listen<AsyncValue<void>>(llmWarmUpProvider, (_, next) {
      if (next is AsyncData) {
        context.go(AppRoutes.diaryList);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mic,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.appName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              warmUpAsync.when(
                loading: () => _LoadingIndicator(context: context),
                data: (_) => const SizedBox.shrink(),
                error: (error, _) => _ErrorMessage(
                  context: context,
                  error: error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return Column(
      children: [
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.splashLoading,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.context, required this.error});

  final BuildContext context;
  final Object error;

  @override
  Widget build(BuildContext _) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        '초기화 실패: $error',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
