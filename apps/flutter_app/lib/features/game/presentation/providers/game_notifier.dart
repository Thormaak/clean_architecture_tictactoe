import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tictactoe/features/rules/rules.dart';

import '../../application/use_cases/check_ai_move_use_case.dart';
import '../../application/use_cases/continue_next_round_use_case.dart';
import '../../application/use_cases/play_move_use_case.dart';
import '../../application/use_cases/restart_game_use_case.dart';
import '../../application/use_cases/start_game_use_case.dart';
import '../../domain/failures/game_failures.dart';
import 'game_providers.dart';

part 'game_notifier.freezed.dart';

/// State for the game UI
@freezed
abstract class GameUIState with _$GameUIState {
  const factory GameUIState({
    MatchState? matchState,
    @Default({}) Set<int> animatedCells,
    @Default(false) bool isAIThinking,
  }) = _GameUIState;

  const GameUIState._();

  /// Current round's game state (for backward compatibility)
  GameState? get gameState => matchState?.currentRound;

  /// Current scores
  int get playerXScore => matchState?.playerXScore ?? 0;
  int get playerOScore => matchState?.playerOScore ?? 0;

  /// Match status helpers
  bool get isMatchOver => matchState?.isMatchOver ?? false;
  bool get isRoundOver => matchState?.isRoundOver ?? false;
  bool get awaitingNextRound => matchState?.awaitingNextRound ?? false;
  bool get isSingleGame => matchState?.isSingleGame ?? true;
}

/// Notifier for managing game state and orchestrating player strategies
class GameNotifier extends Notifier<GameUIState> {
  late final StartGameUseCase _startGameUseCase;
  late final PlayMoveUseCase _playMoveUseCase;
  late final ContinueNextRoundUseCase _continueNextRoundUseCase;
  late final RestartGameUseCase _restartGameUseCase;
  late final CheckAIMoveUseCase _checkAIMoveUseCase;

  PlayerStrategy? _strategyX;
  PlayerStrategy? _strategyO;

  @override
  GameUIState build() {
    _startGameUseCase = ref.read(startGameUseCaseProvider);
    _playMoveUseCase = ref.read(playMoveUseCaseProvider);
    _continueNextRoundUseCase = ref.read(continueNextRoundUseCaseProvider);
    _restartGameUseCase = ref.read(restartGameUseCaseProvider);
    _checkAIMoveUseCase = ref.read(checkAIMoveUseCaseProvider);
    return const GameUIState();
  }

  void _emitFailure(GameFailure failure) {
    ref.read(gameUiEventControllerProvider).add(GameUiFailureEvent(failure));
  }

  void _emitInvalidMove(PlayMoveFailure failure) {
    ref
        .read(gameUiEventControllerProvider)
        .add(GameUiInvalidMoveEvent(failure));
  }

  /// Starts a new game based on the game mode
  Future<void> startGame(GameMode mode, {BestOf bestOf = BestOf.bo1}) async {
    final result = await _startGameUseCase.call(
      StartGameParams(mode: mode, bestOf: bestOf),
    );

    result.fold(
      (startGameResult) {
        _strategyX = startGameResult.strategyX;
        _strategyO = startGameResult.strategyO;
        state = GameUIState(
          matchState: startGameResult.matchState,
          animatedCells: {},
        );
        _checkAndPlayStrategy();
      },
      (failure) {
        _emitFailure(GameFailure.startGame(failure));
      },
    );
  }

  /// Plays a move at the given position
  Future<void> playMove(Position position) async {
    final currentState = state.gameState;
    if (currentState == null) return;
    if (currentState.isGameOver) {
      _emitInvalidMove(const PlayMoveFailure.gameOver());
      return;
    }
    if (state.isAIThinking) {
      _emitInvalidMove(const PlayMoveFailure.invalidMove());
      return;
    }

    final matchState = state.matchState;
    if (matchState == null) return;

    final result = await _playMoveUseCase.call(
      PlayMoveParams(matchState: matchState, position: position),
    );

    result.fold(
      (playMoveResult) {
        state = state.copyWith(
          matchState: playMoveResult.matchState,
          animatedCells: {...state.animatedCells, position.index},
        );
        _checkAndPlayStrategy();
      },
      (failure) {
        if (failure is PlayMoveInvalidMove || failure is PlayMoveGameOver) {
          _emitInvalidMove(failure);
          return;
        }
        _emitFailure(GameFailure.playMove(failure));
      },
    );
  }

