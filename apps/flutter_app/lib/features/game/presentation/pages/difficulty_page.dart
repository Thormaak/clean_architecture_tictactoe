import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tictactoe/features/rules/rules.dart';

import '../../../../core/application/audio/audio_controller.dart';
import '../../../../core/application/router/app_router.dart';
import '../views/difficulty_view.dart';

/// Page for selecting AI difficulty level.
class DifficultyPage extends ConsumerStatefulWidget {
  const DifficultyPage({super.key});

  @override
  ConsumerState<DifficultyPage> createState() => _DifficultyPageState();
}

class _DifficultyPageState extends ConsumerState<DifficultyPage> {
  @override
  void initState() {
    super.initState();
    ref.read(audioControllerProvider).playMusic(MusicTrack.menu);
  }

  @override
  Widget build(BuildContext context) {
    return DifficultyView(
      onBack: () => context.pop(),
      onSettings: () => const SettingsRoute().push(context),
      onSelect: (difficulty) => _navigateToGame(context, difficulty),
    );
  }

  void _navigateToGame(BuildContext context, AIDifficulty difficulty) {
    BestOfSelectionRoute(GameMode.vsAI(difficulty: difficulty)).push(context);
  }
}
