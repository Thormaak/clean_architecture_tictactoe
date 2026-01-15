# TicTacToe Monorepo - Instructions Claude Code

## Structure du Monorepo

```
tictactoe/
├── flutter_app/     # Application Flutter (Riverpod, Freezed)
└── backend/         # Firebase Cloud Functions
```

---

## Environnement de developpement

### FVM (Flutter Version Management)

**OBLIGATOIRE** : Toujours utiliser FVM pour executer les commandes Flutter.

```bash
# Correct
fvm flutter pub get
fvm flutter test
fvm flutter build
fvm dart run build_runner build

# INCORRECT - Ne jamais utiliser directement
flutter pub get
flutter test
```

### Melos (Monorepo Management)

Ce projet utilise Melos pour gerer le monorepo. Les commandes Melos utilisent automatiquement FVM.

#### Installation de Melos

```bash
fvm dart pub global activate melos
```

#### Commandes principales

| Commande | Description |
|----------|-------------|
| `melos bootstrap` | Installer les dependances |
| `melos gen` | Generer le code (Freezed, Riverpod, GoRouter) |
| `melos gen:watch` | Mode watch pour la generation |
| `melos l10n` | Generer les fichiers de localisation |
| `melos test` | Lancer tous les tests |
| `melos analyze` | Analyse statique |
| `melos format` | Formater le code |
| `melos clean` | Nettoyer les artefacts |
| `melos prepare` | Setup complet (bootstrap + gen + l10n) |

#### Premier setup du projet

```bash
# 1. Installer FVM si pas deja fait
dart pub global activate fvm

# 2. Installer la version Flutter du projet
cd flutter_app && fvm install && cd ..

# 3. Installer Melos
fvm dart pub global activate melos

# 4. Setup complet
melos prepare
```

### Backend (Firebase Cloud Functions)

Le backend n'est pas gere par Melos (Node.js/TypeScript).

```bash
cd backend/functions
npm install          # Installer les dependances
npm run build        # Compiler TypeScript
npm run serve        # Lancer l'emulateur
npm run deploy       # Deployer sur Firebase
```

---

## REGLE OBLIGATOIRE : Tests Automatiques

### Flutter (flutter_app/)

Tout fichier dans ces dossiers DOIT avoir un fichier test correspondant :

| Source | Test |
|--------|------|
| `flutter_app/lib/**/services/*.dart` | `flutter_app/test/**/services/*_test.dart` |
| `flutter_app/lib/**/usecases/*.dart` | `flutter_app/test/**/usecases/*_test.dart` |
| `flutter_app/lib/**/providers/*.dart` | `flutter_app/test/**/providers/*_test.dart` |
| `flutter_app/lib/**/cubit/*.dart` | `flutter_app/test/**/cubit/*_test.dart` |
| `flutter_app/lib/**/notifiers/*.dart` | `flutter_app/test/**/notifiers/*_test.dart` |

### Template de test Flutter avec mocktail

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

### Regles de test
1. Creer le test AVANT ou EN MEME TEMPS que le code source
2. Chaque test doit avoir au moins un `test()` ou `testWidgets()`
3. Utiliser mocktail pour les dependances
4. Pattern Arrange/Act/Assert obligatoire
5. Nommer les tests en anglais avec le pattern "should X when Y"

### Exemples existants
Referez-vous aux tests existants pour le style :
- `flutter_app/test/gameplay/services/game_engine_test.dart`
- `flutter_app/test/gameplay/services/win_detector_test.dart`
- `flutter_app/test/gameplay/domain/board_test.dart`

---

## Firebase (backend/)

### Architecture Firebase

- **Architecture** : Clean Architecture + Feature-First
- **Injection** : Constructor Injection + Factory Functions (pas de framework DI)
- **Runtime** : Node.js avec TypeScript
- **Tests** : Jest avec mocks

### Structure des features Firebase

