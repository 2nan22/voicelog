// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$emotionCountsHash() => r'bbe7f2a51c3b0deed704b18013fe800ed84551ac';

/// 감정별 카운트 맵. 예: {'기쁨': 5, '슬픔': 2, '평온': 8, '화남': 1}
///
/// Copied from [emotionCounts].
@ProviderFor(emotionCounts)
final emotionCountsProvider =
    AutoDisposeFutureProvider<Map<String, int>>.internal(
  emotionCounts,
  name: r'emotionCountsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$emotionCountsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef EmotionCountsRef = AutoDisposeFutureProviderRef<Map<String, int>>;
String _$writingStreakHash() => r'aad74a0dd80e44320a34543e38741ed17b398c32';

/// 연속 기록 스트릭 (오늘 기준 연속 작성 일수).
///
/// Copied from [writingStreak].
@ProviderFor(writingStreak)
final writingStreakProvider = AutoDisposeFutureProvider<int>.internal(
  writingStreak,
  name: r'writingStreakProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$writingStreakHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WritingStreakRef = AutoDisposeFutureProviderRef<int>;
String _$topTagsHash() => r'3c7bcb918f8bc72389efa8978899cf78620aada7';

/// 태그 빈도 Top 5. 예: [('#산책', 7), ('#친구', 4), ...]
///
/// Copied from [topTags].
@ProviderFor(topTags)
final topTagsProvider = AutoDisposeFutureProvider<List<(String, int)>>.internal(
  topTags,
  name: r'topTagsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$topTagsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TopTagsRef = AutoDisposeFutureProviderRef<List<(String, int)>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
