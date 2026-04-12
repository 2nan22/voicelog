# Session 18 — Stitch v0.0.2 기반 UI 전면 개선

## 목표

Stitch(`.claude/stitch/v0.0.2-20260412/`)에서 생성된 디자인을 현재 Flutter 구현에 반영한다.
**기능 로직은 건드리지 않고 UI/UX 레이어만 교체**한다.

| Stitch 파일 | 대응 화면 | 디자인 시스템 |
|-------------|-----------|---------------|
| `_1/code.html` | 홈 화면 (`diary_list_screen.dart`) | Seoul Minimalist (Primary `#3182F6`) |
| `ai/code.html` | 녹음 화면 (`diary_record_screen.dart`) | Indigo Serenity (Primary `#0d46d1`) |
| `_2/code.html` | 일기 상세 (`diary_detail_screen.dart`) | Indigo Serenity |

> **공통 원칙** (`voicelog_ai_ux.html` 및 DESIGN.md 기준)
> - Primary: `#3182F6` (Vivid Blue — 토스 스타일, 신뢰·전문성)
> - No-Line Rule: 1px solid border로 섹션 구분 금지 → 배경색 계층(tonal shift)으로 구분
> - Glassmorphism: 플로팅 요소(하단 nav, 헤더, 녹음 컨테이너)에 80% opacity + backdrop-blur 20px
> - Pretendard Variable 폰트, 한국어 자간 -2%, 행간 1.6~1.8
> - 하드코딩 색상 금지 — `AppColors` 상수 및 `ColorScheme` 사용

---

## 사전 조건

- `feat/init-20260411` 브랜치, Session 17(홈 캘린더 뷰) 커밋 완료 상태
- 참고 규칙: `.claude/rules/ui_ux.md`, `.claude/rules/flutter_conventions.md`
- Stitch 디자인 원본: `.claude/stitch/v0.0.2-20260412/`
- UI 파일 목록: `.claude/plan_stitch/ui_files_index.md`

---

## ⚠️ UX 구조 변경 사항 (작업 전 사용자 확인 필요)

Stitch 디자인에서 **탭 네비게이션 구조**가 현재 구현과 다름.

| | 현재 구현 | Stitch 설계 |
|---|-----------|-------------|
| 탭 1 | 홈 (캘린더) | 홈 (캘린더) |
| 탭 2 | 로그 (월별 타임라인) | 기록 (녹음 화면 직접 진입) |
| 탭 3 | 인사이트 | 인사이트 |
| 탭 4 | 프로필 | 설정 |

Stitch는 로그/프로필 탭을 제거하고, 녹음을 탭으로 올린 구조.
이 변경은 라우팅 재편(`main_shell.dart`, `app.dart`, go_router)을 수반하므로
**꼭지 작업 시작 전 사용자에게 확인**: 탭 구조 변경 적용 여부 결정 후 진행.

---

## 꼭지 1 — 색상 시스템 & 테마 업데이트

### 대상 파일

| 파일 | 작업 |
|------|------|
| `lib/core/theme/app_colors.dart` | 색상 상수 추가 및 seed 업데이트 |
| `lib/core/theme/app_theme.dart` | 서피스 계층 색상, 폰트 설정 확인 |

### 변경 내용

#### `app_colors.dart`

현재 seed: `#0059B9` → Stitch 기준으로 `#3182F6` (토스 Vivid Blue)로 업데이트.

```dart
class AppColors {
  AppColors._();

  // Primary — Stitch 기준 토스/삼성 스타일 블루
  static const Color seed = Color(0xFF3182F6);

  // 서피스 계층 (Stitch "Seoul Minimalist" 기준)
  static const Color background          = Color(0xFFF9FAFB);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer    = Color(0xFFE5E8EB);
  static const Color onSurface          = Color(0xFF191F28);
  static const Color onSurfaceVariant   = Color(0xFF4E5968);
  static const Color outlineVariant     = Color(0xFFE5E8EB);

  // 감정 색상 (기존 유지)
  static const Color emotionJoy     = Color(0xFFFFC107);
  static const Color emotionSadness = Color(0xFF42A5F5);
  static const Color emotionCalm    = Color(0xFF66BB6A);
  static const Color emotionAnger   = Color(0xFFEF5350);

  // 기존 호환
  static const Color surfaceDim = Color(0xFFF5F5F5);
}
```

