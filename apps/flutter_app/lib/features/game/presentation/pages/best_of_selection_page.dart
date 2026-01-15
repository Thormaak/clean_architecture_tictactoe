import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tictactoe/features/rules/domain/value_objects/best_of.dart';
import 'package:tictactoe/features/rules/domain/value_objects/game_mode.dart';

import '../../../../core/application/audio/audio_controller.dart';
import '../../../../core/application/router/app_router.dart';
import '../views/best_of_selection_view.dart';

/// Page for selecting Best Of format before starting a game.
/// Used for both Local and vs AI game modes.
class BestOfSelectionPage extends ConsumerStatefulWidget {
  final GameMode gameMode;

  const BestOfSelectionPage({super.key, required this.gameMode});

  @override
  ConsumerState<BestOfSelectionPage> createState() =>
      _BestOfSelectionPageState();
}

class _BestOfSelectionPageState extends ConsumerState<BestOfSelectionPage> {
  @override
  void initState() {
    super.initState();
    ref.read(audioControllerProvider).playMusic(MusicTrack.menu);
  }

  @override
  Widget build(BuildContext context) {
    return BestOfSelectionView(
      onBack: () => context.pop(),
      onSettings: () => const SettingsRoute().push(context),
      onSelect: (bestOf) => _startGame(context, bestOf),
    );
  }

  void _startGame(BuildContext context, BestOf bestOf) {
    GameRoute(GameParams(mode: widget.gameMode, bestOf: bestOf)).go(context);
  }
}
