# 앱 아키텍처 설계 원칙

## 1. 전체 디렉터리 구조

```
voicelog_ai/
├── lib/
│   ├── main.dart                    # ProviderScope 래핑, 앱 진입점
│   ├── app.dart                     # MaterialApp, 라우팅 설정
│   ├── core/
│   │   ├── constants/
│   │   │   ├── prompts.dart         # LLM 프롬프트 템플릿 상수
│   │   │   └── strings.dart         # UI 표시 문자열 상수
│   │   ├── theme/
│   │   │   ├── app_theme.dart       # Material 3 테마 정의
│   │   │   └── app_colors.dart      # 색상 팔레트
│   │   ├── extensions/
│   │   │   ├── datetime_ext.dart    # DateTime 포맷 확장
│   │   │   └── string_ext.dart      # String 유틸 확장
│   │   ├── utils/
│   │   │   ├── logger.dart          # 로컬 로그 유틸
│   │   │   └── llm_response_parser.dart  # LLM 응답 파싱
│   │   └── widgets/
│   │       ├── loading_shimmer.dart # 공통 로딩 shimmer
│   │       └── emotion_chip.dart    # 감정 칩 위젯
│   └── features/
│       ├── diary/
│       │   ├── presentation/
│       │   │   ├── screens/
│       │   │   │   ├── diary_list_screen.dart
│       │   │   │   ├── diary_record_screen.dart
│       │   │   │   └── diary_detail_screen.dart
│       │   │   └── widgets/
│       │   │       ├── waveform_widget.dart
│       │   │       └── streaming_text_widget.dart
│       │   ├── application/
│       │   │   ├── diary_list_provider.dart
│       │   │   ├── diary_record_provider.dart
│       │   │   └── llm_stream_provider.dart
│       │   ├── domain/
│       │   │   ├── diary_entry.dart          # freezed 모델
│       │   │   └── i_diary_repository.dart   # 저장소 인터페이스
│       │   └── infrastructure/
│       │       ├── diary_repository.dart     # Isar 구현체
│       │       └── llm_inference_service.dart # MediaPipe 서비스
│       └── settings/
│           ├── presentation/
│           │   └── screens/
│           │       └── settings_screen.dart
│           ├── application/
│           │   └── settings_provider.dart
│           └── domain/
│               └── app_settings.dart
├── test/
│   ├── unit/
│   │   ├── domain/
│   │   └── utils/
│   ├── widget/
│   └── integration/
├── android/
├── ios/
├── analysis_options.yaml
└── pubspec.yaml
```

---

## 2. 레이어 설계 (Clean Architecture 변형)

```
presentation  →  application  →  domain  ←  infrastructure
   (위젯)          (Provider)      (모델)        (서비스/DB)
```

### presentation (UI 레이어)
- `Screen`: 전체 화면을 구성하는 최상위 위젯 (`ConsumerWidget` 상속)
- `Widget`: 재사용 가능한 UI 컴포넌트
- **허용**: `ref.watch`, `ref.read` 호출, 사용자 이벤트 처리
- **금지**: 비즈니스 로직 직접 구현, 서비스 클래스 직접 호출

### application (상태·비즈니스 로직 레이어)
- Riverpod Provider 파일로만 구성
- **허용**: domain 모델 사용, infrastructure 인터페이스 호출
- **금지**: Flutter 위젯 import, BuildContext 직접 참조

### domain (핵심 모델 레이어)
- freezed 불변 모델, 인터페이스(abstract class)로만 구성
- **허용**: 순수 Dart 코드만
- **금지**: flutter, isar, mediapipe 등 외부 패키지 import (freezed_annotation 제외)

### infrastructure (구현 레이어)
- Isar DB 저장소 구현체, MediaPipe LLM 서비스 구현체
- **허용**: 외부 패키지(isar, mediapipe_genai_flutter) 사용
- **금지**: Flutter 위젯 import, Riverpod Provider 직접 생성

---

## 3. 의존성 방향 규칙

```
presentation → application → domain ← infrastructure
```

- **단방향 의존성**: 안쪽 레이어는 바깥 레이어를 절대 import하지 않는다
- `infrastructure`는 `domain`의 인터페이스를 구현한다
- `application`은 `domain` 인터페이스를 통해 `infrastructure`를 간접 사용한다 (DI via Riverpod)

---

## 4. 피처(Feature) 경계

- 각 피처(diary, settings)는 독립적으로 동작해야 한다
- 피처 간 직접 import 금지: 공유 코드는 반드시 `lib/core/`로 이동
- 피처 간 데이터 전달은 Riverpod Provider를 통한다

---

## 5. 파일 및 클래스 생성 원칙

- 하나의 파일에 하나의 주요 클래스만 정의 (private 헬퍼 클래스는 동일 파일 허용)
- Screen 클래스는 반드시 `_ScreenName` 형식의 파일에 위치
- 인터페이스는 `I` 접두사: `IDiaryRepository`, `ILlmService`

---

## 6. 라우팅

- `go_router` 패키지 사용
- 라우트 상수는 `lib/core/constants/routes.dart`에 정의
- 딥링크, 뒤로가기 스택 관리는 go_router의 `ShellRoute` 활용

```dart
// routes.dart
class AppRoutes {
  static const diaryList = '/';
  static const diaryRecord = '/record';
  static const diaryDetail = '/diary/:id';
  static const settings = '/settings';
}
```

---

## 7. 의존성 주입 (DI)

Riverpod Provider를 통해 의존성을 주입한다. `get_it` 등 별도 DI 컨테이너 사용 금지.

```dart
// infrastructure 구현체를 domain 인터페이스로 제공
@riverpod
IDiaryRepository diaryRepository(DiaryRepositoryRef ref) {
  return IsarDiaryRepository(isar: ref.watch(isarProvider));
}
```
