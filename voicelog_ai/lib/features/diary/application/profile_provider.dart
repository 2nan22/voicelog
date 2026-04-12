import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:voicelog_ai/features/diary/application/diary_list_provider.dart';

part 'profile_provider.g.dart';

/// 프로필 화면에서 사용하는 앱 통계 집계.
@riverpod
Future<AppStats> appStats(AppStatsRef ref) async {
  final entries = await ref.watch(diaryListNotifierProvider.future);

  final totalEntries = entries.length;
  final totalWords = entries.fold<int>(
    0,
    (sum, e) => sum + e.correctedText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length,
  );

  final dates = entries
      .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));

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

  final firstEntry = entries.isEmpty
      ? null
      : entries.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);

  return AppStats(
    totalEntries: totalEntries,
    totalWords: totalWords,
    streak: streak,
    firstEntryDate: firstEntry?.createdAt,
  );
}

class AppStats {
  const AppStats({
    required this.totalEntries,
    required this.totalWords,
    required this.streak,
    this.firstEntryDate,
  });

  final int totalEntries;
  final int totalWords;
  final int streak;
  final DateTime? firstEntryDate;
}
