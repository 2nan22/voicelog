import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:voicelog_ai/core/constants/prompts.dart';
import 'package:voicelog_ai/core/utils/logger.dart';

part 'model_download_notifier.freezed.dart';
part 'model_download_notifier.g.dart';

/// 모델 다운로드 상태.
@freezed
class ModelDownloadState with _$ModelDownloadState {
  const factory ModelDownloadState.idle() = ModelDownloadIdle;
  const factory ModelDownloadState.checking() = ModelDownloadChecking;
  const factory ModelDownloadState.alreadyExists() = ModelDownloadAlreadyExists;
  const factory ModelDownloadState.downloading({
    required double progress, // 0.0 ~ 1.0
    required int receivedBytes,
    required int totalBytes,
  }) = ModelDownloading;
  const factory ModelDownloadState.done() = ModelDownloadDone;
  const factory ModelDownloadState.error({required String message}) = ModelDownloadError;
}

@riverpod
class ModelDownloadNotifier extends _$ModelDownloadNotifier {
  @override
  ModelDownloadState build() => const ModelDownloadState.idle();

  /// 모델 파일 존재 여부를 확인하고, 없으면 자동 다운로드한다.
  Future<void> ensureModelReady() async {
    state = const ModelDownloadState.checking();

    try {
      final modelPath = await _getModelPath();
      final modelFile = File(modelPath);

      if (modelFile.existsSync() && modelFile.lengthSync() > 0) {
        AppLogger.info('모델 파일 이미 존재: $modelPath');
        state = const ModelDownloadState.alreadyExists();
        return;
      }

      AppLogger.info('모델 파일 없음. 다운로드 시작: $kModelDownloadUrl');
      await _download(modelFile);
    } catch (e) {
      AppLogger.error('모델 다운로드 실패', e);
      state = ModelDownloadState.error(message: e.toString());
    }
  }

  Future<void> _download(File destFile) async {
    await destFile.parent.create(recursive: true);

    final tmpFile = File('${destFile.path}.tmp');
    final client = HttpClient();

    try {
      final request = await client.getUrl(Uri.parse(kModelDownloadUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('다운로드 실패 (HTTP ${response.statusCode})');
      }

      final totalBytes = response.contentLength;
      int receivedBytes = 0;

      final sink = tmpFile.openWrite();
      await for (final chunk in response) {
        sink.add(chunk);
        receivedBytes += chunk.length;

        if (totalBytes > 0) {
          state = ModelDownloadState.downloading(
            progress: receivedBytes / totalBytes,
            receivedBytes: receivedBytes,
            totalBytes: totalBytes,
          );
        }
      }
      await sink.flush();
      await sink.close();

      // tmp → 최종 경로로 원자적 rename (중간 실패 시 오염 방지)
      await tmpFile.rename(destFile.path);
      AppLogger.info('모델 다운로드 완료: ${destFile.path}');
      state = const ModelDownloadState.done();
    } catch (e) {
      if (tmpFile.existsSync()) await tmpFile.delete();
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<String> _getModelPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$kModelSubDir/$kModelFileName';
  }

  Future<void> retry() => ensureModelReady();
}
