# Session 10 — 설정 화면

## 목표
앱 설정(다크 모드, 앱 정보)을 Isar에 저장하고, 설정 화면 UI를 구현한다.

## 참고 규칙 파일
- `.claude/rules/state_management.md` (Riverpod, keepAlive)
- `.claude/rules/flutter_conventions.md` (freezed)
- `.claude/rules/ui_ux.md` (Material 3, 다크 모드 연동)

## UI 디자인 참고

작업 전 아래 파일을 반드시 읽는다.

- 디자인 시스템: `.claude/stitch/v0.0.1-20260411/seoul_minimalist/DESIGN.md`
- 화면 목업 (HTML): `.claude/stitch/v0.0.1-20260411/settings_screen_new/code.html`
- 화면 스크린샷: `.claude/stitch/v0.0.1-20260411/settings_screen_new/screen.png`

설정 항목 레이아웃, 토글 스위치, 섹션 구분선은 HTML 목업 기준으로 구현한다.

---

## 꼭지 1 — AppSettings 모델 및 설정 Provider

### 작업 내용

1. `lib/features/settings/domain/app_settings.dart` 작성

   ```dart
   import 'package:freezed_annotation/freezed_annotation.dart';
   import 'package:isar/isar.dart';

   part 'app_settings.freezed.dart';
   part 'app_settings.g.dart';

   @freezed
   @Collection()
   class AppSettings with _$AppSettings {
     const AppSettings._();

     const factory AppSettings({
       @Default(0) Id id,           // 단일 레코드 (id=0 고정)
       @Default(false) bool isDarkMode,
     }) = _AppSettings;

     factory AppSettings.fromJson(Map<String, dynamic> json) =>
         _$AppSettingsFromJson(json);
   }
   ```

2. `lib/features/settings/application/settings_provider.dart` 작성

   ```dart
   import 'package:riverpod_annotation/riverpod_annotation.dart';
   import 'package:voicelog_ai/features/diary/application/diary_repository_provider.dart';
   import 'package:voicelog_ai/features/settings/domain/app_settings.dart';

   part 'settings_provider.g.dart';

   @Riverpod(keepAlive: true)
   class SettingsNotifier extends _$SettingsNotifier {
     @override
     Future<AppSettings> build() async {
       final isar = await ref.watch(isarProvider.future);
       return isar.appSettings.get(0) ?? const AppSettings();
     }

     Future<void> setDarkMode(bool value) async {
       final isar = await ref.read(isarProvider.future);
       final current = state.valueOrNull ?? const AppSettings();
       final updated = current.copyWith(isDarkMode: value);
       await isar.writeTxn(() => isar.appSettings.put(updated));
       state = AsyncData(updated);
     }
   }
   ```

3. Isar 스키마에 `AppSettings` 추가 (`isarProvider`의 `Isar.open()` schemas 목록에 `AppSettingsSchema` 추가)

4. `app.dart`에서 `settingsNotifierProvider`를 watch하여 `themeMode`를 동적으로 적용

   ```dart
   // app.dart build() 내부
   final settingsAsync = ref.watch(settingsNotifierProvider);
   final isDark = settingsAsync.valueOrNull?.isDarkMode ?? false;
   // ...
   themeMode: isDark ? ThemeMode.dark : ThemeMode.system,
   ```

5. `build_runner` 실행

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 1]
feat(settings): AppSettings 모델 및 SettingsNotifier 구현

- AppSettings: Isar Collection, isDarkMode 필드 (id=0 단일 레코드)
- SettingsNotifier: keepAlive, setDarkMode() Isar 저장
- app.dart: settingsNotifierProvider → themeMode 동적 적용

다음 꼭지(SettingsScreen UI)를 진행할까요?
---
```

---

## 꼭지 2 — SettingsScreen UI

### 작업 내용

1. `lib/features/settings/presentation/screens/settings_screen.dart` 작성

   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:voicelog_ai/core/constants/strings.dart';
   import 'package:voicelog_ai/features/settings/application/settings_provider.dart';

   class SettingsScreen extends ConsumerWidget {
     const SettingsScreen({super.key});

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final settingsAsync = ref.watch(settingsNotifierProvider);

       return Scaffold(
         appBar: AppBar(title: const Text('설정')),
         body: settingsAsync.when(
           loading: () => const Center(child: CircularProgressIndicator()),
           error: (e, _) => Center(child: Text('오류: $e')),
           data: (settings) => ListView(
             children: [
               // 섹션: 디스플레이
               _SectionHeader(title: '디스플레이'),
               SwitchListTile(
                 title: const Text('다크 모드'),
                 subtitle: const Text('어두운 테마로 전환합니다'),
                 value: settings.isDarkMode,
                 onChanged: (v) => ref
                     .read(settingsNotifierProvider.notifier)
                     .setDarkMode(v),
               ),
               const Divider(),
               // 섹션: 정보
               _SectionHeader(title: '앱 정보'),
               ListTile(
                 title: const Text(AppStrings.appName),
                 subtitle: const Text('v1.0.0 · On-Device AI 음성 일기'),
                 leading: const Icon(Icons.info_outline),
               ),
               ListTile(
                 title: const Text('개인정보 보호'),
                 subtitle: const Text('모든 데이터는 기기 내부에만 저장됩니다'),
                 leading: const Icon(Icons.lock_outline),
               ),
             ],
           ),
         ),
       );
     }
   }

   class _SectionHeader extends StatelessWidget {
     final String title;
     const _SectionHeader({required this.title});

     @override
     Widget build(BuildContext context) {
       return Padding(
         padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
         child: Text(
           title,
           style: Theme.of(context).textTheme.labelLarge?.copyWith(
             color: Theme.of(context).colorScheme.primary,
           ),
         ),
       );
     }
   }
   ```

2. `flutter analyze` 오류 없음 확인
3. `flutter run` 후 설정 화면에서 다크 모드 토글 동작 확인

   > **Google Stitch 참고**: 섹션 헤더 스타일, ListTile 아이콘 색상, SwitchListTile 디자인을 Stitch 기준으로 조정한다.

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 2]
feat(settings/presentation): SettingsScreen — 다크 모드 토글 및 앱 정보

- 다크 모드 SwitchListTile → SettingsNotifier.setDarkMode 연동
- 앱 정보, 개인정보 보호 정책 안내 (온디바이스 강조)

Session 10 완료. Session 11로 넘어가려면 session_11_testing.md 파일을 참고하세요.
---
```
