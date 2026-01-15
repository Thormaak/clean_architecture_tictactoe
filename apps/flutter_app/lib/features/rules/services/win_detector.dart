import '../domain/entities/board.dart';
import '../domain/entities/player.dart';
import '../domain/value_objects/game_result.dart';
import '../domain/value_objects/position.dart';

/// Detects wins and draws
abstract class WinDetector {
  /// Checks the game result after a move
  GameResult checkResult(Board board);

  /// Finds the winning line if one exists
  WinningLine? findWinningLine(Board board, PlayerMark mark);
}

/// Default implementation of WinDetector
class WinDetectorImpl implements WinDetector {
  /// All possible winning patterns (indices 0-8)
  static const List<List<int>> _winPatterns = [
    [0, 1, 2], // Row 0
    [3, 4, 5], // Row 1
    [6, 7, 8], // Row 2
    [0, 3, 6], // Column 0
    [1, 4, 7], // Column 1
    [2, 5, 8], // Column 2
    [0, 4, 8], // Diagonal
    [2, 4, 6], // Anti-diagonal
  ];

  @override
  GameResult checkResult(Board board) {
    // Check X win
    final xWin = findWinningLine(board, PlayerMark.x);
    if (xWin != null) {
      return GameResult.win(winner: PlayerMark.x, winningLine: xWin);
    }

    // Check O win
    final oWin = findWinningLine(board, PlayerMark.o);
    if (oWin != null) {
      return GameResult.win(winner: PlayerMark.o, winningLine: oWin);
    }

    // Check draw
    if (board.isFull) {
      return const GameResult.draw();
    }

    return const GameResult.ongoing();
  }

  @override
  WinningLine? findWinningLine(Board board, PlayerMark mark) {
    for (int i = 0; i < _winPatterns.length; i++) {
      final pattern = _winPatterns[i];
      if (_checkPattern(board, pattern, mark)) {
        return WinningLine(
          positions: pattern.map(Position.fromIndex).toList(),
          type: _getLineType(i),
        );
      }
    }
    return null;
  }

  bool _checkPattern(Board board, List<int> pattern, PlayerMark mark) {
    return pattern.every((i) => board.cells[i].mark == mark);
  }

  WinningLineType _getLineType(int patternIndex) {
    if (patternIndex < 3) return WinningLineType.horizontal;
    if (patternIndex < 6) return WinningLineType.vertical;
    if (patternIndex == 6) return WinningLineType.diagonal;
    return WinningLineType.antiDiagonal;
  }
}
