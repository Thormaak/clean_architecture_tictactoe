import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/rules/rules.dart';

void main() {
  late GameState state;
  late Player playerX;
  late Player playerO;

  setUp(() {
    playerX = const Player(id: 'x', name: 'Player X', mark: PlayerMark.x);
    playerO = const Player(id: 'o', name: 'Player O', mark: PlayerMark.o);

    state = GameState(
      gameId: 'test',
      config: GameConfig(
        mode: const GameMode.local(),
        playerX: playerX,
        playerO: playerO,
      ),
      board: Board.empty(),
      currentTurn: PlayerMark.x,
      moveHistory: const [],
      result: const GameResult.ongoing(),
      startedAt: DateTime.now(),
    );
  });

  group('GameState - UNIT-GS', () {
    group('isGameOver', () {
      test('[P1] UNIT-GS-001: should return false when result is ongoing', () {
        expect(state.isGameOver, false);
      });

      test('[P1] UNIT-GS-002: should return true when result is win', () {
        final winState = state.copyWith(
          result: GameResult.win(
            winner: PlayerMark.x,
            winningLine: WinningLine(
              positions: [
                const Position(row: 0, col: 0),
                const Position(row: 0, col: 1),
                const Position(row: 0, col: 2),
              ],
              type: WinningLineType.horizontal,
            ),
          ),
        );
        expect(winState.isGameOver, true);
      });

      test('[P1] UNIT-GS-003: should return true when result is draw', () {
        final drawState = state.copyWith(result: const GameResult.draw());
        expect(drawState.isGameOver, true);
      });
    });

    group('currentPlayer', () {
      test('[P1] UNIT-GS-004: should return playerX when currentTurn is x', () {
        expect(state.currentPlayer, playerX);
      });

      test('[P1] UNIT-GS-005: should return playerO when currentTurn is o', () {
        final oTurnState = state.copyWith(currentTurn: PlayerMark.o);
        expect(oTurnState.currentPlayer, playerO);
      });
    });

    group('moveCount', () {
      test('[P1] UNIT-GS-006: should return 0 for empty history', () {
        expect(state.moveCount, 0);
      });

      test('[P1] UNIT-GS-007: should return correct count with moves', () {
        final stateWithMoves = state.copyWith(
          moveHistory: [
            Move(
              position: const Position(row: 0, col: 0),
              mark: PlayerMark.x,
              timestamp: DateTime.now(),
              moveNumber: 1,
            ),
            Move(
              position: const Position(row: 1, col: 1),
              mark: PlayerMark.o,
              timestamp: DateTime.now(),
              moveNumber: 2,
            ),
          ],
        );
        expect(stateWithMoves.moveCount, 2);
      });
    });
  });
}
