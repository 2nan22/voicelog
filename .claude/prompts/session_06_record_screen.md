# Session 06 — 일기 녹음 화면 UI

## 목표
음성 녹음 화면의 레이아웃, 파형 위젯, 마이크 버튼 애니메이션을 구현한다.

## 참고 규칙 파일
- `.claude/rules/ui_ux.md` (Material 3, 애니메이션 규칙)
- `.claude/rules/performance.md` (RepaintBoundary, CustomPainter)
- `.claude/rules/state_management.md` (ConsumerWidget, ref.watch)

## UI 디자인 참고
- **Google Stitch 디자인을 우선 참고한다.**
- Stitch에서 내보낸 코드가 있으면 해당 코드의 레이아웃 구조와 컴포넌트를 최대한 반영한다.
- Stitch 코드가 없으면 아래 가이드라인을 기본으로 구현한다.

---

## 꼭지 1 — DiaryRecordScreen 기본 레이아웃

### 작업 내용

1. `lib/features/diary/presentation/screens/diary_record_screen.dart` 작성

   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:voicelog_ai/core/constants/dimensions.dart';
   import 'package:voicelog_ai/core/constants/strings.dart';
   import 'package:voicelog_ai/features/diary/application/diary_record_provider.dart';
   import 'package:voicelog_ai/features/diary/presentation/widgets/waveform_widget.dart';

   class DiaryRecordScreen extends ConsumerStatefulWidget {
     const DiaryRecordScreen({super.key});

     @override
     ConsumerState<DiaryRecordScreen> createState() => _DiaryRecordScreenState();
   }

   class _DiaryRecordScreenState extends ConsumerState<DiaryRecordScreen>
       with TickerProviderStateMixin {

     @override
     Widget build(BuildContext context) {
       final recordingState = ref.watch(diaryRecordNotifierProvider);
       final sttText = ref.watch(sttTextNotifierProvider);

       return Scaffold(
         appBar: AppBar(
           title: const Text('오늘의 일기'),
           actions: [
             if (recordingState == RecordingState.done)
               TextButton(
                 onPressed: _onSave,
                 child: Text(AppStrings.saveDiary),
               ),
           ],
         ),
         body: SafeArea(
           child: Padding(
             padding: const EdgeInsets.all(AppDimensions.paddingMedium),
             child: Column(
               children: [
                 // STT 인식 텍스트 영역
                 Expanded(
                   child: _buildTextArea(context, sttText, recordingState),
                 ),
                 const SizedBox(height: AppDimensions.paddingMedium),
                 // 파형 표시
                 WaveformWidget(
                   isRecording: recordingState == RecordingState.recording,
                 ),
                 const SizedBox(height: AppDimensions.paddingLarge),
                 // 마이크 버튼
                 _MicButton(recordingState: recordingState),
                 const SizedBox(height: AppDimensions.paddingLarge),
               ],
             ),
           ),
         ),
       );
     }

     Widget _buildTextArea(
       BuildContext context,
       String sttText,
       RecordingState state,
     ) {
       if (sttText.isEmpty) {
         return Center(
           child: Text(
             AppStrings.recordStart,
             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
               color: Theme.of(context).colorScheme.outline,
             ),
           ),
         );
       }
       return SingleChildScrollView(
         child: Text(
           sttText,
           style: Theme.of(context).textTheme.bodyLarge,
         ),
       );
     }

     Future<void> _onSave() async {
       // Session 07에서 LLM 처리 연동 후 완성
     }
   }
   ```

2. `_MicButton` 위젯을 같은 파일 하단에 private 위젯으로 작성
   - `RecordingState`에 따라 아이콘·색상 변경
   - `onPressed` 시 STT 시작/중지 로직 연결 (speechToTextServiceProvider 사용)

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 1]
feat(diary/presentation): DiaryRecordScreen 기본 레이아웃 구현

- AppBar + STT 텍스트 영역 + WaveformWidget 자리 + MicButton 구조
- RecordingState에 따른 UI 분기 (idle/recording/processing/done)
- STT Provider 연동 (speechToTextServiceProvider, sttTextNotifierProvider)

다음 꼭지(WaveformWidget)를 진행할까요?
---
```

---

## 꼭지 2 — WaveformWidget (실시간 음성 파형)

