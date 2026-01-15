import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_result.freezed.dart';

/// Result of a match (multiple rounds)
@freezed
sealed class MatchResult with _$MatchResult {
  /// Match is still ongoing
  const factory MatchResult.ongoing() = MatchResultOngoing;

  /// Player X has won the match
  const factory MatchResult.playerXWins() = MatchResultPlayerXWins;

  /// Player O has won the match
  const factory MatchResult.playerOWins() = MatchResultPlayerOWins;

  /// Match ended in a draw (equal scores after max rounds)
  const factory MatchResult.draw() = MatchResultDraw;
}
