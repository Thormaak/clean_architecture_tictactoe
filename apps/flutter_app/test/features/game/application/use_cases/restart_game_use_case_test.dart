import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:result_dart/result_dart.dart';
import 'package:tictactoe/features/game/application/use_cases/restart_game_use_case.dart';
import 'package:tictactoe/features/game/application/use_cases/start_game_use_case.dart';
import 'package:tictactoe/features/game/domain/failures/game_failures.dart';
import 'package:tictactoe/features/rules/rules.dart';

// === MOCKS ===
class MockStartGameUseCase extends Mock implements StartGameUseCase {}

class MockMatchState extends Mock implements MatchState {}

// === FAKES ===
class FakeStartGameParams extends Fake implements StartGameParams {}

void main() {
  // === SETUP ===
  late RestartGameUseCase sut;
  late MockStartGameUseCase mockStartGameUseCase;

  setUpAll(() {
    registerFallbackValue(FakeStartGameParams());
  });

  setUp(() {
    mockStartGameUseCase = MockStartGameUseCase();
    sut = RestartGameUseCase(mockStartGameUseCase);
  });

  // === TESTS ===
  group('RestartGameUseCase - UNIT-RGUC', () {
    group('call', () {
      test(
        '[P0] UNIT-RGUC-001: should delegate to StartGameUseCase with same mode and bestOf',
        () async {
          // Arrange
          const params = RestartGameParams(
            mode: GameMode.local(),
            bestOf: BestOf.bo3,
          );
          final mockMatchState = MockMatchState();
          final mockResult = StartGameResult(
            matchState: mockMatchState,
            strategyX: null,
            strategyO: null,
          );

          when(
            () => mockStartGameUseCase.call(any()),
          ).thenAnswer((_) async => Success(mockResult));

          // Act
          final result = await sut(params);

          // Assert
          result.fold((success) {
            expect(success.matchState, mockMatchState);
            expect(success.strategyX, null);
            expect(success.strategyO, null);
          }, (failure) => fail('Expected success but got failure: $failure'));
          final captured =
              verify(() => mockStartGameUseCase.call(captureAny())).captured;
          final startParams = captured.first as StartGameParams;
          expect(startParams.mode, params.mode);
          expect(startParams.bestOf, params.bestOf);
        },
      );

      test('[P1] UNIT-RGUC-002: should preserve GameMode.local', () async {
        // Arrange
        const params = RestartGameParams(
          mode: GameMode.local(),
          bestOf: BestOf.bo1,
        );
        final mockMatchState = MockMatchState();
        final mockResult = StartGameResult(
          matchState: mockMatchState,
          strategyX: null,
          strategyO: null,
        );

        when(
          () => mockStartGameUseCase.call(any()),
        ).thenAnswer((_) async => Success(mockResult));

        // Act
        await sut(params);

        // Assert
        final captured =
            verify(() => mockStartGameUseCase.call(captureAny())).captured;
        final startParams = captured.first as StartGameParams;
        expect(startParams.mode, const GameMode.local());
      });

      test(
        '[P1] UNIT-RGUC-003: should preserve GameMode.vsAI with difficulty',
        () async {
          // Arrange
          const params = RestartGameParams(
            mode: GameMode.vsAI(difficulty: AIDifficulty.hard),
            bestOf: BestOf.bo1,
          );
          final mockMatchState = MockMatchState();
          final mockResult = StartGameResult(
            matchState: mockMatchState,
            strategyX: null,
            strategyO: null,
          );

          when(
            () => mockStartGameUseCase.call(any()),
          ).thenAnswer((_) async => Success(mockResult));

          // Act
          await sut(params);

          // Assert
          final captured =
              verify(() => mockStartGameUseCase.call(captureAny())).captured;
          final startParams = captured.first as StartGameParams;
          expect(
            startParams.mode,
            const GameMode.vsAI(difficulty: AIDifficulty.hard),
          );
        },
      );

      test(
        '[P1] UNIT-RGUC-004: should call StartGameUseCase exactly once',
        () async {
          // Arrange
          const params = RestartGameParams(
            mode: GameMode.local(),
            bestOf: BestOf.bo1,
          );
          final mockMatchState = MockMatchState();
          final mockResult = StartGameResult(
            matchState: mockMatchState,
            strategyX: null,
            strategyO: null,
          );

          when(
            () => mockStartGameUseCase.call(any()),
          ).thenAnswer((_) async => Success(mockResult));

          // Act
          await sut(params);

          // Assert
          verify(() => mockStartGameUseCase.call(any())).called(1);
          verifyNoMoreInteractions(mockStartGameUseCase);
        },
      );

      test(
        '[P1] UNIT-RGUC-005: should return RestartGameFailure when StartGameUseCase returns Failure',
        () async {
          // Arrange
          const params = RestartGameParams(
            mode: GameMode.local(),
            bestOf: BestOf.bo1,
          );
          final startGameFailure = const StartGameFailure.createMatchFailed();

          when(
            () => mockStartGameUseCase.call(any()),
          ).thenAnswer((_) async => Failure(startGameFailure));

          // Act
          final result = await sut(params);

          // Assert
          result.fold(
            (success) => fail('Expected failure but got success: $success'),
            (failure) {
              expect(failure, isA<RestartGameFailure>());
              expect(failure, const RestartGameFailure.restartFailed());
            },
          );
          verify(() => mockStartGameUseCase.call(any())).called(1);
        },
      );
    });
  });
}
