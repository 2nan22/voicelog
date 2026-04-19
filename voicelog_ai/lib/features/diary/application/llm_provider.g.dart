// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$llmInferenceServiceHash() =>
    r'4b8c9ddbc8090b1949f334a2c7b5dea71a185e20';

/// LLM 서비스 싱글톤 Provider (앱 생명주기 동안 유지).
///
/// Copied from [llmInferenceService].
@ProviderFor(llmInferenceService)
final llmInferenceServiceProvider = Provider<ILlmInferenceService>.internal(
  llmInferenceService,
  name: r'llmInferenceServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$llmInferenceServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LlmInferenceServiceRef = ProviderRef<ILlmInferenceService>;
String _$llmWarmUpHash() => r'6e77294278b53863f261be5aafa937de6f425be3';

/// LLM 모델 초기화(warm-up) Provider.
///
/// SplashScreen에서 watch하여 앱 시작 시 1회 모델을 로드한다.
///
/// Copied from [llmWarmUp].
@ProviderFor(llmWarmUp)
final llmWarmUpProvider = FutureProvider<void>.internal(
  llmWarmUp,
  name: r'llmWarmUpProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$llmWarmUpHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LlmWarmUpRef = FutureProviderRef<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
