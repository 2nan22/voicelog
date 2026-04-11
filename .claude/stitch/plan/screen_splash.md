# Stitch 프롬프트 — SplashScreen (앱 시작 로딩 화면)

> 이 파일을 Stitch에 그대로 붙여넣으세요.
> design_system.md의 디자인 시스템을 함께 적용합니다.

---

## 화면 기본 정보

- **화면명**: Splash / 앱 시작 로딩
- **플랫폼**: Android + iOS 모바일
- **방향**: 세로 고정
- **상태**: 단일 상태 (로딩 중)

---

## 레이아웃 구조

전체 화면 중앙 정렬. 위아래 여백 균등.

```
┌─────────────────────────────┐
│                             │
│                             │
│         [앱 로고]           │  ← 화면 세로 40% 지점
│                             │
│       Voicelog AI           │  ← displaySmall, 굵게
│                             │
│  ──────────────────────     │  ← LinearProgressIndicator
│                             │
│  AI 엔진을 준비하고 있어요...  │  ← bodyMedium, outline 색상
│                             │
│                             │
└─────────────────────────────┘
```

---

## 각 요소 상세

### 앱 로고
- 마이크 아이콘 (`mic`, Material Symbols outlined)
- 크기: 80×80dp
- 색상: primary (`#6B8CFF`)
- 아래 여백: 24dp

### 앱 이름 텍스트
- 텍스트: `Voicelog AI`
- 스타일: headlineMedium, fontWeight bold
- 색상: onSurface
- 아래 여백: 32dp

### 진행 바 (LinearProgressIndicator)
- 너비: 화면 너비의 60%
- 높이: 4dp
- 색상: primary
- 모서리: 2dp (rounded)
- 애니메이션: indeterminate (무한 반복)
- 아래 여백: 16dp

### 로딩 안내 텍스트
- 텍스트: `AI 엔진을 준비하고 있어요...`
- 스타일: bodyMedium
- 색상: outline (연한 회색)

---

## 배경

- 라이트: `#FFFFFF`
- 다크: Material 3 surface 자동값
- StatusBar: 배경색과 동일 (투명)

---

## 참고 사항

- 이 화면은 앱 첫 실행 시 LLM 모델을 로딩하는 동안 표시됩니다.
- 로딩이 완료되면 자동으로 다음 화면(일기 목록)으로 전환됩니다.
- 로딩 애니메이션 외 인터랙션 없음 (버튼 없음).
