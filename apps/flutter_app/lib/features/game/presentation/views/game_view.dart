import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/presentation/extensions/build_context_extensions.dart';
import '../../../../core/presentation/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/widgets.dart';
import 'package:tictactoe/features/rules/rules.dart';
import '../widgets/game_widgets.dart';

/// Main game view that assembles all game widgets
class GameView extends StatelessWidget {
  final GameState gameState;
  final bool isAIThinking;
  final Set<int> animatedCells;
  final ValueChanged<Position> onCellTap;
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final VoidCallback? onRestart;
  final VoidCallback? onHome;

  // Best Of match support
  final int playerXScore;
  final int playerOScore;
  final int currentRound;
  final int maxRounds;
  final bool isSingleGame;
  final bool awaitingNextRound;
  final MatchResult matchResult;
  final VoidCallback? onContinue;

  const GameView({
    super.key,
    required this.gameState,
    this.isAIThinking = false,
    this.animatedCells = const {},
    required this.onCellTap,
    required this.onBack,
    required this.onSettings,
    this.onRestart,
    this.onHome,
    // Default values for single game (backward compatibility)
    this.playerXScore = 0,
    this.playerOScore = 0,
    this.currentRound = 1,
    this.maxRounds = 1,
    this.isSingleGame = true,
    this.awaitingNextRound = false,
    this.matchResult = const MatchResult.ongoing(),
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = context.isLargeScreen;
    final isWide = context.isLandscape && context.screenWidth >= 1100;
    final horizontalPadding = isLargeScreen ? 48.0 : 24.0;
    final boardSize = isLargeScreen ? 480.0 : null;
    final displayPlayerX = gameState.config.playerX.copyWith(
      score: playerXScore,
    );
    final displayPlayerO = gameState.config.playerO.copyWith(
      score: playerOScore,
    );
    final isGameOver = gameState.isGameOver;
    final winnerMark = switch (gameState.result) {
      GameResultWin(:final winner) => winner,
      _ => null,
    };
    final isXAI = gameState.config.mode.maybeWhen(
      vsAI: (_) => false,
      orElse: () => false,
    );
    final isOAI = gameState.config.mode.maybeWhen(
      vsAI: (_) => true,
      orElse: () => false,
    );

    Widget buildBoard() {
      final board = GameBoard(
        board: gameState.board,
        result: gameState.result,
        currentTurn: gameState.currentTurn,
        animatedCells: animatedCells,
        onCellTap: onCellTap,
      );
      if (boardSize == null) {
        return board;
      }
      return SizedBox(width: boardSize, height: boardSize, child: board);
    }

    final l10n = AppLocalizations.of(context)!;
    final board = buildBoard();
    final gameView =
        isWide
            ? _HorizontalGameView(
              board: board,
              horizontalPadding: horizontalPadding,
              currentPlayer: gameState.currentPlayer,
              displayPlayerX: displayPlayerX,
              displayPlayerO: displayPlayerO,
              isGameOver: isGameOver,
              currentTurn: gameState.currentTurn,
              isAIThinking: isAIThinking,
              isXAI: isXAI,
              isOAI: isOAI,
              winnerMark: winnerMark,
              onBack: onBack,
              onSettings: onSettings,
              isSingleGame: isSingleGame,
              currentRound: currentRound,
              maxRounds: maxRounds,
              l10n: l10n,
            )
            : _VerticalGameView(
              board: board,
              horizontalPadding: horizontalPadding,
              gameState: gameState,
              isAIThinking: isAIThinking,
              playerXScore: playerXScore,
              playerOScore: playerOScore,
              onBack: onBack,
              onSettings: onSettings,
              isSingleGame: isSingleGame,
              currentRound: currentRound,
              maxRounds: maxRounds,
              l10n: l10n,
            );

    return SafeArea(
      child: Stack(
        children: [
          // Main content
          gameView,

          // Overlay logic
          _GameOverlay(
            gameState: gameState,
            isSingleGame: isSingleGame,
            awaitingNextRound: awaitingNextRound,
            matchResult: matchResult,
            playerXScore: playerXScore,
            playerOScore: playerOScore,
            currentRound: currentRound,
            maxRounds: maxRounds,
            onRestart: onRestart,
            onHome: onHome,
            onContinue: onContinue,
          ),
        ],
      ),
    );
  }
}

class _VerticalGameView extends StatelessWidget {
  final Widget board;
  final double horizontalPadding;
  final GameState gameState;
  final bool isAIThinking;
  final int playerXScore;
  final int playerOScore;
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final bool isSingleGame;
  final int currentRound;
  final int maxRounds;
  final AppLocalizations l10n;