```
backend/functions/src/
├── core/                           # Partage entre features
│   ├── errors/
│   │   └── app-error.ts
│   ├── middleware/
│   │   └── auth.middleware.ts
│   └── firebase/
│       └── admin.ts
│
├── features/
│   └── {feature_name}/
│       ├── domain/
│       │   ├── entities/
│       │   │   └── {name}.ts       # Interface pure
│       │   └── repositories/
│       │       └── {name}.repository.ts
│       │
│       ├── application/
│       │   └── usecases/
│       │       └── {action}-{name}.usecase.ts
│       │
│       ├── infrastructure/
│       │   └── repositories/
│       │       └── {name}.repository.impl.ts
│       │
│       ├── presentation/
│       │   ├── callable/           # onCall functions
│       │   ├── http/               # onRequest functions
│       │   ├── triggers/           # Firestore/Auth triggers
│       │   └── scheduled/          # Scheduled functions
│       │
│       └── index.ts                # Factory + exports
│
└── index.ts                        # Export all functions
```

### Pattern Factory (pas de DI framework)

```typescript
// features/game/index.ts
export function createGameRepository() {
  return new FirestoreGameRepository(getFirestore());
}

export function createCreateGameUseCase() {
  return new CreateGameUseCase(createGameRepository());
}

// Export des Cloud Functions
export { createGame } from './presentation/callable/create-game.callable';
```

### Tests Firebase avec Jest

Tout fichier UseCase DOIT avoir un fichier test correspondant :

| Source | Test |
|--------|------|
| `backend/functions/src/**/usecases/*.ts` | `backend/functions/src/**/usecases/*.test.ts` |

### Template de test Firebase

```typescript
import { CreateGameUseCase } from './create-game.usecase';
import { GameRepository } from '../../domain/repositories/game.repository';

describe('CreateGameUseCase', () => {
  let useCase: CreateGameUseCase;
  let mockRepository: jest.Mocked<GameRepository>;

  beforeEach(() => {
    mockRepository = {
      findById: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    };
    useCase = new CreateGameUseCase(mockRepository);
  });

  it('should create a game with correct initial state', async () => {
    // Arrange
    mockRepository.create.mockResolvedValue(undefined);

    // Act
    const result = await useCase.execute({ userId: 'user-123' });

    // Assert
    expect(result.status).toBe('waiting');
    expect(mockRepository.create).toHaveBeenCalledWith(
      expect.objectContaining({ status: 'waiting' })
    );
  });
});
```

### Regles de test Firebase
1. Creer le test AVANT ou EN MEME TEMPS que le code source
2. Chaque test doit avoir au moins un `it()` ou `test()`
3. Utiliser `jest.Mocked<T>` pour mocker les repositories
4. Pattern Arrange/Act/Assert obligatoire
5. Nommer les tests en anglais avec le pattern "should X when Y"

---

## Architecture Flutter

- **State Management** : Riverpod v3 avec NotifierProvider
- **Immutabilite** : Freezed pour les entites et value objects
- **Architecture** : Clean Architecture + Feature-First
- **Navigation** : GoRouter

### Structure des features Flutter

```
flutter_app/lib/features/{feature}/
├── presentation/
│   ├── pages/          # Containers connectant Views aux Providers
│   ├── views/          # Widgets purs sans state management
│   ├── widgets/        # Composants reutilisables
│   └── providers/      # Riverpod Notifiers
├── application/
│   └── usecases/       # Cas d'utilisation
├── domain/
│   ├── entities/       # Entites metier
│   └── repositories/   # Interfaces repositories
└── infrastructure/
    └── repositories/   # Implementations repositories
```

---

## Conventions de Code

### Commentaires

Les agents NE doivent PAS ajouter de commentaires sauf si :
- Le code n'est PAS trivial ou evident
- La logique necessite une explication (algorithme complexe, workaround, etc.)
- Il y a un "pourquoi" non evident (pas un "quoi")

```dart
// INTERDIT - Trivial/evident
// Recupere l'utilisateur
final user = await repository.getUser(id);

// INTERDIT - Decrit le "quoi" pas le "pourquoi"
// Boucle sur les items
for (final item in items) { ... }

// OK - Explique un workaround
// Firebase retourne null si le doc n'existe pas, on doit verifier
if (doc.data() == null) throw NotFoundException();

// OK - Algorithme non trivial
// Utilise l'algo de Kadane pour trouver la somme max en O(n)
```

---

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
