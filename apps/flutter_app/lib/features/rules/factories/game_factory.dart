import '../domain/entities/player.dart';
import '../domain/entities/game_state.dart';
import '../domain/value_objects/game_config.dart';
import '../domain/value_objects/game_mode.dart';
import '../services/game_engine.dart';

/// Factory for creating game configurations quickly
class GameFactory {
  final GameEngine _engine;

  GameFactory([GameEngine? engine]) : _engine = engine ?? GameEngineImpl();

  /// Creates a local game (2 players)
  GameState createLocalGame({
    required String player1Name,
    required String player2Name,
    PlayerMark startingPlayer = PlayerMark.x,
  }) {
    final config = GameConfig(
      mode: const GameMode.local(),
      playerX: Player(id: 'player_x', name: player1Name, mark: PlayerMark.x),
      playerO: Player(id: 'player_o', name: player2Name, mark: PlayerMark.o),
      startingPlayer: startingPlayer,
    );

    return _engine.createGame(config);
  }

  /// Creates a game against AI
  GameState createAIGame({
    required String playerName,
    required String aiName,
    PlayerMark playerMark = PlayerMark.x,
    AIDifficulty difficulty = AIDifficulty.medium,
  }) {
    final humanPlayer = Player(id: 'human', name: playerName, mark: playerMark);

    final aiPlayer = Player(
      id: 'ai',
      name: aiName,
      mark: playerMark == PlayerMark.x ? PlayerMark.o : PlayerMark.x,
    );

    final config = GameConfig(
      mode: GameMode.vsAI(difficulty: difficulty),
      playerX: playerMark == PlayerMark.x ? humanPlayer : aiPlayer,
      playerO: playerMark == PlayerMark.o ? humanPlayer : aiPlayer,
      startingPlayer: PlayerMark.x,
    );

    return _engine.createGame(config);
  }
}
