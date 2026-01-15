import 'dart:math';

import '../../domain/entities/board.dart';
import '../../domain/entities/player.dart';
import '../../domain/value_objects/game_result.dart';
import '../../domain/value_objects/position.dart';
import '../../domain/entities/game_state.dart';
import '../win_detector.dart';
import 'ai_player.dart';

/// Probabilistic AI - mixes smart (minimax) and random moves
///
/// Uses [smartMoveChance] to determine the probability of making
/// an optimal move vs a random move.
class ProbabilisticAIPlayer implements AIPlayer {
  final WinDetector _winDetector;
  final Random _random;
  final double _smartMoveChance;

  /// Creates a probabilistic AI player.
  ///
  /// [smartMoveChance] must be between 0.0 and 1.0:
  /// - 1.0 = always plays optimal moves (like hard difficulty)
  /// - 0.0 = always plays random moves
  /// - 0.5 = 50% chance of optimal move
  ProbabilisticAIPlayer({
    required double smartMoveChance,
    Random? random,
    WinDetector? winDetector,
  }) : assert(smartMoveChance >= 0.0 && smartMoveChance <= 1.0),
       _smartMoveChance = smartMoveChance,
       _random = random ?? Random(),
       _winDetector = winDetector ?? WinDetectorImpl();

  @override
  Future<Position> computeMove(GameState state) async {
    final emptyPositions = state.board.emptyPositions;
    if (emptyPositions.isEmpty) {
      throw StateError('No valid moves available');
    }

    // Always use smart move if chance is 1.0 (avoid unnecessary random call)
    if (_smartMoveChance >= 1.0) {
      return _computeMinimaxMove(state);
    }

    // Always use random move if chance is 0.0
    if (_smartMoveChance <= 0.0) {
      return _computeRandomMove(emptyPositions);
    }

    // Probabilistic choice
    if (_random.nextDouble() < _smartMoveChance) {
      return _computeMinimaxMove(state);
    }
    return _computeRandomMove(emptyPositions);
  }

  // ============================================================
  // Random Algorithm
  // ============================================================

  Position _computeRandomMove(List<Position> emptyPositions) {
    return emptyPositions[_random.nextInt(emptyPositions.length)];
  }

  // ============================================================
  // Minimax Algorithm
  // ============================================================

  Position _computeMinimaxMove(GameState state) {
    final aiMark = state.currentTurn;
    final opponentMark = aiMark == PlayerMark.x ? PlayerMark.o : PlayerMark.x;

    int bestScore = -1000;
    Position? bestMove;

    for (final position in state.board.emptyPositions) {
      final newBoard = state.board.withMove(position, aiMark);
      final score = _minimax(newBoard, 0, false, aiMark, opponentMark);

      if (score > bestScore) {
        bestScore = score;
        bestMove = position;
      }
    }

    // Should never happen if emptyPositions was checked before
    return bestMove!;
  }

  int _minimax(
    Board board,
    int depth,
    bool isMaximizing,
    PlayerMark aiMark,
    PlayerMark opponentMark,
  ) {
    final result = _winDetector.checkResult(board);

    // Terminal states
    if (result is GameResultWin) {
      return result.winner == aiMark ? (10 - depth) : (depth - 10);
    }
    if (result is GameResultDraw) {
      return 0;
    }

    if (isMaximizing) {
      int bestScore = -1000;
      for (final pos in board.emptyPositions) {
        final newBoard = board.withMove(pos, aiMark);
        final score = _minimax(
          newBoard,
          depth + 1,
          false,
          aiMark,
          opponentMark,
        );
        bestScore = max(bestScore, score);
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (final pos in board.emptyPositions) {
        final newBoard = board.withMove(pos, opponentMark);
        final score = _minimax(newBoard, depth + 1, true, aiMark, opponentMark);
        bestScore = min(bestScore, score);
      }
      return bestScore;
    }
  }
}
