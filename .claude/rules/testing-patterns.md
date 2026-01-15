# Testing Patterns Rules

Ces regles s'appliquent a tous les tests du projet Flutter.

## 1. Structure des fichiers de test

### Organisation miroir

```
flutter_app/
├── lib/
│   └── features/
│       └── game/
│           ├── domain/
│           │   └── entities/
│           │       └── player.dart
│           ├── application/
│           │   └── usecases/
│           │       └── create_game_usecase.dart
│           └── presentation/
│               ├── providers/
│               │   └── game_notifier.dart
│               └── widgets/
│                   └── game_board.dart
│
└── test/
    └── features/
        └── game/
            ├── domain/
            │   └── entities/
            │       └── player_test.dart
            ├── application/
            │   └── usecases/
            │       └── create_game_usecase_test.dart
            └── presentation/
                ├── providers/
                │   └── game_notifier_test.dart
                └── widgets/
                    └── game_board_test.dart
```

## 2. Anatomie d'un fichier de test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Imports du code a tester
import 'package:tictactoe/features/game/application/usecases/create_game_usecase.dart';
import 'package:tictactoe/features/game/domain/repositories/game_repository.dart';

// === MOCKS ===
class MockGameRepository extends Mock implements GameRepository {}

// === FAKES (pour registerFallbackValue) ===
class FakeGame extends Fake implements Game {}

void main() {
  // === SETUP ===
  late CreateGameUseCase sut; // Subject Under Test
  late MockGameRepository mockRepository;

  setUpAll(() {
    // Enregistrer les fakes pour any()
    registerFallbackValue(FakeGame());
  });

  setUp(() {
    mockRepository = MockGameRepository();
    sut = CreateGameUseCase(mockRepository);
  });

  tearDown(() {
    // Cleanup si necessaire
  });

  // === TESTS ===
  group('CreateGameUseCase', () {
    group('call', () {
      test('should create game when valid params provided', () async {
        // Arrange
        final params = CreateGameParams(playerName: 'Alice');
        final expectedGame = Game(id: '1', playerName: 'Alice');
        when(() => mockRepository.createGame(any()))
            .thenAnswer((_) async => expectedGame);

        // Act
        final result = await sut(params);

        // Assert
        expect(result, expectedGame);
        verify(() => mockRepository.createGame(any())).called(1);
      });

      test('should throw GameException when repository fails', () async {
        // Arrange
        when(() => mockRepository.createGame(any()))
            .thenThrow(GameException('Database error'));

        // Act & Assert
        expect(
          () => sut(CreateGameParams(playerName: 'Alice')),
          throwsA(isA<GameException>()),
        );
      });
    });
  });
}
```

## 3. Patterns de nommage

### Tests unitaires

```dart
// Pattern: should [expected behavior] when [condition]

test('should return true when board is full', () { ... });
test('should throw InvalidMoveException when cell is occupied', () { ... });
test('should emit loading state when fetching starts', () { ... });
test('should update score when player wins', () { ... });
```

### Groupes de tests

```dart
group('ClassName', () {
  group('methodName', () {
    test('should ...', () { ... });
  });

  group('anotherMethod', () {
    group('when condition A', () {
      test('should ...', () { ... });
    });

    group('when condition B', () {
      test('should ...', () { ... });
    });
  });
});
```

## 4. Mocktail patterns

### Stub methods

```dart
// Retour synchrone
when(() => mock.getValue()).thenReturn(42);

// Retour asynchrone
when(() => mock.fetchData()).thenAnswer((_) async => data);

// Retour Stream
when(() => mock.watchData()).thenAnswer((_) => Stream.value(data));

// Throw exception
when(() => mock.riskyOperation()).thenThrow(CustomException());

// Retour conditionnel
when(() => mock.getItem(any())).thenAnswer((invocation) {
  final id = invocation.positionalArguments[0] as String;
  return id == '1' ? item1 : item2;
});
```

### Verify calls

```dart
// Verifier un appel
verify(() => mock.method()).called(1);

// Verifier plusieurs appels
verify(() => mock.method()).called(3);
verify(() => mock.method()).called(greaterThan(0));
verify(() => mock.method()).called(lessThanOrEqualTo(5));

// Verifier jamais appele
verifyNever(() => mock.method());

// Verifier avec arguments specifiques
verify(() => mock.save(Game(id: '1', name: 'Test'))).called(1);

// Verifier avec any()
verify(() => mock.save(any())).called(1);

// Capturer arguments
final captured = verify(() => mock.save(captureAny())).captured;
expect(captured.first.name, 'Test');

// Ordre des appels
verifyInOrder([
  () => mock.start(),
  () => mock.process(),
  () => mock.finish(),
]);
```

### Fakes pour any()

```dart
// Necessaire quand on utilise any() avec des types custom
class FakeGame extends Fake implements Game {}
class FakeUser extends Fake implements User {}

