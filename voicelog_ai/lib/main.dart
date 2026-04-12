import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:voicelog_ai/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 한국어 DateFormat('a h:mm', 'ko') 사용 전 locale 데이터 초기화 필수.
  // 미호출 시 LocaleDataException 발생.
  await initializeDateFormatting('ko_KR', null);
  runApp(const ProviderScope(child: VoicelogApp()));
}
