import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:voicelog_ai/core/constants/strings.dart';

/// 설정 화면 (Session 10에서 상세 구현 예정).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: '뒤로',
          onPressed: () => context.pop(),
        ),
        title: const Text(AppStrings.appName),
      ),
      body: const Center(
        child: Text('설정 화면은 준비 중입니다.'),
      ),
    );
  }
}
