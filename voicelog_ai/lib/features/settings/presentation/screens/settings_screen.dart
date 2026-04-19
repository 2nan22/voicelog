import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/strings.dart';
import 'package:voicelog_ai/features/settings/application/settings_provider.dart';
import 'package:voicelog_ai/features/settings/domain/app_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: CustomScrollView(
        slivers: [
          _GlassAppBar(scheme: scheme),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
            sliver: settingsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('오류: $e')),
              ),
              data: (settings) => SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 디스플레이 섹션 ──────────────────────────────
                    const _SectionHeader(title: '디스플레이'),
                    const SizedBox(height: 10),
                    _SettingsCard(
                      children: [
                        _ToggleItem(
                          icon: Icons.dark_mode_outlined,
                          label: '다크 모드',
                          value: settings.isDarkMode,
                          onChanged: (v) => ref
                              .read(settingsNotifierProvider.notifier)
                              .setDarkMode(v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── AI 기능 섹션 ──────────────────────────────────
                    const _SectionHeader(title: 'AI 기능'),
                    const SizedBox(height: 10),
                    _SettingsCard(
                      children: [
                        _ToggleItem(
                          icon: Icons.auto_fix_high_rounded,
                          label: '문맥 보정',
                          subtitle: 'AI가 오탈자와 어색한 표현을 최소한으로 수정합니다',
                          value: settings.correctionEnabled,
                          onChanged: (v) => ref
                              .read(settingsNotifierProvider.notifier)
                              .setCorrectionEnabled(v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _WritingStyleCard(currentStyle: settings.writingStyle),
                    const SizedBox(height: 28),

                    // ── 앱 정보 섹션 ─────────────────────────────────
                    const _SectionHeader(title: '앱 정보'),
                    const SizedBox(height: 10),
                    const _SettingsCard(
                      children: [
                        _InfoItem(
                          icon: Icons.info_outline_rounded,
                          label: AppStrings.appName,
                          subtitle: 'v1.0.0 · On-Device AI 음성 일기',
                        ),
                        _InfoItem(
                          icon: Icons.lock_outline_rounded,
                          label: '개인정보 보호',
                          subtitle: '모든 데이터는 기기 내부에만 저장됩니다',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glass SliverAppBar ────────────────────────────────────────────────────────

class _GlassAppBar extends StatelessWidget {
  const _GlassAppBar({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 0,
      toolbarHeight: 64,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: scheme.surface.withValues(alpha: 0.75),
          ),
        ),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: scheme.onSurface),
        tooltip: '뒤로',
        onPressed: () => context.pop(),
      ),
      title: Text(
        '설정',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: scheme.onSurface,
            ),
      ),
    );
  }
}

// ── 섹션 헤더 ─────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontWeight: FontWeight.w800,
              letterSpacing: 3.0,
            ),
      ),
    );
  }
}

// ── 설정 카드 래퍼 ────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

// ── 아이콘 컨테이너 ───────────────────────────────────────────────────────────

class _IconContainer extends StatelessWidget {
  const _IconContainer({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.07),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: scheme.primary),
    );
  }
}

// ── 토글 아이템 (다크 모드) ───────────────────────────────────────────────────

class _ToggleItem extends StatelessWidget {
  const _ToggleItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          _IconContainer(icon: icon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: scheme.primary,
          ),
        ],
      ),
    );
  }
}

// ── 문체 선택 카드 ────────────────────────────────────────────────────────────

class _WritingStyleCard extends ConsumerWidget {
  const _WritingStyleCard({required this.currentStyle});

  final WritingStyle currentStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconContainer(icon: Icons.edit_note_rounded),
              const SizedBox(width: 16),
              Text(
                '일기 보정 문체',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<WritingStyle>(
            segments: const [
              ButtonSegment(value: WritingStyle.diary,  label: Text('일기체')),
              ButtonSegment(value: WritingStyle.memo,   label: Text('메모체')),
              ButtonSegment(value: WritingStyle.letter, label: Text('편지체')),
            ],
            selected: {currentStyle},
            onSelectionChanged: (value) => ref
                .read(settingsNotifierProvider.notifier)
                .setWritingStyle(value.first),
            style: ButtonStyle(
              side: WidgetStatePropertyAll(
                BorderSide(color: scheme.outline.withValues(alpha: 0.3)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _styleDescription(currentStyle),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  String _styleDescription(WritingStyle style) => switch (style) {
    WritingStyle.diary  => '자연스러운 1인칭 독백으로 정리합니다',
    WritingStyle.memo   => '핵심 내용만 간결하게 요약합니다',
    WritingStyle.letter => '따뜻하고 감성적인 표현으로 다듬습니다',
  };
}

// ── 정보 아이템 (탭 불가) ─────────────────────────────────────────────────────

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          _IconContainer(icon: icon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
