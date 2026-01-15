# Firebase Cloud Functions Clean Architecture Rules

Ces regles s'appliquent au backend Firebase Cloud Functions avec une architecture Feature-First.

## 1. Structure Feature-First

```
backend/functions/src/
├── core/                           # Partage entre features
│   ├── errors/                     # Erreurs custom
│   │   └── app-error.ts
│   ├── middleware/                 # Auth, validation
│   │   └── auth.middleware.ts
│   └── firebase/                   # Instances Firebase
│       └── admin.ts                # Admin SDK init
│
├── features/
│   └── {feature_name}/             # Une feature
│       ├── domain/
│       │   ├── entities/
│       │   │   └── {name}.ts       # Interface pure
│       │   └── repositories/
│       │       └── {name}.repository.ts  # Interface
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

## 2. Regles d'imports (STRICTES)

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION                             │
│  (peut importer: Application, Domain, Core)                 │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION                              │
│  (peut importer: Domain UNIQUEMENT)                         │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN                                 │
│  (NE PEUT RIEN IMPORTER - types purs)                       │
└─────────────────────────────────────────────────────────────┘
                          ▲
                          │
┌─────────────────────────────────────────────────────────────┐
│                   INFRASTRUCTURE                            │
│  (peut importer: Domain UNIQUEMENT)                         │
└─────────────────────────────────────────────────────────────┘
```

### Imports autorises et INTERDITS

| Couche | Autorise | INTERDIT |
|--------|----------|----------|
| **Domain** | Rien (types TS purs) | firebase-admin, Application, Infrastructure, Presentation |
| **Application** | Domain | firebase-admin direct, Infrastructure, Presentation |
| **Infrastructure** | Domain, firebase-admin | Application, Presentation |
| **Presentation** | Domain, Application, Core, feature/index.ts | Infrastructure direct |

## 3. Injection de dependances : Constructor + Factory

**Pas de framework DI** pour optimiser le cold start.

### Pattern : Interface + Implementation

```typescript
// domain/repositories/game.repository.ts (INTERFACE)
import { Game } from '../entities/game';

export interface GameRepository {
  findById(id: string): Promise<Game | null>;
  create(game: Game): Promise<void>;
  update(game: Game): Promise<void>;
  delete(id: string): Promise<void>;
}
```

```typescript
// infrastructure/repositories/game.repository.impl.ts (IMPLEMENTATION)
import { Firestore } from 'firebase-admin/firestore';
import { Game } from '../../domain/entities/game';
import { GameRepository } from '../../domain/repositories/game.repository';

export class FirestoreGameRepository implements GameRepository {
  constructor(private readonly db: Firestore) {}

  async findById(id: string): Promise<Game | null> {
    const doc = await this.db.collection('games').doc(id).get();
    if (!doc.exists) return null;
    return doc.data() as Game;
  }

  async create(game: Game): Promise<void> {
    await this.db.collection('games').doc(game.id).set(game);
  }

  // ...
}
```

### Pattern : UseCase avec injection

```typescript
// application/usecases/create-game.usecase.ts
import { GameRepository } from '../../domain/repositories/game.repository';
import { Game } from '../../domain/entities/game';

export class CreateGameUseCase {
  constructor(private readonly gameRepository: GameRepository) {}

  async execute(params: CreateGameParams): Promise<Game> {
    const game: Game = {
      id: generateId(),
      ...params,
      createdAt: new Date(),
    };
    await this.gameRepository.create(game);
    return game;
  }
}
```

### Pattern : Factory par feature

```typescript
// features/game/index.ts
import { getFirestore } from 'firebase-admin/firestore';
import { FirestoreGameRepository } from './infrastructure/repositories/game.repository.impl';
import { CreateGameUseCase } from './application/usecases/create-game.usecase';
import { GetGameUseCase } from './application/usecases/get-game.usecase';

// === FACTORIES ===

export function createGameRepository() {
  return new FirestoreGameRepository(getFirestore());
}

export function createCreateGameUseCase() {
  return new CreateGameUseCase(createGameRepository());
}

export function createGetGameUseCase() {
  return new GetGameUseCase(createGameRepository());
}

// === CLOUD FUNCTIONS EXPORTS ===

export { createGame } from './presentation/callable/create-game.callable';
export { getGame } from './presentation/callable/get-game.callable';
export { onGameCreated } from './presentation/triggers/on-game-created.trigger';
```

### Utilisation dans le handler

```typescript
// presentation/callable/create-game.callable.ts
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { createCreateGameUseCase } from '../../index';

export const createGame = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Must be authenticated');
  }

  // Injection via factory
  const useCase = createCreateGameUseCase();
  const game = await useCase.execute({
    playerName: request.data.playerName,
    userId: request.auth.uid,
  });

  return { gameId: game.id };
});
```

## 4. Conventions de nommage

### Fichiers

| Type | Pattern | Exemple |
|------|---------|---------|
| Entity | `{name}.ts` | `game.ts` |
| Repository interface | `{name}.repository.ts` | `game.repository.ts` |
| Repository impl | `{name}.repository.impl.ts` | `game.repository.impl.ts` |
| UseCase | `{action}-{name}.usecase.ts` | `create-game.usecase.ts` |
| Callable | `{action}-{name}.callable.ts` | `create-game.callable.ts` |
| HTTP | `{action}-{name}.http.ts` | `webhook.http.ts` |
| Trigger | `on-{entity}-{event}.trigger.ts` | `on-game-created.trigger.ts` |
| Scheduled | `{name}.scheduled.ts` | `cleanup.scheduled.ts` |

### Classes et interfaces

