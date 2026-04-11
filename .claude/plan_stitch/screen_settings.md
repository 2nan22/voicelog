# Stitch 프롬프트 — SettingsScreen (설정 화면)

> 이 파일을 Stitch에 그대로 붙여넣으세요.
> design_system.md의 디자인 시스템을 함께 적용합니다.

---

## 화면 기본 정보

- **화면명**: 설정
- **플랫폼**: Android + iOS 모바일
- **방향**: 세로
- **상태**: 단일

---

## 레이아웃 구조

```
┌─────────────────────────────┐
│ ←  설정                     │  ← AppBar
├─────────────────────────────┤
│  디스플레이                 │  ← 섹션 헤더
│                             │
│  다크 모드              ◉   │  ← SwitchListTile
│  어두운 테마로 전환합니다    │
│                             │
│  ─────────────────────────  │  ← Divider
│                             │
│  앱 정보                    │  ← 섹션 헤더
│                             │
│  ⓘ  Voicelog AI            │  ← ListTile (정보 아이콘)
│     v1.0.0 · On-Device AI  │
│                             │
│  🔒  개인정보 보호           │  ← ListTile (자물쇠 아이콘)
│     모든 데이터는 기기 내부에│
│     만 저장됩니다            │
│                             │
└─────────────────────────────┘
```

---

## 각 요소 상세

### AppBar
- 좌측: 뒤로가기 화살표 아이콘
- 제목: `설정` (titleLarge)
- 우측 버튼: 없음

### 섹션 헤더
- 텍스트: `디스플레이` / `앱 정보`
- 스타일: labelLarge, fontWeight bold
- 색상: primary (`#6B8CFF`)
- 패딩: 상 16dp / 좌 16dp / 하 8dp

### 다크 모드 SwitchListTile
- title: `다크 모드` (bodyLarge)
- subtitle: `어두운 테마로 전환합니다` (bodyMedium, outline 색상)
- 우측: Switch (Material 3 스타일, on 색상: primary)
- 패딩: 상하 4dp

### Divider
- 전체 너비
- 색상: outlineVariant
- 상하 여백: 8dp

### ListTile — 앱 버전 정보
- 좌측 아이콘: `info_outline` (24dp, primary 색상)
- title: `Voicelog AI` (bodyLarge)
- subtitle: `v1.0.0 · On-Device AI 음성 일기` (bodySmall, outline 색상)
- 우측 화살표: 없음 (탭 불가)

### ListTile — 개인정보 보호
- 좌측 아이콘: `lock_outline` (24dp, primary 색상)
- title: `개인정보 보호` (bodyLarge)
- subtitle: `모든 데이터는 기기 내부에만 저장됩니다` (bodySmall, outline 색상)
- 우측 화살표: 없음 (탭 불가)

---

## 배경 및 전체 레이아웃

- 배경: surface 색상 (흰색 / 다크 자동)
- 전체: ListView (스크롤 가능)
- 화면 좌우 패딩: 없음 (ListTile이 자체 패딩 처리)

---

## 다크 모드 고려사항

- Switch: 다크 모드에서도 on 시 primary 색상 유지
- 섹션 헤더: primary 색상 유지
- ListTile 아이콘: primary 색상 유지
- 배경: dark surface 자동 전환
