import 'package:freezed_annotation/freezed_annotation.dart';

part 'position.freezed.dart';

/// Position on the board (immutable)
@freezed
abstract class Position with _$Position {
  const factory Position({required int row, required int col}) = _Position;

  const Position._();

  /// Converts to linear index (0-8)
  int get index => row * 3 + col;

  /// Creates from linear index
  factory Position.fromIndex(int index) =>
      Position(row: index ~/ 3, col: index % 3);

  /// Checks if position is valid (within 3x3 board)
  bool get isValid => row >= 0 && row < 3 && col >= 0 && col < 3;
}