| Type | Pattern | Exemple |
|------|---------|---------|
| Entity interface | `{Name}` | `interface Game` |
| Repository interface | `{Name}Repository` | `interface GameRepository` |
| Repository impl | `Firestore{Name}Repository` | `class FirestoreGameRepository` |
| UseCase | `{Action}{Name}UseCase` | `class CreateGameUseCase` |

### Cloud Functions exports

```typescript
// Callable: verbe + nom
export const createGame = onCall(...);
export const joinLobby = onCall(...);

// Trigger: on + entity + event
export const onGameCreated = onDocumentCreated(...);
export const onUserDeleted = auth.user().onDelete(...);

// Scheduled: nom descriptif
export const cleanupOldGames = onSchedule(...);
```

## 5. Templates par couche

### Domain - Entity

```typescript
// domain/entities/game.ts

export type GameStatus = 'waiting' | 'playing' | 'finished';
export type Player = 'X' | 'O';

export interface Game {
  id: string;
  status: GameStatus;
  currentPlayer: Player;
  board: (Player | null)[];
  players: {
    X: string;  // userId
    O: string | null;
  };
  winner: Player | null;
  createdAt: Date;
  updatedAt: Date;
}

// Logique metier pure (fonctions, pas de classes)
export function isGameFull(game: Game): boolean {
  return game.players.O !== null;
}

export function canPlayerMove(game: Game, userId: string): boolean {
  const playerSymbol = game.players.X === userId ? 'X' : 'O';
  return game.status === 'playing' && game.currentPlayer === playerSymbol;
}
```

### Domain - Repository interface

```typescript
// domain/repositories/game.repository.ts
import { Game } from '../entities/game';

export interface GameRepository {
  findById(id: string): Promise<Game | null>;
  findByUserId(userId: string): Promise<Game[]>;
  create(game: Game): Promise<void>;
  update(game: Game): Promise<void>;
  delete(id: string): Promise<void>;
}
```

### Application - UseCase

```typescript
// application/usecases/join-game.usecase.ts
import { GameRepository } from '../../domain/repositories/game.repository';
import { Game, isGameFull } from '../../domain/entities/game';
import { AppError } from '../../../core/errors/app-error';

export interface JoinGameParams {
  gameId: string;
  userId: string;
}

export class JoinGameUseCase {
  constructor(private readonly gameRepository: GameRepository) {}

  async execute(params: JoinGameParams): Promise<Game> {
    const game = await this.gameRepository.findById(params.gameId);

    if (!game) {
      throw new AppError('not-found', 'Game not found');
    }

    if (isGameFull(game)) {
      throw new AppError('failed-precondition', 'Game is full');
    }

    const updatedGame: Game = {
      ...game,
      players: { ...game.players, O: params.userId },
      status: 'playing',
      updatedAt: new Date(),
    };

    await this.gameRepository.update(updatedGame);
    return updatedGame;
  }
}
```

### Presentation - Callable

```typescript
// presentation/callable/join-game.callable.ts
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { createJoinGameUseCase } from '../../index';
import { AppError } from '../../../../core/errors/app-error';

export const joinGame = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { gameId } = request.data;
  if (!gameId || typeof gameId !== 'string') {
    throw new HttpsError('invalid-argument', 'gameId is required');
  }

  try {
    const useCase = createJoinGameUseCase();
    const game = await useCase.execute({
      gameId,
      userId: request.auth.uid,
    });
    return { game };
  } catch (error) {
    if (error instanceof AppError) {
      throw new HttpsError(error.code, error.message);
    }
    throw error;
  }
});
```

### Presentation - Trigger

```typescript
// presentation/triggers/on-game-created.trigger.ts
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { getFirestore } from 'firebase-admin/firestore';

export const onGameCreated = onDocumentCreated(
  'games/{gameId}',
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const game = snapshot.data();
    const db = getFirestore();

    // Mettre a jour les stats
    await db.collection('stats').doc('games').set(
      {
        totalGames: FieldValue.increment(1),
        lastCreated: game.createdAt,
      },
      { merge: true }
    );
  }
);
```

## 6. Core - Erreurs custom

```typescript
// core/errors/app-error.ts
import { FunctionsErrorCode } from 'firebase-functions/v2/https';

export class AppError extends Error {
  constructor(
    public readonly code: FunctionsErrorCode,
    message: string,
    public readonly details?: Record<string, unknown>
  ) {
    super(message);
    this.name = 'AppError';
  }
}
```

## 7. Tests

Chaque fichier dans `usecases/` et `repositories/` doit avoir un test correspondant.

```typescript
// application/usecases/create-game.usecase.test.ts
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
      findByUserId: jest.fn(),
    };
    useCase = new CreateGameUseCase(mockRepository);
  });

  it('should create a game with correct initial state', async () => {
    // Arrange
    mockRepository.create.mockResolvedValue(undefined);

    // Act
    const result = await useCase.execute({
      userId: 'user-123',
      playerName: 'Alice',
    });

    // Assert
    expect(result.status).toBe('waiting');
    expect(result.players.X).toBe('user-123');
    expect(result.players.O).toBeNull();
    expect(mockRepository.create).toHaveBeenCalledWith(
      expect.objectContaining({ status: 'waiting' })
    );
  });
});
```

## Checklist

- [ ] Chaque feature a les 4 dossiers (domain, application, infrastructure, presentation)
- [ ] Chaque feature a un `index.ts` avec les factories
- [ ] Domain : interfaces pures, pas d'import firebase-admin
- [ ] Application : UseCases avec injection par constructeur
- [ ] Infrastructure : implementations avec Firestore
- [ ] Presentation : handlers minces, delegation aux UseCases
- [ ] Erreurs converties en HttpsError dans presentation
- [ ] Tests pour chaque UseCase