#### `app_theme.dart`

- `ColorScheme.fromSeed(seedColor: AppColors.seed, ...)` 확인
- `fontFamily: 'Pretendard'` 및 `letterSpacing: -0.02 * fontSize` 적용 여부 확인
- `scaffoldBackgroundColor: AppColors.background` 명시 추가 (현재 기본값과 다를 수 있음)

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 1]
style(theme): Stitch v0.0.2 기준 색상 시스템 업데이트

- AppColors.seed: #0059B9 → #3182F6 (Vivid Blue)
- 서피스 계층 상수 추가 (background, surfaceContainerLow 등)
- app_theme: scaffoldBackgroundColor 및 폰트 설정 확인

다음 꼭지: 홈 화면 개선 (퀵 인사이트 벤토 추가)
---
```

---

## 꼭지 2 — 홈 화면 개선 (`diary_list_screen.dart`)

### Stitch 참고

`_1/code.html` — 변경 포인트:

1. **퀵 인사이트 벤토 그리드** (캘린더 아래, 최근 기록 위)
   - 좌: 연속 기록 카드 (Primary 배경, 흰 텍스트, bolt 아이콘, streak 일수 + 응원 문구)
   - 우: 이번 주 기분 카드 (흰 배경, psychology 아이콘, 감정 텍스트 + 진행 바)

2. **일기 카드 리디자인** (현재 `DiaryCard` → Stitch 스타일)
   - 감정 아이콘 원형 뱃지 (배경: 감정 색상 10% opacity, 아이콘: 감정 색상)
   - 제목(첫 문장 요약) + 날짜 서브텍스트
   - 본문 2줄 preview
   - 태그 칩 (배경: `surfaceContainerLow`, 작은 텍스트)
   - 카드 배경: 흰색, 그림자: `boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black.withValues(alpha: 0.05))]`

3. **헤더** (Stitch 기준)
   - 앱명 왼쪽 정렬, Primary 색상
   - 우측: 프로필 아바타 (32px 원형)
   - 글래스 배경: `Colors.white.withValues(alpha: 0.8)` + `BackdropFilter blur(20)`

### 수정 파일

| 파일 | 작업 |
|------|------|
| `lib/features/diary/presentation/screens/diary_list_screen.dart` | 퀵 인사이트 벤토 추가, 헤더 개선 |
| `lib/features/diary/presentation/widgets/diary_card.dart` | Stitch 카드 스타일로 교체 |

### 퀵 인사이트 벤토 구현 가이드

```dart
// 캘린더 SliverToBoxAdapter 바로 아래에 추가
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        // 연속 기록 카드
        Expanded(
          child: _InsightCard(
            backgroundColor: scheme.primary,
            icon: Icons.bolt,
            iconColor: Colors.white,
            label: '연속 기록',
            value: '$streakDays일째',           // diaryListNotifierProvider에서 계산
            description: '지금의 흐름을 놓치지 마세요!',
            textColor: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        // 이번 주 기분 카드
        Expanded(
          child: _InsightCard(
            backgroundColor: Colors.white,
            icon: Icons.psychology,
            iconColor: scheme.primary,
            label: '이번 주 기분',
            value: weeklyEmotion,              // 최근 7일 일기 감정 최빈값
            description: null,
            textColor: AppColors.onSurface,
          ),
        ),
      ],
    ),
  ),
),
```

> **데이터 처리 주의**: streak/weeklyEmotion은 `diaryListNotifierProvider` future에서 파생.
> `diaryByDateProvider`가 이미 있으므로 별도 Provider 추가보다 `when` 내부에서 계산 권장.
> 데이터 없을 때는 streak=0, weeklyEmotion='—'로 표시.

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 2]
feat(home): 퀵 인사이트 벤토 추가 및 일기 카드 Stitch 스타일 적용

- 캘린더 하단 연속기록/이번 주 기분 2열 벤토 카드
- DiaryCard: 감정 아이콘 원형 뱃지 + 본문 preview + 태그 스타일 개선
- 홈 헤더: 글래스 배경 + Primary 앱명 + 우측 아바타

다음 꼭지: 녹음 화면 전면 개편
---
```

