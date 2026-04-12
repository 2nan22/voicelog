import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/prompts.dart';
import 'package:voicelog_ai/core/constants/routes.dart';
import 'package:voicelog_ai/core/constants/strings.dart';
import 'package:voicelog_ai/features/diary/application/llm_provider.dart';
import 'package:voicelog_ai/features/diary/application/model_download_notifier.dart';

/// 앱 시작 화면.
///
/// 모델 파일 존재 여부를 확인하고,
/// - 있으면: LLM warm-up → 일기 목록 이동
/// - 없으면: HuggingFace 수동 다운로드 안내 표시
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkState = ref.watch(modelDownloadNotifierProvider);
    final warmUpAsync = ref.watch(llmWarmUpProvider);

    // 모델 존재 확인 완료 시 warm-up 시작, 완료 시 화면 이동
    ref.listen<AsyncValue<void>>(llmWarmUpProvider, (_, next) {
      if (next is AsyncData) context.go(AppRoutes.diaryList);
    });

    // 앱 시작 시 1회 모델 확인 트리거
    if (checkState is ModelDownloadIdle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(modelDownloadNotifierProvider.notifier).checkModel();
      });
    }

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
              checkState.when(
                idle: () => const _StatusText('준비 중...'),
                checking: () => const _StatusText('모델 파일 확인 중...'),
                exists: () => _WarmUpSection(warmUpAsync: warmUpAsync),
                missing: (modelPath) => _ModelMissingGuide(
                  modelPath: modelPath,
                  onRecheck: () =>
                      ref.read(modelDownloadNotifierProvider.notifier).recheck(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 서브 위젯 ────────────────────────────────────────────────────────────────

class _StatusText extends StatelessWidget {
  const _StatusText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      );
}

/// LLM warm-up 진행 상태
class _WarmUpSection extends StatelessWidget {
  const _WarmUpSection({required this.warmUpAsync});
  final AsyncValue<void> warmUpAsync;

  @override
  Widget build(BuildContext context) => warmUpAsync.when(
        loading: () => Column(
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
        ),
        data: (_) => const SizedBox.shrink(),
        error: (e, _) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            '엔진 초기화 실패: $e',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
}

/// 모델 파일 없음 — 수동 설치 안내
class _ModelMissingGuide extends StatelessWidget {
  const _ModelMissingGuide({
    required this.modelPath,
    required this.onRecheck,
  });

  final String modelPath;
  final VoidCallback onRecheck;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Icon(Icons.download_rounded, size: 48, color: cs.primary),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'AI 모델 파일이 필요합니다',
              style: tt.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          // Step 1
          _GuideStep(
            step: '1',
            title: 'HuggingFace에서 다운로드',
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('아래 페이지에서 로그인 후 Gemma 라이선스에 동의하고\n'
                    'gemma-2b-it-cpu-int4.bin 파일을 다운로드하세요.',
                    style: tt.bodySmall),
                const SizedBox(height: 6),
                const _CopyableText(kModelHuggingFacePage),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Step 2
          _GuideStep(
            step: '2',
            title: '기기에 파일 복사',
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('다운로드한 파일을 아래 경로로 복사하세요.\n(ADB 또는 파일 관리자 사용)',
                    style: tt.bodySmall),
                const SizedBox(height: 6),
                _CopyableText(modelPath),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: FilledButton.icon(
              onPressed: onRecheck,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('복사 완료 — 다시 확인'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({required this.step, required this.title, required this.body});

  final String step;
  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: cs.primaryContainer,
          child: Text(step, style: tt.labelSmall?.copyWith(color: cs.onPrimaryContainer)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: tt.titleSmall),
              const SizedBox(height: 4),
              body,
            ],
          ),
        ),
      ],
    );
  }
}

/// 텍스트를 길게 눌러 복사할 수 있는 위젯
class _CopyableText extends StatelessWidget {
  const _CopyableText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: SelectableText(
        text,
        style: tt.bodySmall?.copyWith(
          fontFamily: 'monospace',
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
