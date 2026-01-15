import 'package:result_dart/result_dart.dart';
import 'package:tictactoe/features/game/domain/repositories/i_match_repository.dart';
import 'package:tictactoe/features/rules/rules.dart';
import '../../../../core/application/usecases/use_case.dart';
import '../../domain/failures/game_failures.dart';

/// Parameters for starting a game
class StartGameParams {
  final GameMode mode;
  final BestOf bestOf;

  const StartGameParams({required this.mode, this.bestOf = BestOf.bo1});
}

/// Result of starting a game
class StartGameResult {
  final MatchState matchState;
  final PlayerStrategy? strategyX;
  final PlayerStrategy? strategyO;

  const StartGameResult({
    required this.matchState,
    this.strategyX,
    this.strategyO,
  });
}

/// Use case for starting a new game
class StartGameUseCase
    implements UseCase<StartGameResult, StartGameFailure, StartGameParams> {
  final IMatchRepository _matchRepository;

  StartGameUseCase(this._matchRepository);

  @override
  AsyncResultDart<StartGameResult, StartGameFailure> call(
    StartGameParams params,
  ) async {
    try {
      final config = _buildConfig(params.mode, params.bestOf);
      final matchState = _matchRepository.createMatch(config);

      // Create strategies based on game mode
      final strategies = StrategyFactory.createStrategies(params.mode);

      return Success(
        StartGameResult(
          matchState: matchState,
          strategyX: strategies.strategyX,
          strategyO: strategies.strategyO,
        ),
      );
    } catch (e) {
      return Failure(const StartGameFailure.createMatchFailed());
    }
  }

  /// Builds a game config from mode and bestOf
  GameConfig _buildConfig(GameMode mode, BestOf bestOf) {
    return mode.when(
      local:
          () => GameConfig(
            mode: mode,
            playerX: const Player(
              id: 'player_x',
              name: 'Player 1',
              mark: PlayerMark.x,
            ),
            playerO: const Player(
              id: 'player_o',
              name: 'Player 2',
              mark: PlayerMark.o,
            ),
            bestOf: bestOf,
          ),
      vsAI:
          (difficulty) => GameConfig(
            mode: mode,
            playerX: const Player(id: 'human', name: 'You', mark: PlayerMark.x),
            playerO: const Player(id: 'ai', name: 'AI', mark: PlayerMark.o),
            bestOf: bestOf,
          ),
    );
  }
}
