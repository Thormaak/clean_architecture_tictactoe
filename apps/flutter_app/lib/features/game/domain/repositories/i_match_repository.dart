import 'package:tictactoe/features/rules/rules.dart';

/// Repository interface for match engine operations
/// Abstracts the match engine implementation from the application layer
abstract class IMatchRepository {
  /// Creates a new match with the given configuration
  MatchState createMatch(GameConfig config);

  /// Starts the next round in a match
  MatchEngineResult startNextRound(MatchState match);

  /// Records round completion and updates scores
  MatchState completeRound(MatchState match, GameState completedRound);
}
