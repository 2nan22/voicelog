# Session 03 — 공통 위젯 + Domain 모델 + Isar DB

## 목표
재사용 공통 위젯, 도메인 모델(DiaryEntry), 저장소 인터페이스와 Isar 구현체를 작성한다.

## 참고 규칙 파일
- `.claude/rules/architecture.md` (레이어 설계, 의존성 방향)
- `.claude/rules/flutter_conventions.md` (freezed, import 순서)
- `.claude/rules/ui_ux.md` (EmotionChip 색상 매핑)

---

## 꼭지 1 — 공통 위젯 (LoadingShimmer, EmotionChip)

### 작업 내용

1. `lib/core/widgets/loading_shimmer.dart` 작성

   ```dart
   import 'package:flutter/material.dart';
   import 'package:shimmer/shimmer.dart';

   /// LLM 처리 중 또는 데이터 로딩 시 표시하는 shimmer 플레이스홀더.
   class LoadingShimmer extends StatelessWidget {
     final double height;
     final double borderRadius;

     const LoadingShimmer({
       super.key,
       this.height = 80,
       this.borderRadius = 12,
     });

     @override
     Widget build(BuildContext context) {
       final base = Theme.of(context).colorScheme.surfaceContainerHighest;
       final highlight = Theme.of(context).colorScheme.surface;
       return Shimmer.fromColors(
         baseColor: base,
         highlightColor: highlight,
         child: Container(
           height: height,
           decoration: BoxDecoration(
             color: base,
             borderRadius: BorderRadius.circular(borderRadius),
           ),
         ),
       );
     }
   }
   ```

2. `lib/core/widgets/emotion_chip.dart` 작성

   ```dart
   import 'package:flutter/material.dart';
   import 'package:voicelog_ai/core/theme/app_colors.dart';

   /// 감정값에 따른 색상 칩 위젯.
   /// [emotion]: '기쁨' | '슬픔' | '평온' | '화남'
   class EmotionChip extends StatelessWidget {
     final String emotion;

     const EmotionChip({super.key, required this.emotion});

     Color get _chipColor => switch (emotion) {
       '기쁨' => AppColors.emotionJoy,
       '슬픔' => AppColors.emotionSadness,
       '평온' => AppColors.emotionCalm,
       '화남' => AppColors.emotionAnger,
       _     => AppColors.emotionCalm,
     };

     String get _emoji => switch (emotion) {
       '기쁨' => '😊',
       '슬픔' => '😢',
       '평온' => '😌',
       '화남' => '😡',
       _     => '😌',
     };

     @override
     Widget build(BuildContext context) {
       return Chip(
         label: Text('$_emoji $emotion'),
         backgroundColor: _chipColor.withOpacity(0.2),
         side: BorderSide(color: _chipColor, width: 1.5),
         labelStyle: TextStyle(
           color: _chipColor,
           fontWeight: FontWeight.w600,
         ),
       );
     }
   }
   ```

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 1]
feat(core/widgets): LoadingShimmer 및 EmotionChip 공통 위젯 구현

- LoadingShimmer: shimmer 패키지 기반 로딩 플레이스홀더
- EmotionChip: 기쁨/슬픔/평온/화남 색상 칩 (AppColors 활용)

다음 꼭지(DiaryEntry 모델 + 저장소 인터페이스)를 진행할까요?
---
```

---

## 꼭지 2 — DiaryEntry 모델 및 저장소 인터페이스

### 작업 내용

1. `lib/features/diary/domain/diary_entry.dart` 작성

   ```dart
   import 'package:freezed_annotation/freezed_annotation.dart';
   import 'package:isar/isar.dart';

   part 'diary_entry.freezed.dart';
   part 'diary_entry.g.dart';

   @freezed
   @Collection()
   class DiaryEntry with _$DiaryEntry {
     const DiaryEntry._();

     const factory DiaryEntry({
       @Default(Isar.autoIncrement) Id id,
       required String rawText,
       required String correctedText,
       required String emotion,
       required List<String> tags,
       required DateTime createdAt,
     }) = _DiaryEntry;

     factory DiaryEntry.fromJson(Map<String, dynamic> json) =>
         _$DiaryEntryFromJson(json);

     /// 새 일기 엔트리 생성 팩토리 메서드
     factory DiaryEntry.create({
       required String rawText,
       required String correctedText,
       required String emotion,
       required List<String> tags,
     }) =>
         DiaryEntry(
           rawText: rawText,
           correctedText: correctedText,
           emotion: emotion,
           tags: tags,
           createdAt: DateTime.now(),
         );
   }
   ```

2. `lib/features/diary/domain/i_diary_repository.dart` 작성

   ```dart
   import 'package:isar/isar.dart';
   import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';

   /// 일기 저장소 추상 인터페이스.
   /// infrastructure 레이어의 Isar 구현체가 이를 구현한다.
   abstract class IDiaryRepository {
     Future<List<DiaryEntry>> findAll();
     Future<DiaryEntry?> findById(Id id);
     Future<void> save(DiaryEntry entry);
     Future<void> delete(Id id);
     Future<void> deleteAll();
   }
   ```

3. `build_runner` 실행

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 2]
feat(diary/domain): DiaryEntry freezed 모델 및 IDiaryRepository 인터페이스 정의

- DiaryEntry: isar @Collection, freezed 불변 모델, fromJson/create 팩토리
- IDiaryRepository: CRUD 추상 인터페이스
- build_runner 코드 생성 완료

다음 꼭지(Isar 저장소 구현체 + Provider)를 진행할까요?
---
```

