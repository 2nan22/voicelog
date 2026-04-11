// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_record_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$speechToTextServiceHash() =>
    r'37b0ea7468bc02483ea5823b59888e005b752dba';

/// STT 서비스 Provider
///
/// Copied from [speechToTextService].
@ProviderFor(speechToTextService)
final speechToTextServiceProvider = Provider<SpeechToTextService>.internal(
  speechToTextService,
  name: r'speechToTextServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$speechToTextServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SpeechToTextServiceRef = ProviderRef<SpeechToTextService>;
String _$diaryRecordNotifierHash() =>
    r'1aaf8aa4455d12cb33d569c3ee443a47a1c65be2';

/// 녹음 상태 Notifier
///
/// Copied from [DiaryRecordNotifier].
@ProviderFor(DiaryRecordNotifier)
final diaryRecordNotifierProvider =
    AutoDisposeNotifierProvider<DiaryRecordNotifier, RecordingState>.internal(
  DiaryRecordNotifier.new,
  name: r'diaryRecordNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$diaryRecordNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DiaryRecordNotifier = AutoDisposeNotifier<RecordingState>;
String _$sttTextNotifierHash() => r'a16826f431d8d757380a463e0e5ef018e9f15ec8';

/// STT 인식 텍스트 Notifier (중간 결과 + 최종 결과)
///
/// Copied from [SttTextNotifier].
@ProviderFor(SttTextNotifier)
final sttTextNotifierProvider =
    AutoDisposeNotifierProvider<SttTextNotifier, String>.internal(
  SttTextNotifier.new,
  name: r'sttTextNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sttTextNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SttTextNotifier = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
