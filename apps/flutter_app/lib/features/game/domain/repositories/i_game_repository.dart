import 'package:tictactoe/features/rules/rules.dart';

/// Repository interface for game engine operations
/// Abstracts the game engine implementation from the application layer
abstract class IGameRepository {
  /// Creates a new game with the given configuration
  GameState createGame(GameConfig config);

  /// Plays a move at the given position
  GameEngineResult playMove(GameState state, Position position);
}
