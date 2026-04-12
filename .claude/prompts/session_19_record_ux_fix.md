# Session 19 — 녹음 화면 UX 버그 수정 & Stitch 정합성

## 목표

`diary_record_screen.dart` 기반 녹음 UX를 **실제로 동작하도록** 수정한다.
디자인 교체(Session 18)로 레이아웃은 완료되었으나, 핵심 UX 흐름 3가지에 버그가 있다.

---

## 사전 조건

- `feat/init-20260411` 브랜치, Session 18(Stitch v0.0.2 UI 전면 개편) 커밋 완료 상태
- 참고 디자인: `.claude/stitch/v0.0.2-20260412/ai/screen.png`, `ai/code.html`
- 규칙: `.claude/rules/ui_ux.md`, `.claude/rules/flutter_conventions.md`

---

## Stitch screen.png 기준 UX 시나리오

```
[idle]
  헤딩: "오늘의 목소리를 담아보세요"
  서브: "마이크 버튼을 눌러 시작하세요"
  컨테이너: 마이크 아이콘 + 힌트 텍스트

[recording]
  배지: ● 실시간 녹음 중
  헤딩: "생각을 기록하고 있습니다"
  서브: "자연스럽게 말씀해 주세요. AI가 경청하고 있습니다."  ← 현재와 다름
  컨테이너: STT 인식 텍스트 실시간 표시 (인용 스타일, 22sp)
  파형: 실제 마이크 음량에 반응하는 바 파형
  컨트롤: X(취소) | MicButton(128px) | ■(stop/완료)

[processing]
  배지: ✦ AI 처리 중
  헤딩: "AI가 다듬는 중입니다"
  서브: "잠시만 기다려 주세요"
  컨테이너: 스피너 + "생각을 정리하고 있어요..." → 스트리밍 텍스트로 전환
  AI 배지: "✦ AI 엔진 가동 중" (스피닝)
  파형: 숨김

[done]
  배지: ✓ 보정 완료
  헤딩: "보정이 완료되었습니다"
  서브: "일기를 저장하거나 다시 녹음할 수 있어요"
  컨테이너: 보정 텍스트 + Divider + 감정 칩/태그
  컨트롤: ↺(재녹음) | ▶(재생) | ✓(저장, Primary)
```

---

## 버그 1: 파형이 실제 음량에 반응하지 않음

### 원인 분석

`waveform_widget.dart`의 `_WaveformPainter._barHeight()`:

```dart
double _barHeight(int index, double maxHeight) {
  if (!isRecording) return 4.0;

  if (index < amplitudes.length) {
    // ❌ 문제: index 0이 가장 오래된 amplitude 값 → 파형이 슬라이딩되지 않음
    return (amplitudes[index] * maxHeight).clamp(4.0, maxHeight);
  }

  // amplitudes가 없으면 sin 애니메이션 → "막 움직이는" 현상의 원인
  final phase = (index / _barCount) * 2 * pi + animationValue * 2 * pi;
  return (sin(phase).abs() * 0.7 + 0.3) * maxHeight;
}
```

**두 가지 문제**:
1. `amplitudes[index]` 직접 접근 → bar[0]이 가장 오래된 값. 최신값이 오른쪽 끝에 와야 함.
2. `amplitudes`가 비어있거나 드물게 업데이트되면 항상 sin 파형 → 음량과 무관하게 움직임.

`speech_to_text`의 `onSoundLevelChange`는 실제 기기에서 호출 빈도가 불규칙할 수 있음.
결국 `amplitudes` 배열이 비어있는 경우가 많아 sin 애니메이션만 실행된다.

### 수정 방향

**`waveform_widget.dart` 수정**:

