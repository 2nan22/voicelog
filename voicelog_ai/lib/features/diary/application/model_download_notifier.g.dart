// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_download_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$modelDownloadNotifierHash() =>
    r'9abd942bdf6dc83c7fc4a39480dd388afd84c60f';

/// 모델 파일 존재 여부를 확인하는 Notifier.
///
/// 파일이 없으면 [ModelDownloadState.missing]을 emit하여
/// SplashScreen에서 수동 설치 안내를 표시한다.
///
/// Copied from [ModelDownloadNotifier].
@ProviderFor(ModelDownloadNotifier)
final modelDownloadNotifierProvider = AutoDisposeNotifierProvider<
    ModelDownloadNotifier, ModelDownloadState>.internal(
  ModelDownloadNotifier.new,
  name: r'modelDownloadNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$modelDownloadNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ModelDownloadNotifier = AutoDisposeNotifier<ModelDownloadState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
