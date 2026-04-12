# Session 02 — 코어 레이어 (테마·상수·유틸)

## 목표
앱 전체에서 공유하는 테마, 상수, 유틸리티 함수를 구현한다.
이 세션이 끝나면 Material 3 테마가 적용된 앱이 실행된다.

## 참고 규칙 파일
- `.claude/rules/flutter_conventions.md`
- `.claude/rules/ui_ux.md`
- `.claude/rules/mediapipe_llm.md` (프롬프트 상수 위치)

---

## 꼭지 1 — 테마 설정

### 작업 내용

1. `lib/core/theme/app_colors.dart` 작성

   ```dart
   import 'package:flutter/material.dart';

   class AppColors {
     AppColors._();

     static const Color seed = Color(0xFF6B8CFF);

     // 감정 색상
     static const Color emotionJoy     = Color(0xFFFFC107);
     static const Color emotionSadness = Color(0xFF42A5F5);
     static const Color emotionCalm    = Color(0xFF66BB6A);
     static const Color emotionAnger   = Color(0xFFEF5350);

     static const Color surfaceDim = Color(0xFFF5F5F5);
   }
   ```

2. `lib/core/theme/app_theme.dart` 작성

   ```dart
   import 'package:flutter/material.dart';
   import 'package:voicelog_ai/core/theme/app_colors.dart';

   ThemeData buildLightTheme() {
     final colorScheme = ColorScheme.fromSeed(
       seedColor: AppColors.seed,
       brightness: Brightness.light,
     );
     return ThemeData(
       useMaterial3: true,
       colorScheme: colorScheme,
       fontFamily: 'Pretendard',
     );
   }

   ThemeData buildDarkTheme() {
     final colorScheme = ColorScheme.fromSeed(
       seedColor: AppColors.seed,
       brightness: Brightness.dark,
     );
     return ThemeData(
       useMaterial3: true,
       colorScheme: colorScheme,
       fontFamily: 'Pretendard',
     );
   }
   ```

3. `lib/app.dart`의 `theme:` 을 `buildLightTheme()`으로 교체하고
   `darkTheme: buildDarkTheme()`, `themeMode: ThemeMode.system` 추가

4. Pretendard 폰트 에셋 설정
   - `assets/fonts/Pretendard-Variable.ttf` 위치에 폰트 파일 추가 (폰트 파일은 직접 다운로드)
   - `pubspec.yaml`에 폰트 등록

   ```yaml
   flutter:
     fonts:
       - family: Pretendard
         fonts:
           - asset: assets/fonts/Pretendard-Variable.ttf
   ```

   > 폰트 파일이 없으면 시스템 폰트로 임시 대체하고 TODO 주석을 남긴다.

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 1]
feat(theme): Material 3 테마 및 AppColors 정의

- AppColors: seed(인디고), 감정 4색 상수 정의
- buildLightTheme() / buildDarkTheme() 구현
- app.dart에 테마 및 ThemeMode.system 적용

다음 꼭지(상수 파일들)를 진행할까요?
---
```

---

## 꼭지 2 — 상수 파일 작성

### 작업 내용

1. `lib/core/constants/prompts.dart` 작성 — LLM 프롬프트 템플릿

   ```dart
   /// 일기 보정 및 감정/태그 추출 프롬프트.
   /// {raw_text} 자리에 STT 원문을 치환하여 사용한다.
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

2. `lib/core/constants/strings.dart` 작성 — UI 표시 문자열

   ```dart
   class AppStrings {
     AppStrings._();

     static const String appName       = 'Voicelog AI';
     static const String splashLoading = 'AI 엔진을 준비하고 있어요...';
     static const String recordStart   = '탭하여 녹음 시작';
     static const String recordStop    = '탭하여 녹음 중지';
     static const String processing    = 'AI가 일기를 다듬는 중...';
     static const String saveDiary     = '저장';
     static const String deleteDiary   = '삭제';
     static const String noEntries     = '아직 작성된 일기가 없어요';
     static const String errorMemory   = '메모리가 부족합니다. 잠시 후 다시 시도해 주세요.';
     static const String errorTimeout  = 'AI 처리가 지연되고 있어요. 다시 시도해 주세요.';
   }
   ```

3. `lib/core/constants/dimensions.dart` 작성 — 간격·크기 상수

   ```dart
   class AppDimensions {
     AppDimensions._();

     static const double paddingSmall   = 8.0;
     static const double paddingMedium  = 16.0;
     static const double paddingLarge   = 24.0;
     static const double paddingXLarge  = 32.0;
     static const double borderRadius   = 12.0;
     static const double borderRadiusLg = 24.0;
     static const double micButtonSize  = 72.0;
     static const double cardElevation  = 2.0;
   }
   ```

