import 'package:result_dart/result_dart.dart';
import 'package:tictactoe/features/rules/rules.dart';

import '../../../../core/application/usecases/use_case.dart';
import '../../domain/failures/game_failures.dart';
import '../../domain/repositories/i_game_repository.dart';
import '../../domain/repositories/i_match_repository.dart';

/// Parameters for playing a move
class PlayMoveParams {
  final MatchState matchState;
  final Position position;

  const PlayMoveParams({required this.matchState, required this.position});
}

/// Result of playing a move
class PlayMoveResult {
  final MatchState matchState;

  const PlayMoveResult({required this.matchState});
}

/// Use case for playing a move
class PlayMoveUseCase
    implements UseCase<PlayMoveResult, PlayMoveFailure, PlayMoveParams> {
  final IGameRepository _gameRepository;
  final IMatchRepository _matchRepository;

  PlayMoveUseCase(this._gameRepository, this._matchRepository);

  @override
  AsyncResultDart<PlayMoveResult, PlayMoveFailure> call(
    PlayMoveParams params,
  ) async {
    final currentRound = params.matchState.currentRound;
    if (currentRound == null) {
      return Failure(const PlayMoveFailure.noActiveRound());
    }

    if (currentRound.isGameOver) {
      return Failure(const PlayMoveFailure.gameOver());
    }

    final result = _gameRepository.playMove(currentRound, params.position);

    return result.when(
      success: (newGameState) {
        var newMatchState = params.matchState.copyWith(
          currentRound: newGameState,
        );

        // If round just ended, complete it in the match
        if (newGameState.isGameOver) {
          newMatchState = _matchRepository.completeRound(
            newMatchState,
            newGameState,
          );
        }

        return Success(PlayMoveResult(matchState: newMatchState));
      },
      failure: (_) {
        return Failure(const PlayMoveFailure.invalidMove());
      },
    );
  }
}