### 작업 내용

1. `lib/features/diary/presentation/widgets/waveform_widget.dart` 작성

   ```dart
   import 'dart:math';
   import 'package:flutter/material.dart';

   /// 녹음 중 실시간 음성 파형을 표시하는 위젯.
   /// [isRecording]이 false이면 정지 상태(평탄선)를 표시한다.
   class WaveformWidget extends StatefulWidget {
     final bool isRecording;
     final List<double> amplitudes; // STT 진폭 데이터 (0.0 ~ 1.0)

     const WaveformWidget({
       super.key,
       required this.isRecording,
       this.amplitudes = const [],
     });

     @override
     State<WaveformWidget> createState() => _WaveformWidgetState();
   }

   class _WaveformWidgetState extends State<WaveformWidget>
       with SingleTickerProviderStateMixin {
     late AnimationController _controller;

     @override
     void initState() {
       super.initState();
       _controller = AnimationController(
         vsync: this,
         duration: const Duration(milliseconds: 800),
       )..repeat(reverse: true);
     }

     @override
     void dispose() {
       _controller.dispose();
       super.dispose();
     }

     @override
     Widget build(BuildContext context) {
       return RepaintBoundary( // 파형 repaint가 다른 위젯에 영향 주지 않도록 격리
         child: SizedBox(
           height: 60,
           child: AnimatedBuilder(
             animation: _controller,
             builder: (context, _) {
               return CustomPaint(
                 painter: _WaveformPainter(
                   isRecording: widget.isRecording,
                   amplitudes: widget.amplitudes,
                   animationValue: _controller.value,
                   color: Theme.of(context).colorScheme.primary,
                 ),
                 size: Size.infinite,
               );
             },
           ),
         ),
       );
     }
   }

   class _WaveformPainter extends CustomPainter {
     final bool isRecording;
     final List<double> amplitudes;
     final double animationValue;
     final Color color;

     _WaveformPainter({
       required this.isRecording,
       required this.amplitudes,
       required this.animationValue,
       required this.color,
     });

     @override
     void paint(Canvas canvas, Size size) {
       final paint = Paint()
         ..color = color
         ..strokeWidth = 3
         ..strokeCap = StrokeCap.round;

       final barCount = 30;
       final barWidth = size.width / (barCount * 2);

       for (int i = 0; i < barCount; i++) {
         final x = i * (size.width / barCount) + barWidth;
         double barHeight;

         if (!isRecording) {
           barHeight = 4; // 정지 상태: 평탄선
         } else if (i < amplitudes.length) {
           barHeight = amplitudes[i] * size.height;
         } else {
           // 진폭 데이터 없을 때 sin 파형으로 대체
           final phase = (i / barCount) * 2 * pi + animationValue * 2 * pi;
           barHeight = (sin(phase).abs() * 0.7 + 0.3) * size.height;
         }

         final top = (size.height - barHeight) / 2;
         canvas.drawRRect(
           RRect.fromRectAndRadius(
             Rect.fromLTWH(x - barWidth / 2, top, barWidth, barHeight),
             const Radius.circular(2),
           ),
           paint,
         );
       }
     }

     @override
     bool shouldRepaint(_WaveformPainter oldDelegate) =>
         oldDelegate.isRecording != isRecording ||
         oldDelegate.animationValue != animationValue ||
         oldDelegate.amplitudes != amplitudes;
   }
   ```

   > **Google Stitch 디자인 참고**: Stitch에서 파형 모양이나 색상이 다를 경우
   > `_WaveformPainter`의 `barCount`, `barWidth`, `color` 값을 조정한다.

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 2]
feat(diary/presentation): WaveformWidget 실시간 음성 파형 구현

- CustomPainter 기반 막대형 파형 (30개 바)
- 녹음 중: 진폭 데이터 또는 sin 애니메이션 / 정지: 평탄선
- RepaintBoundary로 렌더링 격리, shouldRepaint 최적화