---

## 꼭지 3 — Isar 저장소 구현체 및 Provider 설정

### 작업 내용

1. `lib/features/diary/infrastructure/diary_repository.dart` 작성

   ```dart
   import 'package:isar/isar.dart';
   import 'package:voicelog_ai/core/utils/logger.dart';
   import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';
   import 'package:voicelog_ai/features/diary/domain/i_diary_repository.dart';

   class IsarDiaryRepository implements IDiaryRepository {
     final Isar _isar;

     IsarDiaryRepository(this._isar);

     @override
     Future<List<DiaryEntry>> findAll() async {
       return _isar.diaryEntrys.where().sortByCreatedAtDesc().findAll();
     }

     @override
     Future<DiaryEntry?> findById(Id id) async {
       return _isar.diaryEntrys.get(id);
     }

     @override
     Future<void> save(DiaryEntry entry) async {
       try {
         await _isar.writeTxn(() => _isar.diaryEntrys.put(entry));
       } on IsarError catch (e) {
         AppLogger.error('DiaryEntry 저장 실패', e);
         rethrow;
       }
     }

     @override
     Future<void> delete(Id id) async {
       try {
         await _isar.writeTxn(() => _isar.diaryEntrys.delete(id));
       } on IsarError catch (e) {
         AppLogger.error('DiaryEntry 삭제 실패', e);
         rethrow;
       }
     }

     @override
     Future<void> deleteAll() async {
       await _isar.writeTxn(() => _isar.diaryEntrys.clear());
     }
   }
   ```

2. `lib/features/diary/application/diary_repository_provider.dart` 작성

   ```dart
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:isar/isar.dart';
   import 'package:path_provider/path_provider.dart';
   import 'package:riverpod_annotation/riverpod_annotation.dart';
   import 'package:voicelog_ai/features/diary/domain/diary_entry.dart';
   import 'package:voicelog_ai/features/diary/domain/i_diary_repository.dart';
   import 'package:voicelog_ai/features/diary/infrastructure/diary_repository.dart';

   part 'diary_repository_provider.g.dart';

   /// Isar 인스턴스 Provider (앱 생명주기 동안 유지)
   @Riverpod(keepAlive: true)
   Future<Isar> isar(IsarRef ref) async {
     final dir = await getApplicationDocumentsDirectory();
     return Isar.open(
       [DiaryEntrySchema],
       directory: dir.path,
     );
   }

   /// IDiaryRepository Provider
   @Riverpod(keepAlive: true)
   Future<IDiaryRepository> diaryRepository(DiaryRepositoryRef ref) async {
     final isar = await ref.watch(isarProvider.future);
     return IsarDiaryRepository(isar);
   }
   ```

3. `build_runner` 실행

   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. `flutter analyze` 오류 없음 확인

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 3]
feat(diary/infrastructure): Isar 저장소 구현체 및 Provider 설정

- IsarDiaryRepository: IDiaryRepository 구현, 에러 로깅 포함
- isarProvider: keepAlive Isar 인스턴스 Provider
- diaryRepositoryProvider: IDiaryRepository Provider
- build_runner 코드 생성 완료

Session 03 완료. Session 04로 넘어가려면 session_04_llm_service.md 파일을 참고하세요.
---
```
