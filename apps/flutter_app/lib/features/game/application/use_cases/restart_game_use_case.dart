import 'package:result_dart/result_dart.dart';
import 'package:tictactoe/features/rules/domain/value_objects/best_of.dart';
import 'package:tictactoe/features/rules/domain/value_objects/game_mode.dart';

import '../../../../core/application/usecases/use_case.dart';
import '../../domain/failures/game_failures.dart';
import 'start_game_use_case.dart';

/// Parameters for restarting a game
class RestartGameParams {
  final GameMode mode;
  final BestOf bestOf;

  const RestartGameParams({required this.mode, required this.bestOf});
}

/// Use case for restarting a game
class RestartGameUseCase
    implements UseCase<StartGameResult, RestartGameFailure, RestartGameParams> {
  final StartGameUseCase _startGameUseCase;

  RestartGameUseCase(this._startGameUseCase);

  @override
  AsyncResultDart<StartGameResult, RestartGameFailure> call(
    RestartGameParams params,
  ) async {
    final result = await _startGameUseCase.call(
      StartGameParams(mode: params.mode, bestOf: params.bestOf),
    );

    return result.fold(
      (success) => Success(success),
      (failure) => Failure(const RestartGameFailure.restartFailed()),
    );
  }
}