  const _VerticalGameView({
    required this.board,
    required this.horizontalPadding,
    required this.gameState,
    required this.isAIThinking,
    required this.playerXScore,
    required this.playerOScore,
    required this.onBack,
    required this.onSettings,
    required this.isSingleGame,
    required this.currentRound,
    required this.maxRounds,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GamingHeaderRow(
          onBack: onBack,
          onSettings: onSettings,
          center:
              isSingleGame
                  ? SuddenDeathLabel(label: l10n.suddenDeath)
                  : RoundIndicator(
                    currentRound: currentRound,
                    maxRounds: maxRounds,
                  ),
        ),
        const SizedBox(height: 16),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _FadeInOnce(
                delay: 100.ms,
                duration: 400.ms,
                child: TurnIndicator(
                  currentPlayer: gameState.currentPlayer,
                  isAIThinking: isAIThinking,
                  isGameOver: gameState.isGameOver,
                ),
              ),
              _FadeScaleInOnce(
                delay: 200.ms,
                duration: 500.ms,
                beginScale: 0.9,
                endScale: 1.0,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: board,
                  ),
                ),
              ),
              _FadeInOnce(
                delay: 300.ms,
                duration: 400.ms,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: PlayerSection(
                    playerX: gameState.config.playerX,
                    playerO: gameState.config.playerO,
                    currentTurn: gameState.currentTurn,
                    result: gameState.result,
                    gameMode: gameState.config.mode,
                    isAIThinking: isAIThinking,
                    playerXScore: playerXScore,
                    playerOScore: playerOScore,
                    maxCardWidth: 180,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HorizontalGameView extends StatelessWidget {
  final Widget board;
  final double horizontalPadding;
  final Player currentPlayer;
  final Player displayPlayerX;
  final Player displayPlayerO;
  final bool isGameOver;
  final PlayerMark currentTurn;
  final bool isAIThinking;
  final bool isXAI;
  final bool isOAI;
  final PlayerMark? winnerMark;
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final bool isSingleGame;
  final int currentRound;
  final int maxRounds;
  final AppLocalizations l10n;

  const _HorizontalGameView({
    required this.board,
    required this.horizontalPadding,
    required this.currentPlayer,
    required this.displayPlayerX,
    required this.displayPlayerO,
    required this.isGameOver,
    required this.currentTurn,
    required this.isAIThinking,
    required this.isXAI,
    required this.isOAI,
    required this.winnerMark,
    required this.onBack,
    required this.onSettings,
    required this.isSingleGame,
    required this.currentRound,
    required this.maxRounds,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GamingHeaderRow(
          onBack: onBack,
          onSettings: onSettings,
          center:
              isSingleGame
                  ? SuddenDeathLabel(label: l10n.suddenDeath)
                  : RoundIndicator(
                    currentRound: currentRound,
                    maxRounds: maxRounds,
                  ),
        ),
        const SizedBox(height: 16),
        _FadeInOnce(
          delay: 100.ms,
          duration: 400.ms,
          child: TurnIndicator(
            currentPlayer: currentPlayer,
            isAIThinking: isAIThinking,
            isGameOver: isGameOver,
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FadeScaleInOnce(
                delay: 200.ms,
                duration: 500.ms,
                beginScale: 0.9,
                endScale: 1.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: PlayerCard(
                            player: displayPlayerX,
                            isActive:
                                !isGameOver && currentTurn == PlayerMark.x,
                            isThinking:
                                isAIThinking &&
                                currentTurn == PlayerMark.x &&
                                isXAI,
                            isWinner: winnerMark == PlayerMark.x,
                            isAI: isXAI,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: board,
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: PlayerCard(
                            player: displayPlayerO,
                            isActive:
                                !isGameOver && currentTurn == PlayerMark.o,
                            isThinking:
                                isAIThinking &&
                                currentTurn == PlayerMark.o &&
                                isOAI,
                            isWinner: winnerMark == PlayerMark.o,
                            isAI: isOAI,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GameOverlay extends StatelessWidget {
  final GameState gameState;
  final bool isSingleGame;
  final bool awaitingNextRound;
  final MatchResult matchResult;
  final int playerXScore;
  final int playerOScore;
  final int currentRound;
  final int maxRounds;
  final VoidCallback? onRestart;
  final VoidCallback? onHome;
  final VoidCallback? onContinue;

  const _GameOverlay({
    required this.gameState,
    required this.isSingleGame,
    required this.awaitingNextRound,
    required this.matchResult,
    required this.playerXScore,
    required this.playerOScore,
    required this.currentRound,
    required this.maxRounds,
    required this.onRestart,
    required this.onHome,
    required this.onContinue,
  });

  bool get _isMatchOver => matchResult is! MatchResultOngoing;

  @override
  Widget build(BuildContext context) {
    // Match over - show match result overlay (for multi-round matches)
    if (_isMatchOver && !isSingleGame) {
      return MatchResultOverlay(
        matchResult: matchResult,
        playerX: gameState.config.playerX,
        playerO: gameState.config.playerO,
        playerXScore: playerXScore,
        playerOScore: playerOScore,
        onRematch: onRestart,
        onHome: onHome,
      );
    }

    // Round over but match continues - show round recap
    if (awaitingNextRound && onContinue != null) {
      return RoundRecapOverlay(
        roundResult: gameState.result,
        playerX: gameState.config.playerX,
        playerO: gameState.config.playerO,
        playerXScore: playerXScore,
        playerOScore: playerOScore,
        currentRound: currentRound,
        maxRounds: maxRounds,
        onContinue: onContinue!,
      );
    }

    // Single game (BO1) or match over - show regular overlays
    if (gameState.isGameOver && isSingleGame) {
      return _SingleGameOverlay(
        gameState: gameState,
        onRestart: onRestart,
        onHome: onHome,
      );
    }

    return const SizedBox.shrink();
  }
}

class _SingleGameOverlay extends StatelessWidget {
  final GameState gameState;
  final VoidCallback? onRestart;
  final VoidCallback? onHome;

  const _SingleGameOverlay({
    required this.gameState,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final result = gameState.result;

    if (result case GameResultWin(:final winner)) {
      final winnerPlayer =
          winner == PlayerMark.x
              ? gameState.config.playerX
              : gameState.config.playerO;

      return VictoryOverlay(
        winner: winnerPlayer,
        moveCount: gameState.moveCount,
        onRematch: onRestart,
        onHome: onHome,
      );
    }

    if (result is GameResultDraw) {
      return DrawOverlay(
        moveCount: gameState.moveCount,
        onRematch: onRestart,
        onHome: onHome,
      );
    }

    return const SizedBox.shrink();
  }
}

/// Unified header with back button and centered content
/// Shows "Sudden Death" for BO1, RoundIndicator for BO3/BO5

class _FadeInOnce extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const _FadeInOnce({
    required this.child,
    required this.duration,
    this.delay = Duration.zero,
  });

  @override
  State<_FadeInOnce> createState() => _FadeInOnceState();
}

class _FadeInOnceState extends State<_FadeInOnce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    _playOnce();
  }

  Future<void> _playOnce() async {
    if (widget.delay != Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

class _FadeScaleInOnce extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double beginScale;
  final double endScale;

  const _FadeScaleInOnce({
    required this.child,
    required this.duration,
    this.delay = Duration.zero,
    this.beginScale = 0.95,
    this.endScale = 1.0,
  });

  @override
  State<_FadeScaleInOnce> createState() => _FadeScaleInOnceState();
}

class _FadeScaleInOnceState extends State<_FadeScaleInOnce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late final Animation<double> _scale = Tween<double>(
    begin: widget.beginScale,
    end: widget.endScale,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _playOnce();
  }

  Future<void> _playOnce() async {
    if (widget.delay != Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
