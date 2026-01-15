import 'package:tictactoe/features/game/domain/repositories/i_match_repository.dart';
import 'package:tictactoe/features/rules/rules.dart';

/// Implementation of MatchRepository that wraps the rules module's MatchEngine
class MatchRepositoryImpl implements IMatchRepository {
  final MatchEngine _matchEngine;

  MatchRepositoryImpl(this._matchEngine);

  @override
  MatchState createMatch(GameConfig config) {
    return _matchEngine.createMatch(config);
  }

  @override
  MatchEngineResult startNextRound(MatchState match) {
    return _matchEngine.startNextRound(match);
  }

  @override
  MatchState completeRound(MatchState match, GameState completedRound) {
    return _matchEngine.completeRound(match, completedRound);
  }
}
