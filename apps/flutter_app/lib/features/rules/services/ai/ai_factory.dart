import '../../domain/value_objects/game_mode.dart';
import 'ai_player.dart';
import 'probabilistic_ai.dart';

/// Factory for creating AI players based on difficulty
class AIPlayerFactory {
  /// Smart move chance percentages for each difficulty
  static const _smartMoveChance = {
    AIDifficulty.easy: 0.5,
    AIDifficulty.medium: 0.8,
    AIDifficulty.hard: 1.0,
  };

  /// Creates an AI player for the given difficulty
  ///
  /// - Easy: 50% smart moves, 50% random moves
  /// - Medium: 80% smart moves, 20% random moves
  /// - Hard: 100% smart moves (unbeatable)
  static AIPlayer create(AIDifficulty difficulty) {
    return ProbabilisticAIPlayer(
      smartMoveChance: _smartMoveChance[difficulty]!,
    );
  }
}
