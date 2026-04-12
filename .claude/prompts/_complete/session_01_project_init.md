# Session 01 — 프로젝트 초기화 및 기반 설정

## 목표
Flutter 프로젝트를 생성하고, 의존성 패키지·린터·폴더 구조·앱 진입점을 설정한다.
이 세션이 끝나면 `flutter run`으로 빈 앱이 실행되어야 한다.

## 참고 규칙 파일
- `.claude/rules/flutter_conventions.md`
- `.claude/rules/architecture.md`
- `CLAUDE.md` (패키지 목록)

---

## 꼭지 1 — Flutter 프로젝트 생성 및 pubspec.yaml 설정

### 작업 내용

1. Flutter 프로젝트 생성
   ```bash
   flutter create --org com.voicelog --platforms android,ios voicelog_ai
   ```

2. `pubspec.yaml`에 아래 패키지를 추가한다.

   ```yaml
   dependencies:
     flutter:
       sdk: flutter

     # STT
     speech_to_text: ^7.0.0

     # 상태 관리
     flutter_riverpod: ^2.6.1
     riverpod_annotation: ^2.6.1

     # 로컬 DB
     isar: ^3.1.0
     isar_flutter_libs: ^3.1.0
     path_provider: ^2.1.5

     # 불변 모델
     freezed_annotation: ^2.4.4
     json_annotation: ^4.9.0

     # 라우팅
     go_router: ^14.6.2

     # UI 유틸
     shimmer: ^3.0.0
     intl: ^0.19.0

   dev_dependencies:
     flutter_test:
       sdk: flutter
     flutter_lints: ^4.0.0
     riverpod_generator: ^2.6.1
     build_runner: ^2.4.13
     freezed: ^2.5.7
     json_serializable: ^6.9.0
     isar_generator: ^3.1.0
   ```

   > **주의**: `mediapipe_genai_flutter`는 아직 pubspec에 추가하지 않는다.
   > Session 04에서 별도로 설정한다 (패키지명·버전 확인 필요).

3. `flutter pub get` 실행 후 오류 없음을 확인한다.

---

### 커밋 메시지 출력 후 대기

작업 완료 후 아래를 출력하고 사용자 확인을 기다린다.

```
---
[커밋 준비 — 꼭지 1]
chore: Flutter 프로젝트 생성 및 pubspec.yaml 의존성 설정

- voicelog_ai 프로젝트 생성 (android, ios 플랫폼)
- 핵심 패키지 추가: riverpod, isar, go_router, speech_to_text, shimmer
- flutter pub get 완료

다음 꼭지(analysis_options + 폴더 구조)를 진행할까요?
---
```

---

## 꼭지 2 — 린터 설정 및 기본 폴더 구조 생성

### 작업 내용

1. `analysis_options.yaml` 수정

   ```yaml
   include: package:flutter_lints/flutter.yaml

   analyzer:
     errors:
       missing_required_param: error
       missing_return: error
     exclude:
       - "**/*.g.dart"
       - "**/*.freezed.dart"

   linter:
     rules:
       - always_use_package_imports
       - avoid_print
       - prefer_const_constructors
       - prefer_const_declarations
       - prefer_final_fields
       - prefer_final_locals
       - sort_constructors_first
       - unawaited_futures
   ```

2. `lib/` 하위에 아래 폴더 구조를 생성한다. (각 폴더에 `.gitkeep` 파일 생성)

   ```
   lib/
   ├── core/
   │   ├── constants/
   │   ├── theme/
   │   ├── extensions/
   │   ├── utils/
   │   └── widgets/
   └── features/
       ├── diary/
       │   ├── presentation/
       │   │   ├── screens/
       │   │   └── widgets/
       │   ├── application/
       │   ├── domain/
       │   └── infrastructure/
       └── settings/
           ├── presentation/
           │   └── screens/
           ├── application/
           └── domain/
   ```

3. 기본으로 생성된 `lib/main.dart` 내용을 비운다 (다음 꼭지에서 재작성).

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 2]
chore: analysis_options 린터 설정 및 feature-first 폴더 구조 생성

- flutter_lints 기반 린터 규칙 설정 (*.g.dart, *.freezed.dart 제외)
- lib/core/, lib/features/ 하위 폴더 구조 생성

다음 꼭지(main.dart + app.dart)를 진행할까요?
---
```

---

## 꼭지 3 — main.dart 및 app.dart 작성

### 작업 내용

1. `lib/main.dart` 작성

   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';

   import 'package:voicelog_ai/app.dart';

   void main() {
     WidgetsFlutterBinding.ensureInitialized();
     runApp(const ProviderScope(child: VoicelogApp()));
   }
   ```

2. `lib/app.dart` 작성 — 라우터는 Session 09에서 완성하므로 임시 홈 화면만 연결

   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';

   class VoicelogApp extends ConsumerWidget {
     const VoicelogApp({super.key});

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       return MaterialApp(
         title: 'Voicelog AI',
         theme: ThemeData(useMaterial3: true),  // Session 02에서 교체
         home: const Scaffold(
           body: Center(child: Text('Voicelog AI')),
         ),
       );
     }
   }
   ```

3. `flutter analyze` 실행하여 오류 없음 확인
4. `flutter run` 으로 빈 앱 실행 확인 (Android 에뮬레이터 또는 실기기)

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 3]
feat: main.dart ProviderScope 설정 및 VoicelogApp 기초 구조 작성

- main()에 ProviderScope 적용
- VoicelogApp (ConsumerWidget) 임시 홈 화면 연결
- flutter analyze 오류 없음 확인

Session 01 완료. Session 02로 넘어가려면 session_02_core_theme.md 파일을 참고하세요.
---
```