setUpAll(() {
  registerFallbackValue(FakeGame());
  registerFallbackValue(FakeUser());
});
```

## 5. Test des Notifiers Riverpod

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGameRepository extends Mock implements GameRepository {}

void main() {
  late ProviderContainer container;
  late MockGameRepository mockRepository;

  setUp(() {
    mockRepository = MockGameRepository();
    container = ProviderContainer(
      overrides: [
        gameRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('GameNotifier', () {
    test('should load games on init', () async {
      // Arrange
      when(() => mockRepository.getGames())
          .thenAnswer((_) async => [game1, game2]);

      // Act
      final notifier = container.read(gameNotifierProvider.notifier);
      await notifier.loadGames();

      // Assert
      final state = container.read(gameNotifierProvider);
      expect(state.games, [game1, game2]);
      expect(state.isLoading, false);
    });

    test('should emit states in correct order', () async {
      // Arrange
      when(() => mockRepository.getGames())
          .thenAnswer((_) async => [game1]);

      final states = <GameState>[];
      container.listen(
        gameNotifierProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      // Act
      await container.read(gameNotifierProvider.notifier).loadGames();

      // Assert
      expect(states, [
        GameState.initial(),
        GameState.loading(),
        GameState.loaded([game1]),
      ]);
    });
  });
}
```

## 6. Widget tests

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('GameBoard', () {
    testWidgets('should display 9 cells', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GameBoard()),
        ),
      );

      // Assert
      expect(find.byType(BoardCell), findsNWidgets(9));
    });

    testWidgets('should call onCellTap when cell is tapped', (tester) async {
      // Arrange
      var tappedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameBoard(
              onCellTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(BoardCell).first);
      await tester.pump();

      // Assert
      expect(tappedIndex, 0);
    });

    testWidgets('should show loading indicator when loading', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameProvider.overrideWith((ref) => GameState.loading()),
          ],
          child: const MaterialApp(home: GamePage()),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

## 7. Test des exceptions

```dart
test('should throw NotFoundException when game not found', () {
  // Arrange
  when(() => mockRepository.getGame('invalid'))
      .thenThrow(NotFoundException('Game not found'));

  // Act & Assert
  expect(
    () => sut.getGame('invalid'),
    throwsA(
      isA<NotFoundException>()
          .having((e) => e.message, 'message', 'Game not found'),
    ),
  );
});

test('should throw TypeError when invalid data', () {
  expect(() => parser.parse(null), throwsA(isA<TypeError>()));
});
```

## 8. Test des Streams

```dart
test('should emit game updates', () async {
  // Arrange
  final games = [game1, game2, game3];
  when(() => mockRepository.watchGames())
      .thenAnswer((_) => Stream.fromIterable(games));

  // Act
  final stream = sut.watchGames();

  // Assert
  await expectLater(
    stream,
    emitsInOrder([game1, game2, game3]),
  );
});

test('should emit error when stream fails', () async {
  // Arrange
  when(() => mockRepository.watchGames())
      .thenAnswer((_) => Stream.error(Exception('Connection lost')));

  // Act & Assert
  await expectLater(
    sut.watchGames(),
    emitsError(isA<Exception>()),
  );
});
```

## 9. Golden tests (snapshot)

```dart
testWidgets('GameBoard matches golden', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData.light(),
      home: const Scaffold(body: GameBoard()),
    ),
  );

  await expectLater(
    find.byType(GameBoard),
    matchesGoldenFile('goldens/game_board.png'),
  );
});
```

## 10. Test helpers et fixtures

```dart
// test/fixtures/game_fixtures.dart

class GameFixtures {
  static Game get emptyGame => Game(
    id: 'test-1',
    board: Board.empty(),
    status: GameStatus.inProgress,
  );

  static Game get wonGame => Game(
    id: 'test-2',
    board: Board.fromMoves([0, 3, 1, 4, 2]),
    status: GameStatus.won,
    winner: Player.x,
  );

  static List<Game> get sampleGames => [emptyGame, wonGame];
}

// Utilisation dans les tests
test('should detect win', () {
  final game = GameFixtures.wonGame;
  expect(game.status, GameStatus.won);
});
```

## Checklist

- [ ] Pattern Arrange/Act/Assert respecte
- [ ] Nommage "should X when Y" en anglais
- [ ] Mocks declares en haut du fichier
- [ ] `registerFallbackValue` pour les types custom avec `any()`
- [ ] `setUp` pour initialisation, `tearDown` pour cleanup
- [ ] `group` pour organiser par classe/methode
- [ ] Verification des appels avec `verify`/`verifyNever`
- [ ] Tests des cas d'erreur (pas seulement happy path)
- [ ] Pas de logique complexe dans les tests
- [ ] Fixtures reutilisables pour donnees de test
