import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:voicelog_ai/features/diary/application/diary_repository_provider.dart';
import 'package:voicelog_ai/features/settings/domain/app_settings.dart';
import 'package:voicelog_ai/features/settings/infrastructure/app_settings_document.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<AppSettings> build() async {
    final isar = await ref.watch(isarProvider.future);
    final doc = await isar.appSettingsDocuments.get(0);
    return AppSettings(
      isDarkMode: doc?.isDarkMode ?? false,
      writingStyle: WritingStyle.values[doc?.writingStyleIndex ?? 0],
    );
  }

  Future<void> setDarkMode(bool value) async {
    final current = await future;
    final isar = await ref.read(isarProvider.future);
    final doc = AppSettingsDocument()
      ..id = 0
      ..isDarkMode = value
      ..writingStyleIndex = current.writingStyle.index;
    await isar.writeTxn(() => isar.appSettingsDocuments.put(doc));
    state = AsyncData(current.copyWith(isDarkMode: value));
  }

  Future<void> setWritingStyle(WritingStyle value) async {
    final current = await future;
    final isar = await ref.read(isarProvider.future);
    final doc = AppSettingsDocument()
      ..id = 0
      ..isDarkMode = current.isDarkMode
      ..writingStyleIndex = value.index;
    await isar.writeTxn(() => isar.appSettingsDocuments.put(doc));
    state = AsyncData(current.copyWith(writingStyle: value));
  }
}
