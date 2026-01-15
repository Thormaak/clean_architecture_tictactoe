import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe/features/game/application/use_cases/start_game_use_case.dart';
import 'package:tictactoe/features/game/domain/failures/game_failures.dart';
import 'package:tictactoe/features/game/domain/repositories/i_match_repository.dart';
import 'package:tictactoe/features/rules/rules.dart';

// === MOCKS ===
class MockMatchRepository extends Mock implements IMatchRepository {}

class MockMatchState extends Mock implements MatchState {}

// === FAKES ===
class FakeGameConfig extends Fake implements GameConfig {}

void main() {
  // === SETUP ===
  late StartGameUseCase sut;
  late MockMatchRepository mockMatchRepository;
  late MockMatchState mockMatchState;

  setUpAll(() {
    registerFallbackValue(FakeGameConfig());
  });

  setUp(() {
    mockMatchRepository = MockMatchRepository();
    mockMatchState = MockMatchState();
    sut = StartGameUseCase(mockMatchRepository);

    when(
      () => mockMatchRepository.createMatch(any()),
    ).thenReturn(mockMatchState);
  });

  // === TESTS ===
  group('StartGameUseCase - UNIT-SGUC', () {
    group('call', () {
      test(
        '[P0] UNIT-SGUC-001: should create local game with 2 human players when mode is local',
        () async {
          // Arrange
          const params = StartGameParams(
            mode: GameMode.local(),
            bestOf: BestOf.bo1,
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold((success) {
            expect(success.matchState, mockMatchState);
            expect(success.strategyX, isNotNull);
            expect(success.strategyO, isNotNull);
            expect(success.strategyX?.requiresExternalInput, isTrue);
            expect(success.strategyO?.requiresExternalInput, isTrue);
          }, (failure) => fail('Expected success but got failure: $failure'));
          verify(() => mockMatchRepository.createMatch(any())).called(1);
        },
      );

      test(
        '[P0] UNIT-SGUC-002: should create AI game when mode is vsAI',
        () async {
          // Arrange
          const params = StartGameParams(
            mode: GameMode.vsAI(difficulty: AIDifficulty.easy),
            bestOf: BestOf.bo1,
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold((success) {
            expect(success.matchState, mockMatchState);
            expect(success.strategyX, isNotNull);
            expect(success.strategyO, isNotNull);
            expect(success.strategyX?.requiresExternalInput, isTrue);
            expect(success.strategyO?.requiresExternalInput, isFalse);
          }, (failure) => fail('Expected success but got failure: $failure'));
          verify(() => mockMatchRepository.createMatch(any())).called(1);
        },
      );

      test(
        '[P1] UNIT-SGUC-003: should configure BestOf.bo3 correctly',
        () async {
          // Arrange
          const params = StartGameParams(
            mode: GameMode.local(),
            bestOf: BestOf.bo3,
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold((success) {
            expect(success, isNotNull);
          }, (failure) => fail('Expected success but got failure: $failure'));
          final captured =
              verify(
                () => mockMatchRepository.createMatch(captureAny()),
              ).captured;
          final config = captured.first as GameConfig;
          expect(config.bestOf, BestOf.bo3);
        },
      );

      test(
        '[P1] UNIT-SGUC-004: should configure BestOf.bo5 correctly',
        () async {
          // Arrange
          const params = StartGameParams(
            mode: GameMode.local(),
            bestOf: BestOf.bo5,
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold((success) {
            expect(success, isNotNull);
          }, (failure) => fail('Expected success but got failure: $failure'));
          final captured =
              verify(
                () => mockMatchRepository.createMatch(captureAny()),
              ).captured;
          final config = captured.first as GameConfig;
          expect(config.bestOf, BestOf.bo5);
        },
      );

      test(
        '[P1] UNIT-SGUC-005: should create AI strategy with hard difficulty',
        () async {
          // Arrange
          const params = StartGameParams(
            mode: GameMode.vsAI(difficulty: AIDifficulty.hard),
            bestOf: BestOf.bo1,
          );

          // Act
          final result = await sut(params);

          // Assert
          result.fold((success) {
            expect(success.strategyO?.requiresExternalInput, isFalse);
          }, (failure) => fail('Expected success but got failure: $failure'));
        },
      );

      test(
        '[P2] UNIT-SGUC-006: should create correct player names for local mode',
        () async {
          // Arrange
          const params = StartGameParams(
            mode: GameMode.local(),
            bestOf: BestOf.bo1,
          );

          // Act
          await sut(params);

          // Assert
          final captured =
              verify(
                () => mockMatchRepository.createMatch(captureAny()),
              ).captured;
          final config = captured.first as GameConfig;
          expect(config.playerX.name, 'Player 1');
          expect(config.playerO.name, 'Player 2');
        },
      );

      test(
        '[P2] UNIT-SGUC-007: should create correct player names for AI mode',
        () async {
          // Arrange
          const params = StartGameParams(
            mode: GameMode.vsAI(difficulty: AIDifficulty.medium),
            bestOf: BestOf.bo1,
          );

          // Act
          await sut(params);

          // Assert
          final captured =
              verify(
                () => mockMatchRepository.createMatch(captureAny()),
              ).captured;
          final config = captured.first as GameConfig;
          expect(config.playerX.name, 'You');
          expect(config.playerO.name, 'AI');
        },
      );

      test(
        '[P1] UNIT-SGUC-008: should return failure when createMatch throws an exception',
        () async {
          // Arrange
          const params = StartGameParams(
            mode: GameMode.local(),
            bestOf: BestOf.bo1,
          );
          when(
            () => mockMatchRepository.createMatch(any()),
          ).thenThrow(Exception('Repository error'));

          // Act
          final result = await sut(params);

          // Assert
          result.fold(
            (success) => fail('Expected failure but got success: $success'),
            (failure) {
              expect(failure, isA<StartGameCreateMatchFailed>());
            },
          );
          verify(() => mockMatchRepository.createMatch(any())).called(1);
        },
      );
    });
  });
}
