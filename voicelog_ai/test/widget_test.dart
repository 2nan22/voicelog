import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voicelog_ai/app.dart';

void main() {
  testWidgets('VoicelogApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: VoicelogApp()),
    );
    expect(find.text('Voicelog AI'), findsOneWidget);
  });
}
