# UI/UX 가이드라인

## 1. 디자인 시스템 기반

- **Material Design 3** 적용 (`useMaterial3: true` 필수)
- `ThemeData.from(colorScheme: ...)` 방식으로 테마 구성
- `Theme.of(context).colorScheme`, `Theme.of(context).textTheme`으로만 색상·텍스트 스타일 참조
- 하드코딩 색상(`Color(0xFF...)`) 사용 금지 — 반드시 `AppColors` 상수 사용

---

## 2. 색상 시스템

```dart
// lib/core/theme/app_colors.dart

class AppColors {
  // 시드 컬러 (차분한 인디고)
  static const Color seed = Color(0xFF6B8CFF);

  // 감정 색상
  static const Color emotionJoy     = Color(0xFFFFC107); // 기쁨 — 노랑
  static const Color emotionSadness = Color(0xFF42A5F5); // 슬픔 — 파랑
  static const Color emotionCalm    = Color(0xFF66BB6A); // 평온 — 초록
  static const Color emotionAnger   = Color(0xFFEF5350); // 화남 — 빨강

  // 배경 및 서피스
  static const Color surfaceDim = Color(0xFFF5F5F5);
}
```

### 테마 설정

```dart
// lib/core/theme/app_theme.dart

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

---

## 3. 타이포그래피

- **기본 폰트**: Pretendard (한국어 최적화, variable weight 사용)
- `pubspec.yaml`에 asset 등록 후 `fontFamily: 'Pretendard'`로 전체 적용
- 폰트 크기는 Material 3의 `TextTheme` 스케일 사용 (`displayLarge`, `titleMedium`, `bodySmall` 등)
- 직접 `fontSize` 하드코딩 금지 (단, 특수 케이스 주석 필수)

---

## 4. 화면별 UI 규칙

### SplashScreen
- 앱 로고 + LLM 모델 로딩 진행률 표시
- `LinearProgressIndicator` (색상: `colorScheme.primary`)
- 로딩 텍스트: "AI 엔진을 준비하고 있어요..." (한국어 톤)

### DiaryRecordScreen (핵심 화면)
- **녹음 중**: 마이크 아이콘 주변에 `AnimatedContainer` 기반 펄스 애니메이션
- **파형 표시**: `CustomPainter`로 실시간 음성 파형 (진폭 데이터 → 막대 그래프)
- **LLM 처리 중**: `shimmer` 패키지로 로딩 shimmer 효과
- **스트리밍 텍스트**: 타이핑되듯 나타나는 애니메이션 (`AnimatedSwitcher` 또는 타이머)

### 감정 칩 (EmotionChip)
```dart
// lib/core/widgets/emotion_chip.dart

class EmotionChip extends StatelessWidget {
  final String emotion; // '기쁨' | '슬픔' | '평온' | '화남'

  Color get _chipColor => switch (emotion) {
    '기쁨'  => AppColors.emotionJoy,
    '슬픔'  => AppColors.emotionSadness,
    '평온'  => AppColors.emotionCalm,
    '화남'  => AppColors.emotionAnger,
    _       => AppColors.emotionCalm,
  };
  // ...
}
```

### DiaryListScreen
- `CustomScrollView` + `SliverAppBar` (스크롤 시 축소되는 헤더)
- 날짜별 그룹핑: `SliverStickyHeader` 또는 직접 구현
- 일기 카드: `Card` + `InkWell` (Material 3 tonal surface)

---

## 5. 위젯 작성 규칙

### ConsumerWidget 우선

```dart
// Good
class DiaryRecordScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) { ... }
}

// 애니메이션 필요 시에만 ConsumerStatefulWidget
class WaveformWidget extends ConsumerStatefulWidget { ... }
```

### 크기·간격 상수화

```dart
// lib/core/constants/dimensions.dart
class AppDimensions {
  static const double paddingSmall  = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge  = 24.0;
  static const double borderRadius  = 12.0;
  static const double micButtonSize = 72.0;
}
```

- 직접 숫자 리터럴 사용 금지 (`SizedBox(height: 16)` → `SizedBox(height: AppDimensions.paddingMedium)`)

---

## 6. 애니메이션 규칙

- 애니메이션 지속시간: 짧은 전환 200ms, 일반 300ms, 느린 전환 500ms
- `AnimationController`의 `vsync`는 반드시 `TickerProviderStateMixin` 또는 `SingleTickerProviderStateMixin` 사용
- 애니메이션 컨트롤러는 `dispose()`에서 반드시 해제
- 복잡한 시퀀스 애니메이션은 `flutter_animate` 패키지 사용 허용

---

## 7. 반응형 레이아웃

- 폰 세로 모드 기준으로 설계 (태블릿 대응은 Phase 2 이후)
- `MediaQuery.of(context).size`로 화면 크기 참조
- 안전 영역: `SafeArea` 위젯 최상단에 적용
- 키보드 오버레이: `resizeToAvoidBottomInset: true` (기본값 유지)

---

## 8. 접근성

- 모든 아이콘 버튼에 `Semantics` 또는 `tooltip` 필수
- 색상만으로 상태를 구분하지 않는다 (아이콘 또는 텍스트 병행)
- 최소 터치 영역: 48×48dp (Material 가이드라인 준수)

---

## 9. 다크 모드

- `ThemeMode.system`으로 시스템 설정 자동 따라가기
- 다크/라이트 테마 모두 `buildLightTheme()`, `buildDarkTheme()` 각각 정의
- 색상은 항상 `Theme.of(context).colorScheme`에서 가져와 자동으로 테마 전환됨
