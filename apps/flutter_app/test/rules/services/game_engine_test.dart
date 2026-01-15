import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/features/rules/rules.dart';
import '../../fixtures/game_fixtures.dart';

void main() {
  late GameEngine engine;

  setUp(() {
    engine = GameEngineImpl();
  });

  /// Helper: Plays a sequence of moves and returns final state
  /// Throws if any move fails
  GameState playMoveSequence(GameState game, List<Position> moves) {
    var currentGame = game;
    for (final move in moves) {
      final result = engine.playMove(currentGame, move);
      expect(
        result,
        isA<GameEngineSuccess>(),
        reason: 'Move at $move should succeed',
      );
      currentGame = (result as GameEngineSuccess).newState;
    }
    return currentGame;
  }

  group('GameEngine - UNIT-GE', () {
    group('createGame', () {
      test('[P1] UNIT-GE-001: should create game with empty board', () {
        // Arrange
        // (factory already set up in setUp)

        // Act
        final game = GameFixtures.createDefaultLocalGame(engine: engine);

        // Assert
        expect(game.board.emptyPositions.length, 9);
        expect(game.moveHistory.isEmpty, true);
        expect(game.result, isA<GameResultOngoing>());
      });

      test('[P2] UNIT-GE-002: should set starting player correctly', () {
        // Arrange
        const startingPlayer = PlayerMark.o;

        // Act
        final game = GameFixtures.createDefaultLocalGame(
          engine: engine,
          startingPlayer: startingPlayer,
        );

        // Assert
        expect(game.currentTurn, PlayerMark.o);
      });

      test('[P2] UNIT-GE-003: should configure players correctly', () {
        // Arrange
        const player1 = GameFixtures.sampleNameAlice;
        const player2 = GameFixtures.sampleNameBob;

        // Act
        final game = GameFixtures.createLocalGame(
          engine: engine,
          player1Name: player1,
          player2Name: player2,
        );

        // Assert
        expect(game.config.playerX.name, player1);
        expect(game.config.playerO.name, player2);
      });
    });

    group('playMove', () {
      test('[P1] UNIT-GE-004: should update board with move', () {
        // Arrange
        var game = GameFixtures.createDefaultLocalGame(engine: engine);
        final pos = const Position(row: 1, col: 1);

        // Act
        final result = engine.playMove(game, pos);

        // Assert
        expect(result, isA<GameEngineSuccess>());
        final success = result as GameEngineSuccess;
        expect(success.newState.board.getCell(pos).mark, PlayerMark.x);
      });

      test('[P1] UNIT-GE-005: should switch turns after move', () {
        // Arrange
        var game = GameFixtures.createDefaultLocalGame(engine: engine);

        // Act
        final result = engine.playMove(game, const Position(row: 0, col: 0));

        // Assert
        expect(result, isA<GameEngineSuccess>());
        final success = result as GameEngineSuccess;
        expect(success.newState.currentTurn, PlayerMark.o);
      });

      test('[P2] UNIT-GE-006: should add move to history', () {
        // Arrange
        var game = GameFixtures.createDefaultLocalGame(engine: engine);
        const position = Position(row: 0, col: 0);

        // Act
        final result = engine.playMove(game, position);

        // Assert
        expect(result, isA<GameEngineSuccess>());
        final success = result as GameEngineSuccess;
        expect(success.newState.moveHistory.length, 1);
        expect(success.newState.moveHistory.first.position, position);
      });

      test('[P0] UNIT-GE-007: should reject move on occupied cell', () {
        // Arrange
        var game = GameFixtures.createDefaultLocalGame(engine: engine);
        final pos = const Position(row: 0, col: 0);

        final result1 = engine.playMove(game, pos);
        game = (result1 as GameEngineSuccess).newState;

        // Act
        final result2 = engine.playMove(game, pos);

        // Assert
        expect(result2, isA<GameEngineFailure>());
        final failure = result2 as GameEngineFailure;
        expect(failure.error, isA<GameEngineErrorInvalidMove>());
      });

      test('[P0] UNIT-GE-008: should detect win', () {
        // Arrange
        var game = GameFixtures.createDefaultLocalGame(engine: engine);

        // X plays (0,0), (0,1), (0,2) - horizontal win
        // O plays (1,0), (1,1)
        final moves = [
          const Position(row: 0, col: 0), // X
          const Position(row: 1, col: 0), // O
          const Position(row: 0, col: 1), // X
          const Position(row: 1, col: 1), // O
        ];
        game = playMoveSequence(game, moves);

        // Act
        final result = engine.playMove(game, const Position(row: 0, col: 2));

        // Assert
        expect(result, isA<GameEngineSuccess>());
        final success = result as GameEngineSuccess;
        expect(success.newState.result, isA<GameResultWin>());
        final win = success.newState.result as GameResultWin;
        expect(win.winner, PlayerMark.x);
      });

      test('[P0] UNIT-GE-009: should reject move after game over', () {
        // Arrange
        var game = GameFixtures.createDefaultLocalGame(engine: engine);

        // Play to win
        final winningMoves = [
          const Position(row: 0, col: 0), // X
          const Position(row: 1, col: 0), // O
          const Position(row: 0, col: 1), // X
          const Position(row: 1, col: 1), // O
          const Position(row: 0, col: 2), // X wins
        ];
        game = playMoveSequence(game, winningMoves);

        // Act - Try to play after win
        final result = engine.playMove(game, const Position(row: 2, col: 0));

        // Assert
        expect(result, isA<GameEngineFailure>());
      });

      test('[P0] UNIT-GE-010: should detect draw', () {
        // Arrange
        var game = GameFixtures.createDefaultLocalGame(engine: engine);

        // Play to draw:
        // X O X
        // X O O
        // O X X
        final moves = [
          const Position(row: 0, col: 0), // X
          const Position(row: 0, col: 1), // O
          const Position(row: 0, col: 2), // X
          const Position(row: 1, col: 1), // O
          const Position(row: 1, col: 0), // X
          const Position(row: 2, col: 0), // O
          const Position(row: 1, col: 2), // X
          const Position(row: 2, col: 2), // O
        ];

        // Act - Play all moves up to last one
        game = playMoveSequence(game, moves);
        final lastMove = const Position(row: 2, col: 1); // X - draw
        final result = engine.playMove(game, lastMove);

        // Assert
        expect(result, isA<GameEngineSuccess>());
        final finalGame = (result as GameEngineSuccess).newState;
        expect(finalGame.result, isA<GameResultDraw>());
      });
    });
  });

  group('GameFactory - UNIT-GF', () {
    test(
      '[P1] UNIT-GF-001: createLocalGame should create valid local game',
      () {
        // Arrange
        // (factory already set up)

        // Act
        final game = GameFixtures.createDefaultLocalGame(engine: engine);

        // Assert
        expect(game.config.mode, isA<GameModeLocal>());
        expect(game.config.playerX.name, GameFixtures.defaultPlayer1Name);
        expect(game.config.playerO.name, GameFixtures.defaultPlayer2Name);
      },
    );

    test('[P1] UNIT-GF-002: createAIGame should create valid AI game', () {
      // Arrange
      const difficulty = AIDifficulty.hard;
      const playerMark = PlayerMark.x;

      // Act
      final game = GameFixtures.createAIGame(
        engine: engine,
        difficulty: difficulty,
        playerMark: playerMark,
      );

      // Assert
      expect(game.config.mode, isA<GameModeVsAI>());
      final mode = game.config.mode as GameModeVsAI;
      expect(mode.difficulty, difficulty);
      expect(game.config.playerX.name, GameFixtures.defaultHumanName);
      expect(game.config.playerO.name, GameFixtures.defaultAIName);
    });

    test('[P2] UNIT-GF-003: should handle all AI difficulty levels', () {
      // Arrange
      final difficulties = [
        AIDifficulty.easy,
        AIDifficulty.medium,
        AIDifficulty.hard,
      ];

      for (final difficulty in difficulties) {
        // Act
        final game = GameFixtures.createAIGame(
          engine: engine,
          difficulty: difficulty,
        );

        // Assert
        final mode = game.config.mode as GameModeVsAI;
        expect(
          mode.difficulty,
          difficulty,
          reason: 'Difficulty should be $difficulty',
        );
      }
    });
  });
}
