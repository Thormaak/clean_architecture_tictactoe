import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/rules/rules.dart';

void main() {
  late MatchEngine matchEngine;
  late GameEngine gameEngine;
  late GameConfig config;
  late Player playerX;
  late Player playerO;

  setUp(() {
    gameEngine = GameEngineImpl();
    matchEngine = MatchEngineImpl(gameEngine: gameEngine);
    playerX = const Player(id: 'x', name: 'Player X', mark: PlayerMark.x);
    playerO = const Player(id: 'o', name: 'Player O', mark: PlayerMark.o);
    config = GameConfig(
      mode: const GameMode.local(),
      playerX: playerX,
      playerO: playerO,
      bestOf: BestOf.bo3,
    );
  });

  GameState playToWin(GameState game, PlayerMark winner) {
    // Plays a sequence that results in a win for the specified player
    // Handles different starting players
    final startsWithX = game.currentTurn == PlayerMark.x;

    List<Position> moves;
    if (winner == PlayerMark.x) {
      if (startsWithX) {
        // X starts and wins on row 0
        moves = const [
          Position(row: 0, col: 0), // X
          Position(row: 1, col: 0), // O
          Position(row: 0, col: 1), // X
          Position(row: 1, col: 1), // O
          Position(row: 0, col: 2), // X wins
        ];
      } else {
        // O starts, X wins on row 0
        moves = const [
          Position(row: 1, col: 0), // O
          Position(row: 0, col: 0), // X
          Position(row: 1, col: 1), // O
          Position(row: 0, col: 1), // X
          Position(row: 2, col: 2), // O (random)
          Position(row: 0, col: 2), // X wins
        ];
      }
    } else {
      if (startsWithX) {
        // X starts, O wins on row 1
        moves = const [
          Position(row: 0, col: 0), // X
          Position(row: 1, col: 0), // O
          Position(row: 2, col: 0), // X
          Position(row: 1, col: 1), // O
          Position(row: 2, col: 2), // X
          Position(row: 1, col: 2), // O wins
        ];
      } else {
        // O starts and wins on row 1
        moves = const [
          Position(row: 1, col: 0), // O
          Position(row: 0, col: 0), // X
          Position(row: 1, col: 1), // O
          Position(row: 0, col: 1), // X
          Position(row: 1, col: 2), // O wins
        ];
      }
    }

    var currentGame = game;
    for (final move in moves) {
      final result = gameEngine.playMove(currentGame, move);
      if (result is GameEngineSuccess) {
        currentGame = result.newState;
      }
    }
    return currentGame;
  }

  GameState playToDraw(GameState game) {
    final startsWithX = game.currentTurn == PlayerMark.x;

    // Different draw patterns based on who starts
    final moves =
        startsWithX
            ? const [
              // X starts
              // X O X
              // X O O
              // O X X
              Position(row: 0, col: 0), // X
              Position(row: 0, col: 1), // O
              Position(row: 0, col: 2), // X
              Position(row: 1, col: 1), // O
              Position(row: 1, col: 0), // X
              Position(row: 2, col: 0), // O
              Position(row: 1, col: 2), // X
              Position(row: 2, col: 2), // O
              Position(row: 2, col: 1), // X - draw
            ]
            : const [
              // O starts
              // O X O
              // O X X
              // X O X
              Position(row: 0, col: 0), // O
              Position(row: 0, col: 1), // X
              Position(row: 0, col: 2), // O
              Position(row: 1, col: 1), // X
              Position(row: 1, col: 0), // O
              Position(row: 2, col: 0), // X
              Position(row: 1, col: 2), // O
              Position(row: 2, col: 2), // X
              Position(row: 2, col: 1), // O - draw
            ];

    var currentGame = game;
    for (final move in moves) {
      final result = gameEngine.playMove(currentGame, move);
      if (result is GameEngineSuccess) {
        currentGame = result.newState;
      }
    }
    return currentGame;
  }

  group('MatchEngine - UNIT-ME', () {
    group('createMatch', () {
      test(
        '[P1] UNIT-ME-001: should create match with empty completed rounds',
        () {
          final match = matchEngine.createMatch(config);

          expect(match.completedRounds, isEmpty);
          expect(match.currentRoundNumber, 1);
        },
      );

      test(
        '[P1] UNIT-ME-002: should create match with initial scores of 0',
        () {
          final match = matchEngine.createMatch(config);

          expect(match.playerXScore, 0);
          expect(match.playerOScore, 0);
        },
      );

      test('[P1] UNIT-ME-003: should create match with ongoing result', () {
        final match = matchEngine.createMatch(config);

        expect(match.result, isA<MatchResultOngoing>());
        expect(match.isMatchOver, false);
      });

      test(
        '[P1] UNIT-ME-004: should create match with first round started',
        () {
          final match = matchEngine.createMatch(config);

          expect(match.currentRound, isNotNull);
          expect(match.currentRound!.result, isA<GameResultOngoing>());
        },
      );

      test('[P1] UNIT-ME-005: should store config with bestOf', () {
        final match = matchEngine.createMatch(config);

        expect(match.config.bestOf, BestOf.bo3);
        expect(match.bestOf, BestOf.bo3);
      });
    });

    group('completeRound', () {
      test('[P0] UNIT-ME-006: should increment playerX score when X wins', () {
        var match = matchEngine.createMatch(config);
        final completedRound = playToWin(match.currentRound!, PlayerMark.x);

        match = matchEngine.completeRound(match, completedRound);

        expect(match.playerXScore, 1);
        expect(match.playerOScore, 0);
      });

      test('[P0] UNIT-ME-007: should increment playerO score when O wins', () {
        var match = matchEngine.createMatch(config);
        final completedRound = playToWin(match.currentRound!, PlayerMark.o);

        match = matchEngine.completeRound(match, completedRound);

        expect(match.playerXScore, 0);
        expect(match.playerOScore, 1);
      });

      test('[P1] UNIT-ME-008: should not give points on draw', () {
        var match = matchEngine.createMatch(config);
        final completedRound = playToDraw(match.currentRound!);

        match = matchEngine.completeRound(match, completedRound);

        expect(match.playerXScore, 0);
        expect(match.playerOScore, 0);
      });

      test('[P1] UNIT-ME-009: should add completed round to history', () {
        var match = matchEngine.createMatch(config);
        final completedRound = playToWin(match.currentRound!, PlayerMark.x);

        match = matchEngine.completeRound(match, completedRound);

        expect(match.completedRounds.length, 1);
        expect(match.completedRounds.first.result, isA<GameResultWin>());
      });

      test(
        '[P0] UNIT-ME-010: should set match result to playerXWins when X reaches roundsToWin',
        () {
          var match = matchEngine.createMatch(config);

          // X wins round 1
          var round1 = playToWin(match.currentRound!, PlayerMark.x);
          match = matchEngine.completeRound(match, round1);

          // Start round 2
          final startResult = matchEngine.startNextRound(match);
          match = (startResult as MatchEngineSuccess).newState;

          // X wins round 2
          var round2 = playToWin(match.currentRound!, PlayerMark.x);
          match = matchEngine.completeRound(match, round2);

          expect(match.result, isA<MatchResultPlayerXWins>());
          expect(match.isMatchOver, true);
          expect(match.playerXScore, 2);
        },
      );

      test(
        '[P0] UNIT-ME-011: should set match result to playerOWins when O reaches roundsToWin',
        () {
          var match = matchEngine.createMatch(config);

          // O wins round 1
          var round1 = playToWin(match.currentRound!, PlayerMark.o);
          match = matchEngine.completeRound(match, round1);

          // Start round 2
          final startResult = matchEngine.startNextRound(match);
          match = (startResult as MatchEngineSuccess).newState;

          // O wins round 2
          var round2 = playToWin(match.currentRound!, PlayerMark.o);
          match = matchEngine.completeRound(match, round2);

          expect(match.result, isA<MatchResultPlayerOWins>());
          expect(match.isMatchOver, true);
          expect(match.playerOScore, 2);
        },
      );

      test(
        '[P1] UNIT-ME-012: should keep match ongoing when no one reached roundsToWin',
        () {
          var match = matchEngine.createMatch(config);

          // X wins round 1
          var round1 = playToWin(match.currentRound!, PlayerMark.x);
          match = matchEngine.completeRound(match, round1);

          expect(match.result, isA<MatchResultOngoing>());
          expect(match.isMatchOver, false);
        },
      );

      test('[P1] UNIT-ME-013: should set endedAt when match is over', () {
        var match = matchEngine.createMatch(config);

        // X wins round 1
        var round1 = playToWin(match.currentRound!, PlayerMark.x);
        match = matchEngine.completeRound(match, round1);
        expect(match.endedAt, isNull);

        // Start round 2
        final startResult = matchEngine.startNextRound(match);
        match = (startResult as MatchEngineSuccess).newState;

        // X wins round 2 - match over
        var round2 = playToWin(match.currentRound!, PlayerMark.x);
        match = matchEngine.completeRound(match, round2);

        expect(match.endedAt, isNotNull);
      });
    });

    group('startNextRound', () {
      test(
        '[P0] UNIT-ME-014: should create new round with incremented round number',
        () {
          var match = matchEngine.createMatch(config);
          final completedRound = playToWin(match.currentRound!, PlayerMark.x);
          match = matchEngine.completeRound(match, completedRound);

          final result = matchEngine.startNextRound(match);

          expect(result, isA<MatchEngineSuccess>());
          final newMatch = (result as MatchEngineSuccess).newState;
          expect(newMatch.currentRoundNumber, 2);
        },
      );

      test(
        '[P0] UNIT-ME-015: should create new round with alternating starting player',
        () {
          var match = matchEngine.createMatch(config);

          // X wins round 1
          final completedRound = playToWin(match.currentRound!, PlayerMark.x);
          match = matchEngine.completeRound(match, completedRound);

          // Next round should start with O (loser starts)
          final result = matchEngine.startNextRound(match);
          final newMatch = (result as MatchEngineSuccess).newState;

          expect(newMatch.currentRound!.currentTurn, PlayerMark.o);
        },
      );

      test('[P1] UNIT-ME-016: should fail when match is already over', () {
        // Create BO1 match
        final bo1Config = config.copyWith(bestOf: BestOf.bo1);
        var match = matchEngine.createMatch(bo1Config);

        // X wins - match is over
        final completedRound = playToWin(match.currentRound!, PlayerMark.x);
        match = matchEngine.completeRound(match, completedRound);

        final result = matchEngine.startNextRound(match);

        expect(result, isA<MatchEngineFailure>());
        final failure = result as MatchEngineFailure;
        expect(failure.error, isA<MatchEngineErrorMatchAlreadyOver>());
      });

      test('[P1] UNIT-ME-017: should fail when round is still in progress', () {
        final match = matchEngine.createMatch(config);

        final result = matchEngine.startNextRound(match);

        expect(result, isA<MatchEngineFailure>());
        final failure = result as MatchEngineFailure;
        expect(failure.error, isA<MatchEngineErrorRoundInProgress>());
      });

      test('[P1] UNIT-ME-018: should preserve scores across rounds', () {
        var match = matchEngine.createMatch(config);

        // X wins round 1
        final round1 = playToWin(match.currentRound!, PlayerMark.x);
        match = matchEngine.completeRound(match, round1);

        final result = matchEngine.startNextRound(match);
        final newMatch = (result as MatchEngineSuccess).newState;

        expect(newMatch.playerXScore, 1);
        expect(newMatch.playerOScore, 0);
      });
    });

    group('BO1 scenarios', () {
      late GameConfig bo1Config;

      setUp(() {
        bo1Config = config.copyWith(bestOf: BestOf.bo1);
      });

      test('[P0] UNIT-ME-019: should end match when X wins single round', () {
        var match = matchEngine.createMatch(bo1Config);

        final completedRound = playToWin(match.currentRound!, PlayerMark.x);
        match = matchEngine.completeRound(match, completedRound);

        expect(match.isMatchOver, true);
        expect(match.result, isA<MatchResultPlayerXWins>());
        expect(match.playerXScore, 1);
        expect(match.playerOScore, 0);
        expect(match.completedRounds.length, 1);
      });

      test('[P0] UNIT-ME-020: should end match when O wins single round', () {
        var match = matchEngine.createMatch(bo1Config);

        final completedRound = playToWin(match.currentRound!, PlayerMark.o);
        match = matchEngine.completeRound(match, completedRound);

        expect(match.isMatchOver, true);
        expect(match.result, isA<MatchResultPlayerOWins>());
        expect(match.playerXScore, 0);
        expect(match.playerOScore, 1);
        expect(match.completedRounds.length, 1);
      });

      test(
        '[P0] UNIT-ME-021: should end match as draw when single round is draw',
        () {
          var match = matchEngine.createMatch(bo1Config);

          final completedRound = playToDraw(match.currentRound!);
          match = matchEngine.completeRound(match, completedRound);

          expect(match.isMatchOver, true);
          expect(match.result, isA<MatchResultDraw>());
          expect(match.playerXScore, 0);
          expect(match.playerOScore, 0);
          expect(match.completedRounds.length, 1);
        },
      );

      test(
        '[P1] UNIT-ME-022: should not allow starting next round after BO1 ends',
        () {
          var match = matchEngine.createMatch(bo1Config);

          final completedRound = playToWin(match.currentRound!, PlayerMark.x);
          match = matchEngine.completeRound(match, completedRound);

          final result = matchEngine.startNextRound(match);

          expect(result, isA<MatchEngineFailure>());
          final failure = result as MatchEngineFailure;
          expect(failure.error, isA<MatchEngineErrorMatchAlreadyOver>());
        },
      );
    });

    group('BO3 scenarios', () {
      test('[P0] UNIT-ME-023: should end match with X winning 2-0', () {
        var match = matchEngine.createMatch(config);

        // Round 1: X wins
        var round = playToWin(match.currentRound!, PlayerMark.x);
        match = matchEngine.completeRound(match, round);
        expect(match.isMatchOver, false);

        // Round 2: X wins again
        match =
            (matchEngine.startNextRound(match) as MatchEngineSuccess).newState;
        round = playToWin(match.currentRound!, PlayerMark.x);
        match = matchEngine.completeRound(match, round);

        expect(match.isMatchOver, true);
        expect(match.result, isA<MatchResultPlayerXWins>());
        expect(match.playerXScore, 2);
        expect(match.playerOScore, 0);
        expect(match.completedRounds.length, 2);
      });

      test('[P0] UNIT-ME-024: should end match with O winning 2-0', () {
        var match = matchEngine.createMatch(config);

        // Round 1: O wins
        var round = playToWin(match.currentRound!, PlayerMark.o);
        match = matchEngine.completeRound(match, round);
        expect(match.isMatchOver, false);

        // Round 2: O wins again
        match =
            (matchEngine.startNextRound(match) as MatchEngineSuccess).newState;
        round = playToWin(match.currentRound!, PlayerMark.o);
        match = matchEngine.completeRound(match, round);

        expect(match.isMatchOver, true);
        expect(match.result, isA<MatchResultPlayerOWins>());
        expect(match.playerXScore, 0);
        expect(match.playerOScore, 2);
        expect(match.completedRounds.length, 2);
      });

      test('[P0] UNIT-ME-025: should end match with X winning 2-1', () {
        var match = matchEngine.createMatch(config);

        // Round 1: X wins
        var round = playToWin(match.currentRound!, PlayerMark.x);
        match = matchEngine.completeRound(match, round);

        // Round 2: O wins
        match =
            (matchEngine.startNextRound(match) as MatchEngineSuccess).newState;
        round = playToWin(match.currentRound!, PlayerMark.o);
        match = matchEngine.completeRound(match, round);
        expect(match.isMatchOver, false);

        // Round 3: X wins
        match =
            (matchEngine.startNextRound(match) as MatchEngineSuccess).newState;
        round = playToWin(match.currentRound!, PlayerMark.x);
        match = matchEngine.completeRound(match, round);

        expect(match.isMatchOver, true);
        expect(match.result, isA<MatchResultPlayerXWins>());
        expect(match.playerXScore, 2);
        expect(match.playerOScore, 1);
        expect(match.completedRounds.length, 3);
      });

      test('[P0] UNIT-ME-026: should end match with O winning 2-1', () {
        var match = matchEngine.createMatch(config);

        // Round 1: O wins
        var round = playToWin(match.currentRound!, PlayerMark.o);
        match = matchEngine.completeRound(match, round);

        // Round 2: X wins
        match =
            (matchEngine.startNextRound(match) as MatchEngineSuccess).newState;
        round = playToWin(match.currentRound!, PlayerMark.x);
        match = matchEngine.completeRound(match, round);
        expect(match.isMatchOver, false);

        // Round 3: O wins
        match =
            (matchEngine.startNextRound(match) as MatchEngineSuccess).newState;
        round = playToWin(match.currentRound!, PlayerMark.o);
        match = matchEngine.completeRound(match, round);

        expect(match.isMatchOver, true);
        expect(match.result, isA<MatchResultPlayerOWins>());
        expect(match.playerXScore, 1);
        expect(match.playerOScore, 2);
        expect(match.completedRounds.length, 3);
      });

      test(
        '[P0] UNIT-ME-027: should end in match draw with 1-1 after 3 rounds (draw in round 3)',
        () {
          var match = matchEngine.createMatch(config);

          // Round 1: X wins (1-0)
          var round = playToWin(match.currentRound!, PlayerMark.x);
          match = matchEngine.completeRound(match, round);

          // Round 2: O wins (1-1)
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          round = playToWin(match.currentRound!, PlayerMark.o);
          match = matchEngine.completeRound(match, round);
          expect(match.isMatchOver, false);

          // Round 3: Draw - still 1-1 after maxRounds
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          round = playToDraw(match.currentRound!);
          match = matchEngine.completeRound(match, round);

          expect(match.playerXScore, 1);
          expect(match.playerOScore, 1);
          expect(match.isMatchOver, true);
          expect(match.result, isA<MatchResultDraw>());
          expect(match.completedRounds.length, 3);
        },
      );

      test(
        '[P0] UNIT-ME-028: should end in match draw with 0-0 after 3 draws',
        () {
          var match = matchEngine.createMatch(config);

          // All 3 rounds are draws
          for (var i = 0; i < 3; i++) {
            if (i > 0) {
              match =
                  (matchEngine.startNextRound(match) as MatchEngineSuccess)
                      .newState;
            }
            final round = playToDraw(match.currentRound!);
            match = matchEngine.completeRound(match, round);
          }

          expect(match.playerXScore, 0);
          expect(match.playerOScore, 0);
          expect(match.isMatchOver, true);
          expect(match.result, isA<MatchResultDraw>());
          expect(match.completedRounds.length, 3);
        },
      );

      test(
        '[P0] UNIT-ME-029: should end with X win when X leads 1-0 after 3 rounds (2 draws + 1 win)',
        () {
          var match = matchEngine.createMatch(config);

          // Round 1: Draw (0-0)
          var round = playToDraw(match.currentRound!);
          match = matchEngine.completeRound(match, round);
          expect(match.isMatchOver, false);

          // Round 2: Draw (0-0)
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          round = playToDraw(match.currentRound!);
          match = matchEngine.completeRound(match, round);
          expect(match.isMatchOver, false);

          // Round 3: X wins (1-0) - maxRounds reached, X has more points
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          round = playToWin(match.currentRound!, PlayerMark.x);
          match = matchEngine.completeRound(match, round);

          expect(match.playerXScore, 1);
          expect(match.playerOScore, 0);
          expect(match.isMatchOver, true);
          expect(match.result, isA<MatchResultPlayerXWins>());
          expect(match.completedRounds.length, 3);
          expect(match.currentRoundNumber, 3);
        },
      );

      test(
        '[P0] UNIT-ME-030: should end with O win when O leads 1-0 after 3 rounds (2 draws + 1 win)',
        () {
          var match = matchEngine.createMatch(config);

          // Round 1: Draw (0-0)
          var round = playToDraw(match.currentRound!);
          match = matchEngine.completeRound(match, round);
          expect(match.isMatchOver, false);

          // Round 2: Draw (0-0)
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          round = playToDraw(match.currentRound!);
          match = matchEngine.completeRound(match, round);
          expect(match.isMatchOver, false);

          // Round 3: O wins (0-1) - maxRounds reached, O has more points
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          round = playToWin(match.currentRound!, PlayerMark.o);
          match = matchEngine.completeRound(match, round);

          expect(match.playerXScore, 0);
          expect(match.playerOScore, 1);
          expect(match.isMatchOver, true);
          expect(match.result, isA<MatchResultPlayerOWins>());
          expect(match.completedRounds.length, 3);
          expect(match.currentRoundNumber, 3);
        },
      );

      test(
        '[P0] UNIT-ME-031: should end with X win when X leads 1-0 after 3 rounds (draw-win-draw)',
        () {
          var match = matchEngine.createMatch(config);

          // Round 1: Draw (0-0)
          var round = playToDraw(match.currentRound!);
          match = matchEngine.completeRound(match, round);

          // Round 2: X wins (1-0)
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          round = playToWin(match.currentRound!, PlayerMark.x);
          match = matchEngine.completeRound(match, round);
          expect(match.isMatchOver, false);

          // Round 3: Draw - still 1-0, maxRounds reached
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          round = playToDraw(match.currentRound!);
          match = matchEngine.completeRound(match, round);

          expect(match.playerXScore, 1);
          expect(match.playerOScore, 0);
          expect(match.isMatchOver, true);
          expect(match.result, isA<MatchResultPlayerXWins>());
        },
      );

      test(
        '[P0] UNIT-ME-032: should end with O win when O leads 1-0 after 3 rounds (draw-win-draw)',
        () {
          var match = matchEngine.createMatch(config);

          // Round 1: Draw (0-0)
          var round = playToDraw(match.currentRound!);
          match = matchEngine.completeRound(match, round);

          // Round 2: O wins (0-1)
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          round = playToWin(match.currentRound!, PlayerMark.o);
          match = matchEngine.completeRound(match, round);
          expect(match.isMatchOver, false);

          // Round 3: Draw - still 0-1, maxRounds reached
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          round = playToDraw(match.currentRound!);
          match = matchEngine.completeRound(match, round);

          expect(match.playerXScore, 0);
          expect(match.playerOScore, 1);
          expect(match.isMatchOver, true);
          expect(match.result, isA<MatchResultPlayerOWins>());
        },
      );

      test(
        '[P0] UNIT-ME-033: should end with X win when X wins first round then 2 draws',
        () {
          var match = matchEngine.createMatch(config);

          // Round 1: X wins (1-0)
          var round = playToWin(match.currentRound!, PlayerMark.x);
          match = matchEngine.completeRound(match, round);

          // Round 2: Draw (1-0)
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          round = playToDraw(match.currentRound!);
          match = matchEngine.completeRound(match, round);
          expect(match.isMatchOver, false);

          // Round 3: Draw - still 1-0, maxRounds reached
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          round = playToDraw(match.currentRound!);
          match = matchEngine.completeRound(match, round);

          expect(match.playerXScore, 1);
          expect(match.playerOScore, 0);
          expect(match.isMatchOver, true);
          expect(match.result, isA<MatchResultPlayerXWins>());
        },
      );

      test(
        '[P1] UNIT-ME-034: should not allow round 4 after maxRounds in BO3',
        () {
          var match = matchEngine.createMatch(config);

          // Play 3 rounds (all draws)
          for (var i = 0; i < 3; i++) {
            if (i > 0) {
              match =
                  (matchEngine.startNextRound(match) as MatchEngineSuccess)
                      .newState;
            }
            final round = playToDraw(match.currentRound!);
            match = matchEngine.completeRound(match, round);
          }

          expect(match.isMatchOver, true);

          // Try to start round 4 - should fail
          final result = matchEngine.startNextRound(match);
          expect(result, isA<MatchEngineFailure>());
          final failure = result as MatchEngineFailure;
          expect(failure.error, isA<MatchEngineErrorMatchAlreadyOver>());
        },
      );

      test('[P1] UNIT-ME-035: should not give points on draw', () {
        var match = matchEngine.createMatch(config);

        final round = playToDraw(match.currentRound!);
        match = matchEngine.completeRound(match, round);

        expect(match.playerXScore, 0);
        expect(match.playerOScore, 0);
      });
    });

    group('BO5 scenarios', () {
      late GameConfig bo5Config;

      setUp(() {
        bo5Config = config.copyWith(bestOf: BestOf.bo5);
      });

      test('[P0] UNIT-ME-036: should end match with X winning 3-0', () {
        var match = matchEngine.createMatch(bo5Config);

        // X wins 3 rounds
        for (var i = 0; i < 3; i++) {
          if (i > 0) {
            match =
                (matchEngine.startNextRound(match) as MatchEngineSuccess)
                    .newState;
          }
          final round = playToWin(match.currentRound!, PlayerMark.x);
          match = matchEngine.completeRound(match, round);
        }

        expect(match.isMatchOver, true);
        expect(match.result, isA<MatchResultPlayerXWins>());
        expect(match.playerXScore, 3);
        expect(match.playerOScore, 0);
        expect(match.completedRounds.length, 3);
      });

      test('[P0] UNIT-ME-037: should end match with O winning 3-0', () {
        var match = matchEngine.createMatch(bo5Config);

        // O wins 3 rounds
        for (var i = 0; i < 3; i++) {
          if (i > 0) {
            match =
                (matchEngine.startNextRound(match) as MatchEngineSuccess)
                    .newState;
          }
          final round = playToWin(match.currentRound!, PlayerMark.o);
          match = matchEngine.completeRound(match, round);
        }

        expect(match.isMatchOver, true);
        expect(match.result, isA<MatchResultPlayerOWins>());
        expect(match.playerXScore, 0);
        expect(match.playerOScore, 3);
        expect(match.completedRounds.length, 3);
      });

      test('[P0] UNIT-ME-038: should end match with X winning 3-1', () {
        var match = matchEngine.createMatch(bo5Config);

        // X wins round 1
        var round = playToWin(match.currentRound!, PlayerMark.x);
        match = matchEngine.completeRound(match, round);

        // O wins round 2
        match =
            (matchEngine.startNextRound(match) as MatchEngineSuccess).newState;
        round = playToWin(match.currentRound!, PlayerMark.o);
        match = matchEngine.completeRound(match, round);

        // X wins round 3
        match =
            (matchEngine.startNextRound(match) as MatchEngineSuccess).newState;
        round = playToWin(match.currentRound!, PlayerMark.x);
        match = matchEngine.completeRound(match, round);

        // X wins round 4
        match =
            (matchEngine.startNextRound(match) as MatchEngineSuccess).newState;
        round = playToWin(match.currentRound!, PlayerMark.x);
        match = matchEngine.completeRound(match, round);

        expect(match.isMatchOver, true);
        expect(match.result, isA<MatchResultPlayerXWins>());
        expect(match.playerXScore, 3);
        expect(match.playerOScore, 1);
        expect(match.completedRounds.length, 4);
      });

      test('[P0] UNIT-ME-039: should end match with O winning 3-2', () {
        var match = matchEngine.createMatch(bo5Config);

        // X wins rounds 1, 2
        for (var i = 0; i < 2; i++) {
          if (i > 0) {
            match =
                (matchEngine.startNextRound(match) as MatchEngineSuccess)
                    .newState;
          }
          final round = playToWin(match.currentRound!, PlayerMark.x);
          match = matchEngine.completeRound(match, round);
        }

        // O wins rounds 3, 4, 5
        for (var i = 0; i < 3; i++) {
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          final round = playToWin(match.currentRound!, PlayerMark.o);
          match = matchEngine.completeRound(match, round);
        }

        expect(match.isMatchOver, true);
        expect(match.result, isA<MatchResultPlayerOWins>());
        expect(match.playerXScore, 2);
        expect(match.playerOScore, 3);
        expect(match.completedRounds.length, 5);
      });

      test(
        '[P0] UNIT-ME-040: should end in match draw with 2-2 after 5 rounds (draw in round 5)',
        () {
          var match = matchEngine.createMatch(bo5Config);

          // X wins rounds 1, 2
          for (var i = 0; i < 2; i++) {
            if (i > 0) {
              match =
                  (matchEngine.startNextRound(match) as MatchEngineSuccess)
                      .newState;
            }
            final round = playToWin(match.currentRound!, PlayerMark.x);
            match = matchEngine.completeRound(match, round);
          }

          // O wins rounds 3, 4
          for (var i = 0; i < 2; i++) {
            match =
                (matchEngine.startNextRound(match) as MatchEngineSuccess)
                    .newState;
            final round = playToWin(match.currentRound!, PlayerMark.o);
            match = matchEngine.completeRound(match, round);
          }

          // Round 5: Draw - 2-2 after maxRounds
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          final round = playToDraw(match.currentRound!);
          match = matchEngine.completeRound(match, round);

          expect(match.playerXScore, 2);
          expect(match.playerOScore, 2);
          expect(match.isMatchOver, true);
          expect(match.result, isA<MatchResultDraw>());
          expect(match.completedRounds.length, 5);
        },
      );

      test('[P0] UNIT-ME-041: should end in match draw after 5 draws', () {
        var match = matchEngine.createMatch(bo5Config);

        // All 5 rounds are draws
        for (var i = 0; i < 5; i++) {
          if (i > 0) {
            match =
                (matchEngine.startNextRound(match) as MatchEngineSuccess)
                    .newState;
          }
          final round = playToDraw(match.currentRound!);
          match = matchEngine.completeRound(match, round);
        }

        expect(match.playerXScore, 0);
        expect(match.playerOScore, 0);
        expect(match.isMatchOver, true);
        expect(match.result, isA<MatchResultDraw>());
        expect(match.completedRounds.length, 5);
      });

      test(
        '[P0] UNIT-ME-042: should end with X win when X leads 1-0 after 5 rounds (4 draws + 1 win)',
        () {
          var match = matchEngine.createMatch(bo5Config);

          // Rounds 1-4: Draws (0-0)
          for (var i = 0; i < 4; i++) {
            if (i > 0) {
              match =
                  (matchEngine.startNextRound(match) as MatchEngineSuccess)
                      .newState;
            }
            final round = playToDraw(match.currentRound!);
            match = matchEngine.completeRound(match, round);
            expect(match.isMatchOver, false);
          }

          // Round 5: X wins (1-0) - maxRounds reached
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          final round = playToWin(match.currentRound!, PlayerMark.x);
          match = matchEngine.completeRound(match, round);

          expect(match.playerXScore, 1);
          expect(match.playerOScore, 0);
          expect(match.isMatchOver, true);
          expect(match.result, isA<MatchResultPlayerXWins>());
          expect(match.completedRounds.length, 5);
        },
      );

      test(
        '[P0] UNIT-ME-043: should end with O win when O leads 1-0 after 5 rounds (4 draws + 1 win)',
        () {
          var match = matchEngine.createMatch(bo5Config);

          // Rounds 1-4: Draws (0-0)
          for (var i = 0; i < 4; i++) {
            if (i > 0) {
              match =
                  (matchEngine.startNextRound(match) as MatchEngineSuccess)
                      .newState;
            }
            final round = playToDraw(match.currentRound!);
            match = matchEngine.completeRound(match, round);
          }

          // Round 5: O wins (0-1) - maxRounds reached
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          final round = playToWin(match.currentRound!, PlayerMark.o);
          match = matchEngine.completeRound(match, round);

          expect(match.playerXScore, 0);
          expect(match.playerOScore, 1);
          expect(match.isMatchOver, true);
          expect(match.result, isA<MatchResultPlayerOWins>());
          expect(match.completedRounds.length, 5);
        },
      );

      test(
        '[P0] UNIT-ME-044: should end with X win when X leads 2-1 after 5 rounds (2 draws)',
        () {
          var match = matchEngine.createMatch(bo5Config);

          // Round 1: X wins (1-0)
          var round = playToWin(match.currentRound!, PlayerMark.x);
          match = matchEngine.completeRound(match, round);

          // Round 2: O wins (1-1)
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          round = playToWin(match.currentRound!, PlayerMark.o);
          match = matchEngine.completeRound(match, round);

          // Round 3: Draw (1-1)
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          round = playToDraw(match.currentRound!);
          match = matchEngine.completeRound(match, round);

          // Round 4: X wins (2-1)
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          round = playToWin(match.currentRound!, PlayerMark.x);
          match = matchEngine.completeRound(match, round);
          expect(match.isMatchOver, false);

          // Round 5: Draw (2-1) - maxRounds reached, X has more
          match =
              (matchEngine.startNextRound(match) as MatchEngineSuccess)
                  .newState;
          round = playToDraw(match.currentRound!);
          match = matchEngine.completeRound(match, round);

          expect(match.playerXScore, 2);
          expect(match.playerOScore, 1);
          expect(match.isMatchOver, true);
          expect(match.result, isA<MatchResultPlayerXWins>());
          expect(match.completedRounds.length, 5);
        },
      );

      test(
        '[P1] UNIT-ME-045: should not allow round 6 after maxRounds in BO5',
        () {
          var match = matchEngine.createMatch(bo5Config);

          // Play 5 rounds (all draws)
          for (var i = 0; i < 5; i++) {
            if (i > 0) {
              match =
                  (matchEngine.startNextRound(match) as MatchEngineSuccess)
                      .newState;
            }
            final round = playToDraw(match.currentRound!);
            match = matchEngine.completeRound(match, round);
          }

          expect(match.isMatchOver, true);
          expect(match.currentRoundNumber, 5);

          // Try to start round 6 - should fail
          final result = matchEngine.startNextRound(match);
          expect(result, isA<MatchEngineFailure>());
          final failure = result as MatchEngineFailure;
          expect(failure.error, isA<MatchEngineErrorMatchAlreadyOver>());
        },
      );
    });
  });
}