---

## 꼭지 3 — 녹음 화면 전면 개편 (`diary_record_screen.dart`)

### Stitch 참고

`ai/code.html` — 핵심 변경:

1. **앰비언트 글로우 배경**: `Stack` 최하단에 Primary 10% opacity 원형 블러 2개 (blur 120px)
2. **녹음 상태 배지**: 상단 중앙에 `● 실시간 녹음 중` (error_container 배경, 빨간 점 펄스)
3. **대형 헤딩**: "생각을 기록하고 있습니다" (extraBold, 28~32sp)
4. **STT 글래스모픽 컨테이너**: 
   - 배경: `Colors.white.withValues(alpha: 0.7)` + `BackdropFilter blur(20)`
   - 둥근 모서리: 40px radius
   - 최소 높이: 200px
   - 텍스트 크기: 18~22sp, 행간 1.6
5. **AI 상태 배지**: Primary/5 배경, `auto_awesome` 스피닝 아이콘 + "AI 엔진 가동 중"
6. **파형**: 현재 WaveformWidget 유지 (배경이 바뀌므로 색상만 Primary로 조정)
7. **마이크 버튼 그룹** (좌: 취소, 중: 마이크, 우: 완료):
   - 마이크: `w-32 h-32` (128px), `gradient(primary → primary_container)`, 이중 pulse ring
   - 취소: 64px 원형, `surfaceContainer` 배경
   - 완료: 64px 원형, Primary 배경

### 현재 구현과의 주요 차이점

| 항목 | 현재 | Stitch |
|------|------|--------|
| 레이아웃 | 글래스 헤더 + 스크롤(STT카드·LLM카드) + 하단 패널 | 풀스크린 중앙 정렬, 스크롤 최소화 |
| STT 카드 | `_SttCard` (일반 Card) | 글래스모픽 컨테이너 (full-width, 40px radius) |
| LLM 결과 | `_LlmResultCard` (별도 카드) | STT 컨테이너 안에 통합 or 처리 완료 후 대체 |
| 마이크 버튼 | `MicButton` (현 72px) | 128px 그라디언트 버튼 + 이중 ping ring |
| 배경 | 단색 scaffold | 앰비언트 글로우 (blur circle) |

### 수정 파일

| 파일 | 작업 |
|------|------|
| `lib/features/diary/presentation/screens/diary_record_screen.dart` | 전면 레이아웃 교체 |
| `lib/features/diary/presentation/widgets/mic_button.dart` | 그라디언트 + 이중 ping 스타일로 교체 |
| `lib/features/diary/presentation/widgets/waveform_widget.dart` | 파형 색상 Primary로 확인·조정 |

### 레이아웃 구조 (교체 후)

```
Scaffold
  └─ Stack
       ├─ [배경] 앰비언트 글로우 (blur circle 2개, pointer-events: none)
       ├─ [콘텐츠] Column (SafeArea → paddingTop 24, paddingH 24)
       │    ├─ _GlassHeader (앱명 + 뒤로가기)
       │    ├─ Spacer(flex: 1)
       │    ├─ _RecordingStateBadge (● 녹음 중 / AI 처리 중 / 완료 — 상태별)
       │    ├─ SizedBox(height: 16)
       │    ├─ Text(헤딩 — 상태별 문구)
       │    ├─ SizedBox(height: 8)
       │    ├─ Text(서브 — "자연스럽게 말씀해 주세요")
       │    ├─ SizedBox(height: 24)
       │    ├─ _GlassSttContainer (STT/LLM 텍스트 표시)
       │    ├─ SizedBox(height: 16)
       │    ├─ _AiStatusBadge (AI 분석 중 — processing 상태에만 표시)
       │    ├─ Spacer(flex: 2)
       │    ├─ WaveformWidget (recording 상태에만 표시)
       │    ├─ SizedBox(height: 24)
       │    └─ _ControlsRow (취소 | 마이크(128px 그라디언트) | 완료)
       └─ [하단] 고정 여백 (SafeArea bottom)
```

