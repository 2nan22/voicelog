# Git 워크플로우 규칙

## 1. 브랜치 전략

```
main          ← 배포 가능한 안정 버전
  └── develop ← 통합 브랜치 (기능 완성 후 merge)
        ├── feature/xxx       ← 기능 개발 브랜치
        ├── fix/xxx           ← 버그 수정 브랜치
        └── refactor/xxx      ← 리팩터링 브랜치

backup/vX.Y.Z-YYYYMMDD  ← 버전 스냅샷 브랜치 (develop에서 생성)
```

| 브랜치 | 생성 기준 | merge 대상 |
|--------|-----------|------------|
| `feature/*` | 새 기능 시작 시 | develop |
| `fix/*` | 버그 확인 시 | develop |
| `backup/vX.Y.Z-날짜` | 기능 완성 마일스톤 | 없음 (보존용) |
| `main` | 배포 준비 완료 시 | — |

---

## 2. 커밋 컨벤션 (Conventional Commits)

```
<type>(<scope>): <subject>

<body> (선택)
```

### Type 목록

| Type | 사용 상황 | 예시 |
|------|-----------|------|
| `feat` | 새 기능 추가 | `feat(diary): 음성 녹음 화면 구현` |
| `fix` | 버그 수정 | `fix(llm): OOM 발생 시 dispose 누락 수정` |
| `refactor` | 기능 변화 없는 코드 개선 | `refactor(state): diaryProvider Notifier로 전환` |
| `docs` | 문서·주석 수정 | `docs: LLM 서비스 doc comment 추가` |
| `chore` | 빌드 설정, 패키지 업데이트 | `chore: flutter_riverpod 2.5.1로 업그레이드` |
| `test` | 테스트 추가·수정 | `test(parser): LLM 응답 파서 단위 테스트 추가` |
| `style` | 포맷팅, 세미콜론 누락 등 | `style: dart format 적용` |

### 커밋 메시지 규칙

- **Subject**: 50자 이내, 한국어 권장, 마침표 금지
- **Body**: 선택사항, 변경 이유 또는 주요 결정 사항 기술
- 하나의 커밋에 하나의 논리적 변경만 포함
- WIP 커밋은 `develop` 브랜치에서만 허용, `main` 머지 전 정리

---

## 3. 버전 관리 (SemVer)

```
v[MAJOR].[MINOR].[PATCH]

MAJOR: 앱 구조 전면 개편, 호환성 파괴 변경
MINOR: 새 기능 추가 (기존 기능 유지)
PATCH: 버그 수정, 소규모 개선
```

### 버전 백업 브랜치 생성 절차

```bash
# 1. develop 브랜치에서 기능 완성 확인
git checkout develop

# 2. 버전 백업 브랜치 생성 (보존용, merge 대상 없음)
git checkout -b backup/v0.1.0-20260411

# 3. develop으로 복귀
git checkout develop
```

---

## 4. 프롬프트 파일 작업 단위 규칙 (핵심)

Claude Code가 프롬프트 파일(`.claude/` 내 작업 지시 파일)로 작업을 수행할 때 반드시 지켜야 할 규칙이다.

### 작업 단위

- 1개 프롬프트 파일 내의 꼭지(섹션)를 **2~4개** 단위로 묶어 작업한다
- 한 꼭지는 논리적으로 완결된 작업 단위 (예: "STT 설정", "마이크 UI 구현")

### 각 꼭지 완료 후 의무 절차

```
꼭지 작업 완료
  ↓
1. 변경 파일 확인 (git status)
2. 커밋 메시지 출력 (아래 형식 준수)
3. 사용자에게 확인 요청
  ↓
사용자 확인 ("다음 진행해" 또는 유사 명령)
  ↓
다음 꼭지 작업 시작
```

### 커밋 메시지 출력 형식

```
---
[커밋 준비]
feat(diary): STT 설정 및 마이크 위젯 구현

- speech_to_text 패키지 설정 완료
- 마이크 버튼 위젯 및 음성 인식 시작/중지 로직 구현
- Android/iOS 마이크 권한 설정 추가

다음 작업을 진행해도 될까요? (다음 꼭지: MediaPipe LLM 엔진 통합)
---
```

- Claude는 **직접 커밋하지 않는다** — 커밋 메시지를 출력하고 대기
- 사용자가 직접 커밋하거나 Claude에게 커밋 명령을 내릴 때만 `git commit` 실행

---

## 5. 버전 체인지로그 관리

- `.claude/Add_version_changelog_prompt.md` 파일의 절차를 따른다
- 새 backup 브랜치 생성 시 해당 파일의 "현재 버전 목록" 표를 함께 갱신한다

---

## 6. 금지 사항

- `git push --force` (main/develop 브랜치에 절대 금지)
- `git commit --amend` (이미 push된 커밋에 금지)
- `git rebase -i` 후 force push (공유 브랜치에 금지)
- 커밋 메시지 없는 커밋 (`git commit -m ""`)
- `.env`, API 키, 개인 데이터를 커밋에 포함