다음 꼭지(마이크 버튼 펄스 애니메이션)를 진행할까요?
---
```

---

## 꼭지 3 — 마이크 버튼 펄스 애니메이션

### 작업 내용

1. `_MicButton` private 위젯을 `diary_record_screen.dart`에서 분리하여
   `lib/features/diary/presentation/widgets/mic_button.dart`로 이동

   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:voicelog_ai/core/constants/dimensions.dart';
   import 'package:voicelog_ai/features/diary/application/diary_record_provider.dart';
   import 'package:voicelog_ai/features/diary/infrastructure/speech_to_text_service.dart';

   /// 녹음 시작/중지 마이크 버튼.
   /// 녹음 중일 때 펄스(ripple) 애니메이션을 표시한다.
   class MicButton extends ConsumerStatefulWidget {
     const MicButton({super.key});

     @override
     ConsumerState<MicButton> createState() => _MicButtonState();
   }

   class _MicButtonState extends ConsumerState<MicButton>
       with SingleTickerProviderStateMixin {
     late AnimationController _pulseController;
     late Animation<double> _pulseAnimation;

     @override
     void initState() {
       super.initState();
       _pulseController = AnimationController(
         vsync: this,
         duration: const Duration(milliseconds: 1000),
       );
       _pulseAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
         CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
       );
     }

     @override
     void dispose() {
       _pulseController.dispose();
       super.dispose();
     }

     Future<void> _onTap() async {
       final state = ref.read(diaryRecordNotifierProvider);
       final sttService = ref.read(speechToTextServiceProvider);
       final notifier = ref.read(diaryRecordNotifierProvider.notifier);
       final sttNotifier = ref.read(sttTextNotifierProvider.notifier);

       if (state == RecordingState.idle) {
         final granted = await sttService.initialize();
         if (!granted) return;
         notifier.startRecording();
         _pulseController.repeat(reverse: true);
         await sttService.startListening(
           onResult: (text, isFinal) {
             sttNotifier.update(text);
             if (isFinal) {
               notifier.startProcessing();
               _pulseController.stop();
               _pulseController.reset();
             }
           },
         );
       } else if (state == RecordingState.recording) {
         await sttService.stopListening();
         notifier.startProcessing();
         _pulseController.stop();
         _pulseController.reset();
       }
     }

     @override
     Widget build(BuildContext context) {
       final state = ref.watch(diaryRecordNotifierProvider);
       final isRecording = state == RecordingState.recording;
       final primaryColor = Theme.of(context).colorScheme.primary;

       return GestureDetector(
         onTap: state == RecordingState.processing ? null : _onTap,
         child: AnimatedBuilder(
           animation: _pulseAnimation,
           builder: (context, child) {
             return Stack(
               alignment: Alignment.center,
               children: [
                 if (isRecording)
                   Transform.scale(
                     scale: _pulseAnimation.value,
                     child: Container(
                       width: AppDimensions.micButtonSize,
                       height: AppDimensions.micButtonSize,
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         color: primaryColor.withOpacity(0.2),
                       ),
                     ),
                   ),
                 child!,
               ],
             );
           },
           child: Container(
             width: AppDimensions.micButtonSize,
             height: AppDimensions.micButtonSize,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               color: isRecording
                   ? Theme.of(context).colorScheme.errorContainer
                   : primaryColor,
             ),
             child: Icon(
               isRecording ? Icons.stop : Icons.mic,
               color: isRecording
                   ? Theme.of(context).colorScheme.onErrorContainer
                   : Theme.of(context).colorScheme.onPrimary,
               size: 32,
             ),
           ),
         ),
       );
     }
   }
   ```

2. `DiaryRecordScreen`에서 `_MicButton` → `MicButton` import로 교체

3. `flutter analyze` 오류 없음 확인
4. `flutter run` 후 마이크 버튼 펄스 애니메이션 동작 확인

   > **Google Stitch 참고**: 버튼 크기, 색상, 애니메이션 강도가 다를 경우
   > `AppDimensions.micButtonSize` 값과 `Tween(begin: 1.0, end: 1.4)` 범위를 조정한다.

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 3]
feat(diary/presentation): MicButton 펄스 애니메이션 및 STT 녹음 흐름 연동

- MicButton: 녹음 중 펄스(ripple) 애니메이션 (AnimationController)
- STT 시작/중지 → DiaryRecordNotifier 상태 전이 연결
- 위젯 분리: mic_button.dart로 이동

Session 06 완료. Session 07로 넘어가려면 session_07_llm_streaming_ui.md 파일을 참고하세요.
---
```
