import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/rules/rules.dart';
import '../../fixtures/game_fixtures.dart';

void main() {
  late WinDetector detector;

  setUp(() {
    detector = WinDetectorImpl();
  });

  /// Helper: Creates board from move indices
  /// This is kept as local helper for readability in win detection tests
  Board createBoardWithMoves(List<int> xMoves, List<int> oMoves) {
    return GameFixtures.createBoardWithMoves(xMoves: xMoves, oMoves: oMoves);
  }

  group('WinDetector - UNIT-WD', () {
    group('horizontal wins', () {
      test('[P0] UNIT-WD-001: should detect row 0 win', () {
        // Arrange
        // X X X
        // O O .
        // . . .
        final board = createBoardWithMoves([0, 1, 2], [3, 4]);

        // Act
        final result = detector.checkResult(board);

        // Assert
        expect(result, isA<GameResultWin>());
        final win = result as GameResultWin;
        expect(win.winner, PlayerMark.x);
        expect(win.winningLine.type, WinningLineType.horizontal);
      });

      test('[P0] UNIT-WD-002: should detect row 1 win', () {
        // Arrange
        // O O .
        // X X X
        // . . .
        final board = createBoardWithMoves([3, 4, 5], [0, 1]);

        // Act
        final result = detector.checkResult(board);

        // Assert
        expect(result, isA<GameResultWin>());
        final win = result as GameResultWin;
        expect(win.winner, PlayerMark.x);
      });

      test('[P0] UNIT-WD-003: should detect row 2 win', () {
        // Arrange
        // O O .
        // . . .
        // X X X
        final board = createBoardWithMoves([6, 7, 8], [0, 1]);

        // Act
        final result = detector.checkResult(board);

        // Assert
        expect(result, isA<GameResultWin>());
        final win = result as GameResultWin;
        expect(win.winner, PlayerMark.x);
      });
    });

    group('vertical wins', () {
      test('[P0] UNIT-WD-004: should detect column 0 win', () {
        // Arrange
        // X O .
        // X O .
        // X . .
        final board = createBoardWithMoves([0, 3, 6], [1, 4]);

        // Act
        final result = detector.checkResult(board);

        // Assert
        expect(result, isA<GameResultWin>());
        final win = result as GameResultWin;
        expect(win.winner, PlayerMark.x);
        expect(win.winningLine.type, WinningLineType.vertical);
      });

      test('[P0] UNIT-WD-005: should detect column 1 win', () {
        // Arrange
        // O X .
        // O X .
        // . X .
        final board = createBoardWithMoves([1, 4, 7], [0, 3]);

        // Act
        final result = detector.checkResult(board);

        // Assert
        expect(result, isA<GameResultWin>());
        final win = result as GameResultWin;
        expect(win.winner, PlayerMark.x);
      });

      test('[P0] UNIT-WD-006: should detect column 2 win', () {
        // Arrange
        // O . X
        // O . X
        // . . X
        final board = createBoardWithMoves([2, 5, 8], [0, 3]);

        // Act
        final result = detector.checkResult(board);

        // Assert
        expect(result, isA<GameResultWin>());
        final win = result as GameResultWin;
        expect(win.winner, PlayerMark.x);
      });
    });

    group('diagonal wins', () {
      test('[P0] UNIT-WD-007: should detect main diagonal win', () {
        // Arrange
        // X O .
        // O X .
        // . . X
        final board = createBoardWithMoves([0, 4, 8], [1, 3]);

        // Act
        final result = detector.checkResult(board);

        // Assert
        expect(result, isA<GameResultWin>());
        final win = result as GameResultWin;
        expect(win.winner, PlayerMark.x);
        expect(win.winningLine.type, WinningLineType.diagonal);
      });

      test('[P0] UNIT-WD-008: should detect anti-diagonal win', () {
        // Arrange
        // O . X
        // O X .
        // X . .
        final board = createBoardWithMoves([2, 4, 6], [0, 3]);

        // Act
        final result = detector.checkResult(board);

        // Assert
        expect(result, isA<GameResultWin>());
        final win = result as GameResultWin;
        expect(win.winner, PlayerMark.x);
        expect(win.winningLine.type, WinningLineType.antiDiagonal);
      });
    });

    group('O wins', () {
      test('[P0] UNIT-WD-009: should detect O win', () {
        // Arrange
        // O O O
        // X X .
        // X . .
        final board = createBoardWithMoves([3, 4, 6], [0, 1, 2]);

        // Act
        final result = detector.checkResult(board);

        // Assert
        expect(result, isA<GameResultWin>());
        final win = result as GameResultWin;
        expect(win.winner, PlayerMark.o);
      });
    });

    group('draw', () {
      test(
        '[P0] UNIT-WD-010: should detect draw when board is full with no winner',
        () {
          // Arrange
          // X O X
          // X O O
          // O X X
          final board = createBoardWithMoves([0, 2, 3, 7, 8], [1, 4, 5, 6]);

          // Act
          final result = detector.checkResult(board);

          // Assert
          expect(result, isA<GameResultDraw>());
        },
      );
    });

    group('ongoing', () {
      test('[P1] UNIT-WD-011: should return ongoing for empty board', () {
        // Arrange
        final board = Board.empty();

        // Act
        final result = detector.checkResult(board);

        // Assert
        expect(result, isA<GameResultOngoing>());
      });

      test('[P1] UNIT-WD-012: should return ongoing for in-progress game', () {
        // Arrange
        // X O .
        // . X .
        // . . .
        final board = createBoardWithMoves([0, 4], [1]);

        // Act
        final result = detector.checkResult(board);

        // Assert
        expect(result, isA<GameResultOngoing>());
      });
    });

    group('findWinningLine', () {
      test('[P2] UNIT-WD-013: should return null when no winning line', () {
        // Arrange
        final board = createBoardWithMoves([0, 4], [1]);

        // Act
        final xLine = detector.findWinningLine(board, PlayerMark.x);
        final oLine = detector.findWinningLine(board, PlayerMark.o);

        // Assert
        expect(xLine, isNull);
        expect(oLine, isNull);
      });

      test('[P2] UNIT-WD-014: should return winning line positions', () {
        // Arrange
        final board = createBoardWithMoves([0, 1, 2], [3, 4]);

        // Act
        final line = detector.findWinningLine(board, PlayerMark.x);

        // Assert
        expect(line, isNotNull);
        expect(line!.positions.length, 3);
        expect(line.positions[0], const Position(row: 0, col: 0));
        expect(line.positions[1], const Position(row: 0, col: 1));
        expect(line.positions[2], const Position(row: 0, col: 2));
      });
    });
  });
}
