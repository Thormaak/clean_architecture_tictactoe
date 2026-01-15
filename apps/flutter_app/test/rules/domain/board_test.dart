import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/rules/rules.dart';

void main() {
  group('Board - UNIT-BD', () {
    group('empty', () {
      test('[P1] UNIT-BD-001: should create board with 9 empty cells', () {
        // Arrange & Act
        final board = Board.empty();

        // Assert
        expect(board.cells.length, 9);
        expect(board.cells.every((c) => c.isEmpty), true);
      });

      test('[P2] UNIT-BD-002: should have cells with correct positions', () {
        // Arrange & Act
        final board = Board.empty();

        // Assert
        for (int i = 0; i < 9; i++) {
          expect(board.cells[i].position.index, i);
        }
      });
    });

    group('getCell', () {
      test('[P1] UNIT-BD-003: should return correct cell by position', () {
        // Arrange
        final board = Board.empty();
        final pos = const Position(row: 1, col: 1);

        // Act
        final cell = board.getCell(pos);

        // Assert
        expect(cell.position, pos);
      });

      test('[P2] UNIT-BD-004: should return correct cell by coordinates', () {
        // Arrange
        final board = Board.empty();

        // Act
        final cell = board.getCellAt(2, 1);

        // Assert
        expect(cell.position, const Position(row: 2, col: 1));
      });
    });

    group('withMove', () {
      test('[P1] UNIT-BD-005: should create new board with move', () {
        // Arrange
        final board = Board.empty();
        final pos = const Position(row: 1, col: 1);

        // Act
        final newBoard = board.withMove(pos, PlayerMark.x);

        // Assert
        expect(newBoard.getCell(pos).mark, PlayerMark.x);
      });

      test(
        '[P0] UNIT-BD-006: should not modify original board (immutability)',
        () {
          // Arrange
          final board = Board.empty();
          final pos = const Position(row: 1, col: 1);

          // Act
          board.withMove(pos, PlayerMark.x);

          // Assert
          expect(board.getCell(pos).isEmpty, true);
        },
      );

      test('[P1] UNIT-BD-007: should preserve other cells', () {
        // Arrange
        var board = Board.empty();
        final pos1 = const Position(row: 0, col: 0);
        final pos2 = const Position(row: 1, col: 1);

        // Act
        board = board.withMove(pos1, PlayerMark.x);
        board = board.withMove(pos2, PlayerMark.o);

        // Assert
        expect(board.getCell(pos1).mark, PlayerMark.x);
        expect(board.getCell(pos2).mark, PlayerMark.o);
      });
    });

    group('isPositionEmpty', () {
      test('[P1] UNIT-BD-008: should return true for empty position', () {
        // Arrange
        final board = Board.empty();

        // Act
        final isEmpty = board.isPositionEmpty(const Position(row: 0, col: 0));

        // Assert
        expect(isEmpty, true);
      });

      test('[P1] UNIT-BD-009: should return false for occupied position', () {
        // Arrange
        final board = Board.empty().withMove(
          const Position(row: 0, col: 0),
          PlayerMark.x,
        );

        // Act
        final isEmpty = board.isPositionEmpty(const Position(row: 0, col: 0));

        // Assert
        expect(isEmpty, false);
      });
    });

    group('emptyPositions', () {
      test('[P1] UNIT-BD-010: should return all positions for empty board', () {
        // Arrange
        final board = Board.empty();

        // Act
        final emptyPos = board.emptyPositions;

        // Assert
        expect(emptyPos.length, 9);
      });

      test(
        '[P1] UNIT-BD-011: should return remaining positions after moves',
        () {
          // Arrange
          var board = Board.empty();
          board = board.withMove(const Position(row: 0, col: 0), PlayerMark.x);
          board = board.withMove(const Position(row: 1, col: 1), PlayerMark.o);

          // Act
          final emptyPos = board.emptyPositions;

          // Assert
          expect(emptyPos.length, 7);
          expect(emptyPos.contains(const Position(row: 0, col: 0)), false);
          expect(emptyPos.contains(const Position(row: 1, col: 1)), false);
        },
      );
    });

    group('isFull', () {
      test('[P1] UNIT-BD-012: should return false for empty board', () {
        // Arrange & Act
        final isFull = Board.empty().isFull;

        // Assert
        expect(isFull, false);
      });

      test(
        '[P1] UNIT-BD-013: should return false for partially filled board',
        () {
          // Arrange
          final board = Board.empty().withMove(
            const Position(row: 0, col: 0),
            PlayerMark.x,
          );

          // Act
          final isFull = board.isFull;

          // Assert
          expect(isFull, false);
        },
      );

      test('[P1] UNIT-BD-014: should return true for full board', () {
        // Arrange
        var board = Board.empty();
        final marks = [
          PlayerMark.x,
          PlayerMark.o,
          PlayerMark.x,
          PlayerMark.o,
          PlayerMark.x,
          PlayerMark.o,
          PlayerMark.o,
          PlayerMark.x,
          PlayerMark.o,
        ];

        for (int i = 0; i < 9; i++) {
          board = board.withMove(Position.fromIndex(i), marks[i]);
        }

        // Act
        final isFull = board.isFull;

        // Assert
        expect(isFull, true);
      });
    });
  });

  group('Cell - UNIT-CL', () {
    test('[P2] UNIT-CL-001: isEmpty should return true when mark is null', () {
      // Arrange
      final cell = Cell(position: const Position(row: 0, col: 0));

      // Act & Assert
      expect(cell.isEmpty, true);
      expect(cell.isOccupied, false);
    });

    test(
      '[P2] UNIT-CL-002: isOccupied should return true when mark is set',
      () {
        // Arrange
        final cell = Cell(
          position: const Position(row: 0, col: 0),
          mark: PlayerMark.x,
        );

        // Act & Assert
        expect(cell.isEmpty, false);
        expect(cell.isOccupied, true);
      },
    );
  });
}
