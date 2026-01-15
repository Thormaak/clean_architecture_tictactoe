import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/rules/rules.dart';

void main() {
  late GameEngine engine;
  late GameConfig config;
  late Player playerX;
  late Player playerO;

  setUp(() {
    engine = GameEngineImpl();
    playerX = const Player(id: 'x', name: 'Player X', mark: PlayerMark.x);
    playerO = const Player(id: 'o', name: 'Player O', mark: PlayerMark.o);
    config = GameConfig(
      mode: const GameMode.local(),
      playerX: playerX,
      playerO: playerO,
      bestOf: BestOf.bo3,
    );
  });

  MatchState createMatchState({
    List<GameState> completedRounds = const [],
    GameState? currentRound,
    int playerXScore = 0,
    int playerOScore = 0,
    int currentRoundNumber = 1,
    MatchResult result = const MatchResult.ongoing(),
  }) {
    return MatchState(
      matchId: 'test-match',
      config: config,
      completedRounds: completedRounds,
      currentRound: currentRound ?? engine.createGame(config),
      playerXScore: playerXScore,
      playerOScore: playerOScore,
      currentRoundNumber: currentRoundNumber,
      result: result,
      startedAt: DateTime.now(),
    );
  }

  GameState createCompletedRound(GameResult result) {
    final game = engine.createGame(config);
    return game.copyWith(result: result, endedAt: DateTime.now());
  }

  group('MatchState - UNIT-MS', () {
    group('bestOf', () {
      test('[P1] UNIT-MS-001: should return config bestOf value', () {
        final match = createMatchState();
        expect(match.bestOf, BestOf.bo3);
      });
    });

    group('roundsToWin', () {
      test('[P1] UNIT-MS-002: should return 2 for BO3', () {
        final match = createMatchState();
        expect(match.roundsToWin, 2);
      });
    });

    group('maxRounds', () {
      test('[P1] UNIT-MS-003: should return 3 for BO3', () {
        final match = createMatchState();
        expect(match.maxRounds, 3);
      });
    });

    group('isMatchOver', () {
      test('[P1] UNIT-MS-004: should return false when result is ongoing', () {
        final match = createMatchState();
        expect(match.isMatchOver, false);
      });

      test(
        '[P1] UNIT-MS-005: should return true when result is playerXWins',
        () {
          final match = createMatchState(
            result: const MatchResult.playerXWins(),
          );
          expect(match.isMatchOver, true);
        },
      );

      test(
        '[P1] UNIT-MS-006: should return true when result is playerOWins',
        () {
          final match = createMatchState(
            result: const MatchResult.playerOWins(),
          );
          expect(match.isMatchOver, true);
        },
      );
    });

    group('isRoundOver', () {
      test(
        '[P1] UNIT-MS-007: should return false when current round is ongoing',
        () {
          final match = createMatchState();
          expect(match.isRoundOver, false);
        },
      );

      test(
        '[P1] UNIT-MS-008: should return true when current round has ended',
        () {
          final completedRound = createCompletedRound(
            const GameResult.win(
              winner: PlayerMark.x,
              winningLine: WinningLine(
                positions: [
                  Position(row: 0, col: 0),
                  Position(row: 0, col: 1),
                  Position(row: 0, col: 2),
                ],
                type: WinningLineType.horizontal,
              ),
            ),
          );
          final match = createMatchState(currentRound: completedRound);
          expect(match.isRoundOver, true);
        },
      );

      test(
        '[P1] UNIT-MS-009: should return false when current round is null',
        () {
          final match = createMatchState(currentRound: null);
          expect(match.isRoundOver, false);
        },
      );
    });

    group('awaitingNextRound', () {
      test(
        '[P1] UNIT-MS-010: should return true when round over but match not over',
        () {
          final completedRound = createCompletedRound(
            const GameResult.win(
              winner: PlayerMark.x,
              winningLine: WinningLine(
                positions: [
                  Position(row: 0, col: 0),
                  Position(row: 0, col: 1),
                  Position(row: 0, col: 2),
                ],
                type: WinningLineType.horizontal,
              ),
            ),
          );
          final match = createMatchState(
            currentRound: completedRound,
            playerXScore: 1,
          );
          expect(match.awaitingNextRound, true);
        },
      );

      test('[P1] UNIT-MS-011: should return false when match is over', () {
        final completedRound = createCompletedRound(
          const GameResult.win(
            winner: PlayerMark.x,
            winningLine: WinningLine(
              positions: [
                Position(row: 0, col: 0),
                Position(row: 0, col: 1),
                Position(row: 0, col: 2),
              ],
              type: WinningLineType.horizontal,
            ),
          ),
        );
        final match = createMatchState(
          currentRound: completedRound,
          playerXScore: 2,
          result: const MatchResult.playerXWins(),
        );
        expect(match.awaitingNextRound, false);
      });

      test('[P1] UNIT-MS-012: should return false when round is not over', () {
        final match = createMatchState();
        expect(match.awaitingNextRound, false);
      });
    });

    group('isSingleGame', () {
      test('[P1] UNIT-MS-013: should return false for BO3', () {
        final match = createMatchState();
        expect(match.isSingleGame, false);
      });

      test('[P1] UNIT-MS-014: should return true for BO1', () {
        final bo1Config = config.copyWith(bestOf: BestOf.bo1);
        final match = MatchState(
          matchId: 'test',
          config: bo1Config,
          completedRounds: const [],
          currentRound: engine.createGame(bo1Config),
          playerXScore: 0,
          playerOScore: 0,
          currentRoundNumber: 1,
          result: const MatchResult.ongoing(),
          startedAt: DateTime.now(),
        );
        expect(match.isSingleGame, true);
      });
    });

    group('nextRoundStartingPlayer', () {
      test(
        '[P1] UNIT-MS-015: should return config starting player when no completed rounds',
        () {
          final match = createMatchState();
          expect(match.nextRoundStartingPlayer, PlayerMark.x);
        },
      );

      test('[P1] UNIT-MS-016: should return O when X won last round', () {
        final completedRound = createCompletedRound(
          const GameResult.win(
            winner: PlayerMark.x,
            winningLine: WinningLine(
              positions: [
                Position(row: 0, col: 0),
                Position(row: 0, col: 1),
                Position(row: 0, col: 2),
              ],
              type: WinningLineType.horizontal,
            ),
          ),
        );
        final match = createMatchState(
          completedRounds: [completedRound],
          playerXScore: 1,
        );
        expect(match.nextRoundStartingPlayer, PlayerMark.o);
      });

      test('[P1] UNIT-MS-017: should return X when O won last round', () {
        final completedRound = createCompletedRound(
          const GameResult.win(
            winner: PlayerMark.o,
            winningLine: WinningLine(
              positions: [
                Position(row: 0, col: 0),
                Position(row: 0, col: 1),
                Position(row: 0, col: 2),
              ],
              type: WinningLineType.horizontal,
            ),
          ),
        );
        final match = createMatchState(
          completedRounds: [completedRound],
          playerOScore: 1,
        );
        expect(match.nextRoundStartingPlayer, PlayerMark.x);
      });

      test('[P1] UNIT-MS-018: should alternate on draw', () {
        final completedRound = createCompletedRound(const GameResult.draw());
        final match = createMatchState(completedRounds: [completedRound]);
        expect(match.nextRoundStartingPlayer, PlayerMark.o);
      });
    });
  });
}