  /// Continues to the next round after a round ends
  Future<void> continueToNextRound() async {
    final matchState = state.matchState;
    if (matchState == null) return;
    if (!matchState.awaitingNextRound) return;

    final result = await _continueNextRoundUseCase.call(
      ContinueNextRoundParams(matchState: matchState),
    );

    result.fold(
      (continueNextRoundResult) {
        state = state.copyWith(
          matchState: continueNextRoundResult.matchState,
          animatedCells: {},
        );
        _checkAndPlayStrategy();
      },
      (failure) {
        _emitFailure(GameFailure.continueNextRound(failure));
      },
    );
  }

  /// Checks if the current player's strategy should auto-play
  Future<void> _checkAndPlayStrategy() async {
    final currentState = state.gameState;
    if (currentState == null) return;
    if (currentState.isGameOver) return;
    if (state.isAIThinking) return;

    final result = await _checkAIMoveUseCase.call(
      CheckAIMoveParams(
        gameState: currentState,
        strategyX: _strategyX,
        strategyO: _strategyO,
        isAIThinking: state.isAIThinking,
      ),
    );

    result.fold(
      (checkAIMoveResult) {
        if (!checkAIMoveResult.shouldPlay || checkAIMoveResult.move == null) {
          return;
        }

        // Start thinking and play move asynchronously
        _playAIMove(checkAIMoveResult.move!);
      },
      (_) {
        // Error checking AI move - ignore
      },
    );
  }

  Future<void> _playAIMove(Position move) async {
    // Start thinking
    state = state.copyWith(isAIThinking: true);

    // Visual delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    // Verify game state is still valid before playing
    if (state.gameState == null || state.gameState!.isGameOver) {
      state = state.copyWith(isAIThinking: false);
      return;
    }

    final matchState = state.matchState;
    if (matchState == null) {
      state = state.copyWith(isAIThinking: false);
      return;
    }

    final playResult = await _playMoveUseCase.call(
      PlayMoveParams(matchState: matchState, position: move),
    );

    playResult.fold(
      (playMoveResult) {
        state = state.copyWith(
          matchState: playMoveResult.matchState,
          animatedCells: {...state.animatedCells, move.index},
          isAIThinking: false,
        );
        _checkAndPlayStrategy();
      },
      (_) {
        state = state.copyWith(isAIThinking: false);
      },
    );
  }

  /// Restarts the entire match
  Future<void> restartGame() async {
    final matchState = state.matchState;
    if (matchState == null) return;

    final result = await _restartGameUseCase.call(
      RestartGameParams(
        mode: matchState.config.mode,
        bestOf: matchState.config.bestOf,
      ),
    );

    result.fold(
      (startGameResult) {
        _strategyX = startGameResult.strategyX;
        _strategyO = startGameResult.strategyO;
        state = GameUIState(
          matchState: startGameResult.matchState,
          animatedCells: {},
        );
        _checkAndPlayStrategy();
      },
      (failure) {
        _emitFailure(GameFailure.restartGame(failure));
      },
    );
  }
}

/// Provider for the game notifier
final gameNotifierProvider = NotifierProvider<GameNotifier, GameUIState>(
  GameNotifier.new,
);

/// One-shot UI events for the game
abstract class GameUiEvent {
  const GameUiEvent();
}

class GameUiFailureEvent extends GameUiEvent {
  const GameUiFailureEvent(this.failure);

  final GameFailure failure;
}

class GameUiInvalidMoveEvent extends GameUiEvent {
  const GameUiInvalidMoveEvent(this.failure);

  final PlayMoveFailure failure;
}

final gameUiEventControllerProvider = Provider<StreamController<GameUiEvent>>((
  ref,
) {
  final controller = StreamController<GameUiEvent>.broadcast();
  ref.onDispose(controller.close);
  return controller;
});

final gameUiEventProvider = StreamProvider<GameUiEvent>((ref) {
  return ref.watch(gameUiEventControllerProvider).stream;
});
