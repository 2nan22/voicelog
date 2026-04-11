import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoicelogApp extends ConsumerWidget {
  const VoicelogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Voicelog AI',
      theme: ThemeData(useMaterial3: true), // Session 02에서 교체
      home: const Scaffold(
        body: Center(child: Text('Voicelog AI')),
      ),
    );
  }
}
