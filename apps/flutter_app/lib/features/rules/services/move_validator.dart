import '../domain/entities/game_state.dart';
import '../domain/value_objects/position.dart';
import '../domain/value_objects/validation.dart';

/// Validates moves in the game
abstract class MoveValidator {
  /// Validates if a move is legal
  MoveValidationResult validate(GameState state, Position position);
}

/// Default implementation of MoveValidator
class MoveValidatorImpl implements MoveValidator {
  @override
  MoveValidationResult validate(GameState state, Position position) {
    if (state.isGameOver) {
      return const MoveValidationResult.invalid(MoveError.gameOver);
    }

    if (!position.isValid) {
      return const MoveValidationResult.invalid(MoveError.invalidPosition);
    }

    if (!state.board.isPositionEmpty(position)) {
      return const MoveValidationResult.invalid(MoveError.positionOccupied);
    }

    return const MoveValidationResult.valid();
  }
}
