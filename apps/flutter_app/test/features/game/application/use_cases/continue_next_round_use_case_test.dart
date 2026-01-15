import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe/features/game/application/use_cases/continue_next_round_use_case.dart';
import 'package:tictactoe/features/game/domain/repositories/i_match_repository.dart';
import 'package:tictactoe/features/game/domain/failures/game_failures.dart';
import 'package:tictactoe/features/rules/rules.dart';

// === MOCKS ===
class MockMatchRepository extends Mock implements IMatchRepository {}

class MockMatchState extends Mock implements MatchState {}

// === FAKES ===
class FakeMatchState extends Fake implements MatchState {}

void main() {
  // === SETUP ===
  late ContinueNextRoundUseCase sut;
  late MockMatchRepository mockMatchRepository;

  setUpAll(() {
    registerFallbackValue(FakeMatchState());
  });

  setUp(() {
    mockMatchRepository = MockMatchRepository();
    sut = ContinueNextRoundUseCase(mockMatchRepository);
  });

  // === TESTS ===
  group('ContinueNextRoundUseCase - UNIT-CNRUC', () {
    group('call', () {
      test(
        '[P1] UNIT-CNRUC-001: should return error when not awaiting next round',
        () async {
          // Arrange
          final mockMatchState = MockMatchState();
          when(() => mockMatchState.awaitingNextRound).thenReturn(false);

          final params = ContinueNextRoundParams(matchState: mockMatchState);

          // Act
          final result = await sut(params);

          // Assert
          result.fold((success) => fail('Expected failure but got success'), (
            failure,
          ) {
            expect(failure, isA<ContinueNextRoundRoundInProgress>());
          });
        },
      );

      test(
        '[P0] UNIT-CNRUC-002: should start next round when match is awaiting',
        () async {
          // Arrange
          final mockMatchState = MockMatchState();
          final mockNewMatchState = MockMatchState();

          when(() => mockMatchState.awaitingNextRound).thenReturn(true);
          when(
            () => mockMatchRepository.startNextRound(any()),
          ).thenReturn(MatchEngineResult.success(mockNewMatchState));

          final params = ContinueNextRoundParams(matchState: mockMatchState);

          // Act
          final result = await sut(params);

          // Assert
          result.fold((success) {
            expect(success.matchState, mockNewMatchState);
          }, (failure) => fail('Expected success but got failure'));
          verify(
            () => mockMatchRepository.startNextRound(mockMatchState),
          ).called(1);
        },
      );

      test(
        '[P1] UNIT-CNRUC-003: should return error when match is already over',
        () async {
          // Arrange
          final mockMatchState = MockMatchState();

          when(() => mockMatchState.awaitingNextRound).thenReturn(true);
          when(() => mockMatchRepository.startNextRound(any())).thenReturn(
            MatchEngineResult.failure(const MatchEngineErrorMatchAlreadyOver()),
          );

          final params = ContinueNextRoundParams(matchState: mockMatchState);

          // Act
          final result = await sut(params);

          // Assert
          result.fold((success) => fail('Expected failure but got success'), (
            failure,
          ) {
            expect(failure, isA<ContinueNextRoundMatchAlreadyOver>());
          });
        },
      );

      test(
        '[P1] UNIT-CNRUC-004: should return error when round is still in progress',
        () async {
          // Arrange
          final mockMatchState = MockMatchState();

          when(() => mockMatchState.awaitingNextRound).thenReturn(true);
          when(() => mockMatchRepository.startNextRound(any())).thenReturn(
            MatchEngineResult.failure(const MatchEngineErrorRoundInProgress()),
          );

          final params = ContinueNextRoundParams(matchState: mockMatchState);

          // Act
          final result = await sut(params);

          // Assert
          result.fold((success) => fail('Expected failure but got success'), (
            failure,
          ) {
            expect(failure, isA<ContinueNextRoundRoundInProgress>());
          });
        },
      );

      test(
        '[P1] UNIT-CNRUC-005: should return error when no round to complete',
        () async {
          // Arrange
          final mockMatchState = MockMatchState();

          when(() => mockMatchState.awaitingNextRound).thenReturn(true);
          when(() => mockMatchRepository.startNextRound(any())).thenReturn(
            MatchEngineResult.failure(
              const MatchEngineErrorNoRoundToComplete(),
            ),
          );

          final params = ContinueNextRoundParams(matchState: mockMatchState);

          // Act
          final result = await sut(params);

          // Assert
          result.fold((success) => fail('Expected failure but got success'), (
            failure,
          ) {
            expect(failure, isA<ContinueNextRoundStartRoundFailed>());
          });
        },
      );
    });
  });
}
