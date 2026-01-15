---
name: widget-test-generator
description: Generate Flutter widget tests with WidgetTester for pages, views, and reusable widgets. Use when creating or modifying presentation layer components.
globs:
  - "flutter_app/lib/**/pages/**/*.dart"
  - "flutter_app/lib/**/views/**/*.dart"
  - "flutter_app/lib/**/widgets/**/*.dart"
---

# Widget Test Generator Skill

## Quand utiliser

Ce skill s'active automatiquement lors de la creation ou modification de :
- **Pages** : Containers avec state management
- **Views** : Widgets purs sans state management
- **Widgets** : Composants reutilisables

## Workflow obligatoire

1. **Creer le widget** dans `flutter_app/lib/`
2. **Creer IMMEDIATEMENT le test** dans `flutter_app/test/`
3. **Utiliser WidgetTester** pour les tests de widgets

## Structure des tests

| Source | Test |
|--------|------|
| `lib/features/game/presentation/pages/game_page.dart` | `test/features/game/presentation/pages/game_page_test.dart` |
| `lib/features/game/presentation/views/game_view.dart` | `test/features/game/presentation/views/game_view_test.dart` |
| `lib/features/game/presentation/widgets/board_cell.dart` | `test/features/game/presentation/widgets/board_cell_test.dart` |

## Template de test widget

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

// Import du widget a tester
import 'package:tictactoe/features/game/presentation/widgets/game_board.dart';

// Mocks si necessaire
class MockGameNotifier extends Mock implements GameNotifier {}

void main() {
  group('GameBoard', () {
    // Helper pour wrapper le widget
    Widget createWidgetUnderTest({
      List<Override>? overrides,
    }) {
      return ProviderScope(
        overrides: overrides ?? [],
        child: const MaterialApp(
          home: Scaffold(
            body: GameBoard(),
          ),
        ),
      );
    }

    group('rendering', () {
      testWidgets('should render 9 cells', (tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Assert
        expect(find.byType(BoardCell), findsNWidgets(9));
      });

      testWidgets('should display player X symbol when X plays', (tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(
          overrides: [
            gameProvider.overrideWith((_) => GameState(
              board: Board.withMove(0, Player.x),
            )),
          ],
        ));

        // Assert
        expect(find.text('X'), findsOneWidget);
      });
    });

    group('interactions', () {
      testWidgets('should call onCellTap when empty cell is tapped', (tester) async {
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

      testWidgets('should not call onCellTap when occupied cell is tapped', (tester) async {
        // Arrange
        var tapCount = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameBoard(
                board: Board.withMove(0, Player.x),
                onCellTap: (_) => tapCount++,
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(BoardCell).first);
        await tester.pump();

        // Assert
        expect(tapCount, 0);
      });
    });

    group('states', () {
      testWidgets('should show loading indicator when loading', (tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(
          overrides: [
            gameProvider.overrideWith((_) => GameState.loading()),
          ],
        ));

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should show error message when error', (tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest(
          overrides: [
            gameProvider.overrideWith((_) => GameState.error('Something went wrong')),
          ],
        ));

        // Assert
        expect(find.text('Something went wrong'), findsOneWidget);
      });
    });

    group('navigation', () {
      testWidgets('should navigate to result page when game ends', (tester) async {
        // Arrange
        final mockRouter = MockGoRouter();
        await tester.pumpWidget(
          InheritedGoRouter(
            goRouter: mockRouter,
            child: createWidgetUnderTest(),
          ),
        );

        // Act
        // Simuler fin de partie

        // Assert
        verify(() => mockRouter.go(Routes.result)).called(1);
      });
    });
  });
}
```

## Template pour Page avec Riverpod

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockGameNotifier extends StateNotifier<GameState> with Mock
    implements GameNotifier {
  MockGameNotifier() : super(GameState.initial());
}

void main() {
  late MockGameNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockGameNotifier();
  });

  group('GamePage', () {
    testWidgets('should display GameView with correct state', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameNotifierProvider.overrideWith((_) => mockNotifier),
          ],
          child: const MaterialApp(
            home: GamePage(),
          ),
        ),
      );

      // Assert
      expect(find.byType(GameView), findsOneWidget);
    });
  });
}
```

## Template pour View pure

```dart
void main() {
  group('GameView', () {
    testWidgets('should render correctly with all props', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GameView(
              playerName: 'Alice',
              score: 10,
              isMyTurn: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });
  });
}
```

## Finders utiles

```dart
// Par type
find.byType(GameBoard);

// Par texte
find.text('Start Game');
find.textContaining('Score');

// Par widget
find.byWidget(myWidget);

// Par key
find.byKey(Key('start-button'));

// Par icone
find.byIcon(Icons.play_arrow);

// Descendants
find.descendant(
  of: find.byType(Card),
  matching: find.text('Title'),
);

// Ancetres
find.ancestor(
  of: find.text('Title'),
  matching: find.byType(Card),
);
```

## Actions utiles

```dart
// Tap
await tester.tap(find.byType(ElevatedButton));
await tester.pump(); // Rebuild

// Long press
await tester.longPress(find.byType(ListTile));

// Drag
await tester.drag(find.byType(Slider), Offset(50, 0));

// Enter text
await tester.enterText(find.byType(TextField), 'Hello');

// Scroll
await tester.scrollUntilVisible(
  find.text('Item 50'),
  500.0,
  scrollable: find.byType(Scrollable),
);

// Wait for animations
await tester.pumpAndSettle();

// Wait specific duration
await tester.pump(Duration(milliseconds: 500));
```

## Conventions

- Nommage "should X when Y" en anglais
- Un `group` par categorie (rendering, interactions, states, navigation)
- Helper `createWidgetUnderTest()` pour eviter la duplication
- `pumpAndSettle()` pour les animations, `pump()` pour les rebuilds simples
