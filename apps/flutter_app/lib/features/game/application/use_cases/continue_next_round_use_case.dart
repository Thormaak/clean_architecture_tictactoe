import 'package:result_dart/result_dart.dart';
import 'package:tictactoe/features/game/domain/repositories/i_match_repository.dart';
import 'package:tictactoe/features/rules/rules.dart';

import '../../../../core/application/usecases/use_case.dart';
import '../../domain/failures/game_failures.dart';

/// Parameters for continuing to next round
class ContinueNextRoundParams {
  final MatchState matchState;

  const ContinueNextRoundParams({required this.matchState});
}

/// Result of continuing to next round
class ContinueNextRoundResult {
  final MatchState matchState;

  const ContinueNextRoundResult({required this.matchState});
}

/// Use case for continuing to the next round
class ContinueNextRoundUseCase
    implements
        UseCase<
          ContinueNextRoundResult,
          ContinueNextRoundFailure,
          ContinueNextRoundParams
        > {
  final IMatchRepository _matchRepository;

  ContinueNextRoundUseCase(this._matchRepository);

  @override
  AsyncResultDart<ContinueNextRoundResult, ContinueNextRoundFailure> call(
    ContinueNextRoundParams params,
  ) async {
    if (!params.matchState.awaitingNextRound) {
      return Failure(const ContinueNextRoundFailure.roundInProgress());
    }

    final result = _matchRepository.startNextRound(params.matchState);

    return result.when(
      success: (newMatchState) {
        return Success(ContinueNextRoundResult(matchState: newMatchState));
      },
      failure: (error) {
        return error.when(
          matchAlreadyOver:
              () => Failure(const ContinueNextRoundFailure.matchAlreadyOver()),
          roundInProgress:
              () => Failure(const ContinueNextRoundFailure.roundInProgress()),
          noRoundToComplete:
              () => Failure(const ContinueNextRoundFailure.startRoundFailed()),
        );
      },
    );
  }
}
