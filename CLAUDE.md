# Voicelog AI — Claude Code 프로젝트 가이드

## 프로젝트 개요

**Voicelog AI**는 외부 서버 통신 없이 스마트폰 기기 내부에서 음성 인식 → AI 보정 → 분석을 완결하는
온디바이스 음성 일기 앱이다.

| 항목 | 내용 |
|------|------|
| 프레임워크 | Flutter (Dart) |
| 지원 플랫폼 | Android (Samsung 전 기기), iOS (Apple 전 기기) |
| 주 테스트 기기 | Samsung Galaxy S23 FE (Android) |
| STT | Android: Native Speech Recognition / iOS: SFSpeechRecognizer (speech_to_text 패키지 추상화) |
| On-Device LLM | Google MediaPipe LLM Inference API (mediapipe_genai_flutter) |
| 추론 모델 | Gemma 2 2B INT4 양자화 (gemma-2b-it-cpu-int4.bin) |
| 로컬 DB | Isar (순수 Dart, 온디바이스 NoSQL) |
| 상태 관리 | Riverpod 2.x (riverpod_annotation 코드 생성 방식) |

---

## 핵심 원칙

### 절대 금지 사항

- **외부 API 호출 금지**: `http`, `dio`, `firebase`, `supabase` 등 네트워크 통신 패키지 사용 불가
- **dart:io 직접 파일 접근 금지**: `path_provider` 패키지를 통해서만 경로 획득 후 접근
- **개인 데이터 외부 전송 금지**: 일기 내용, 음성 데이터, 감정 분석 결과를 외부로 전송하는 코드 작성 불가
- **글로벌 상태 남용 금지**: `static` 변수를 통한 전역 상태 공유 금지 (Riverpod Provider 사용)
- **LLM 세션 미해제 금지**: 추론 완료 후 반드시 `dispose()` 호출

### 코드 생성 원칙

- 새 파일 생성 전, 기존 유사 파일이 있는지 확인하고 재사용 검토
- 불변 데이터 클래스는 반드시 `freezed` 사용
- `async/await` 사용 시 반드시 에러 핸들링 포함
- 플랫폼 분기(Android/iOS)는 `Platform.isAndroid` 또는 `defaultTargetPlatform` 사용

---

## 고정 패키지 목록

```yaml
dependencies:
  # STT
  speech_to_text: ^7.x

  # On-Device LLM
  mediapipe_genai_flutter: <최신 공식 Google 패키지>

  # 상태 관리
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x

  # 로컬 DB
  isar: ^3.x
  isar_flutter_libs: ^3.x
  path_provider: ^2.x

  # 불변 데이터 모델
  freezed_annotation: ^2.x
  json_annotation: ^4.x

  # 유틸리티
  intl: ^0.x  # 날짜 포맷

dev_dependencies:
  riverpod_generator: ^2.x
  build_runner: ^2.x
  freezed: ^2.x
  json_serializable: ^6.x
  flutter_lints: ^4.x
```

---

## 디렉터리 구조 요약

```
lib/
├── core/
│   ├── constants/          # 앱 전역 상수 (prompts.dart 포함)
│   ├── theme/              # Material 3 테마 설정
│   ├── extensions/         # Dart 확장 메서드
│   └── utils/              # 순수 유틸리티 함수
├── features/
│   ├── diary/              # 일기 작성·조회 피처
│   │   ├── presentation/   # 위젯, 화면
│   │   ├── application/    # Riverpod Provider
│   │   ├── domain/         # 모델, 인터페이스
│   │   └── infrastructure/ # Isar 저장소, LLM 서비스
│   └── settings/           # 설정 피처
└── main.dart
```

---

## 규칙 파일 인덱스

| 파일 | 다루는 주제 |
|------|-------------|
| [.claude/rules/flutter_conventions.md](.claude/rules/flutter_conventions.md) | Dart/Flutter 코드 스타일·네이밍·import 순서 |
| [.claude/rules/architecture.md](.claude/rules/architecture.md) | 디렉터리 구조, 레이어 설계, 의존성 방향 |
| [.claude/rules/mediapipe_llm.md](.claude/rules/mediapipe_llm.md) | MediaPipe LLM 통합, 생명주기, 메모리 관리 |
| [.claude/rules/state_management.md](.claude/rules/state_management.md) | Riverpod Provider 패턴, ref 사용 규칙 |
| [.claude/rules/ui_ux.md](.claude/rules/ui_ux.md) | Material 3 테마, 폰트, 위젯 작성 가이드 |
| [.claude/rules/performance.md](.claude/rules/performance.md) | 온디바이스 최적화, 발열·배터리 관리 |
| [.claude/rules/git_workflow.md](.claude/rules/git_workflow.md) | 브랜치 전략, 커밋 컨벤션, 버전 관리 |
| [.claude/rules/testing.md](.claude/rules/testing.md) | 테스트 전략, Mock 정책, 커버리지 목표 |

---

## LLM 프롬프트 템플릿

프롬프트는 `lib/core/constants/prompts.dart`에만 정의한다.

```dart
// 일기 보정 및 감정/태그 추출 프롬프트
const String kDiaryProcessingPrompt = '''
<start_of_turn>user
당신은 일기 정리 비서입니다. 아래 텍스트를 자연스러운 독백체로 수정하고,
감정(기쁨/슬픔/평온/화남)과 키워드 3개를 추출하세요.
응답 형식:
[보정본] 내용...
[감정] 감정값
[태그] #키워드1, #키워드2, #키워드3

입력: {raw_text}<end_of_turn>
<start_of_turn>model
''';
```
