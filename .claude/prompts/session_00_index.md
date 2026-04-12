# Voicelog AI — 세션별 작업 인덱스

## 작업 진행 방법

1. 각 세션 파일을 순서대로 참고하여 작업 진행
2. 한 세션 내 꼭지(2~4개)를 순서대로 수행
3. **각 꼭지 완료 후 커밋 메시지 출력 → 사용자 확인 후 다음 꼭지 진행**

---

## 세션 목록

| 세션 | 파일 | 주요 내용 |
|------|------|-----------|
| Session 01 | `session_01_project_init.md` | Flutter 프로젝트 생성, pubspec, 폴더 구조, main.dart |
| Session 02 | `session_02_core_layer.md` | 테마(Material 3), 상수 파일, 유틸리티·확장 메서드 |
| Session 03 | `session_03_domain_db.md` | 공통 위젯, DiaryEntry 모델, Isar 저장소 |
| Session 04 | `session_04_llm_service.md` | MediaPipe LLM 서비스, warm-up Provider, SplashScreen |
| Session 05 | `session_05_stt_service.md` | STT 서비스, Android/iOS 권한, 녹음 상태 Provider |
| Session 06 | `session_06_record_screen.md` | 녹음 화면 레이아웃, 파형 위젯, 마이크 버튼 애니메이션 |
| Session 07 | `session_07_llm_streaming_ui.md` | LLM 스트리밍 연결, StreamingTextWidget, 감정·태그 칩 |
| Session 08 | `session_08_diary_list.md` | 일기 저장, DiaryListScreen, DiaryCard |
| Session 09 | `session_09_detail_routing.md` | 상세 화면, go_router 완성, 앱 생명주기 관리 |
| Session 10 | `session_10_settings.md` | 설정 모델, SettingsScreen, 다크 모드 |
| Session 11 | `session_11_testing.md` | 단위 테스트, Mock 클래스, 위젯 테스트, 커버리지 |
| Session 12 | `session_12_logs_tab.md` | ShellRoute 탭 네비 리팩토링, Logs 월별 타임라인 |
| Session 13 | `session_13_insight_tab.md` | 감정 도넛 차트, 스트릭, 태그 빈도 Insight 화면 |
| Session 14 | `session_14_profile_tab.md` | 앱 통계, 모델 정보, 전체 삭제, Profile 화면 |
| Session 15 | `_complete/session_15_bugfix.md` | 버그 수정 |
| Session 16 | `_complete/session_16_record_home_v2.md` | 문체 선택, 녹음 화면 STT/LLM 카드 분리, 파형 연동 |
| Session 17 | `_complete/session_17_home_calendar.md` | 홈 화면 캘린더 뷰로 교체 (table_calendar) |
| Session 18 | `session_18_ui_stitch_v2.md` | Stitch v0.0.2 기반 UI 전면 개선 (4 꼭지) |

---

## UI 디자인 참고 원칙

- **화면 UI, 버튼, 레이아웃은 Google Stitch 디자인을 최우선 참고**
- Stitch에서 생성한 코드가 있으면 해당 컴포넌트 구조를 반영
- Stitch 코드가 없는 경우 각 세션 파일의 가이드라인으로 구현

---

## 주요 기술 결정 사항

| 항목 | 결정 | 이유 |
|------|------|------|
| 상태 관리 | Riverpod 2.x (@riverpod) | 코드 생성, 타입 안전, 테스트 용이 |
| 로컬 DB | Isar | 순수 Dart, 빠른 온디바이스 NoSQL |
| 라우팅 | go_router | Flutter 공식 권장, 딥링크 지원 |
| 불변 모델 | freezed | copyWith, JSON, 패턴 매칭 |
| 폰트 | Pretendard | 한국어 최적화 Variable 폰트 |
| 아키텍처 | Feature-first + Clean Architecture | 레이어 명확, 테스트 용이 |
