# Session 07 — LLM 스트리밍 처리 및 결과 UI

## 목표
STT 완료 후 LLM 처리 흐름을 연결하고, 스트리밍 텍스트 및 감정/태그 칩 UI를 구현한다.
이 세션이 끝나면 음성 녹음 → AI 보정 → 감정/태그 표시까지 전체 흐름이 동작한다.

## 참고 규칙 파일
- `.claude/rules/mediapipe_llm.md` (스트리밍, 파서, 생명주기)
- `.claude/rules/state_management.md` (StreamProvider, ref.listen)
- `.claude/rules/performance.md` (Isolate, 발열 타이머)

## UI 디자인 참고
- **Google Stitch 디자인을 우선 참고한다.**
- 스트리밍 텍스트 출력 영역, 감정·태그 칩 배치, 저장 버튼 디자인은 Stitch 기준으로 구현한다.

---

## 꼭지 1 — LLM 처리 흐름 연결 (DiaryRecordScreen 업데이트)

### 작업 내용

1. `DiaryRecordScreen`에서 STT 처리 완료(`RecordingState.processing`) 감지 시
   `llmStreamProvider`를 트리거하도록 `ref.listen` 추가

   ```dart
   // DiaryRecordScreen.build() 내부에 추가
   ref.listen(diaryRecordNotifierProvider, (prev, next) {
     if (prev != RecordingState.processing &&
         next == RecordingState.processing) {
       // LLM 스트리밍 시작: 발열 타이머 시작
       _startInferenceTimer();
     }
   });
   ```

2. `lib/features/diary/application/llm_provider.dart`의 `_buildPrompt()` 완성

   ```dart
   import 'package:voicelog_ai/core/constants/prompts.dart';

   String _buildPrompt(String rawText) {
     return kDiaryProcessingPrompt.replaceAll('{raw_text}', rawText);
   }
   ```

3. LLM 스트리밍 중 30초 초과 시 경고 다이얼로그 표시

   ```dart
   // DiaryRecordScreen 내부
   Timer? _inferenceTimer;

   void _startInferenceTimer() {
     _inferenceTimer?.cancel();
     _inferenceTimer = Timer(const Duration(seconds: 30), () {
       if (mounted) {
         showDialog(
           context: context,
           builder: (_) => AlertDialog(
             title: const Text('처리 지연'),
             content: Text(AppStrings.errorTimeout),
             actions: [
               TextButton(
                 onPressed: () => Navigator.pop(context),
                 child: const Text('확인'),
               ),
             ],
           ),
         );
       }
     });
   }

   @override
   void dispose() {
     _inferenceTimer?.cancel();
     super.dispose();
   }
   ```

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 1]
feat(diary): STT 완료 → LLM 스트리밍 파이프라인 연결

- DiaryRecordScreen: processing 상태 감지 시 llmStreamProvider 트리거
- kDiaryProcessingPrompt 치환 로직 완성
- 30초 초과 시 경고 다이얼로그 표시 (발열 관리)

다음 꼭지(StreamingTextWidget)를 진행할까요?
---
```

---

## 꼭지 2 — StreamingTextWidget (타이핑 효과)

### 작업 내용

1. `lib/features/diary/presentation/widgets/streaming_text_widget.dart` 작성

   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:voicelog_ai/core/widgets/loading_shimmer.dart';
   import 'package:voicelog_ai/features/diary/application/diary_record_provider.dart';
   import 'package:voicelog_ai/features/diary/application/llm_provider.dart';

   /// LLM 스트리밍 응답을 실시간으로 표시하는 위젯.
   /// processing 상태에서 shimmer → 스트리밍 텍스트 순으로 전환한다.
   class StreamingTextWidget extends ConsumerWidget {
     final String rawText;

     const StreamingTextWidget({super.key, required this.rawText});

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final recordingState = ref.watch(diaryRecordNotifierProvider);

       if (recordingState != RecordingState.processing &&
           recordingState != RecordingState.done) {
         return const SizedBox.shrink();
       }

       final llmStream = ref.watch(llmStreamProvider(rawText));

       return llmStream.when(
         loading: () => const LoadingShimmer(),
         error: (e, _) => Text(
           '오류가 발생했어요: $e',
           style: TextStyle(
             color: Theme.of(context).colorScheme.error,
           ),
         ),
         data: (partialText) => _StreamingText(text: partialText),
       );
     }
   }

   /// 텍스트가 토큰 단위로 누적되어 표시되는 애니메이션 텍스트
   class _StreamingText extends StatefulWidget {
     final String text;
     const _StreamingText({required this.text});

     @override
     State<_StreamingText> createState() => _StreamingTextState();
   }

   class _StreamingTextState extends State<_StreamingText>
       with SingleTickerProviderStateMixin {
     late AnimationController _cursorController;

     @override
     void initState() {
       super.initState();
       // 커서 깜빡임 애니메이션
       _cursorController = AnimationController(
         vsync: this,
         duration: const Duration(milliseconds: 500),
       )..repeat(reverse: true);
     }

     @override
     void dispose() {
       _cursorController.dispose();
       super.dispose();
     }

     @override
     Widget build(BuildContext context) {
       return AnimatedBuilder(
         animation: _cursorController,
         builder: (context, _) {
           final cursor = _cursorController.value > 0.5 ? '|' : '';
           return Text(
             '${widget.text}$cursor',
             style: Theme.of(context).textTheme.bodyLarge,
           );
         },
       );
     }
   }
   ```

