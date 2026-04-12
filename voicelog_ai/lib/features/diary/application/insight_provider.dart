import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';

part 'insight_provider.g.dart';

/// 감정별 카운트 맵. 예: {'기쁨': 5, '슬픔': 2, '평온': 8, '화남': 1}
@riverpod
Future<Map<String, int>> emotionCounts(EmotionCountsRef ref) async {
  final entries = await ref.watch(diaryListNotifierProvider.future);
  final counts = <String, int>{};
  for (final e in entries) {
    counts[e.emotion] = (counts[e.emotion] ?? 0) + 1;
  }
  return counts;
}

/// 연속 기록 스트릭 (오늘 기준 연속 작성 일수).
@riverpod
Future<int> writingStreak(WritingStreakRef ref) async {
  final entries = await ref.watch(diaryListNotifierProvider.future);
  if (entries.isEmpty) return 0;

  final dates = entries
      .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a)); // 최신순 정렬

  int streak = 0;
  DateTime cursor = DateTime.now();
  cursor = DateTime(cursor.year, cursor.month, cursor.day);

  for (final date in dates) {
    if (date == cursor || date == cursor.subtract(const Duration(days: 1))) {
      streak++;
      cursor = date;
    } else {
      break;
    }
  }
  return streak;
}

/// 태그 빈도 Top 5. 예: [('#산책', 7), ('#친구', 4), ...]
@riverpod
Future<List<(String, int)>> topTags(TopTagsRef ref) async {
  final entries = await ref.watch(diaryListNotifierProvider.future);
  final counts = <String, int>{};
  for (final e in entries) {
    for (final tag in e.tags) {
      counts[tag] = (counts[tag] ?? 0) + 1;
    }
  }
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.take(5).map((e) => (e.key, e.value)).toList();
}
