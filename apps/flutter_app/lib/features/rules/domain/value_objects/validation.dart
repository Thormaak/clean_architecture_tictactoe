import 'package:freezed_annotation/freezed_annotation.dart';

part 'validation.freezed.dart';

/// Reasons why a move can be invalid
enum MoveError {
  gameOver,
  positionOccupied,
  notYourTurn,
  invalidPosition,
  timeoutExceeded,
}

/// Result of move validation
@freezed
sealed class MoveValidationResult with _$MoveValidationResult {
  const factory MoveValidationResult.valid() = MoveValidationValid;
  const factory MoveValidationResult.invalid(MoveError error) =
      MoveValidationInvalid;
}
