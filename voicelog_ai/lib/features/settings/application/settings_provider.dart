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
    final styleIdx = doc?.writingStyleIndex ?? 0;
    return AppSettings(
      isDarkMode: doc?.isDarkMode ?? false,
      writingStyle: styleIdx >= 0 && styleIdx < WritingStyle.values.length
          ? WritingStyle.values[styleIdx]
          : WritingStyle.diary,
      correctionEnabled: doc?.correctionEnabled ?? false,
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
      ..writingStyleIndex = value.index
      ..correctionEnabled = current.correctionEnabled;
    await isar.writeTxn(() => isar.appSettingsDocuments.put(doc));
    state = AsyncData(current.copyWith(writingStyle: value));
  }

  Future<void> setCorrectionEnabled(bool value) async {
    final current = await future;
    final isar = await ref.read(isarProvider.future);
    final doc = AppSettingsDocument()
      ..id = 0
      ..isDarkMode = current.isDarkMode
      ..writingStyleIndex = current.writingStyle.index
      ..correctionEnabled = value;
    await isar.writeTxn(() => isar.appSettingsDocuments.put(doc));
    state = AsyncData(current.copyWith(correctionEnabled: value));
  }
}
