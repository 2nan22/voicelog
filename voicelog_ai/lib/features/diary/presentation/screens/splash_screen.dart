import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/routes.dart';
import 'package:voicelog_ai/core/constants/strings.dart';
import 'package:voicelog_ai/features/diary/application/llm_provider.dart';
import 'package:voicelog_ai/features/diary/application/model_download_notifier.dart';

/// 앱 시작 화면.
///
/// 모델 파일 존재 여부를 확인하고, 없으면 다운로드 후 LLM warm-up을 거쳐
/// 일기 목록 화면([AppRoutes.diaryList])으로 자동 이동한다.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(modelDownloadNotifierProvider);
    final warmUpAsync = ref.watch(llmWarmUpProvider);

    // 다운로드 완료 시 실패했던 warm-up을 재시도
    ref.listen<ModelDownloadState>(modelDownloadNotifierProvider, (_, next) {
      if (next is ModelDownloadDone) {
        ref.invalidate(llmWarmUpProvider);
      }
    });

    // warm-up 완료 시 일기 목록으로 이동
    ref.listen<AsyncValue<void>>(llmWarmUpProvider, (_, next) {
      if (next is AsyncData) context.go(AppRoutes.diaryList);
    });

    // 앱 시작 시 1회 모델 확인 트리거 (idle 상태일 때만)
    if (downloadState is ModelDownloadIdle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(modelDownloadNotifierProvider.notifier).ensureModelReady();
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
              // ── 상태별 UI ────────────────────────────────────────
              downloadState.when(
                idle: () => const _StatusText('준비 중...'),
                checking: () => const _StatusText('모델 파일 확인 중...'),
                alreadyExists: () => _WarmUpSection(warmUpAsync: warmUpAsync),
                downloading: (progress, received, total) => _DownloadSection(
                  progress: progress,
                  received: received,
                  total: total,
                ),
                done: () => _WarmUpSection(warmUpAsync: warmUpAsync),
                error: (message) => _ErrorSection(
                  message: message,
                  onRetry: () =>
                      ref.read(modelDownloadNotifierProvider.notifier).retry(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 상태별 서브 위젯 ─────────────────────────────────────────────────────────

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

/// 다운로드 진행률 UI
class _DownloadSection extends StatelessWidget {
  const _DownloadSection({
    required this.progress,
    required this.received,
    required this.total,
  });

  final double progress;
  final int received;
  final int total;

  String _formatMb(int bytes) => '${(bytes / 1024 / 1024).toStringAsFixed(0)} MB';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Text(
            'AI 모델 다운로드 중...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Wi-Fi 환경을 권장합니다 (약 1.5 GB)',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            total > 0
                ? '${_formatMb(received)} / ${_formatMb(total)} (${(progress * 100).round()}%)'
                : '${_formatMb(received)} 수신 중...',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

/// 다운로드 완료 후 LLM warm-up 상태 표시
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
        error: (e, _) => _ErrorSection(
          message: '엔진 초기화 실패: $e',
          onRetry: null,
        ),
      );
}

/// 에러 + 재시도 버튼
class _ErrorSection extends StatelessWidget {
  const _ErrorSection({required this.message, required this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('다시 시도'),
              ),
            ],
          ],
        ),
      );
}
