import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:voicelog_ai/features/diary/domain/i_diary_repository.dart';
import 'package:voicelog_ai/features/diary/infrastructure/diary_entry_document.dart';
import 'package:voicelog_ai/features/diary/infrastructure/diary_repository.dart';
import 'package:voicelog_ai/features/settings/infrastructure/app_settings_document.dart';

part 'diary_repository_provider.g.dart';

/// Isar 인스턴스 Provider (앱 생명주기 동안 유지)
@Riverpod(keepAlive: true)
Future<Isar> isar(IsarRef ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [DiaryEntryDocumentSchema, AppSettingsDocumentSchema],
    directory: dir.path,
  );
}

/// IDiaryRepository Provider
@Riverpod(keepAlive: true)
Future<IDiaryRepository> diaryRepository(DiaryRepositoryRef ref) async {
  final isar = await ref.watch(isarProvider.future);
  return IsarDiaryRepository(isar);
}
