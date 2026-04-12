import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:voicelog_ai/core/constants/prompts.dart';
import 'package:voicelog_ai/core/utils/logger.dart';

part 'model_download_notifier.freezed.dart';
part 'model_download_notifier.g.dart';

/// 모델 파일 확인 상태.
@freezed
class ModelDownloadState with _$ModelDownloadState {
  const factory ModelDownloadState.idle() = ModelDownloadIdle;
  const factory ModelDownloadState.checking() = ModelDownloadChecking;
  const factory ModelDownloadState.exists() = ModelDownloadExists;
  const factory ModelDownloadState.missing({required String modelPath}) = ModelDownloadMissing;
}

/// 모델 파일 존재 여부를 확인하는 Notifier.
///
/// 파일이 없으면 [ModelDownloadState.missing]을 emit하여
/// SplashScreen에서 수동 설치 안내를 표시한다.
@riverpod
class ModelDownloadNotifier extends _$ModelDownloadNotifier {
  @override
  ModelDownloadState build() => const ModelDownloadState.idle();

  Future<void> checkModel() async {
    state = const ModelDownloadState.checking();
    try {
      final modelPath = await _getModelPath();
      final modelFile = File(modelPath);

      if (modelFile.existsSync() && modelFile.lengthSync() > 0) {
        AppLogger.info('모델 파일 존재 확인: $modelPath');
        state = const ModelDownloadState.exists();
      } else {
        AppLogger.info('모델 파일 없음: $modelPath');
        state = ModelDownloadState.missing(modelPath: modelPath);
      }
    } catch (e) {
      AppLogger.error('모델 파일 확인 실패', e);
      // 확인 실패 시 경로를 알 수 없으므로 missing으로 처리
      state = const ModelDownloadState.missing(modelPath: '경로를 확인할 수 없습니다');
    }
  }

  /// 파일 복사 후 재확인
  Future<void> recheck() => checkModel();

  Future<String> _getModelPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$kModelSubDir/$kModelFileName';
  }
}
