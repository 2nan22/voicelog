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
