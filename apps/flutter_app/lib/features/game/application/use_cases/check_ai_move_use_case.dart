import 'package:result_dart/result_dart.dart';
import 'package:tictactoe/features/rules/domain/entities/game_state.dart';
import 'package:tictactoe/features/rules/domain/entities/player.dart';
import 'package:tictactoe/features/rules/domain/value_objects/position.dart';
import 'package:tictactoe/features/rules/strategies/player_strategy.dart';

import '../../../../core/application/usecases/use_case.dart';
import '../../domain/failures/game_failures.dart';

/// Parameters for checking if AI should play
class CheckAIMoveParams {
  final GameState gameState;
  final PlayerStrategy? strategyX;
  final PlayerStrategy? strategyO;
  final bool isAIThinking;

  const CheckAIMoveParams({
    required this.gameState,
    this.strategyX,
    this.strategyO,
    this.isAIThinking = false,
  });
}

/// Result of checking AI move
class CheckAIMoveResult {
  final Position? move;
  final bool shouldPlay;

  const CheckAIMoveResult({this.move, this.shouldPlay = false});
}

/// Use case for checking if AI should play and getting the move
class CheckAIMoveUseCase
    implements
        UseCase<CheckAIMoveResult, CheckAIMoveFailure, CheckAIMoveParams> {
  @override
  AsyncResultDart<CheckAIMoveResult, CheckAIMoveFailure> call(
    CheckAIMoveParams params,
  ) async {
    try {
      if (params.gameState.isGameOver) {
        return Success(const CheckAIMoveResult());
      }

      if (params.isAIThinking) {
        return Success(const CheckAIMoveResult());
      }

      final currentStrategy =
          params.gameState.currentTurn == PlayerMark.x
              ? params.strategyX
              : params.strategyO;

      if (currentStrategy == null || currentStrategy.requiresExternalInput) {
        return Success(const CheckAIMoveResult());
      }

      // Get the move from the strategy
      final move = await currentStrategy.getNextMove(params.gameState);

      if (move != null) {
        return Success(CheckAIMoveResult(move: move, shouldPlay: true));
      }

      return Success(const CheckAIMoveResult());
    } catch (e) {
      return Failure(const CheckAIMoveFailure.checkFailed());
    }
  }
}
