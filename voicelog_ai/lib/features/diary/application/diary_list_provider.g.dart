// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$diaryByDateHash() => r'751698a630618173cf50e330647451e03bafd37b';

/// 날짜(연·월·일만) → 해당 날의 DiaryEntry 목록 맵.
/// 캘린더 이벤트 마커 및 선택 날짜 목록에 사용.
///
/// Copied from [diaryByDate].
@ProviderFor(diaryByDate)
final diaryByDateProvider =
    AutoDisposeFutureProvider<Map<DateTime, List<DiaryEntry>>>.internal(
  diaryByDate,
  name: r'diaryByDateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$diaryByDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DiaryByDateRef
    = AutoDisposeFutureProviderRef<Map<DateTime, List<DiaryEntry>>>;
String _$diaryListNotifierHash() => r'5fdae80547299509a8f1e5860adcdf7b28ddac3b';

/// See also [DiaryListNotifier].
@ProviderFor(DiaryListNotifier)
final diaryListNotifierProvider = AutoDisposeAsyncNotifierProvider<
    DiaryListNotifier, List<DiaryEntry>>.internal(
  DiaryListNotifier.new,
  name: r'diaryListNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$diaryListNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DiaryListNotifier = AutoDisposeAsyncNotifier<List<DiaryEntry>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
