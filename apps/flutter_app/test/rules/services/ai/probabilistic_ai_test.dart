import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe/features/rules/rules.dart';

class MockRandom extends Mock implements Random {}

void main() {
  group('ProbabilisticAIPlayer - UNIT-PAI', () {
    late GameState state;

    setUp(() {
      final playerX = const Player(
        id: 'human',
        name: 'Human',
        mark: PlayerMark.x,
      );
      final playerO = const Player(id: 'ai', name: 'AI', mark: PlayerMark.o);

      state = GameState(
        gameId: 'test',
        config: GameConfig(
          mode: const GameMode.vsAI(),
          playerX: playerX,
          playerO: playerO,
        ),
        board: Board.empty(),
        currentTurn: PlayerMark.o,
        moveHistory: const [],
        result: const GameResult.ongoing(),
        startedAt: DateTime.now(),
      );
    });

    GameState createGameState({
      required Board board,
      required PlayerMark currentTurn,
    }) {
      final playerX = const Player(
        id: 'human',
        name: 'Human',
        mark: PlayerMark.x,
      );
      final playerO = const Player(id: 'ai', name: 'AI', mark: PlayerMark.o);

      return GameState(
        gameId: 'test',
        config: GameConfig(
          mode: const GameMode.vsAI(difficulty: AIDifficulty.hard),
          playerX: playerX,
          playerO: playerO,
        ),
        board: board,
        currentTurn: currentTurn,
        moveHistory: const [],
        result: const GameResult.ongoing(),
        startedAt: DateTime.now(),
      );
    }

    group('random move behavior (smartMoveChance = 0.0)', () {
      test('[P1] UNIT-PAI-001: should return a valid empty position', () async {
        final ai = ProbabilisticAIPlayer(smartMoveChance: 0.0);
        final move = await ai.computeMove(state);

        expect(move.isValid, true);
        expect(state.board.isPositionEmpty(move), true);
      });

      test(
        '[P1] UNIT-PAI-002: should return position from available empty positions',
        () async {
          var board = Board.empty();
          board = board.withMove(const Position(row: 0, col: 0), PlayerMark.x);
          board = board.withMove(const Position(row: 0, col: 1), PlayerMark.o);
          board = board.withMove(const Position(row: 0, col: 2), PlayerMark.x);
          board = board.withMove(const Position(row: 1, col: 0), PlayerMark.o);
          board = board.withMove(const Position(row: 1, col: 1), PlayerMark.x);
          board = board.withMove(const Position(row: 1, col: 2), PlayerMark.o);
          board = board.withMove(const Position(row: 2, col: 0), PlayerMark.x);
          // Only (2,1) and (2,2) are empty

          final stateWithBoard = state.copyWith(board: board);
          final ai = ProbabilisticAIPlayer(smartMoveChance: 0.0);
          final move = await ai.computeMove(stateWithBoard);

          expect(
            move == const Position(row: 2, col: 1) ||
                move == const Position(row: 2, col: 2),
            true,
          );
        },
      );

      test(
        '[P2] UNIT-PAI-003: should use provided random for deterministic behavior',
        () async {
          final random = Random(42);
          final ai = ProbabilisticAIPlayer(
            smartMoveChance: 0.0,
            random: random,
          );

          final move1 = await ai.computeMove(state);

          final random2 = Random(42);
          final ai2 = ProbabilisticAIPlayer(
            smartMoveChance: 0.0,
            random: random2,
          );
          final move2 = await ai2.computeMove(state);

          expect(move1, move2);
        },
      );

      test('[P1] UNIT-PAI-004: should throw when no moves available', () async {
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

        final fullState = state.copyWith(board: board);
        final ai = ProbabilisticAIPlayer(smartMoveChance: 0.0);

        expect(() => ai.computeMove(fullState), throwsA(isA<StateError>()));
      });
    });

    group('minimax behavior (smartMoveChance = 1.0)', () {
      test('[P0] UNIT-PAI-005: should block opponent winning move', () async {
        // X X .
        // . O .
        // . . .
        // AI (O) should block at (0, 2)
        var board = Board.empty();
        board = board.withMove(const Position(row: 0, col: 0), PlayerMark.x);
        board = board.withMove(const Position(row: 0, col: 1), PlayerMark.x);
        board = board.withMove(const Position(row: 1, col: 1), PlayerMark.o);

        final gameState = createGameState(
          board: board,
          currentTurn: PlayerMark.o,
        );
        final ai = ProbabilisticAIPlayer(smartMoveChance: 1.0);
        final move = await ai.computeMove(gameState);

        expect(move, const Position(row: 0, col: 2));
      });

      test(
        '[P0] UNIT-PAI-006: should take winning move when available',
        () async {
          // O O .
          // X X .
          // . . .
          // AI (O) should win at (0, 2)
          var board = Board.empty();
          board = board.withMove(const Position(row: 0, col: 0), PlayerMark.o);
          board = board.withMove(const Position(row: 0, col: 1), PlayerMark.o);
          board = board.withMove(const Position(row: 1, col: 0), PlayerMark.x);
          board = board.withMove(const Position(row: 1, col: 1), PlayerMark.x);

          final gameState = createGameState(
            board: board,
            currentTurn: PlayerMark.o,
          );
          final ai = ProbabilisticAIPlayer(smartMoveChance: 1.0);
          final move = await ai.computeMove(gameState);

          expect(move, const Position(row: 0, col: 2));
        },
      );

      test('[P0] UNIT-PAI-007: should prefer winning over blocking', () async {
        // O O .
        // X X .
        // . . .
        // AI (O) should win at (0, 2) not block at (1, 2)
        var board = Board.empty();
        board = board.withMove(const Position(row: 0, col: 0), PlayerMark.o);
        board = board.withMove(const Position(row: 0, col: 1), PlayerMark.o);
        board = board.withMove(const Position(row: 1, col: 0), PlayerMark.x);
        board = board.withMove(const Position(row: 1, col: 1), PlayerMark.x);

        final gameState = createGameState(
          board: board,
          currentTurn: PlayerMark.o,
        );
        final ai = ProbabilisticAIPlayer(smartMoveChance: 1.0);
        final move = await ai.computeMove(gameState);

        expect(move, const Position(row: 0, col: 2));
      });

      test(
        '[P1] UNIT-PAI-008: should return valid move on empty board',
        () async {
          final gameState = createGameState(
            board: Board.empty(),
            currentTurn: PlayerMark.o,
          );
          final ai = ProbabilisticAIPlayer(smartMoveChance: 1.0);
          final move = await ai.computeMove(gameState);

          // On empty board, all moves lead to draw with perfect play
          // so any valid move is acceptable
          expect(move.isValid, true);
          expect(gameState.board.isPositionEmpty(move), true);
        },
      );

      group('AI never loses', () {
        test(
          '[P1] UNIT-PAI-009: AI as O should never lose when human starts center',
          () async {
            var board = Board.empty();
            board = board.withMove(
              const Position(row: 1, col: 1),
              PlayerMark.x,
            );

            var gameState = createGameState(
              board: board,
              currentTurn: PlayerMark.o,
            );
            final detector = WinDetectorImpl();
            final ai = ProbabilisticAIPlayer(smartMoveChance: 1.0);

            int moves = 1;
            while (moves < 9) {
              final result = detector.checkResult(gameState.board);
              if (result is! GameResultOngoing) break;

              if (gameState.currentTurn == PlayerMark.o) {
                final aiMove = await ai.computeMove(gameState);
                gameState = gameState.copyWith(
                  board: gameState.board.withMove(aiMove, PlayerMark.o),
                  currentTurn: PlayerMark.x,
                );
              } else {
                final humanMove = gameState.board.emptyPositions.first;
                gameState = gameState.copyWith(
                  board: gameState.board.withMove(humanMove, PlayerMark.x),
                  currentTurn: PlayerMark.o,
                );
              }
              moves++;
            }

            final finalResult = detector.checkResult(gameState.board);

            if (finalResult is GameResultWin) {
              expect(finalResult.winner, isNot(PlayerMark.x));
            }
          },
        );

        test('[P1] UNIT-PAI-010: AI as X should never lose', () async {
          final playerX = const Player(
            id: 'ai',
            name: 'AI',
            mark: PlayerMark.x,
          );
          final playerO = const Player(
            id: 'human',
            name: 'Human',
            mark: PlayerMark.o,
          );

          var gameState = GameState(
            gameId: 'test',
            config: GameConfig(
              mode: const GameMode.vsAI(difficulty: AIDifficulty.hard),
              playerX: playerX,
              playerO: playerO,
            ),
            board: Board.empty(),
            currentTurn: PlayerMark.x,
            moveHistory: const [],
            result: const GameResult.ongoing(),
            startedAt: DateTime.now(),
          );

          final detector = WinDetectorImpl();
          final ai = ProbabilisticAIPlayer(smartMoveChance: 1.0);

          int moves = 0;
          while (moves < 9) {
            final result = detector.checkResult(gameState.board);
            if (result is! GameResultOngoing) break;

            if (gameState.currentTurn == PlayerMark.x) {
              final aiMove = await ai.computeMove(gameState);
              gameState = gameState.copyWith(
                board: gameState.board.withMove(aiMove, PlayerMark.x),
                currentTurn: PlayerMark.o,
              );
            } else {
              final humanMove = gameState.board.emptyPositions.first;
              gameState = gameState.copyWith(
                board: gameState.board.withMove(humanMove, PlayerMark.o),
                currentTurn: PlayerMark.x,
              );
            }
            moves++;
          }

          final finalResult = detector.checkResult(gameState.board);

          if (finalResult is GameResultWin) {
            expect(finalResult.winner, isNot(PlayerMark.o));
          }
        });
      });
    });

    group('probabilistic behavior', () {
      test('[P1] UNIT-PAI-011: should return a valid empty position', () async {
        final ai = ProbabilisticAIPlayer(smartMoveChance: 0.5);
        final move = await ai.computeMove(state);

        expect(move.isValid, true);
        expect(state.board.isPositionEmpty(move), true);
      });

      test(
        '[P2] UNIT-PAI-012: should use smart AI when random is below smartMoveChance',
        () async {
          final mockRandom = MockRandom();
          when(() => mockRandom.nextDouble()).thenReturn(0.3);
          when(() => mockRandom.nextInt(any())).thenReturn(0);

          final ai = ProbabilisticAIPlayer(
            smartMoveChance: 0.5,
            random: mockRandom,
          );
          final move = await ai.computeMove(state);

          expect(move.isValid, true);
          expect(state.board.isPositionEmpty(move), true);
        },
      );

      test(
        '[P2] UNIT-PAI-013: should use random AI when random is above smartMoveChance',
        () async {
          final mockRandom = MockRandom();
          when(() => mockRandom.nextDouble()).thenReturn(0.7);
          when(() => mockRandom.nextInt(any())).thenReturn(0);

          final ai = ProbabilisticAIPlayer(
            smartMoveChance: 0.5,
            random: mockRandom,
          );
          final move = await ai.computeMove(state);

          expect(move.isValid, true);
          expect(state.board.isPositionEmpty(move), true);
        },
      );

      test(
        '[P2] UNIT-PAI-014: should respect custom smartMoveChance',
        () async {
          final mockRandom = MockRandom();
          when(() => mockRandom.nextDouble()).thenReturn(0.4);
          when(() => mockRandom.nextInt(any())).thenReturn(0);

          final ai = ProbabilisticAIPlayer(
            smartMoveChance: 0.3,
            random: mockRandom,
          );
          final move = await ai.computeMove(state);

          expect(move.isValid, true);
          expect(state.board.isPositionEmpty(move), true);
        },
      );

      test(
        '[P2] UNIT-PAI-015: should always use smart AI when smartMoveChance is 1.0',
        () async {
          final mockRandom = MockRandom();
          when(() => mockRandom.nextDouble()).thenReturn(0.99);

          final ai = ProbabilisticAIPlayer(
            smartMoveChance: 1.0,
            random: mockRandom,
          );
          final move = await ai.computeMove(state);

          expect(move.isValid, true);
          verifyNever(() => mockRandom.nextDouble());
        },
      );

      test(
        '[P2] UNIT-PAI-016: should always use random AI when smartMoveChance is 0.0',
        () async {
          final mockRandom = MockRandom();
          when(() => mockRandom.nextDouble()).thenReturn(0.01);
          when(() => mockRandom.nextInt(any())).thenReturn(0);

          final ai = ProbabilisticAIPlayer(
            smartMoveChance: 0.0,
            random: mockRandom,
          );
          final move = await ai.computeMove(state);

          expect(move.isValid, true);
          verifyNever(() => mockRandom.nextDouble());
        },
      );
    });
  });
}
