import '../domain/entities/player.dart';
import '../domain/value_objects/game_mode.dart';
import 'ai_player_strategy.dart';
import 'human_player_strategy.dart';
import 'player_strategy.dart';

/// Record type for strategy pair
typedef StrategyPair = ({PlayerStrategy strategyX, PlayerStrategy strategyO});

/// Factory for creating player strategies based on game mode.
class StrategyFactory {
  /// Creates strategies for both players based on game mode.
  ///
  /// - [mode]: The game mode determining strategy types
  /// - [humanMark]: In vsAI mode, which mark the human plays (default: X)
  static StrategyPair createStrategies(
    GameMode mode, {
    PlayerMark humanMark = PlayerMark.x,
  }) {
    return mode.when(
      local:
          () => (
            strategyX: const HumanPlayerStrategy(),
            strategyO: const HumanPlayerStrategy(),
          ),
      vsAI: (difficulty) {
        final aiStrategy = AIPlayerStrategy.fromDifficulty(difficulty);
        if (humanMark == PlayerMark.x) {
          return (
            strategyX: const HumanPlayerStrategy(),
            strategyO: aiStrategy,
          );
        } else {
          return (
            strategyX: aiStrategy,
            strategyO: const HumanPlayerStrategy(),
          );
        }
      },
    );
  }
}