### 상태별 UI 분기

```
RecordingState.idle       → 마이크 버튼(Primary), 헤딩: "오늘의 목소리를 담아보세요"
RecordingState.recording  → 녹음 배지 표시, 파형 표시, 헤딩: "생각을 기록하고 있습니다"
RecordingState.processing → AI 배지(스피닝), 헤딩: "AI가 다듬는 중입니다"
RecordingState.done       → LLM 결과 표시, 헤딩: "보정이 완료되었습니다"
RecordingState.error      → 에러 안내
```

> **주의**: 기존 `_SttCard`, `_LlmResultCard` Private 위젯 내부 로직(StreamingTextWidget, DiaryResultWidget 연동)은 
> 새 `_GlassSttContainer`로 이전. 실제 Provider 연동·저장 로직은 변경 없음.

### 마이크 버튼 그라디언트 구현

```dart
// mic_button.dart 또는 diary_record_screen.dart 내 _MicFab 위젯
Container(
  width: 128,
  height: 128,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [scheme.primary, scheme.primaryContainer],
    ),
    boxShadow: [
      BoxShadow(
        color: scheme.primary.withValues(alpha: 0.3),
        blurRadius: 48,
        offset: const Offset(0, 24),
      ),
    ],
  ),
  child: Icon(Icons.mic, color: scheme.onPrimary, size: 52),
)
// 이중 ping ring: AnimatedContainer 또는 ScaleTransition 2개 (opacity 0.2, 0.4)
```

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 3]
feat(record): 녹음 화면 Stitch v0.0.2 UI 전면 개편

- 앰비언트 글로우 배경 (Primary blur circle)
- 상태별 배지 (_RecordingStateBadge: 녹음중/AI처리중)
- STT/LLM 통합 글래스모픽 컨테이너 (40px radius, backdrop-blur)
- 마이크 버튼: 128px 그라디언트 + 이중 ping ring 애니메이션
- 레이아웃: 스크롤 제거 → 풀스크린 Column 중앙 정렬

다음 꼭지: 일기 상세 화면 에디토리얼 개편
---
```

---

## 꼭지 4 — 일기 상세 화면 에디토리얼 개편 (`diary_detail_screen.dart`)

### Stitch 참고

`_2/code.html` — 핵심 변경:

1. **에디토리얼 헤더 섹션**
   - 소제목: `오늘의 기록` (Primary, 극소, 넓은 자간, uppercase)
   - 대제목: `4월 12일 월요일 | 평온한 하루` (extraBold, 30~36sp)
   - 감정 태그 + 시각 태그 (rounded-full, 감정색 배경)

2. **AI 리플렉션 카드**
   - 흰 카드, `auto_awesome` 아이콘 + "AI의 한마디" 라벨
   - 이탤릭 인용 스타일 텍스트 (18sp, 행간 1.8)
   - 현재 구현에는 없는 기능 → **LLM에서 반환하지 않으면 섹션 자체 숨김**

3. **감정·키워드 그리드** (2열)
   - 좌: 감정 카드 (감정 색상 배경, 큰 감정명, 반투명 아이콘)
   - 우: 키워드 카드 (`surfaceContainerLow` 배경, 태그 칩 목록)

4. **본문 타이포그래피** (prose 스타일)
   - `bodyLarge` 또는 custom 20sp, 행간 1.9
   - 단락 사이 `SizedBox(height: 32)` 간격

5. **원본 텍스트 섹션** (토글 가능)
   - 현재 `_OriginalTextSection` → Stitch 스타일: 흰 카드 + expand 버튼 + 원본 텍스트 + 재생 바
   - 오디오 재생 바는 현재 구현에 없으므로 **텍스트만 표시 (재생 UI 제외)**

### 수정 파일

| 파일 | 작업 |
|------|------|
| `lib/features/diary/presentation/screens/diary_detail_screen.dart` | 에디토리얼 레이아웃으로 전면 교체 |

### 레이아웃 구조 (교체 후)

```
Scaffold
  └─ CustomScrollView
       ├─ SliverAppBar (글래스 헤더 — 뒤로가기 + 앱명 + 공유 아이콘)
       └─ SliverToBoxAdapter
            └─ Padding(horizontal: 24)
                 ├─ _EditorialHeader (소제목 + 대제목 + 태그 행)
                 ├─ SizedBox(height: 40)
                 ├─ _AiReflectionCard (AI 한마디 — 텍스트 있을 때만 표시)
                 ├─ SizedBox(height: 16)
                 ├─ _EmotionKeywordGrid (2열: 감정 카드 + 키워드 카드)
                 ├─ SizedBox(height: 40)
                 ├─ _ProseBody (본문 단락들)
                 ├─ SizedBox(height: 40)
                 └─ _OriginalTextSection (토글 카드)
