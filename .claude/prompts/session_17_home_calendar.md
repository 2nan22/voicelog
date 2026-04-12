# Session 17 — 홈 화면 캘린더 뷰 교체

## 목표

| 항목 | 내용 |
|------|------|
| 홈 화면 | `diary_list_screen.dart` 전면 교체 — 일기 목록 → `table_calendar` 월간 캘린더 뷰 |

---

## Session 16 완료 요약

> 아래 작업은 이미 커밋 완료 상태. 다시 구현하지 말 것.

| 꼭지 | 내용 | 주요 파일 |
|------|------|-----------|
| 꼭지 1 | LLM 보정 문체 선택 (일기체·메모체·편지체) | `app_settings.dart`, `settings_provider.dart`, `prompts.dart`, `settings_screen.dart` |
| 꼭지 2 | 녹음 화면 STT/LLM 결과 카드 분리 + 버튼 재설계 | `diary_record_screen.dart` — `_SttCard` / `_LlmResultCard` / `_ControlsRow` |
| 꼭지 3 | 실시간 마이크 파형 연동 + 녹음 파일 저장·재생 | `speech_to_text_service.dart`, `diary_record_provider.dart`, `mic_button.dart` |

### Session 16 추가 수정 사항

- `record: ^5.x` → `^6.x` 업그레이드 (`record_linux 0.7.2` ↔ `record_platform_interface 1.5.0` 충돌 수정)

---

## 사전 조건

- `feat/init-20260411` 브랜치 기준
- Session 16 꼭지 1~3 + record 버그 수정 커밋 완료 확인 후 진행
- 참고 규칙: `.claude/rules/architecture.md`, `.claude/rules/state_management.md`, `.claude/rules/ui_ux.md`

---

## 꼭지 1 — 홈 화면 캘린더 뷰로 교체

### 배경 및 현재 상태

- `diary_list_screen.dart` (현재 약 400줄): `CustomScrollView` + `SliverList.builder`로 일기 카드 목록 표시
- Logs 탭(`logs_screen.dart`)에서도 월별 타임라인을 제공하여 중복
- 홈 탭은 **캘린더**로 교체 — 날짜 기반 탐색 + 감정 색상 점 마커 시각화

### 새 패키지 추가 (`pubspec.yaml`)

```yaml
dependencies:
  table_calendar: ^3.1.3
```

### 수정 파일 목록

| 파일 | 작업 |
|------|------|
| `pubspec.yaml` | `table_calendar` 추가 |
| `lib/features/diary/application/diary_list_provider.dart` | `diaryByDateProvider` 파생 Provider 추가 |
| `lib/features/diary/presentation/screens/diary_list_screen.dart` | 캘린더 뷰로 전면 교체 |

### 작업 내용

#### 1. `diary_list_provider.dart` — 날짜별 일기 맵 파생 Provider

```dart
/// 날짜(연·월·일만) → 해당 날의 DiaryEntry 목록 맵.
/// 캘린더 이벤트 마커 및 선택 날짜 목록에 사용.
@riverpod
Future<Map<DateTime, List<DiaryEntry>>> diaryByDate(DiaryByDateRef ref) async {
  final entries = await ref.watch(diaryListNotifierProvider.future);
  final map = <DateTime, List<DiaryEntry>>{};
  for (final e in entries) {
    final day = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
    map.putIfAbsent(day, () => []).add(e);
  }
  return map;
}
```

#### 2. `diary_list_screen.dart` — 캘린더 뷰 전면 교체

전체 구조:
```
CustomScrollView
  ├─ SliverPersistentHeader (기존 글래스 헤더 유지)
  └─ SliverToBoxAdapter
       ├─ TableCalendar (월간 캘린더)
       │    - focusedDay: 현재 선택된 날짜 (selectedDay 기준)
       │    - eventLoader: 날짜 → DiaryEntry 목록 반환
       │    - markerBuilder: 감정별 색상 점(6px) 최대 3개 렌더링
       └─ AnimatedSwitcher
            └─ 선택된 날짜의 일기 카드 목록 (DiaryCard 재사용)
                 (일기 없으면 "이 날의 일기가 없어요" 안내 텍스트)
```

감정 색상 마커 구현:
```dart
// eventLoader 콜백
eventLoader: (day) {
  final key = DateTime(day.year, day.month, day.day);
  return diaryByDate[key] ?? [];
},

// calendarBuilders.markerBuilder
markerBuilder: (context, date, events) {
  if (events.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: events.take(3).map((e) {
        final entry = e as DiaryEntry;
        return Container(
          width: 6, height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _emotionColor(entry.emotion),
          ),
        );
      }).toList(),
    ),
  );
},
```

