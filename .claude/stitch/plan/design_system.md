# Voicelog AI — 디자인 시스템

> Stitch에서 모든 화면을 만들 때 이 파일을 함께 참고하세요.
> 각 화면 파일 상단에 이 내용을 포함하거나 "design_system.md 참고"라고 언급하세요.

---

## 기본 설정

- **디자인 시스템**: Material Design 3
- **플랫폼**: Android + iOS (모바일 세로 모드 기준)
- **다크 모드**: 지원 (라이트/다크 모두 설계)

---

## 색상

### 메인 시드 컬러
- Primary: `#6B8CFF` (차분한 인디고)
- Material 3의 `ColorScheme.fromSeed`로 자동 생성되는 컬러 팔레트 사용

### 감정 색상 (고정값)
| 감정 | 색상 | Hex |
|------|------|-----|
| 기쁨 | 노랑 | `#FFC107` |
| 슬픔 | 파랑 | `#42A5F5` |
| 평온 | 초록 | `#66BB6A` |
| 화남 | 빨강 | `#EF5350` |

### 배경
- 라이트 모드: `#FFFFFF` (surface), `#F5F5F5` (surfaceDim)
- 다크 모드: Material 3 자동 생성값 사용

---

## 타이포그래피

- **폰트**: Pretendard (한국어 최적화)
- **스케일**: Material 3 TextTheme 기준

| 역할 | 스타일 | 사용처 |
|------|--------|--------|
| displayMedium | 굵고 큰 텍스트 | 앱 이름, 빈 화면 안내 |
| headlineMedium | 중간 헤더 | 섹션 제목 |
| titleLarge | 강조 본문 | AppBar 제목 |
| bodyLarge | 본문 텍스트 | 일기 내용, STT 텍스트 |
| bodyMedium | 보조 본문 | 카드 요약, 태그 |
| labelSmall | 작은 라벨 | 시간, 힌트 |

---

## 간격 및 크기

| 이름 | 값 | 사용처 |
|------|----|--------|
| paddingSmall | 8dp | 컴포넌트 내부 간격 |
| paddingMedium | 16dp | 화면 기본 여백 |
| paddingLarge | 24dp | 섹션 간 간격 |
| paddingXLarge | 32dp | 주요 요소 간격 |
| borderRadius | 12dp | 카드, 버튼 모서리 |
| borderRadiusLarge | 24dp | 칩, 바텀시트 모서리 |
| micButtonSize | 72dp | 마이크 버튼 지름 |

---

## 공통 컴포넌트

### 감정 칩 (EmotionChip)
- 배경: 감정 색상 20% 투명도
- 테두리: 감정 색상 1.5dp 실선
- 텍스트: 감정 색상, semibold
- 이모지 + 텍스트 형식: `😊 기쁨` / `😢 슬픔` / `😌 평온` / `😡 화남`
- 모서리: 24dp (둥근 필)

### 태그 칩
- 배경: surfaceContainerHighest
- 텍스트: primary 색상
- 모서리: 16dp
- 형식: `#태그명`

### 카드 (DiaryCard)
- elevation: 2dp
- 모서리: 12dp
- 내부 패딩: 16dp
- 왼쪽 감정 컬러 바: 너비 4dp, 높이 60dp, 모서리 2dp

### 로딩 shimmer
- 배경 색상: surfaceContainerHighest
- 하이라이트: surface
- 모서리: 12dp

---

## 아이콘

Material Symbols (outlined 스타일) 사용:
- `mic` — 마이크 (녹음 시작)
- `stop` — 정지 (녹음 중)
- `settings_outlined` — 설정
- `delete_outline` — 삭제
- `info_outline` — 정보
- `lock_outline` — 보안/개인정보
- `expand_more` / `expand_less` — 접기/펼치기

---

## 애니메이션 타이밍

| 이름 | 시간 |
|------|------|
| 빠른 전환 | 200ms |
| 기본 전환 | 300ms |
| 느린 전환 | 500ms |
| 펄스 반복 | 1000ms |
| 커서 깜빡임 | 500ms |
