import '../domain/entities/game_state.dart';
import '../domain/value_objects/position.dart';

/// Strategy interface for player move decision.
///
/// This pattern allows the domain to remain pure while the application
/// layer orchestrates different types of players (human, AI, remote).
abstract class PlayerStrategy {
  /// Returns the next move for the player.
  ///
  /// - For AI: computes the best move
  /// - For Human: returns null (handled by UI events)
  /// - For Remote: returns null (handled by network events)
  Future<Position?> getNextMove(GameState state);

  /// Whether this strategy requires external input (human tap, network event).
  ///
  /// If true, the orchestrator should wait for external input.
  /// If false, the orchestrator should call [getNextMove] to get the move.
  bool get requiresExternalInput;
}
