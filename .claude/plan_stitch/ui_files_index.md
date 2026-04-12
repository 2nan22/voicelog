# Voicelog AI — UI 파일 전체 목록

> 전면 UI 교체 작업 시 Stitch에 이 파일과 `design_system.md`를 함께 전달하세요.
> 마지막 갱신: 2026-04-12 (Session 17 완료 기준)

---

## Screens (8개)

| 파일 경로 (`lib/` 기준) | 주요 위젯 | 역할 |
|------------------------|-----------|------|
| `features/diary/presentation/screens/diary_list_screen.dart` | `DiaryListBody`, `_GlassNavWidget`, `_GradientFab` | 홈 탭 — 월간 캘린더 + 날짜 선택 시 일기 목록 |
| `features/diary/presentation/screens/diary_record_screen.dart` | `DiaryRecordScreen`, `_SttCard`, `_LlmResultCard`, `_ControlsRow`, `_BottomPanel`, `_GlassHeader` | 녹음 화면 — STT/LLM 카드, 실시간 파형, 하단 버튼 |
| `features/diary/presentation/screens/diary_detail_screen.dart` | `DiaryDetailScreen`, `_GlassAppBar`, `_EmotionPill`, `_TagPill`, `_OriginalTextSection` | 일기 상세 — 글래스 헤더, 감정/태그 칩, 본문, 원문 |
| `features/diary/presentation/screens/logs_screen.dart` | `LogsScreen`, `_TimelineItem`, `_LogsGlassHeader` | Logs 탭 — 월별 전체 일기 타임라인 |
| `features/diary/presentation/screens/insight_screen.dart` | `InsightScreen`, `_StreakCard`, `_EmotionSection`, `_TagSection`, `_InsightGlassHeader` | 인사이트 탭 — 연속 기록 스트릭, 감정 분포, 자주 쓴 태그 |
| `features/diary/presentation/screens/profile_screen.dart` | `ProfileScreen`, `_AvatarSection`, `_StatsGrid`, `_StatCard`, `_DataManagementSection` | 프로필 탭 — 통계 그리드, 앱 정보, 데이터 관리 |
| `features/diary/presentation/screens/splash_screen.dart` | `SplashScreen`, `_DownloadSection`, `_WarmUpSection`, `_ErrorSection` | 스플래시 — 모델 다운로드 + LLM 워밍업 진행 |
| `features/settings/presentation/screens/settings_screen.dart` | `SettingsScreen`, `_WritingStyleCard`, `_ToggleItem`, `_GlassAppBar` | 설정 — 다크모드 토글, AI 문체(일기체·메모체·편지체) 선택 |

---

## Widgets — Feature (6개)

| 파일 경로 (`lib/` 기준) | 주요 위젯 | 역할 |
|------------------------|-----------|------|
| `features/diary/presentation/widgets/diary_card.dart` | `DiaryCard`, `_EmotionBadge`, `_TagChip` | 일기 카드 — 좌측 감정 컬러바, 날짜·감정 배지, 본문 2줄, 태그 |
| `features/diary/presentation/widgets/mic_button.dart` | `MicButton` | 마이크 버튼 — 상태별(idle/recording/processing) 아이콘 + 펄스 애니메이션 |
| `features/diary/presentation/widgets/waveform_widget.dart` | `WaveformWidget`, `_WaveformPainter` | 실시간 음성 파형 — CustomPainter, 진폭 막대 그래프 |
| `features/diary/presentation/widgets/streaming_text_widget.dart` | `StreamingTextWidget` | LLM 스트리밍 텍스트 — 누적 출력 + 깜빡이는 커서 |
| `features/diary/presentation/widgets/diary_result_widget.dart` | `DiaryResultWidget`, `_TagChip` | LLM 최종 결과 — 감정 칩, 태그 칩 표시 |
| `features/diary/presentation/widgets/emotion_donut_chart.dart` | `EmotionDonutChart`, `_DonutPainter` | 감정 분포 도넛 차트 — CustomPainter |

---

## Widgets — Core (3개)

| 파일 경로 (`lib/` 기준) | 주요 위젯 | 역할 |
|------------------------|-----------|------|
| `core/widgets/main_shell.dart` | `MainShell`, `_GlassBottomNav`, `_NavItem` | 하단 탭 네비게이션 Shell (홈·로그·인사이트·프로필) |
| `core/widgets/emotion_chip.dart` | `EmotionChip` | 감정값 기반 색상 칩 — 기쁨/슬픔/평온/화남 |
| `core/widgets/loading_shimmer.dart` | `LoadingShimmer` | 데이터 로딩 shimmer 플레이스홀더 |

---

## 테마 · 상수 (4개)

| 파일 경로 (`lib/` 기준) | 역할 |
|------------------------|------|
| `core/theme/app_colors.dart` | 전역 색상 상수 — seed(`#0059B9`), 감정 4색, 배경 |
| `core/theme/app_theme.dart` | Material 3 라이트/다크 테마 빌더 (Pretendard 폰트) |
| `core/constants/dimensions.dart` | 치수 상수 — padding(8/16/24/32), border-radius(12/24), 마이크 버튼(72) |
| `core/constants/strings.dart` | UI 표시 텍스트 상수 — 앱명, 버튼 라벨, 에러 메시지 등 |

---

## 요약

| 분류 | 파일 수 |
|------|---------|
| Screens | 8 |
| Widgets (feature) | 6 |
| Widgets (core) | 3 |
| Theme · 상수 | 4 |
| **합계** | **21** |
