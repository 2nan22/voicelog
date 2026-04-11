# Stitch 사용 방법 — Voicelog AI

## 파일 목록

| 파일 | Stitch에 줄 시점 |
|------|----------------|
| `design_system.md` | 모든 화면 작업 전, 공통으로 항상 포함 |
| `screen_splash.md` | Session 04 작업 전 |
| `screen_diary_list.md` | Session 08 작업 전 |
| `screen_diary_record.md` | Session 06 작업 전 (가장 복잡한 화면) |
| `screen_diary_detail.md` | Session 09 작업 전 |
| `screen_settings.md` | Session 10 작업 전 |

---

## Stitch에 붙여넣는 방법

### 방법 1: 단일 화면 프롬프트

```
[design_system.md 내용]

---

[screen_xxx.md 내용]
```

두 파일을 위아래로 합쳐서 한 번에 붙여넣으면 됩니다.

### 방법 2: 화면 파일만

Stitch가 이미 디자인 시스템을 기억하고 있다면 각 화면 파일만 붙여넣어도 됩니다.

---

## Stitch 코드를 Claude 세션에 적용하는 방법

Stitch에서 Flutter 코드를 export한 후, 해당 세션 프롬프트 파일과 함께 Claude에게 전달합니다.

```
session_06_record_screen.md 를 참고해서 작업해줘.

아래는 Stitch에서 만든 녹음 화면 코드야.
레이아웃 구조와 위젯은 이 코드를 기반으로 하고,
STT/LLM Provider 연결, 애니메이션 로직은 세션 파일대로 구현해줘.

--- Stitch 코드 시작 ---
[여기에 Stitch export 코드 붙여넣기]
--- Stitch 코드 끝 ---
```

---

## 주의사항

- Stitch export 코드에서 **하드코딩된 색상값**은 `AppColors` 상수로 교체
- Stitch export 코드에서 **하드코딩된 문자열**은 `AppStrings` 상수로 교체
- Stitch export 코드에서 **하드코딩된 크기값**은 `AppDimensions` 상수로 교체
- `StatefulWidget`을 `ConsumerStatefulWidget` 또는 `ConsumerWidget`으로 교체