2. `DiaryRecordScreen`의 텍스트 영역에서 `StreamingTextWidget`을 조건부로 표시

   > **Google Stitch 참고**: 스트리밍 텍스트 영역의 카드 배경, 테두리, 커서 스타일을 Stitch 디자인에 맞게 조정한다.

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 2]
feat(diary/presentation): StreamingTextWidget — LLM 스트리밍 실시간 출력 UI

- LoadingShimmer → 스트리밍 텍스트 순 전환
- 커서 깜빡임 애니메이션으로 생동감 표현
- DiaryRecordScreen 텍스트 영역에 통합

다음 꼭지(LLM 응답 파싱 → EmotionChip + Tag 칩 렌더링)를 진행할까요?
---
```

---

## 꼭지 3 — 응답 파싱 및 감정·태그 칩 렌더링

### 작업 내용

1. `lib/features/diary/application/diary_process_provider.dart` 작성
   - LLM 스트림이 완료되면 응답 전체를 파싱
   - 파싱 결과(`LlmParsedResult`)를 상태로 보유

   ```dart
   import 'package:riverpod_annotation/riverpod_annotation.dart';
   import 'package:voicelog_ai/core/utils/llm_response_parser.dart';
   import 'package:voicelog_ai/features/diary/application/llm_provider.dart';

   part 'diary_process_provider.g.dart';

   /// LLM 전체 응답 누적 및 파싱 결과 Provider
   @riverpod
   class DiaryProcessNotifier extends _$DiaryProcessNotifier {
     final StringBuffer _buffer = StringBuffer();

     @override
     LlmParsedResult? build() => null;

     void appendChunk(String chunk) {
       _buffer.write(chunk);
       // 파싱 가능한 완결 신호 감지 시 파싱
       if (_buffer.toString().contains('[태그]')) {
         state = LlmResponseParser.parse(_buffer.toString());
       }
     }

     void finalize() {
       state = LlmResponseParser.parse(_buffer.toString());
     }

     void reset() {
       _buffer.clear();
       state = null;
     }
   }
   ```

2. `llmStreamProvider`의 스트림을 `DiaryProcessNotifier.appendChunk()`로 연결
   (스트림 완료 시 `finalize()` 호출)

3. `lib/features/diary/presentation/widgets/diary_result_widget.dart` 작성

   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:voicelog_ai/core/constants/dimensions.dart';
   import 'package:voicelog_ai/core/widgets/emotion_chip.dart';
   import 'package:voicelog_ai/features/diary/application/diary_process_provider.dart';

   /// LLM 파싱 결과(보정본, 감정, 태그)를 표시하는 위젯.
   class DiaryResultWidget extends ConsumerWidget {
     const DiaryResultWidget({super.key});

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final result = ref.watch(diaryProcessNotifierProvider);
       if (result == null) return const SizedBox.shrink();

       return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           // 감정 칩
           EmotionChip(emotion: result.emotion),
           const SizedBox(height: AppDimensions.paddingSmall),
           // 태그 칩 목록
           Wrap(
             spacing: 8,
             children: result.tags
                 .map((tag) => Chip(label: Text(tag)))
                 .toList(),
           ),
         ],
       );
     }
   }
   ```

4. `build_runner` 실행 및 `flutter analyze` 확인
5. 실기기에서 전체 흐름 테스트: 녹음 → STT → LLM → 감정/태그 표시

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 3]
feat(diary): LLM 응답 파싱 → 감정 칩 및 태그 칩 렌더링

- DiaryProcessNotifier: 스트림 청크 누적 + LlmResponseParser 파싱
- DiaryResultWidget: EmotionChip + 태그 Chip Wrap 레이아웃
- 전체 흐름 연동: 녹음→STT→LLM→감정/태그 표시

Session 07 완료. Session 08로 넘어가려면 session_08_diary_list.md 파일을 참고하세요.
---
```
