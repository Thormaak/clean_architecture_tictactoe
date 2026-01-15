/// Test data factories for game-related entities
///
/// Provides consistent test data across the test suite.
/// Use these factories instead of hardcoded values to:
/// - Maintain single source of truth
/// - Facilitate business rule changes
/// - Improve test readability
library;

import 'package:tictactoe/features/rules/rules.dart';

/// Centralized test data factory for game entities
class GameFixtures {
  // === Player Names ===
  static const defaultPlayer1Name = 'Player 1';
  static const defaultPlayer2Name = 'Player 2';
  static const defaultHumanName = 'You';
  static const defaultAIName = 'AI';

  // Sample names for custom scenarios
  static const sampleNameAlice = 'Alice';
  static const sampleNameBob = 'Bob';

  // === Game Factories ===

  /// Creates a default local game (2 human players)
  static GameState createDefaultLocalGame({
    GameEngine? engine,
    PlayerMark startingPlayer = PlayerMark.x,
  }) {
    final factory = GameFactory(engine ?? GameEngineImpl());
    return factory.createLocalGame(
      player1Name: defaultPlayer1Name,
      player2Name: defaultPlayer2Name,
      startingPlayer: startingPlayer,
    );
  }

  /// Creates a custom local game with overrides
  static GameState createLocalGame({
    GameEngine? engine,
    String? player1Name,
    String? player2Name,
    PlayerMark startingPlayer = PlayerMark.x,
  }) {
    final factory = GameFactory(engine ?? GameEngineImpl());
    return factory.createLocalGame(
      player1Name: player1Name ?? defaultPlayer1Name,
      player2Name: player2Name ?? defaultPlayer2Name,
      startingPlayer: startingPlayer,
    );
  }

  /// Creates a default AI game (human vs AI)
  static GameState createDefaultAIGame({
    GameEngine? engine,
    AIDifficulty difficulty = AIDifficulty.medium,
    PlayerMark playerMark = PlayerMark.x,
  }) {
    final factory = GameFactory(engine ?? GameEngineImpl());
    return factory.createAIGame(
      playerName: defaultHumanName,
      aiName: defaultAIName,
      playerMark: playerMark,
      difficulty: difficulty,
    );
  }

  /// Creates a custom AI game with overrides
  static GameState createAIGame({
    GameEngine? engine,
    String? playerName,
    String? aiName,
    PlayerMark playerMark = PlayerMark.x,
    AIDifficulty difficulty = AIDifficulty.medium,
  }) {
    final factory = GameFactory(engine ?? GameEngineImpl());
    return factory.createAIGame(
      playerName: playerName ?? defaultHumanName,
      aiName: aiName ?? defaultAIName,
      playerMark: playerMark,
      difficulty: difficulty,
    );
  }

  // === Board Factories ===

  /// Creates a board from move sequences
  ///
  /// Example:
  /// ```dart
  /// final board = GameFixtures.createBoardWithMoves(
  ///   xMoves: [0, 1, 2], // X wins row 0
  ///   oMoves: [3, 4],
  /// );
  /// ```
  static Board createBoardWithMoves({
    List<int> xMoves = const [],
    List<int> oMoves = const [],
  }) {
    var board = Board.empty();
    for (final index in xMoves) {
      board = board.withMove(Position.fromIndex(index), PlayerMark.x);
    }
    for (final index in oMoves) {
      board = board.withMove(Position.fromIndex(index), PlayerMark.o);
    }
    return board;
  }

  /// Creates a board from position sequences
  static Board createBoardWithPositions({
    List<Position> xPositions = const [],
    List<Position> oPositions = const [],
  }) {
    var board = Board.empty();
    for (final pos in xPositions) {
      board = board.withMove(pos, PlayerMark.x);
    }
    for (final pos in oPositions) {
      board = board.withMove(pos, PlayerMark.o);
    }
    return board;
  }

  // === Common Board Scenarios ===

  /// Board with X winning on row 0
  /// ```
  /// X X X
  /// O O .
  /// . . .
  /// ```
  static Board boardXWinsRow0() =>
      createBoardWithMoves(xMoves: [0, 1, 2], oMoves: [3, 4]);

  /// Board with O winning on main diagonal
  /// ```
  /// O X .
  /// X O .
  /// . . O
  /// ```
  static Board boardOWinsDiagonal() =>
      createBoardWithMoves(xMoves: [1, 3], oMoves: [0, 4, 8]);

  /// Board resulting in draw
  /// ```
  /// X O X
  /// X O O
  /// O X X
  /// ```
  static Board boardDraw() =>
      createBoardWithMoves(xMoves: [0, 2, 3, 7, 8], oMoves: [1, 4, 5, 6]);

  /// Nearly full board with 2 empty cells
  static Board boardNearlyFull() =>
      createBoardWithMoves(xMoves: [0, 2, 3, 6], oMoves: [1, 4, 5]);

  // === Player Factories ===

  /// Creates a default player X
  static Player createPlayerX({String? name}) => Player(
    id: 'player-x',
    name: name ?? defaultPlayer1Name,
    mark: PlayerMark.x,
  );

  /// Creates a default player O
  static Player createPlayerO({String? name}) => Player(
    id: 'player-o',
    name: name ?? defaultPlayer2Name,
    mark: PlayerMark.o,
  );

  // === GameState Factory ===

