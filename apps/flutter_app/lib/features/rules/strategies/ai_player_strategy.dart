import '../domain/entities/game_state.dart';
import '../domain/value_objects/game_mode.dart';
import '../domain/value_objects/position.dart';
import '../services/ai/ai_factory.dart';
import '../services/ai/ai_player.dart';
import 'player_strategy.dart';

/// Strategy for AI players.
///
/// Wraps an [AIPlayer] to compute moves automatically.
class AIPlayerStrategy implements PlayerStrategy {
  final AIPlayer _aiPlayer;

  AIPlayerStrategy(this._aiPlayer);

  /// Creates an AI strategy from a difficulty level.
  factory AIPlayerStrategy.fromDifficulty(AIDifficulty difficulty) {
    return AIPlayerStrategy(AIPlayerFactory.create(difficulty));
  }

  @override
  Future<Position?> getNextMove(GameState state) async {
    return _aiPlayer.computeMove(state);
  }

  @override
  bool get requiresExternalInput => false;
}
