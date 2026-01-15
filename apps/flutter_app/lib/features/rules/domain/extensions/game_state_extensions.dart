import '../entities/game_state.dart';
import '../entities/player.dart';
import '../value_objects/game_mode.dart';

/// UI-related extensions for [GameState].
///
/// These extensions help the presentation layer determine
/// player characteristics based on the current game state.
extension GameStateUIExtensions on GameState {
  /// Returns true if the current player is an AI.
  ///
  /// Only returns true in vsAI mode when it's O's turn.
  bool get isCurrentPlayerAI {
    return config.mode.maybeWhen(
      vsAI: (_) => currentTurn == PlayerMark.o,
      orElse: () => false,
    );
  }

  /// Returns true if the given player mark represents an AI.
  bool isPlayerAI(PlayerMark mark) {
    return config.mode.maybeWhen(
      vsAI: (_) => mark == PlayerMark.o,
      orElse: () => false,
    );
  }
}