```dart
double _barHeight(int index, double maxHeight) {
  if (!isRecording) return 4.0;

  if (amplitudes.isNotEmpty) {
    // 최신 amplitude를 오른쪽 끝 bar에 매핑
    // bar[_barCount-1] = amplitudes.last, bar[0] = amplitudes에서 _barCount개 앞
    final offset = amplitudes.length - _barCount;
    final ampIndex = offset + index;
    if (ampIndex >= 0 && ampIndex < amplitudes.length) {
      return (amplitudes[ampIndex] * maxHeight).clamp(4.0, maxHeight);
    }
    // 아직 충분한 데이터가 없는 초기 구간 → 최신 amplitude로 변조된 sin
    final latestAmp = amplitudes.last;
    final phase = (index / _barCount) * 2 * pi;
    return ((sin(phase).abs() * 0.5 + 0.5) * latestAmp * maxHeight).clamp(4.0, maxHeight);
  }

  // amplitude 데이터 없음 → 조용한 flat 상태 (4px)
  // 기존의 random sin 대신 flat을 유지해 "아무 반응 없음"임을 명확히 표시
  return 4.0;
}
```

> **판단 기준**: 진폭 데이터가 없을 때 sin 애니메이션을 보여주는 게 맞는지 재검토.
> 실제 기기에서 `onSoundLevelChange`가 잘 작동하면 진폭 데이터가 들어오므로 flat이 맞음.
> 그러나 기기 호환성 문제로 진폭이 아예 안 오는 경우를 대비해 낮은 진폭의 sin 애니메이션을 유지할 수도 있음.
> **우선순위**: amplitude가 있으면 실제 음량 반응, 없으면 조용한 sin (amplitude: 0.3 이하).

**수정 파일**: `lib/features/diary/presentation/widgets/waveform_widget.dart`

---

## 버그 2: LLM 처리 중 UX — 스피너와 메시지가 불명확

### 현재 상태

`_GlassSttContainer._buildLlmContent()`:
- `rawAccumulated.isEmpty` → `LoadingShimmer` (shimmer 바만 표시)
- `rawAccumulated` 있음 → `StreamingTextWidget` (텍스트 스트리밍)

### 문제점

1. Shimmer만 있어서 "AI가 처리 중"임을 직관적으로 알 수 없음
2. "생각을 정리하고 있어요..." 같은 명시적 메시지 없음
3. LLM 출력이 `[보정본]` 태그 전에 먼저 누적되는 원문 텍스트가 표시될 수 있음

### 수정 방향

`_GlassSttContainer._buildLlmContent()` 수정:

```dart
Widget _buildLlmContent(BuildContext context, LlmParsedResult? parsedResult) {
  // 1. done + 파싱 완료: 보정 결과 표시
  if (recordingState == RecordingState.done && parsedResult != null) {
    return _buildDoneContent(context, parsedResult);
  }

  // 2. processing + 스트리밍 텍스트 있음: [보정본] 추출하여 표시
  final accumulated = ...; // ref.watch 필요 → ConsumerWidget으로 변경 필요
  if (accumulated.isNotEmpty) {
    return Column(
      children: [
        Text('AI 보정 레이블'),
        StreamingTextWidget(),
      ],
    );
  }

  // 3. processing + 텍스트 없음: 스피너 + 메시지
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CircularProgressIndicator(color: scheme.primary, strokeWidth: 2.5),
      SizedBox(height: 16),
      Text(
        '생각을 정리하고 있어요...',
        style: bodyMedium (onSurfaceVariant),
      ),
    ],
  );
}
```

> **주의**: `_GlassSttContainer`가 현재 `StatelessWidget`이므로 `rawAccumulated`를 직접 watch하려면
> `ConsumerWidget`으로 변경이 필요하거나, `processState`를 파라미터로 받아야 함.
> 현재 `DiaryRecordScreen.build()`에서 `diaryProcessNotifierProvider`를 watch하지 않으므로
> `_GlassSttContainer`에 `processState`를 주입하거나 내부에서 watch하도록 수정.

**수정 파일**: `lib/features/diary/presentation/screens/diary_record_screen.dart`

---

## 버그 3: Stitch screen.png 대비 세부 UI 불일치

### 3-1. 서브텍스트 (recording 상태)

| | 현재 | Stitch |
|---|---|---|
| recording 서브 | "자연스럽게 말씀해 주세요" | "자연스럽게 말씀해 주세요. AI가 경청하고 있습니다." |

`_DiaryRecordScreenState._subtitleText()` 수정:
```dart
RecordingState.recording => '자연스럽게 말씀해 주세요. AI가 경청하고 있습니다.',
```

