import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe/features/game/application/use_cases/play_move_use_case.dart';
import 'package:tictactoe/features/game/domain/repositories/i_game_repository.dart';
import 'package:tictactoe/features/game/domain/repositories/i_match_repository.dart';
import 'package:tictactoe/features/game/domain/failures/game_failures.dart';
import 'package:tictactoe/features/rules/rules.dart';

import '../../../../fixtures/game_fixtures.dart';

// === MOCKS ===
class MockGameRepository extends Mock implements IGameRepository {}

class MockMatchRepository extends Mock implements IMatchRepository {}

// === FAKES ===
class FakeGameState extends Fake implements GameState {}

class FakePosition extends Fake implements Position {}

class FakeMatchState extends Fake implements MatchState {}

void main() {
  // === SETUP ===
  late PlayMoveUseCase sut;
  late MockGameRepository mockGameRepository;
  late MockMatchRepository mockMatchRepository;

  setUpAll(() {
    registerFallbackValue(FakeGameState());
    registerFallbackValue(FakePosition());
    registerFallbackValue(FakeMatchState());
  });

  setUp(() {
    mockGameRepository = MockGameRepository();
    mockMatchRepository = MockMatchRepository();
    sut = PlayMoveUseCase(mockGameRepository, mockMatchRepository);
  });

  // === TESTS ===
  group('PlayMoveUseCase - UNIT-PMUC', () {
    group('call', () {
      test(
        '[P1] UNIT-PMUC-001: should return error when no active round',
        () async {
          // Arrange
          final matchState = GameFixtures.createDefaultMatchState(
            currentRound: null, // No active round
          );

          final params = PlayMoveParams(
            matchState: matchState,
            position: const Position(row: 0, col: 0),
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold(
            (success) => fail('Expected failure but got success: $success'),
            (failure) {
              expect(failure, isA<PlayMoveFailure>());
              expect(failure, const PlayMoveFailure.noActiveRound());
            },
          );
        },
      );

      test(
        '[P1] UNIT-PMUC-002: should return error when game is over',
        () async {
          // Arrange
          final gameState = GameFixtures.createGameStateWithWin(
            winner: PlayerMark.x,
            type: WinningLineType.horizontal,
            index: 0,
          );
          final matchState = GameFixtures.createDefaultMatchState(
            currentRound: gameState,
          );

          final params = PlayMoveParams(
            matchState: matchState,
            position: const Position(row: 0, col: 0),
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold(
            (success) => fail('Expected failure but got success: $success'),
            (failure) {
              expect(failure, isA<PlayMoveFailure>());
              expect(failure, const PlayMoveFailure.gameOver());
            },
          );
        },
      );

      test(
        '[P0] UNIT-PMUC-003: should play move and return updated match state when valid',
        () async {
          // Arrange
          final gameState = GameFixtures.createGameState();
          final matchState = GameFixtures.createDefaultMatchState(
            currentRound: gameState,
          );

          final newGameState = gameState.copyWith(
            board: gameState.board.withMove(
              const Position(row: 0, col: 0),
              PlayerMark.x,
            ),
          );

          when(
            () => mockGameRepository.playMove(any(), any()),
          ).thenReturn(GameEngineResult.success(newGameState));

          final params = PlayMoveParams(
            matchState: matchState,
            position: const Position(row: 0, col: 0),
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold((success) {
            expect(success.matchState.currentRound, newGameState);
          }, (failure) => fail('Expected success but got failure: $failure'));
          verify(
            () => mockGameRepository.playMove(gameState, params.position),
          ).called(1);
        },
      );

      test(
        '[P0] UNIT-PMUC-004: should complete round when game ends after move',
        () async {
          // Arrange
          final gameState = GameFixtures.createGameState();
          final matchState = GameFixtures.createDefaultMatchState(
            currentRound: gameState,
          );

          final newGameState = gameState.copyWith(
            board: gameState.board.withMove(
              const Position(row: 0, col: 0),
              PlayerMark.x,
            ),
            result: GameFixtures.createWinResult(
              winner: PlayerMark.x,
              type: WinningLineType.horizontal,
              index: 0,
            ),
          );

          final completedMatchState = matchState.copyWith(
            completedRounds: [...matchState.completedRounds, newGameState],
            currentRound: null,
          );

          when(
            () => mockGameRepository.playMove(any(), any()),
          ).thenReturn(GameEngineResult.success(newGameState));
          when(
            () => mockMatchRepository.completeRound(any(), any()),
          ).thenReturn(completedMatchState);

          final params = PlayMoveParams(
            matchState: matchState,
            position: const Position(row: 0, col: 0),
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold((success) {
            expect(success.matchState, completedMatchState);
          }, (failure) => fail('Expected success but got failure: $failure'));
          verify(
            () => mockMatchRepository.completeRound(any(), newGameState),
          ).called(1);
        },
      );

      test(
        '[P1] UNIT-PMUC-005: should return error message when position is occupied',
        () async {
          // Arrange
          final gameState = GameFixtures.createGameState();
          final matchState = GameFixtures.createDefaultMatchState(
            currentRound: gameState,
          );

          when(() => mockGameRepository.playMove(any(), any())).thenReturn(
            GameEngineResult.failure(
              const GameEngineErrorInvalidMove(MoveError.positionOccupied),
            ),
          );

          final params = PlayMoveParams(
            matchState: matchState,
            position: const Position(row: 0, col: 0),
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold(
            (success) => fail('Expected failure but got success: $success'),
            (failure) {
              expect(failure, isA<PlayMoveFailure>());
              expect(failure, const PlayMoveFailure.invalidMove());
            },
          );
        },
      );

      test(
        '[P1] UNIT-PMUC-006: should return error message when not player turn',
        () async {
          // Arrange
          final gameState = GameFixtures.createGameState();
          final matchState = GameFixtures.createDefaultMatchState(
            currentRound: gameState,
          );

          when(() => mockGameRepository.playMove(any(), any())).thenReturn(
            GameEngineResult.failure(
              const GameEngineErrorInvalidMove(MoveError.notYourTurn),
            ),
          );

          final params = PlayMoveParams(
            matchState: matchState,
            position: const Position(row: 0, col: 0),
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold(
            (success) => fail('Expected failure but got success: $success'),
            (failure) {
              expect(failure, isA<PlayMoveFailure>());
              expect(failure, const PlayMoveFailure.invalidMove());
            },
          );
        },
      );
    });
  });
}
