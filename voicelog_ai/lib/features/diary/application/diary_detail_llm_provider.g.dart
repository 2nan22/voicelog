// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_detail_llm_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$diaryDetailLlmNotifierHash() =>
    r'6f6972d8756279a6e91bc037afb91eadc75a66c7';

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

abstract class _$DiaryDetailLlmNotifier
    extends BuildlessAutoDisposeNotifier<DetailLlmState> {
  late final int entryId;

  DetailLlmState build(
    int entryId,
  );
}

/// 상세 화면 LLM 재처리 Notifier. entryId를 키로 하는 family Provider.
///
/// Copied from [DiaryDetailLlmNotifier].
@ProviderFor(DiaryDetailLlmNotifier)
const diaryDetailLlmNotifierProvider = DiaryDetailLlmNotifierFamily();

/// 상세 화면 LLM 재처리 Notifier. entryId를 키로 하는 family Provider.
///
/// Copied from [DiaryDetailLlmNotifier].
class DiaryDetailLlmNotifierFamily extends Family<DetailLlmState> {
  /// 상세 화면 LLM 재처리 Notifier. entryId를 키로 하는 family Provider.
  ///
  /// Copied from [DiaryDetailLlmNotifier].
  const DiaryDetailLlmNotifierFamily();

  /// 상세 화면 LLM 재처리 Notifier. entryId를 키로 하는 family Provider.
  ///
  /// Copied from [DiaryDetailLlmNotifier].
  DiaryDetailLlmNotifierProvider call(
    int entryId,
  ) {
    return DiaryDetailLlmNotifierProvider(
      entryId,
    );
  }

  @override
  DiaryDetailLlmNotifierProvider getProviderOverride(
    covariant DiaryDetailLlmNotifierProvider provider,
  ) {
    return call(
      provider.entryId,
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
  String? get name => r'diaryDetailLlmNotifierProvider';
}

/// 상세 화면 LLM 재처리 Notifier. entryId를 키로 하는 family Provider.
///
/// Copied from [DiaryDetailLlmNotifier].
class DiaryDetailLlmNotifierProvider extends AutoDisposeNotifierProviderImpl<
    DiaryDetailLlmNotifier, DetailLlmState> {
  /// 상세 화면 LLM 재처리 Notifier. entryId를 키로 하는 family Provider.
  ///
  /// Copied from [DiaryDetailLlmNotifier].
  DiaryDetailLlmNotifierProvider(
    int entryId,
  ) : this._internal(
          () => DiaryDetailLlmNotifier()..entryId = entryId,
          from: diaryDetailLlmNotifierProvider,
          name: r'diaryDetailLlmNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$diaryDetailLlmNotifierHash,
          dependencies: DiaryDetailLlmNotifierFamily._dependencies,
          allTransitiveDependencies:
              DiaryDetailLlmNotifierFamily._allTransitiveDependencies,
          entryId: entryId,
        );

  DiaryDetailLlmNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.entryId,
  }) : super.internal();

  final int entryId;

  @override
  DetailLlmState runNotifierBuild(
    covariant DiaryDetailLlmNotifier notifier,
  ) {
    return notifier.build(
      entryId,
    );
  }

  @override
  Override overrideWith(DiaryDetailLlmNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: DiaryDetailLlmNotifierProvider._internal(
        () => create()..entryId = entryId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        entryId: entryId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<DiaryDetailLlmNotifier, DetailLlmState>
      createElement() {
    return _DiaryDetailLlmNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DiaryDetailLlmNotifierProvider && other.entryId == entryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, entryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DiaryDetailLlmNotifierRef
    on AutoDisposeNotifierProviderRef<DetailLlmState> {
  /// The parameter `entryId` of this provider.
  int get entryId;
}

class _DiaryDetailLlmNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<DiaryDetailLlmNotifier,
        DetailLlmState> with DiaryDetailLlmNotifierRef {
  _DiaryDetailLlmNotifierProviderElement(super.provider);

  @override
  int get entryId => (origin as DiaryDetailLlmNotifierProvider).entryId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
