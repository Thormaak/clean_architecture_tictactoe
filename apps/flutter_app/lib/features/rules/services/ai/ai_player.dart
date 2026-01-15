import '../../domain/entities/game_state.dart';
import '../../domain/value_objects/position.dart';

/// Interface for AI player strategies
abstract class AIPlayer {
  /// Computes the best move for the current game state
  Future<Position> computeMove(GameState state);
}
