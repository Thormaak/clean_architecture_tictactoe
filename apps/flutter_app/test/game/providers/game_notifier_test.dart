import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/game/domain/failures/game_failures.dart';
import 'package:tictactoe/features/game/presentation/providers/game_notifier.dart';
import 'package:tictactoe/features/rules/rules.dart';

void main() {
  group('GameNotifier - UNIT-GN', () {
    late ProviderContainer container;
    late GameNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(gameNotifierProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('initial state', () {
      test('[P1] UNIT-GN-001: should have null gameState initially', () {
        // Arrange & Act
        final state = container.read(gameNotifierProvider);

        // Assert
        expect(state.gameState, isNull);
        expect(state.animatedCells, isEmpty);
      });
    });

    group('startGame', () {
      test('[P1] UNIT-GN-002: should start local game correctly', () async {
        // Act
        await notifier.startGame(const GameMode.local());

        // Assert
        final state = container.read(gameNotifierProvider);
        expect(state.gameState, isNotNull);
        expect(state.gameState!.config.mode, isA<GameModeLocal>());
        expect(state.gameState!.board.emptyPositions.length, 9);
        expect(state.animatedCells, isEmpty);
      });

      test(
        '[P1] UNIT-GN-003: should start vsAI game with easy difficulty',
        () async {
          // Act
          await notifier.startGame(
            const GameMode.vsAI(difficulty: AIDifficulty.easy),
          );

          // Assert
          final state = container.read(gameNotifierProvider);
          expect(state.gameState, isNotNull);
          expect(state.gameState!.config.mode, isA<GameModeVsAI>());
          final mode = state.gameState!.config.mode as GameModeVsAI;
          expect(mode.difficulty, AIDifficulty.easy);
        },
      );

      test(
        '[P1] UNIT-GN-004: should start vsAI game with medium difficulty',
        () async {
          // Act
          await notifier.startGame(
            const GameMode.vsAI(difficulty: AIDifficulty.medium),
          );

          // Assert
          final state = container.read(gameNotifierProvider);
          final mode = state.gameState!.config.mode as GameModeVsAI;
          expect(mode.difficulty, AIDifficulty.medium);
        },
      );

      test(
        '[P1] UNIT-GN-005: should start vsAI game with hard difficulty',
        () async {
          // Act
          await notifier.startGame(
            const GameMode.vsAI(difficulty: AIDifficulty.hard),
          );

          // Assert
          final state = container.read(gameNotifierProvider);
          final mode = state.gameState!.config.mode as GameModeVsAI;
          expect(mode.difficulty, AIDifficulty.hard);
        },
      );
    });

    group('playMove', () {
      test(
        '[P1] UNIT-GN-006: should play valid move and update state',
        () async {
          // Arrange
          await notifier.startGame(const GameMode.local());

          // Act
          await notifier.playMove(const Position(row: 0, col: 0));

          // Assert
          final state = container.read(gameNotifierProvider);
          expect(
            state.gameState!.board.getCell(const Position(row: 0, col: 0)),
            isNotNull,
          );
          expect(state.animatedCells, contains(0));
        },
      );

      test('[P1] UNIT-GN-007: should switch turns after valid move', () async {
        // Arrange
        await notifier.startGame(const GameMode.local());
        final initialTurn =
            container.read(gameNotifierProvider).gameState!.currentTurn;

        // Act
        await notifier.playMove(const Position(row: 0, col: 0));

        // Assert
        final newTurn =
            container.read(gameNotifierProvider).gameState!.currentTurn;
        expect(newTurn, isNot(initialTurn));
      });

      test(
        '[P1] UNIT-GN-008: should emit failure event for invalid move',
        () async {
          // Arrange
          await notifier.startGame(const GameMode.local());
          await notifier.playMove(const Position(row: 0, col: 0));

          final events = <GameUiEvent>[];
          final subscription = container
              .read(gameUiEventControllerProvider)
              .stream
              .listen(events.add);
          try {
            // Act
            await notifier.playMove(
              const Position(row: 0, col: 0),
            ); // Same position
            await Future<void>.delayed(Duration.zero);

            // Assert
            expect(events, isNotEmpty);
            expect(events.last, isA<GameUiInvalidMoveEvent>());
            expect(
              (events.last as GameUiInvalidMoveEvent).failure,
              const PlayMoveFailure.invalidMove(),
            );
          } finally {
            await subscription.cancel();
          }
        },
      );

      test(
        '[P2] UNIT-GN-009: should do nothing if game state is null',
        () async {
          // Act
          await notifier.playMove(const Position(row: 0, col: 0));

          // Assert
          final state = container.read(gameNotifierProvider);
          expect(state.gameState, isNull);
        },
      );

      test('[P1] UNIT-GN-010: should do nothing if game is over', () async {
        // Arrange
        await notifier.startGame(const GameMode.local());

        // Play winning sequence for X
        await notifier.playMove(const Position(row: 0, col: 0)); // X
        await notifier.playMove(const Position(row: 1, col: 0)); // O
        await notifier.playMove(const Position(row: 0, col: 1)); // X
        await notifier.playMove(const Position(row: 1, col: 1)); // O
        await notifier.playMove(const Position(row: 0, col: 2)); // X wins

        final stateAfterWin = container.read(gameNotifierProvider);
        expect(stateAfterWin.gameState!.isGameOver, true);

        // Act
        await notifier.playMove(const Position(row: 2, col: 2));

        // Assert
        final finalState = container.read(gameNotifierProvider);
        expect(
          finalState.gameState!.board.isPositionEmpty(
            const Position(row: 2, col: 2),
          ),
          true,
        );
      });

      test('[P2] UNIT-GN-011: should accumulate animated cells', () async {
        // Arrange
        await notifier.startGame(const GameMode.local());

        // Act
        await notifier.playMove(const Position(row: 0, col: 0));
        await notifier.playMove(const Position(row: 1, col: 1));
        await notifier.playMove(const Position(row: 2, col: 2));

        // Assert
        final state = container.read(gameNotifierProvider);
        expect(state.animatedCells, contains(0));
        expect(state.animatedCells, contains(4));
        expect(state.animatedCells, contains(8));
      });
    });

    group('GameUIState', () {
      test(
        '[P2] UNIT-GN-012: copyWith should preserve values when not specified',
        () {
          // Arrange
          const original = GameUIState(animatedCells: {1, 2, 3});

          // Act
          final copied = original.copyWith();

          // Assert
          expect(copied.animatedCells, {1, 2, 3});
        },
      );

      test('[P2] UNIT-GN-013: copyWith should override specified values', () {
        // Arrange
        const original = GameUIState(animatedCells: {1, 2, 3});

        // Act
        final copied = original.copyWith(animatedCells: {4, 5});

        // Assert
        expect(copied.animatedCells, {4, 5});
      });
    });

    group('Best Of modes', () {
      test('[P1] UNIT-GN-014: should start BO3 match correctly', () async {
        // Act
        await notifier.startGame(const GameMode.local(), bestOf: BestOf.bo3);

        // Assert
        final state = container.read(gameNotifierProvider);
        expect(state.matchState, isNotNull);
        expect(state.matchState!.config.bestOf, BestOf.bo3);
        expect(state.matchState!.currentRoundNumber, 1);
        expect(state.playerXScore, 0);
        expect(state.playerOScore, 0);
      });

      test('[P1] UNIT-GN-015: should start BO5 match correctly', () async {
        // Act
        await notifier.startGame(const GameMode.local(), bestOf: BestOf.bo5);

        // Assert
        final state = container.read(gameNotifierProvider);
        expect(state.matchState!.config.bestOf, BestOf.bo5);
      });

      test('[P1] UNIT-GN-016: should track scores after round win', () async {
        // Arrange
        await notifier.startGame(const GameMode.local(), bestOf: BestOf.bo3);

        // Play winning sequence for X
        await notifier.playMove(const Position(row: 0, col: 0)); // X
        await notifier.playMove(const Position(row: 1, col: 0)); // O
        await notifier.playMove(const Position(row: 0, col: 1)); // X
        await notifier.playMove(const Position(row: 1, col: 1)); // O
        await notifier.playMove(const Position(row: 0, col: 2)); // X wins

        // Assert
        final state = container.read(gameNotifierProvider);
        expect(state.isRoundOver, true);
        expect(state.playerXScore, 1);
        expect(state.playerOScore, 0);
        expect(state.isMatchOver, false);
      });

      test('[P1] UNIT-GN-017: should detect match winner in BO3', () async {
        // Arrange
        await notifier.startGame(const GameMode.local(), bestOf: BestOf.bo3);

        // Helper to play a winning game for the current player
        Future<void> playWinningSequence() async {
          final currentTurn =
              container.read(gameNotifierProvider).gameState!.currentTurn;
          if (currentTurn == PlayerMark.x) {
            // X starts: X wins with top row
            await notifier.playMove(const Position(row: 0, col: 0)); // X
            await notifier.playMove(const Position(row: 1, col: 0)); // O
            await notifier.playMove(const Position(row: 0, col: 1)); // X
            await notifier.playMove(const Position(row: 1, col: 1)); // O
            await notifier.playMove(const Position(row: 0, col: 2)); // X wins
          } else {
            // O starts: O plays first, then X wins
            await notifier.playMove(const Position(row: 1, col: 0)); // O
            await notifier.playMove(const Position(row: 0, col: 0)); // X
            await notifier.playMove(const Position(row: 1, col: 1)); // O
            await notifier.playMove(const Position(row: 0, col: 1)); // X
            await notifier.playMove(const Position(row: 2, col: 2)); // O
            await notifier.playMove(const Position(row: 0, col: 2)); // X wins
          }
        }

        // Round 1: X wins
        await playWinningSequence();
        expect(container.read(gameNotifierProvider).playerXScore, 1);

        // Continue to round 2
        await notifier.continueToNextRound();

        // Round 2: X wins again
        await playWinningSequence();

        // Assert
        final state = container.read(gameNotifierProvider);
        expect(state.playerXScore, 2);
        expect(state.isMatchOver, true);
      });
    });

    group('continueToNextRound', () {
      test(
        '[P1] UNIT-GN-018: should continue to next round after round ends',
        () async {
          // Arrange
          await notifier.startGame(const GameMode.local(), bestOf: BestOf.bo3);

          // Play winning sequence for X
          await notifier.playMove(const Position(row: 0, col: 0)); // X
          await notifier.playMove(const Position(row: 1, col: 0)); // O
          await notifier.playMove(const Position(row: 0, col: 1)); // X
          await notifier.playMove(const Position(row: 1, col: 1)); // O
          await notifier.playMove(const Position(row: 0, col: 2)); // X wins

          expect(container.read(gameNotifierProvider).awaitingNextRound, true);

          // Act
          await notifier.continueToNextRound();

          // Assert
          final state = container.read(gameNotifierProvider);
          expect(state.matchState!.currentRoundNumber, 2);
          expect(state.gameState!.board.emptyPositions.length, 9);
          expect(state.animatedCells, isEmpty);
        },
      );

      test('[P2] UNIT-GN-019: should do nothing if no match state', () async {
        // Act
        await notifier.continueToNextRound();

        // Assert
        final state = container.read(gameNotifierProvider);
        expect(state.matchState, isNull);
      });

      test(
        '[P2] UNIT-GN-020: should do nothing if not awaiting next round',
        () async {
          // Arrange
          await notifier.startGame(const GameMode.local(), bestOf: BestOf.bo3);

          // Act (no round played yet)
          await notifier.continueToNextRound();

          // Assert
          final state = container.read(gameNotifierProvider);
          expect(state.matchState!.currentRoundNumber, 1);
        },
      );
    });

    group('restartGame', () {
      test('[P1] UNIT-GN-021: should restart game and reset state', () async {
        // Arrange
        await notifier.startGame(const GameMode.local(), bestOf: BestOf.bo3);
        await notifier.playMove(const Position(row: 0, col: 0));
        await notifier.playMove(const Position(row: 1, col: 1));

        // Act
        await notifier.restartGame();

        // Assert
        final state = container.read(gameNotifierProvider);
        expect(state.gameState!.board.emptyPositions.length, 9);
        expect(state.animatedCells, isEmpty);
        expect(state.playerXScore, 0);
        expect(state.playerOScore, 0);
      });

      test(
        '[P2] UNIT-GN-022: should preserve game mode after restart',
        () async {
          // Arrange
          await notifier.startGame(
            const GameMode.vsAI(difficulty: AIDifficulty.hard),
            bestOf: BestOf.bo5,
          );

          // Act
          await notifier.restartGame();

          // Assert
          final state = container.read(gameNotifierProvider);
          expect(state.matchState!.config.mode, isA<GameModeVsAI>());
          expect(state.matchState!.config.bestOf, BestOf.bo5);
        },
      );

      test('[P2] UNIT-GN-023: should do nothing if no match state', () async {
        // Act
        await notifier.restartGame();

        // Assert
        final state = container.read(gameNotifierProvider);
        expect(state.matchState, isNull);
      });
    });

    group('GameUIState computed properties', () {
      test(
        '[P2] UNIT-GN-024: should return correct gameState from matchState',
        () async {
          // Arrange
          await notifier.startGame(const GameMode.local());

          // Act
          final state = container.read(gameNotifierProvider);

          // Assert
          expect(state.gameState, equals(state.matchState!.currentRound));
        },
      );

      test(
        '[P2] UNIT-GN-025: should return default values when matchState is null',
        () {
          // Act
          final state = container.read(gameNotifierProvider);

          // Assert
          expect(state.gameState, isNull);
          expect(state.playerXScore, 0);
          expect(state.playerOScore, 0);
          expect(state.isMatchOver, false);
          expect(state.isRoundOver, false);
          expect(state.awaitingNextRound, false);
          expect(state.isSingleGame, true);
        },
      );

      test('[P2] UNIT-GN-026: isSingleGame should be true for BO1', () async {
        // Arrange
        await notifier.startGame(const GameMode.local(), bestOf: BestOf.bo1);

        // Assert
        final state = container.read(gameNotifierProvider);
        expect(state.isSingleGame, true);
      });

      test('[P2] UNIT-GN-027: isSingleGame should be false for BO3', () async {
        // Arrange
        await notifier.startGame(const GameMode.local(), bestOf: BestOf.bo3);

        // Assert
        final state = container.read(gameNotifierProvider);
        expect(state.isSingleGame, false);
      });
    });

    group('draw scenarios', () {
      test('[P1] UNIT-GN-028: should handle draw in single game', () async {
        // Arrange
        await notifier.startGame(const GameMode.local());

        // Play a draw game
        await notifier.playMove(const Position(row: 0, col: 0)); // X
        await notifier.playMove(const Position(row: 0, col: 1)); // O
        await notifier.playMove(const Position(row: 0, col: 2)); // X
        await notifier.playMove(const Position(row: 1, col: 1)); // O
        await notifier.playMove(const Position(row: 1, col: 0)); // X
        await notifier.playMove(const Position(row: 1, col: 2)); // O
        await notifier.playMove(const Position(row: 2, col: 1)); // X
        await notifier.playMove(const Position(row: 2, col: 0)); // O
        await notifier.playMove(const Position(row: 2, col: 2)); // X - Draw

        // Assert
        final state = container.read(gameNotifierProvider);
        expect(state.gameState!.isGameOver, true);
        expect(state.gameState!.result, isA<GameResultDraw>());
      });

      test('[P1] UNIT-GN-029: should handle draw in BO3 match', () async {
        // Arrange
        await notifier.startGame(const GameMode.local(), bestOf: BestOf.bo3);

        // Play a draw game
        await notifier.playMove(const Position(row: 0, col: 0)); // X
        await notifier.playMove(const Position(row: 0, col: 1)); // O
        await notifier.playMove(const Position(row: 0, col: 2)); // X
        await notifier.playMove(const Position(row: 1, col: 1)); // O
        await notifier.playMove(const Position(row: 1, col: 0)); // X
        await notifier.playMove(const Position(row: 1, col: 2)); // O
        await notifier.playMove(const Position(row: 2, col: 1)); // X
        await notifier.playMove(const Position(row: 2, col: 0)); // O
        await notifier.playMove(const Position(row: 2, col: 2)); // X - Draw

        // Assert
        final state = container.read(gameNotifierProvider);
        expect(state.isRoundOver, true);
        expect(state.playerXScore, 0);
        expect(state.playerOScore, 0);
        expect(state.isMatchOver, false);
      });
    });
  });
}
