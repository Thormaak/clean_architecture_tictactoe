import 'package:freezed_annotation/freezed_annotation.dart';

import '../value_objects/position.dart';
import 'player.dart';

part 'board.freezed.dart';

/// A cell on the board
@freezed
abstract class Cell with _$Cell {
  const factory Cell({required Position position, PlayerMark? mark}) = _Cell;

  const Cell._();

  bool get isEmpty => mark == null;
  bool get isOccupied => mark != null;
}

/// The 3x3 game board
@freezed
abstract class Board with _$Board {
  const factory Board({required List<Cell> cells}) = _Board;

  const Board._();

  /// Creates an empty board
  factory Board.empty() => Board(
    cells: List.generate(9, (i) => Cell(position: Position.fromIndex(i))),
  );

  /// Gets a cell by position
  Cell getCell(Position position) => cells[position.index];

  /// Gets a cell by coordinates
  Cell getCellAt(int row, int col) => getCell(Position(row: row, col: col));

  /// Checks if a position is empty
  bool isPositionEmpty(Position position) => getCell(position).isEmpty;

  /// Returns all empty positions
  List<Position> get emptyPositions =>
      cells.where((c) => c.isEmpty).map((c) => c.position).toList();

  /// Checks if the board is full
  bool get isFull => cells.every((c) => c.isOccupied);

  /// Creates a new board with a move played
  Board withMove(Position position, PlayerMark mark) {
    final newCells = List<Cell>.from(cells);
    newCells[position.index] = Cell(position: position, mark: mark);
    return Board(cells: newCells);
  }
}
