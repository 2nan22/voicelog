// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_process_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$diaryProcessNotifierHash() =>
    r'0cee329f03cd118e45955750895c4dc4684da8a9';

/// LLM 스트림 청크를 누적하고 파싱 결과를 보유하는 Notifier.
///
/// 사용 흐름:
/// 1. [reset] — 처리 시작 전 초기화
/// 2. [appendChunk] — 스트리밍 청크마다 호출
/// 3. [finalize] — 스트림 완료 후 최종 파싱 (스트림 중 [태그] 미감지 시 fallback)
///
/// Copied from [DiaryProcessNotifier].
@ProviderFor(DiaryProcessNotifier)
final diaryProcessNotifierProvider = AutoDisposeNotifierProvider<
    DiaryProcessNotifier, DiaryProcessState>.internal(
  DiaryProcessNotifier.new,
  name: r'diaryProcessNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$diaryProcessNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DiaryProcessNotifier = AutoDisposeNotifier<DiaryProcessState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
