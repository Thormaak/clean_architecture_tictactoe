import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/rules/rules.dart';

void main() {
  late MoveValidator validator;
  late GameState state;

  setUp(() {
    validator = MoveValidatorImpl();

    final playerX = const Player(id: 'x', name: 'Player X', mark: PlayerMark.x);
    final playerO = const Player(id: 'o', name: 'Player O', mark: PlayerMark.o);

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

  group('MoveValidator - UNIT-MV', () {
    test(
      '[P1] UNIT-MV-001: should return valid for empty position on ongoing game',
      () {
        final result = validator.validate(
          state,
          const Position(row: 1, col: 1),
        );
        expect(result, const MoveValidationResult.valid());
      },
    );

    test(
      '[P1] UNIT-MV-002: should return invalid with gameOver when game is over',
      () {
        final gameOverState = state.copyWith(result: const GameResult.draw());

        final result = validator.validate(
          gameOverState,
          const Position(row: 1, col: 1),
        );

        expect(result, const MoveValidationResult.invalid(MoveError.gameOver));
      },
    );

    test(
      '[P1] UNIT-MV-003: should return invalid with invalidPosition for out of bounds',
      () {
        final result = validator.validate(
          state,
          const Position(row: 3, col: 0),
        );
        expect(
          result,
          const MoveValidationResult.invalid(MoveError.invalidPosition),
        );
      },
    );

    test(
      '[P1] UNIT-MV-004: should return invalid with invalidPosition for negative position',
      () {
        final result = validator.validate(
          state,
          const Position(row: -1, col: 0),
        );
        expect(
          result,
          const MoveValidationResult.invalid(MoveError.invalidPosition),
        );
      },
    );

    test(
      '[P1] UNIT-MV-005: should return invalid with positionOccupied for taken cell',
      () {
        final boardWithMove = state.board.withMove(
          const Position(row: 1, col: 1),
          PlayerMark.x,
        );
        final stateWithMove = state.copyWith(board: boardWithMove);

        final result = validator.validate(
          stateWithMove,
          const Position(row: 1, col: 1),
        );

        expect(
          result,
          const MoveValidationResult.invalid(MoveError.positionOccupied),
        );
      },
    );
  });
}
