import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/entities/board.dart';
import '../domain/entities/game_state.dart';
import '../domain/entities/player.dart';
import '../domain/value_objects/game_config.dart';
import '../domain/value_objects/game_result.dart';
import '../domain/value_objects/move.dart';
import '../domain/value_objects/position.dart';
import '../domain/value_objects/validation.dart';
import 'move_validator.dart';
import 'win_detector.dart';

part 'game_engine.freezed.dart';

/// Result of a game engine operation
@freezed
sealed class GameEngineResult with _$GameEngineResult {
  const factory GameEngineResult.success(GameState newState) =
      GameEngineSuccess;
  const factory GameEngineResult.failure(GameEngineError error) =
      GameEngineFailure;
}

/// Errors that can occur in the game engine
@freezed
sealed class GameEngineError with _$GameEngineError {
  const factory GameEngineError.invalidMove(MoveError reason) =
      GameEngineErrorInvalidMove;
}

/// Main game engine - entry point for all game logic
abstract class GameEngine {
  /// Creates a new game
  GameState createGame(GameConfig config);

  /// Plays a move
  GameEngineResult playMove(GameState state, Position position);
}

/// Default implementation of GameEngine
class GameEngineImpl implements GameEngine {
  final MoveValidator _moveValidator;
  final WinDetector _winDetector;
  final String Function() _idGenerator;

  GameEngineImpl({
    MoveValidator? moveValidator,
    WinDetector? winDetector,
    String Function()? idGenerator,
  }) : _moveValidator = moveValidator ?? MoveValidatorImpl(),
       _winDetector = winDetector ?? WinDetectorImpl(),
       _idGenerator =
           idGenerator ??
           (() => DateTime.now().millisecondsSinceEpoch.toString());

  @override
  GameState createGame(GameConfig config) {
    return GameState(
      gameId: _idGenerator(),
      config: config,
      board: Board.empty(),
      currentTurn: config.startingPlayer,
      moveHistory: const [],
      result: const GameResult.ongoing(),
      startedAt: DateTime.now(),
    );
  }

  @override
  GameEngineResult playMove(GameState state, Position position) {
    // Validate the move
    final validation = _moveValidator.validate(state, position);

    if (validation is MoveValidationInvalid) {
      return GameEngineResult.failure(
        GameEngineError.invalidMove(validation.error),
      );
    }

    // Create the move
    final move = Move(
      position: position,
      mark: state.currentTurn,
      timestamp: DateTime.now(),
      moveNumber: state.moveCount + 1,
    );

    // Update the board
    final newBoard = state.board.withMove(position, state.currentTurn);

    // Check the result
    final result = _winDetector.checkResult(newBoard);

    // Determine next player
    final nextTurn =
        state.currentTurn == PlayerMark.x ? PlayerMark.o : PlayerMark.x;

    // Create new state
    final newState = state.copyWith(
      board: newBoard,
      currentTurn: nextTurn,
      moveHistory: [...state.moveHistory, move],
      result: result,
      endedAt: result is! GameResultOngoing ? DateTime.now() : null,
    );

    return GameEngineResult.success(newState);
  }
}
