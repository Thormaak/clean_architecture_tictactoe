import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe/features/game/infrastructure/repositories/match_repository_impl.dart';
import 'package:tictactoe/features/rules/rules.dart';
import '../../../../fixtures/game_fixtures.dart';

class MockMatchEngine extends Mock implements MatchEngine {}

void main() {
  late MatchRepositoryImpl sut;
  late MockMatchEngine mockMatchEngine;

  setUp(() {
    mockMatchEngine = MockMatchEngine();
    sut = MatchRepositoryImpl(mockMatchEngine);
  });

  group('MatchRepositoryImpl', () {
    group('createMatch', () {
      test('should delegate to MatchEngine.createMatch', () {
        // Arrange
        final config = GameConfig(
          mode: const GameMode.local(),
          playerX: GameFixtures.createPlayerX(),
          playerO: GameFixtures.createPlayerO(),
        );
        final expectedMatch = GameFixtures.createDefaultMatchState(config: config);
        when(() => mockMatchEngine.createMatch(config))
            .thenReturn(expectedMatch);

        // Act
        final result = sut.createMatch(config);

        // Assert
        expect(result, expectedMatch);
        verify(() => mockMatchEngine.createMatch(config)).called(1);
      });
    });

    group('startNextRound', () {
      test('should delegate to MatchEngine.startNextRound', () {
        // Arrange
        final match = GameFixtures.createDefaultMatchState();
        final expectedResult = MatchEngineResult.success(match);
        when(() => mockMatchEngine.startNextRound(match))
            .thenReturn(expectedResult);

        // Act
        final result = sut.startNextRound(match);

        // Assert
        expect(result, expectedResult);
        verify(() => mockMatchEngine.startNextRound(match)).called(1);
      });
    });

    group('completeRound', () {
      test('should delegate to MatchEngine.completeRound', () {
        // Arrange
        final match = GameFixtures.createDefaultMatchState();
        final completedRound = GameFixtures.createGameState();
        final expectedMatch = match;
        when(() => mockMatchEngine.completeRound(match, completedRound))
            .thenReturn(expectedMatch);

        // Act
        final result = sut.completeRound(match, completedRound);

        // Assert
        expect(result, expectedMatch);
        verify(() => mockMatchEngine.completeRound(match, completedRound))
            .called(1);
      });
    });
  });
}