```

### AI 리플렉션 카드 처리

현재 `DiaryEntry`에 AI 코멘트 필드가 없으므로:
- `DiaryEntry.correctedText`를 사용해 도메인 모델 변경 없이 표시
- 또는 섹션을 `null` 체크로 조건부 렌더링 (추후 필드 추가 여지)
- **단기 해결**: 빈 카드로 남기지 말고, AI 리플렉션 섹션 전체 숨김 (`if (entry.aiReflection != null)` 패턴)

### 에디토리얼 헤더 구현 예시

```dart
class _EditorialHeader extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 기록',
          style: TextStyle(
            color: scheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          entry.createdAt.toLocaleDateString(),  // datetime_ext 확장 메서드 활용
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            _EmotionTag(entry.emotion),
            _TimeTag(entry.createdAt),
          ],
        ),
      ],
    );
  }
}
```

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 4]
feat(detail): 일기 상세 화면 에디토리얼 레이아웃으로 전면 개편

- 에디토리얼 헤더: 소제목 + 대형 날짜 헤딩 + 감정/시각 태그
- 감정·키워드 2열 그리드 (감정 색상 카드 + 태그 칩 카드)
- 본문: prose 스타일 타이포그래피 (20sp, 행간 1.9)
- 원본 텍스트: 토글 가능한 접힘 카드 (Stitch 스타일)
- AI 리플렉션 섹션: 필드 미구현 상태로 숨김 처리

Session 18 완료.
---
```

---

## [참고] Session 18 수정 파일 전체 목록

| 파일 | 꼭지 |
|------|------|
| `lib/core/theme/app_colors.dart` | 꼭지 1 |
| `lib/core/theme/app_theme.dart` | 꼭지 1 |
| `lib/features/diary/presentation/screens/diary_list_screen.dart` | 꼭지 2 |
| `lib/features/diary/presentation/widgets/diary_card.dart` | 꼭지 2 |
| `lib/features/diary/presentation/screens/diary_record_screen.dart` | 꼭지 3 |
| `lib/features/diary/presentation/widgets/mic_button.dart` | 꼭지 3 |
| `lib/features/diary/presentation/widgets/waveform_widget.dart` | 꼭지 3 (색상 확인) |
| `lib/features/diary/presentation/screens/diary_detail_screen.dart` | 꼭지 4 |

> **선택 작업 (Session 19 이후)**: 탭 네비게이션 구조 변경 (`main_shell.dart`, `app.dart`)
> Stitch 기준 홈·기록·인사이트·설정 4탭 구조로 개편.
> 이 작업은 로그/프로필 탭 제거를 수반하므로 별도 세션으로 분리.