4. `lib/core/constants/routes.dart` 작성 — 라우트 경로 상수

   ```dart
   class AppRoutes {
     AppRoutes._();

     static const String splash      = '/';
     static const String diaryList   = '/diary';
     static const String diaryRecord = '/diary/record';
     static const String diaryDetail = '/diary/:id';
     static const String settings    = '/settings';
   }
   ```

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 2]
feat(core): 앱 전역 상수 파일 작성

- prompts.dart: Gemma 2 일기 보정 프롬프트 템플릿
- strings.dart: UI 표시 문자열 상수
- dimensions.dart: 간격·크기 상수
- routes.dart: go_router 경로 상수

다음 꼭지(유틸리티 함수)를 진행할까요?
---
```

---

## 꼭지 3 — 유틸리티 함수 작성

### 작업 내용

1. `lib/core/utils/logger.dart` 작성 — 로컬 전용 로그 유틸

   ```dart
   import 'package:flutter/foundation.dart';

   /// 기기 로컬에만 출력하는 로거. 외부 전송 금지.
   class AppLogger {
     AppLogger._();

     static void info(String message) {
       if (kDebugMode) debugPrint('[INFO] $message');
     }

     static void warn(String message) {
       if (kDebugMode) debugPrint('[WARN] $message');
     }

     static void error(String message, [Object? error, StackTrace? stack]) {
       if (kDebugMode) {
         debugPrint('[ERROR] $message');
         if (error != null) debugPrint('  error: $error');
         if (stack != null) debugPrint('  stack: $stack');
       }
     }
   }
   ```

2. `lib/core/utils/llm_response_parser.dart` 작성

   - `LlmParsedResult` freezed 모델과 `LlmResponseParser` 파서 클래스를 이 파일에 함께 작성한다.

   ```dart
   import 'package:freezed_annotation/freezed_annotation.dart';

   part 'llm_response_parser.freezed.dart';

   @freezed
   class LlmParsedResult with _$LlmParsedResult {
     const factory LlmParsedResult({
       required String correctedText,
       required String emotion,
       required List<String> tags,
     }) = _LlmParsedResult;
   }

   /// LLM 응답 문자열을 파싱하여 [LlmParsedResult]를 반환한다.
   /// 파싱 실패 시 기본값(빈 문자열, '평온', 빈 목록)을 반환한다.
   class LlmResponseParser {
     LlmResponseParser._();

     static LlmParsedResult parse(String rawResponse) {
       final correctedMatch =
           RegExp(r'\[보정본\](.*?)(?=\[감정\]|\[태그\]|$)', dotAll: true)
               .firstMatch(rawResponse);
       final emotionMatch =
           RegExp(r'\[감정\]\s*(\S+)').firstMatch(rawResponse);
       final tagsMatch =
           RegExp(r'\[태그\]\s*(.+)').firstMatch(rawResponse);

       return LlmParsedResult(
         correctedText: correctedMatch?.group(1)?.trim() ?? '',
         emotion: emotionMatch?.group(1)?.trim() ?? '평온',
         tags: tagsMatch?.group(1)?.split(',').map((t) => t.trim()).toList() ?? [],
       );
     }
   }
   ```

3. `lib/core/extensions/datetime_ext.dart` 작성

   ```dart
   import 'package:intl/intl.dart';

   extension DateTimeFormatExt on DateTime {
     /// 예: 2026년 4월 11일
     String toKoreanDate() => DateFormat('yyyy년 M월 d일').format(this);

     /// 예: 오후 3:45
     String toKoreanTime() => DateFormat('a h:mm', 'ko').format(this);

     /// 일기 목록 날짜 그룹 헤더용: 오늘 / 어제 / yyyy년 M월 d일
     String toRelativeDate() {
       final now = DateTime.now();
       final today = DateTime(now.year, now.month, now.day);
       final target = DateTime(year, month, day);
       final diff = today.difference(target).inDays;
       if (diff == 0) return '오늘';
       if (diff == 1) return '어제';
       return toKoreanDate();
     }
   }
   ```

4. `build_runner` 실행하여 코드 생성 파일 확인

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. `flutter analyze` 오류 없음 확인

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 3]
feat(core): 유틸리티 및 확장 메서드 구현

- AppLogger: 로컬 전용 로그 유틸 (외부 전송 없음)
- LlmResponseParser + LlmParsedResult: LLM 응답 파싱
- DateTimeFormatExt: 한국어 날짜 포맷 확장 메서드
- build_runner 코드 생성 완료

Session 02 완료. Session 03으로 넘어가려면 session_03_domain_db.md 파일을 참고하세요.
---
```
