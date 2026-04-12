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
    return AppSettings(isDarkMode: doc?.isDarkMode ?? false);
  }

  Future<void> setDarkMode(bool value) async {
    final isar = await ref.read(isarProvider.future);
    final doc = AppSettingsDocument()
      ..id = 0
      ..isDarkMode = value;
    await isar.writeTxn(() => isar.appSettingsDocuments.put(doc));
    state = AsyncData(AppSettings(isDarkMode: value));
  }
}
