import '../entities/player.dart';
import '../value_objects/game_mode.dart';

/// UI-related extensions for [GameMode].
///
/// These extensions help the presentation layer determine
/// how to display players based on the game mode.
extension GameModeUIExtensions on GameMode {
  /// Returns true if the given mark represents an AI player in this mode.
  ///
  /// In vsAI mode, the AI always plays as O by default.
  bool isAIPlayer(PlayerMark mark) {
    return maybeWhen(vsAI: (_) => mark == PlayerMark.o, orElse: () => false);
  }
}