### 3-2. STT 텍스트 스타일 (컨테이너 내부)

screen.png: 22~24sp, fontWeight w600, 인용 스타일, 일부 단어 Primary 강조
현재: `bodyLarge (16sp)` → 너무 작음

`_GlassSttContainer._buildSttContent()` 수정:
```dart
Text(
  sttText,
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.6,
    color: AppColors.onSurface,
    letterSpacing: -0.3,
  ),
),
```

### 3-3. 컨트롤 버튼 — recording 상태 우측 버튼

screen.png: ■ (stop, 사각형) 아이콘
현재: `Icons.check_rounded` (체크 마크)

`_ControlsRow._buildRightButton()` recording 케이스:
```dart
RecordingState.recording => _RoundButton(
  icon: Icons.stop_rounded,  // check_rounded → stop_rounded
  tooltip: AppStrings.btnFinishRecording,
  onTap: onFinishRecording,
  isFilled: true,
),
```

---

## 수정 파일 전체 목록

| 파일 | 꼭지 | 변경 내용 |
|------|------|-----------|
| `lib/features/diary/presentation/widgets/waveform_widget.dart` | 꼭지 1 | amplitude 인덱스 매핑 수정, 데이터 없을 때 flat 또는 저진폭 sin |
| `lib/features/diary/presentation/screens/diary_record_screen.dart` | 꼭지 2, 3 | processing UX (스피너+메시지), 서브텍스트, STT 텍스트 스타일, stop 아이콘 |

---

## 꼭지 구성

### 꼭지 1 — 파형 amplitude 매핑 수정

- `waveform_widget.dart` 수정
- `_WaveformPainter._barHeight()` 로직: 최신값 → 오른쪽 끝 bar 매핑
- amplitude 없을 때: flat(4px) 또는 저진폭 sin (0.3 이하)

```
---
[커밋 준비 — 꼭지 1]
fix(record): 파형 amplitude 인덱스 매핑 수정 — 최신값 우측 정렬

- amplitude 없을 때 sin 랜덤 대신 flat(4px) 유지 → 음량 무반응 명확화
- 최신 amplitude를 가장 오른쪽 bar에 매핑 (슬라이딩 윈도우 방향 수정)

다음 꼭지: LLM processing UX 및 세부 UI 수정
---
```

### 꼭지 2 — LLM processing UX + 세부 UI

- `diary_record_screen.dart` 수정
- `_GlassSttContainer`: ConsumerWidget 변환 or processState 주입
  - processing + empty → 스피너 + "생각을 정리하고 있어요..."
  - processing + 텍스트 있음 → StreamingTextWidget
  - done → 보정 결과 + 감정/태그
- `_subtitleText()`: recording 서브텍스트 업데이트
- `_buildSttContent()`: STT 텍스트 22sp, fontWeight w600
- `_buildRightButton()`: recording → `Icons.stop_rounded`

```
---
[커밋 준비 — 꼭지 2]
fix(record): LLM processing UX 개선 및 세부 UI Stitch 정합성 수정

- processing 중: 스피너 + "생각을 정리하고 있어요..." (shimmer 대체)
- STT 텍스트: 22sp bold → screen.png 인용 스타일 반영
- recording 우측 버튼: check → stop_rounded
- recording 서브텍스트: "AI가 경청하고 있습니다" 문구 추가

Session 19 완료.
---
```

---

## 작업 전 확인 사항

1. `_GlassSttContainer`가 `processState`를 어떻게 받을지 결정:
   - **방안 A** (권장): `_GlassSttContainer`를 `ConsumerWidget`으로 변경, 내부에서 `ref.watch(diaryProcessNotifierProvider)`
   - **방안 B**: `DiaryRecordScreen.build()`에서 `processState` 를 watch하여 파라미터로 전달

2. 파형 flat 전략 vs 저진폭 sin:
   - 실기기 테스트 없이는 확인 불가
   - 기본값: amplitude 없으면 **저진폭 sin (maxAmplitude: 0.25)** 유지 → 시각적으로 "대기 중" 느낌
   - amplitude 있으면 실제 음량 반영