  /// Creates a custom GameState with overrides
  static GameState createGameState({
    String? gameId,
    GameConfig? config,
    Board? board,
    PlayerMark? currentTurn,
    List<Move>? moveHistory,
    GameResult? result,
    DateTime? startedAt,
  }) {
    return GameState(
      gameId: gameId ?? 'test-game',
      config:
          config ??
          GameConfig(
            mode: const GameMode.local(),
            playerX: createPlayerX(),
            playerO: createPlayerO(),
          ),
      board: board ?? Board.empty(),
      currentTurn: currentTurn ?? PlayerMark.x,
      moveHistory: moveHistory ?? const [],
      result: result ?? const GameResult.ongoing(),
      startedAt: startedAt ?? DateTime.now(),
    );
  }

  // === Win Result Helpers ===

  /// Creates a winning line for a specific pattern
  ///
  /// Patterns:
  /// - horizontal: row 0, 1, or 2
  /// - vertical: col 0, 1, or 2
  /// - diagonal: main diagonal (top-left to bottom-right)
  /// - antiDiagonal: anti-diagonal (top-right to bottom-left)
  static WinningLine createWinningLine({
    required WinningLineType type,
    int index = 0, // row for horizontal, col for vertical
  }) {
    switch (type) {
      case WinningLineType.horizontal:
        final row = index;
        return WinningLine(
          positions: [
            Position(row: row, col: 0),
            Position(row: row, col: 1),
            Position(row: row, col: 2),
          ],
          type: WinningLineType.horizontal,
        );
      case WinningLineType.vertical:
        final col = index;
        return WinningLine(
          positions: [
            Position(row: 0, col: col),
            Position(row: 1, col: col),
            Position(row: 2, col: col),
          ],
          type: WinningLineType.vertical,
        );
      case WinningLineType.diagonal:
        return WinningLine(
          positions: [
            Position(row: 0, col: 0),
            Position(row: 1, col: 1),
            Position(row: 2, col: 2),
          ],
          type: WinningLineType.diagonal,
        );
      case WinningLineType.antiDiagonal:
        return WinningLine(
          positions: [
            Position(row: 0, col: 2),
            Position(row: 1, col: 1),
            Position(row: 2, col: 0),
          ],
          type: WinningLineType.antiDiagonal,
        );
    }
  }

  /// Creates a win result for a specific player and winning line type
  ///
  /// Example:
  /// ```dart
  /// final result = GameFixtures.createWinResult(
  ///   winner: PlayerMark.x,
  ///   type: WinningLineType.horizontal,
  ///   index: 0, // row 0
  /// );
  /// ```
  static GameResult createWinResult({
    required PlayerMark winner,
    required WinningLineType type,
    int index = 0,
  }) {
    return GameResult.win(
      winner: winner,
      winningLine: createWinningLine(type: type, index: index),
    );
  }

  /// Creates a GameState with a win result
  ///
  /// Example:
  /// ```dart
  /// final gameState = GameFixtures.createGameStateWithWin(
  ///   winner: PlayerMark.x,
  ///   type: WinningLineType.horizontal,
  ///   index: 0,
  /// );
  /// ```
  static GameState createGameStateWithWin({
    required PlayerMark winner,
    required WinningLineType type,
    int index = 0,
    Board? board,
    String? gameId,
    GameConfig? config,
    PlayerMark? currentTurn,
    List<Move>? moveHistory,
    DateTime? startedAt,
  }) {
    return createGameState(
      gameId: gameId,
      config: config,
      board: board,
      currentTurn: currentTurn,
      moveHistory: moveHistory,
      result: createWinResult(winner: winner, type: type, index: index),
      startedAt: startedAt,
    );
  }

  // === MatchState Factory ===

  /// Creates a default MatchState with minimal configuration
  static MatchState createDefaultMatchState({
    String? matchId,
    GameConfig? config,
    List<GameState>? completedRounds,
    GameState? currentRound,
    int playerXScore = 0,
    int playerOScore = 0,
    int currentRoundNumber = 1,
    MatchResult? result,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return MatchState(
      matchId: matchId ?? 'test-match',
      config:
          config ??
          GameConfig(
            mode: const GameMode.local(),
            playerX: createPlayerX(),
            playerO: createPlayerO(),
          ),
      completedRounds: completedRounds ?? const [],
      currentRound: currentRound,
      playerXScore: playerXScore,
      playerOScore: playerOScore,
      currentRoundNumber: currentRoundNumber,
      result: result ?? const MatchResult.ongoing(),
      startedAt: startedAt ?? DateTime.now(),
      endedAt: endedAt,
    );
  }

  // === Helper for Move Sequences ===

  /// Plays a sequence of moves and returns final state
  ///
  /// Useful for setting up complex game scenarios.
  ///
  /// Example:
  /// ```dart
  /// final game = GameFixtures.playMoveSequence(
  ///   engine,
  ///   initialGame,
  ///   [Position(row: 0, col: 0), Position(row: 1, col: 0)],
  /// );
  /// ```
  static GameState playMoveSequence(
    GameEngine engine,
    GameState initialState,
    List<Position> moves,
  ) {
    var game = initialState;
    for (final move in moves) {
      final result = engine.playMove(game, move);
      if (result is GameEngineSuccess) {
        game = result.newState;
      } else {
        throw StateError('Failed to play move at $move');
      }
    }
    return game;
  }
}
