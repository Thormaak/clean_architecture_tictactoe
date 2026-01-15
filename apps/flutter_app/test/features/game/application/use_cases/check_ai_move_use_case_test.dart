import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe/features/game/application/use_cases/check_ai_move_use_case.dart';
import 'package:tictactoe/features/game/domain/failures/game_failures.dart';
import 'package:tictactoe/features/rules/rules.dart';

// === MOCKS ===
class MockGameState extends Mock implements GameState {}

class MockPlayerStrategy extends Mock implements PlayerStrategy {}

// === FAKES ===
class FakeGameState extends Fake implements GameState {}

void main() {
  // === SETUP ===
  late CheckAIMoveUseCase sut;

  setUpAll(() {
    registerFallbackValue(FakeGameState());
  });

  setUp(() {
    sut = CheckAIMoveUseCase();
  });

  // === TESTS ===
  group('CheckAIMoveUseCase - UNIT-CAMUC', () {
    group('call', () {
      test(
        '[P1] UNIT-CAMUC-001: should return empty result when game is over',
        () async {
          // Arrange
          final mockGameState = MockGameState();
          when(() => mockGameState.isGameOver).thenReturn(true);

          final params = CheckAIMoveParams(gameState: mockGameState);

          // Act
          final result = await sut(params);

          // Assert
          result.fold((CheckAIMoveResult success) {
            expect(success.shouldPlay, isFalse);
            expect(success.move, isNull);
          }, (failure) => fail('Expected success but got failure: $failure'));
        },
      );

      test(
        '[P1] UNIT-CAMUC-002: should return empty result when AI is already thinking',
        () async {
          // Arrange
          final mockGameState = MockGameState();
          when(() => mockGameState.isGameOver).thenReturn(false);

          final params = CheckAIMoveParams(
            gameState: mockGameState,
            isAIThinking: true,
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold((CheckAIMoveResult success) {
            expect(success.shouldPlay, isFalse);
            expect(success.move, isNull);
          }, (failure) => fail('Expected success but got failure: $failure'));
        },
      );

      test(
        '[P1] UNIT-CAMUC-003: should return empty result when current player has no strategy',
        () async {
          // Arrange
          final mockGameState = MockGameState();
          when(() => mockGameState.isGameOver).thenReturn(false);
          when(() => mockGameState.currentTurn).thenReturn(PlayerMark.x);

          final params = CheckAIMoveParams(
            gameState: mockGameState,
            strategyX: null,
            strategyO: null,
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold((CheckAIMoveResult success) {
            expect(success.shouldPlay, isFalse);
            expect(success.move, isNull);
          }, (failure) => fail('Expected success but got failure: $failure'));
        },
      );

      test(
        '[P1] UNIT-CAMUC-004: should return empty result when strategy requires external input',
        () async {
          // Arrange
          final mockGameState = MockGameState();
          final mockStrategy = MockPlayerStrategy();
          when(() => mockGameState.isGameOver).thenReturn(false);
          when(() => mockGameState.currentTurn).thenReturn(PlayerMark.x);
          when(() => mockStrategy.requiresExternalInput).thenReturn(true);

          final params = CheckAIMoveParams(
            gameState: mockGameState,
            strategyX: mockStrategy,
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold((CheckAIMoveResult success) {
            expect(success.shouldPlay, isFalse);
            expect(success.move, isNull);
          }, (failure) => fail('Expected success but got failure: $failure'));
        },
      );

      test(
        '[P0] UNIT-CAMUC-005: should return AI move when strategy is available for X',
        () async {
          // Arrange
          final mockGameState = MockGameState();
          final mockStrategy = MockPlayerStrategy();
          const expectedMove = Position(row: 1, col: 1);

          when(() => mockGameState.isGameOver).thenReturn(false);
          when(() => mockGameState.currentTurn).thenReturn(PlayerMark.x);
          when(() => mockStrategy.requiresExternalInput).thenReturn(false);
          when(
            () => mockStrategy.getNextMove(any()),
          ).thenAnswer((_) async => expectedMove);

          final params = CheckAIMoveParams(
            gameState: mockGameState,
            strategyX: mockStrategy,
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold((CheckAIMoveResult success) {
            expect(success.shouldPlay, isTrue);
            expect(success.move, expectedMove);
          }, (failure) => fail('Expected success but got failure: $failure'));
          verify(() => mockStrategy.getNextMove(mockGameState)).called(1);
        },
      );

      test(
        '[P0] UNIT-CAMUC-006: should return AI move when strategy is available for O',
        () async {
          // Arrange
          final mockGameState = MockGameState();
          final mockStrategy = MockPlayerStrategy();
          const expectedMove = Position(row: 2, col: 2);

          when(() => mockGameState.isGameOver).thenReturn(false);
          when(() => mockGameState.currentTurn).thenReturn(PlayerMark.o);
          when(() => mockStrategy.requiresExternalInput).thenReturn(false);
          when(
            () => mockStrategy.getNextMove(any()),
          ).thenAnswer((_) async => expectedMove);

          final params = CheckAIMoveParams(
            gameState: mockGameState,
            strategyO: mockStrategy,
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold((CheckAIMoveResult success) {
            expect(success.shouldPlay, isTrue);
            expect(success.move, expectedMove);
          }, (failure) => fail('Expected success but got failure: $failure'));
          verify(() => mockStrategy.getNextMove(mockGameState)).called(1);
        },
      );

      test(
        '[P1] UNIT-CAMUC-007: should return empty result when strategy returns null',
        () async {
          // Arrange
          final mockGameState = MockGameState();
          final mockStrategy = MockPlayerStrategy();

          when(() => mockGameState.isGameOver).thenReturn(false);
          when(() => mockGameState.currentTurn).thenReturn(PlayerMark.x);
          when(() => mockStrategy.requiresExternalInput).thenReturn(false);
          when(
            () => mockStrategy.getNextMove(any()),
          ).thenAnswer((_) async => null);

          final params = CheckAIMoveParams(
            gameState: mockGameState,
            strategyX: mockStrategy,
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold((CheckAIMoveResult success) {
            expect(success.shouldPlay, isFalse);
            expect(success.move, isNull);
          }, (failure) => fail('Expected success but got failure: $failure'));
        },
      );

      test(
        '[P1] UNIT-CAMUC-008: should return failure when an exception is thrown',
        () async {
          // Arrange
          final mockGameState = MockGameState();
          final mockStrategy = MockPlayerStrategy();

          when(() => mockGameState.isGameOver).thenReturn(false);
          when(() => mockGameState.currentTurn).thenReturn(PlayerMark.x);
          when(() => mockStrategy.requiresExternalInput).thenReturn(false);
          when(
            () => mockStrategy.getNextMove(any()),
          ).thenThrow(Exception('Test exception'));

          final params = CheckAIMoveParams(
            gameState: mockGameState,
            strategyX: mockStrategy,
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold(
            (success) => fail('Expected failure but got success: $success'),
            (failure) {
              expect(failure, isA<CheckAIMoveCheckFailed>());
            },
          );
        },
      );
    });
  });
}
