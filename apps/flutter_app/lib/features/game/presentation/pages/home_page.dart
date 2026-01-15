import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tictactoe/features/rules/domain/value_objects/game_mode.dart';

import '../../../../core/application/audio/audio_controller.dart';
import '../../../../core/application/router/app_router.dart';
import '../views/home_view.dart';

/// Home page container widget.
/// Handles navigation and passes callbacks to HomeView.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    ref.read(audioControllerProvider).playMusic(MusicTrack.menu);
  }

  @override
  Widget build(BuildContext context) {
    return HomeView(
      onLocalGame:
          () => BestOfSelectionRoute(const GameMode.local()).push(context),
      onAIGame: () => const DifficultyRoute().push(context),
      onSettings: () => const SettingsRoute().push(context),
    );
  }
}
