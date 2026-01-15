import 'package:freezed_annotation/freezed_annotation.dart';

import '../value_objects/game_config.dart';
import '../value_objects/game_result.dart';
import '../value_objects/move.dart';
import 'board.dart';
import 'player.dart';

part 'game_state.freezed.dart';

/// Complete state of a game
@freezed
abstract class GameState with _$GameState {
  const factory GameState({
    required String gameId,
    required GameConfig config,
    required Board board,
    required PlayerMark currentTurn,
    required List<Move> moveHistory,
    required GameResult result,
    required DateTime startedAt,
    DateTime? endedAt,
  }) = _GameState;

  const GameState._();

  /// Is the game over?
  bool get isGameOver => result is! GameResultOngoing;

  /// Current player
  Player get currentPlayer =>
      currentTurn == PlayerMark.x ? config.playerX : config.playerO;

  /// Number of moves played
  int get moveCount => moveHistory.length;
}
