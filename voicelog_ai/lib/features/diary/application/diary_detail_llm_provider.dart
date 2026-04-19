import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:voicelog_ai/core/constants/prompts.dart';
import 'package:voicelog_ai/core/utils/llm_response_parser.dart';
import 'package:voicelog_ai/core/utils/logger.dart';
import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';
import 'package:voicelog_ai/features/diary/application/llm_provider.dart';
import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';
import 'package:voicelog_ai/features/settings/domain/app_settings.dart';

part 'diary_detail_llm_provider.freezed.dart';
part 'diary_detail_llm_provider.g.dart';

enum DetailLlmPhase { idle, running, done, error }

/// 상세 화면 LLM 재처리 상태.
@freezed
class DetailLlmState with _$DetailLlmState {
  const factory DetailLlmState({
    @Default(DetailLlmPhase.idle) DetailLlmPhase phase,
    @Default('') String accumulated,
  }) = _DetailLlmState;
}

/// 상세 화면 LLM 재처리 Notifier. entryId를 키로 하는 family Provider.
@riverpod
class DiaryDetailLlmNotifier extends _$DiaryDetailLlmNotifier {
  @override
  DetailLlmState build(int entryId) => const DetailLlmState();

  /// 메타데이터(제목/감정/태그/인물/장소)를 재추출하여 저장한다.
  Future<void> reExtractMetadata(DiaryEntry entry) async {
    final service = ref.read(llmInferenceServiceProvider);
    if (!service.isReady) {
      try {
        await service.initialize();
      } catch (e) {
        AppLogger.error('LLM 초기화 실패', e);
        state = state.copyWith(phase: DetailLlmPhase.error);
        return;
      }
    }

    state = const DetailLlmState(phase: DetailLlmPhase.running);

    try {
      final prompt = kMetadataExtractionPrompt.replaceAll('{raw_text}', entry.rawText);
      var accumulated = '';
      await for (final chunk in service.generateStream(prompt)) {
        accumulated += chunk;
        state = state.copyWith(accumulated: accumulated);
      }

      final result = LlmResponseParser.parseMetadata(accumulated);
      final updated = entry.copyWith(
        title: result.title,
        emotion: result.emotion,
        tags: result.tags,
        people: result.people,
        places: result.places,
      );
      await ref.read(diaryListNotifierProvider.notifier).updateEntry(updated);
      state = state.copyWith(phase: DetailLlmPhase.done, accumulated: '');
    } catch (e) {
      AppLogger.error('메타데이터 재추출 실패', e);
      state = state.copyWith(phase: DetailLlmPhase.error);
    }
  }

  /// 문맥 보정을 실행하여 correctedText를 갱신한다.
  Future<void> runCorrection(DiaryEntry entry, WritingStyle style) async {
    final service = ref.read(llmInferenceServiceProvider);
    if (!service.isReady) {
      try {
        await service.initialize();
      } catch (e) {
        AppLogger.error('LLM 초기화 실패', e);
        state = state.copyWith(phase: DetailLlmPhase.error);
        return;
      }
    }

    state = const DetailLlmState(phase: DetailLlmPhase.running);

    try {
      final styleInstruction =
          kWritingStyleInstructions[style] ?? kWritingStyleInstructions[WritingStyle.diary]!;
      final prompt = kCorrectionPrompt
          .replaceAll('{style_instruction}', styleInstruction)
          .replaceAll('{raw_text}', entry.rawText);
      var accumulated = '';
      await for (final chunk in service.generateStream(prompt)) {
        accumulated += chunk;
        state = state.copyWith(accumulated: accumulated);
      }

      final corrected = LlmResponseParser.parseCorrectedText(accumulated);
      final updated = entry.copyWith(
        correctedText: corrected.isEmpty ? null : corrected,
      );
      await ref.read(diaryListNotifierProvider.notifier).updateEntry(updated);
      state = state.copyWith(phase: DetailLlmPhase.done, accumulated: '');
    } catch (e) {
      AppLogger.error('문맥 보정 실패', e);
      state = state.copyWith(phase: DetailLlmPhase.error);
    }
  }
}
