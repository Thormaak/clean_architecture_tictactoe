import '../../domain/repositories/i_game_repository.dart';
import 'package:tictactoe/features/rules/rules.dart';

/// Implementation of GameRepository that wraps the rules module's GameEngine
class GameRepositoryImpl implements IGameRepository {
  final GameEngine _gameEngine;

  GameRepositoryImpl(this._gameEngine);

  @override
  GameState createGame(GameConfig config) {
    return _gameEngine.createGame(config);
  }

  @override
  GameEngineResult playMove(GameState state, Position position) {
    return _gameEngine.playMove(state, position);
  }
}