감정 색상 헬퍼 (AppColors 사용):
```dart
Color _emotionColor(String emotion) => switch (emotion) {
  '기쁨'  => AppColors.emotionJoy,
  '슬픔'  => AppColors.emotionSadness,
  '화남'  => AppColors.emotionAnger,
  _       => AppColors.emotionCalm,
};
```

선택 날짜 상태 관리:
- `_selectedDay`는 `ConsumerStatefulWidget`의 로컬 state로 관리 (`ref`가 필요하므로)
- 또는 `selectedDayProvider` 별도 Provider로 분리 (컨텍스트 없이 상태 접근 필요한 경우)
- 간단하게 `ConsumerStatefulWidget`의 `setState`로 충분

TableCalendar 스타일 (Material 3 기준):
```dart
TableCalendar(
  locale: 'ko_KR',
  firstDay: DateTime(2020),
  lastDay: DateTime(2100),
  focusedDay: _focusedDay,
  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
  onDaySelected: (selectedDay, focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  },
  calendarFormat: CalendarFormat.month,
  // 포맷 변경 버튼 숨김
  availableCalendarFormats: const {CalendarFormat.month: '월'},
  headerStyle: HeaderStyle(
    formatButtonVisible: false,
    titleCentered: true,
    titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.w700,
    ),
  ),
  calendarStyle: CalendarStyle(
    todayDecoration: BoxDecoration(
      color: scheme.primary.withValues(alpha: 0.15),
      shape: BoxShape.circle,
    ),
    todayTextStyle: TextStyle(
      color: scheme.primary,
      fontWeight: FontWeight.w700,
    ),
    selectedDecoration: BoxDecoration(
      color: scheme.primary,
      shape: BoxShape.circle,
    ),
    markerDecoration: const BoxDecoration(), // markerBuilder로 직접 렌더링
    markersMaxCount: 0, // markerBuilder 사용 시 기본 마커 비활성화
  ),
  eventLoader: ...,
  calendarBuilders: CalendarBuilders(markerBuilder: ...),
),
```

#### 3. `build_runner` 실행

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

### 커밋 메시지 출력 후 대기

```
---
[커밋 준비 — 꼭지 1]
feat(home): 홈 화면 일기 목록 → 캘린더 뷰로 교체

- table_calendar 패키지 도입
- diaryByDateProvider: 날짜별 DiaryEntry 맵 파생 Provider
- diary_list_screen: TableCalendar 월간 뷰
  - 일기 있는 날 감정 색상 점 마커 (최대 3개)
  - 날짜 선택 시 하단 AnimatedSwitcher로 일기 카드 목록 표시
  - 기존 SliverList 일기 목록 제거 (Logs 탭 중복 기능 정리)

Session 16·17 완료.
---
```

---

## [참고] Session 16 수정 파일 전체 목록

Session 17 완료 후 UI 일괄 변경 작업(Session 18+) 시 아래 파일이 교체 대상이 됩니다.

### 탭별 화면

| 탭 / 화면 | 파일 경로 |
|-----------|-----------|
| 홈 (캘린더) | `lib/features/diary/presentation/screens/diary_list_screen.dart` |
| 녹음 화면 | `lib/features/diary/presentation/screens/diary_record_screen.dart` |
| 설정 화면 | `lib/features/settings/presentation/screens/settings_screen.dart` |

### 공유 컴포넌트

| 컴포넌트 | 파일 경로 |
|----------|-----------|
| 마이크 버튼 | `lib/features/diary/presentation/widgets/mic_button.dart` |
| 파형 위젯 | `lib/features/diary/presentation/widgets/waveform_widget.dart` |
| 스트리밍 텍스트 | `lib/features/diary/presentation/widgets/streaming_text_widget.dart` |

### 상태 · 도메인

| 역할 | 파일 경로 |
|------|-----------|
| 녹음 상태 + 진폭 버퍼 | `lib/features/diary/application/diary_record_provider.dart` |
| LLM Provider (문체 반영) | `lib/features/diary/application/llm_provider.dart` |
| 설정 도메인 (WritingStyle) | `lib/features/settings/domain/app_settings.dart` |
| 프롬프트 상수 | `lib/core/constants/prompts.dart` |
