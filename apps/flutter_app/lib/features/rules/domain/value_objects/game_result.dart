import 'package:freezed_annotation/freezed_annotation.dart';

import '../entities/player.dart';
import 'position.dart';

part 'game_result.freezed.dart';

/// Type of winning line
enum WinningLineType { horizontal, vertical, diagonal, antiDiagonal }

/// Represents a winning line on the board
@freezed
abstract class WinningLine with _$WinningLine {
  const factory WinningLine({
    required List<Position> positions,
    required WinningLineType type,
  }) = _WinningLine;
}

/// Result of a game
@freezed
sealed class GameResult with _$GameResult {
  /// Game is still ongoing
  const factory GameResult.ongoing() = GameResultOngoing;

  /// A player has won
  const factory GameResult.win({
    required PlayerMark winner,
    required WinningLine winningLine,
  }) = GameResultWin;

  /// Game ended in a draw
  const factory GameResult.draw() = GameResultDraw;
}
