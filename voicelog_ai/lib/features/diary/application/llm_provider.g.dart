// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$llmInferenceServiceHash() =>
    r'4b8c9ddbc8090b1949f334a2c7b5dea71a185e20';

/// LLM 서비스 싱글톤 Provider (앱 생명주기 동안 유지).
///
/// [MethodChannelLlmInferenceService]를 [ILlmInferenceService]로 제공한다.
/// [ref.onDispose]에서 자동으로 [ILlmInferenceService.dispose]를 호출한다.
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
/// 완료 시 AsyncData<void>, 실패 시 AsyncError를 emit한다.
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
String _$llmStreamHash() => r'd99bf841594ed5f30009c49daa17d93682b5caab';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// STT 원문 텍스트 → LLM 스트리밍 응답 Provider.
///
/// [rawText]를 프롬프트 템플릿에 치환하여 [ILlmInferenceService.generateStream]에 전달한다.
/// 스트림 구독 취소 시 스트리밍이 중단된다.
///
/// Copied from [llmStream].
@ProviderFor(llmStream)
const llmStreamProvider = LlmStreamFamily();

/// STT 원문 텍스트 → LLM 스트리밍 응답 Provider.
///
/// [rawText]를 프롬프트 템플릿에 치환하여 [ILlmInferenceService.generateStream]에 전달한다.
/// 스트림 구독 취소 시 스트리밍이 중단된다.
///
/// Copied from [llmStream].
class LlmStreamFamily extends Family<AsyncValue<String>> {
  /// STT 원문 텍스트 → LLM 스트리밍 응답 Provider.
  ///
  /// [rawText]를 프롬프트 템플릿에 치환하여 [ILlmInferenceService.generateStream]에 전달한다.
  /// 스트림 구독 취소 시 스트리밍이 중단된다.
  ///
  /// Copied from [llmStream].
  const LlmStreamFamily();

  /// STT 원문 텍스트 → LLM 스트리밍 응답 Provider.
  ///
  /// [rawText]를 프롬프트 템플릿에 치환하여 [ILlmInferenceService.generateStream]에 전달한다.
  /// 스트림 구독 취소 시 스트리밍이 중단된다.
  ///
  /// Copied from [llmStream].
  LlmStreamProvider call(
    String rawText,
  ) {
    return LlmStreamProvider(
      rawText,
    );
  }

  @override
  LlmStreamProvider getProviderOverride(
    covariant LlmStreamProvider provider,
  ) {
    return call(
      provider.rawText,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'llmStreamProvider';
}

/// STT 원문 텍스트 → LLM 스트리밍 응답 Provider.
///
/// [rawText]를 프롬프트 템플릿에 치환하여 [ILlmInferenceService.generateStream]에 전달한다.
/// 스트림 구독 취소 시 스트리밍이 중단된다.
///
/// Copied from [llmStream].
class LlmStreamProvider extends AutoDisposeStreamProvider<String> {
  /// STT 원문 텍스트 → LLM 스트리밍 응답 Provider.
  ///
  /// [rawText]를 프롬프트 템플릿에 치환하여 [ILlmInferenceService.generateStream]에 전달한다.
  /// 스트림 구독 취소 시 스트리밍이 중단된다.
  ///
  /// Copied from [llmStream].
  LlmStreamProvider(
    String rawText,
  ) : this._internal(
          (ref) => llmStream(
            ref as LlmStreamRef,
            rawText,
          ),
          from: llmStreamProvider,
          name: r'llmStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$llmStreamHash,
          dependencies: LlmStreamFamily._dependencies,
          allTransitiveDependencies: LlmStreamFamily._allTransitiveDependencies,
          rawText: rawText,
        );

  LlmStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.rawText,
  }) : super.internal();

  final String rawText;

  @override
  Override overrideWith(
    Stream<String> Function(LlmStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LlmStreamProvider._internal(
        (ref) => create(ref as LlmStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        rawText: rawText,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<String> createElement() {
    return _LlmStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LlmStreamProvider && other.rawText == rawText;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, rawText.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin LlmStreamRef on AutoDisposeStreamProviderRef<String> {
  /// The parameter `rawText` of this provider.
  String get rawText;
}

class _LlmStreamProviderElement extends AutoDisposeStreamProviderElement<String>
    with LlmStreamRef {
  _LlmStreamProviderElement(super.provider);

  @override
  String get rawText => (origin as LlmStreamProvider).rawText;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
