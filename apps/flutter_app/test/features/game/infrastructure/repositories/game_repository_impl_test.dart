import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tictactoe/features/game/infrastructure/repositories/game_repository_impl.dart';
import 'package:tictactoe/features/rules/rules.dart';
import '../../../../fixtures/game_fixtures.dart';

class MockGameEngine extends Mock implements GameEngine {}

void main() {
  late GameRepositoryImpl sut;
  late MockGameEngine mockGameEngine;

  setUp(() {
    mockGameEngine = MockGameEngine();
    sut = GameRepositoryImpl(mockGameEngine);
  });

  group('GameRepositoryImpl', () {
    group('createGame', () {
      test('should delegate to GameEngine.createGame', () {
        // Arrange
        final config = GameConfig(
          mode: const GameMode.local(),
          playerX: GameFixtures.createPlayerX(),
          playerO: GameFixtures.createPlayerO(),
        );
        final expectedState = GameFixtures.createGameState(config: config);
        when(() => mockGameEngine.createGame(config))
            .thenReturn(expectedState);

        // Act
        final result = sut.createGame(config);

        // Assert
        expect(result, expectedState);
        verify(() => mockGameEngine.createGame(config)).called(1);
      });
    });

    group('playMove', () {
      test('should delegate to GameEngine.playMove', () {
        // Arrange
        final state = GameFixtures.createGameState();
        const position = Position(row: 0, col: 0);
        final expectedResult = GameEngineResult.success(state);
        when(() => mockGameEngine.playMove(state, position))
            .thenReturn(expectedResult);

        // Act
        final result = sut.playMove(state, position);

        // Assert
        expect(result, expectedResult);
        verify(() => mockGameEngine.playMove(state, position)).called(1);
      });
    });
  });
}
