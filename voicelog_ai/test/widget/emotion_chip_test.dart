import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voicelog_ai/core/widgets/emotion_chip.dart';

void main() {
  group('EmotionChip', () {
    Widget buildChip(String emotion) => MaterialApp(
          home: Scaffold(body: EmotionChip(emotion: emotion)),
        );

    testWidgets('기쁨 칩 렌더링 — 이모지+텍스트 포함', (tester) async {
      await tester.pumpWidget(buildChip('기쁨'));
      expect(find.text('😊 기쁨'), findsOneWidget);
    });

    testWidgets('슬픔 칩 렌더링 — 이모지+텍스트 포함', (tester) async {
      await tester.pumpWidget(buildChip('슬픔'));
      expect(find.text('😢 슬픔'), findsOneWidget);
    });

    testWidgets('평온 칩 렌더링 — 이모지+텍스트 포함', (tester) async {
      await tester.pumpWidget(buildChip('평온'));
      expect(find.text('😌 평온'), findsOneWidget);
    });

    testWidgets('화남 칩 렌더링 — 이모지+텍스트 포함', (tester) async {
      await tester.pumpWidget(buildChip('화남'));
      expect(find.text('😡 화남'), findsOneWidget);
    });

    testWidgets('알 수 없는 감정 — 기본값으로 오류 없이 렌더링', (tester) async {
      await tester.pumpWidget(buildChip('unknown'));
      expect(find.byType(Chip), findsOneWidget);
      expect(find.text('😌 unknown'), findsOneWidget);
    });
  });
}
