import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tictactoe/core/application/router/app_router.dart';
import 'package:tictactoe/core/application/audio/audio_controller.dart';
import 'package:tictactoe/core/presentation/theme/gaming_theme.dart';
import 'package:tictactoe/core/presentation/widgets/widgets.dart';
import 'package:tictactoe/features/rules/domain/value_objects/best_of.dart';
import 'package:tictactoe/features/rules/domain/value_objects/game_mode.dart';

import '../providers/game_notifier.dart';
import '../views/game_view.dart';

/// Main game page that manages state and delegates to GameView
class GamePage extends ConsumerStatefulWidget {
  final GameMode gameMode;
  final BestOf bestOf;

  // Extracted static decoration for performance
  static const _loadingDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [GamingTheme.darkBackground, Color(0xFF1A1A3E)],
    ),
  );

  const GamePage({super.key, required this.gameMode, this.bestOf = BestOf.bo1});

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  bool _pendingPlayerMoveSfx = false;

  @override
  void initState() {
    super.initState();
    // Start the game after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(gameNotifierProvider.notifier)
          .startGame(widget.gameMode, bestOf: widget.bestOf);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<GameUiEvent>>(gameUiEventProvider, (_, next) {
      next.whenData((event) {
        _pendingPlayerMoveSfx = false;
        if (event is GameUiInvalidMoveEvent) {
          ref.read(audioControllerProvider).playSfx(SfxType.invalid);
        }
      });
    });

    ref.listen<GameUIState>(gameNotifierProvider, (previous, next) {
      final previousMoveCount = previous?.gameState?.moveCount ?? 0;
      final nextMoveCount = next.gameState?.moveCount ?? 0;
      if (_pendingPlayerMoveSfx && nextMoveCount > previousMoveCount) {
        ref.read(audioControllerProvider).playSfx(SfxType.place);
        _pendingPlayerMoveSfx = false;
      }

      final wasOver = previous?.gameState?.isGameOver ?? false;
      final isOver = next.gameState?.isGameOver ?? false;
      if (!wasOver && isOver) {
        ref.read(audioControllerProvider).playSfx(SfxType.gameOver);
      }
    });

    final uiState = ref.watch(gameNotifierProvider);
    final gameState = uiState.gameState;
    final matchState = uiState.matchState;

    // Show loading while game is being created
    if (gameState == null || matchState == null) {
      return GamingScaffold(
        child: const DecoratedBox(
          decoration: GamePage._loadingDecoration,
          child: Center(
            child: CircularProgressIndicator(color: GamingTheme.accentCyan),
          ),
        ),
      );
    }

    return GamingScaffold(
      child: GameView(
        gameState: gameState,
        isAIThinking: uiState.isAIThinking,
        animatedCells: uiState.animatedCells,
        onCellTap: (position) {
          _pendingPlayerMoveSfx = true;
          ref.read(gameNotifierProvider.notifier).playMove(position);
        },
        onBack: () => context.pop(),
        onSettings: () => const SettingsRoute().push(context),
        onRestart: () {
          ref.read(gameNotifierProvider.notifier).restartGame();
        },
        onHome: () => const HomeRoute().go(context),
        // Match state info for Best Of support
        playerXScore: uiState.playerXScore,
        playerOScore: uiState.playerOScore,
        currentRound: matchState.currentRoundNumber,
        maxRounds: matchState.maxRounds,
        isSingleGame: uiState.isSingleGame,
        awaitingNextRound: uiState.awaitingNextRound,
        matchResult: matchState.result,
        onContinue: () {
          ref.read(gameNotifierProvider.notifier).continueToNextRound();
        },
      ),
    );
  }
}
