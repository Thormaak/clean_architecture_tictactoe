---
description: Generate Flutter tests with mocktail for usecases, services, providers, cubits and notifiers
globs:
  - "flutter_app/lib/**/services/**/*.dart"
  - "flutter_app/lib/**/usecases/**/*.dart"
  - "flutter_app/lib/**/providers/**/*.dart"
  - "flutter_app/lib/**/cubit/**/*.dart"
  - "flutter_app/lib/**/notifiers/**/*.dart"
---

# Flutter Test Generator Skill

## Quand utiliser

Ce skill s'active automatiquement lors de la creation ou modification de :
- **Services** : Logique metier (game_engine, win_detector, etc.)
- **Usecases** : Cas d'utilisation applicatifs
- **Providers** : Riverpod providers
- **Notifiers** : Riverpod Notifier classes
- **Cubits** : BLoC Cubit classes

## Workflow obligatoire

1. **Creer le fichier source** dans `flutter_app/lib/`
2. **Creer IMMEDIATEMENT le test** dans `flutter_app/test/` avec la meme structure
3. **Utiliser mocktail** pour mocker les dependances

## Structure des tests

Le fichier test doit etre place dans `flutter_app/test/` en miroir de `flutter_app/lib/` :

| Source | Test |
|--------|------|
| `flutter_app/lib/features/game/services/score_service.dart` | `flutter_app/test/features/game/services/score_service_test.dart` |
| `flutter_app/lib/features/auth/usecases/login_usecase.dart` | `flutter_app/test/features/auth/usecases/login_usecase_test.dart` |
| `flutter_app/lib/features/game/providers/game_provider.dart` | `flutter_app/test/features/game/providers/game_provider_test.dart` |

## Template mocktail

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Import du fichier a tester
import 'package:tictactoe/features/.../{name}.dart';

// Mocks des dependances
class MockDependency extends Mock implements Dependency {}

void main() {
  // Subject Under Test
  late ClassUnderTest sut;
  late MockDependency mockDependency;

  setUp(() {
    mockDependency = MockDependency();
    sut = ClassUnderTest(dependency: mockDependency);
  });

  group('ClassUnderTest', () {
    group('methodName', () {
      test('should return expected result when condition is met', () {
        // Arrange
        when(() => mockDependency.someMethod()).thenReturn(expectedValue);

        // Act
        final result = sut.methodName();

        // Assert
        expect(result, expectedValue);
        verify(() => mockDependency.someMethod()).called(1);
      });

      test('should throw exception when error occurs', () {
        // Arrange
        when(() => mockDependency.someMethod()).thenThrow(Exception('error'));

        // Act & Assert
        expect(() => sut.methodName(), throwsException);
      });
    });
  });
}
```

## Conventions de nommage des tests

- Utiliser l'anglais
- Pattern : `should [expected behavior] when [condition]`
- Exemples :
  - `should return true when board is full`
  - `should throw InvalidMoveException when cell is occupied`
  - `should emit loading state when fetching data`

## Mocktail - Rappels

```dart
// Stub une methode
when(() => mock.method()).thenReturn(value);
when(() => mock.method()).thenAnswer((_) async => value);
when(() => mock.method()).thenThrow(Exception());

// Verifier un appel
verify(() => mock.method()).called(1);
verify(() => mock.method(any())).called(greaterThan(0));
verifyNever(() => mock.method());

// Capturer des arguments
final captured = verify(() => mock.method(captureAny())).captured;
```

## Exemples du projet

Consultez les tests existants pour le style :
- `flutter_app/test/gameplay/services/game_engine_test.dart`
- `flutter_app/test/gameplay/services/win_detector_test.dart`
- `flutter_app/test/gameplay/domain/board_test.dart`
