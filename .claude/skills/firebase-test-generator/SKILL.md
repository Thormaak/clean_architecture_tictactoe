---
name: firebase-test-generator
description: Generate Firebase Cloud Functions tests with Jest and firebase-functions-test for callable functions, HTTP triggers, Firestore triggers, and Auth triggers.
globs:
  - "backend/functions/src/**/*.ts"
  - "backend/functions/src/**/*.js"
---

# Firebase Test Generator Skill

## Quand utiliser

Ce skill s'active automatiquement lors de la creation ou modification de :
- **Callable functions** : `onCall` handlers
- **HTTP functions** : `onRequest` handlers
- **Firestore triggers** : `onCreate`, `onUpdate`, `onDelete`, `onWrite`
- **Auth triggers** : `onCreate`, `onDelete`
- **Scheduled functions** : `onSchedule`

## Structure des fichiers

```
backend/
├── functions/
│   ├── src/
│   │   ├── index.ts              # Exports
│   │   ├── game/
│   │   │   ├── createGame.ts     # Function
│   │   │   └── createGame.test.ts # Test
│   │   └── user/
│   │       ├── onUserCreate.ts
│   │       └── onUserCreate.test.ts
│   ├── jest.config.js
│   └── package.json
```

## Configuration Jest

```javascript
// jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/*.test.ts'],
  moduleFileExtensions: ['ts', 'js'],
  collectCoverageFrom: ['src/**/*.ts', '!src/**/*.test.ts'],
  setupFilesAfterEnv: ['./jest.setup.ts'],
};
```

```typescript
// jest.setup.ts
import * as admin from 'firebase-admin';

// Initialiser l'app de test
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: 'test-project',
  });
}

// Desactiver les logs en test
jest.spyOn(console, 'log').mockImplementation();
jest.spyOn(console, 'info').mockImplementation();
```

## Template : Callable Function Test

```typescript
// src/game/createGame.test.ts
import * as admin from 'firebase-admin';
import { createGame } from './createGame';

// Mock Firestore
jest.mock('firebase-admin', () => {
  const actualAdmin = jest.requireActual('firebase-admin');
  return {
    ...actualAdmin,
    firestore: jest.fn(() => ({
      collection: jest.fn(() => ({
        doc: jest.fn(() => ({
          set: jest.fn().mockResolvedValue(undefined),
          get: jest.fn().mockResolvedValue({ exists: false }),
        })),
        add: jest.fn().mockResolvedValue({ id: 'new-game-id' }),
      })),
    })),
  };
});

describe('createGame', () => {
  const mockContext = {
    auth: {
      uid: 'test-user-id',
      token: { email: 'test@example.com' },
    },
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('when authenticated', () => {
    it('should create a new game', async () => {
      // Arrange
      const data = { playerName: 'Alice' };

      // Act
      const result = await createGame(data, mockContext as any);

      // Assert
      expect(result).toEqual({
        gameId: 'new-game-id',
        status: 'created',
      });
    });

    it('should throw if playerName is missing', async () => {
      // Arrange
      const data = {};

      // Act & Assert
      await expect(createGame(data, mockContext as any))
        .rejects
        .toThrow('Player name is required');
    });
  });

  describe('when not authenticated', () => {
    it('should throw unauthenticated error', async () => {
      // Arrange
      const data = { playerName: 'Alice' };
      const noAuthContext = { auth: null };

      // Act & Assert
      await expect(createGame(data, noAuthContext as any))
        .rejects
        .toThrow('unauthenticated');
    });
  });
});
```

## Template : Firestore Trigger Test

```typescript
// src/game/onGameCreate.test.ts
import * as functionsTest from 'firebase-functions-test';
import * as admin from 'firebase-admin';

const testEnv = functionsTest({
  projectId: 'test-project',
});

import { onGameCreate } from './onGameCreate';

describe('onGameCreate', () => {
  afterAll(() => {
    testEnv.cleanup();
  });

  it('should initialize game state when game is created', async () => {
    // Arrange
    const gameData = {
      playerName: 'Alice',
      createdAt: admin.firestore.Timestamp.now(),
    };

    const snap = testEnv.firestore.makeDocumentSnapshot(
      gameData,
      'games/game-123'
    );

    const wrapped = testEnv.wrap(onGameCreate);

    // Act
    await wrapped(snap);

    // Assert
    // Verifier les effets de bord (Firestore writes, etc.)
  });
});
```

## Template : Auth Trigger Test

```typescript
// src/user/onUserCreate.test.ts
import * as functionsTest from 'firebase-functions-test';

const testEnv = functionsTest({
  projectId: 'test-project',
});

import { onUserCreate } from './onUserCreate';

describe('onUserCreate', () => {
  afterAll(() => {
    testEnv.cleanup();
  });

  it('should create user profile on signup', async () => {
    // Arrange
    const user = testEnv.auth.makeUserRecord({
      uid: 'user-123',
      email: 'test@example.com',
      displayName: 'Test User',
    });

    const wrapped = testEnv.wrap(onUserCreate);

    // Act
    await wrapped(user);

    // Assert
    // Verifier que le profil a ete cree
  });
});
```

## Template : HTTP Function Test

```typescript
// src/api/webhook.test.ts
import * as httpMocks from 'node-mocks-http';
import { webhook } from './webhook';

describe('webhook', () => {
  it('should process valid webhook payload', async () => {
    // Arrange
    const req = httpMocks.createRequest({
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-webhook-secret': 'valid-secret',
      },
      body: {
        event: 'payment.completed',
        data: { amount: 100 },
      },
    });

    const res = httpMocks.createResponse();

    // Act
    await webhook(req, res);

    // Assert
    expect(res.statusCode).toBe(200);
    expect(res._getJSONData()).toEqual({
      success: true,
    });
  });

  it('should reject invalid secret', async () => {
    // Arrange
    const req = httpMocks.createRequest({
      method: 'POST',
      headers: {
        'x-webhook-secret': 'invalid',
      },
      body: {},
    });

    const res = httpMocks.createResponse();

    // Act
    await webhook(req, res);

    // Assert
    expect(res.statusCode).toBe(401);
  });
});
```

## Mocking Firebase Services

### Firestore

```typescript
const mockFirestore = {
  collection: jest.fn().mockReturnThis(),
  doc: jest.fn().mockReturnThis(),
  set: jest.fn().mockResolvedValue(undefined),
  get: jest.fn().mockResolvedValue({
    exists: true,
    data: () => ({ name: 'Test' }),
  }),
  update: jest.fn().mockResolvedValue(undefined),
  delete: jest.fn().mockResolvedValue(undefined),
  where: jest.fn().mockReturnThis(),
  orderBy: jest.fn().mockReturnThis(),
  limit: jest.fn().mockReturnThis(),
};

jest.spyOn(admin, 'firestore').mockReturnValue(mockFirestore as any);
```

### Auth

```typescript
const mockAuth = {
  getUser: jest.fn().mockResolvedValue({
    uid: 'user-123',
    email: 'test@example.com',
  }),
  createCustomToken: jest.fn().mockResolvedValue('custom-token'),
  setCustomUserClaims: jest.fn().mockResolvedValue(undefined),
};

jest.spyOn(admin, 'auth').mockReturnValue(mockAuth as any);
```

### Storage

```typescript
const mockBucket = {
  file: jest.fn().mockReturnValue({
    save: jest.fn().mockResolvedValue(undefined),
    delete: jest.fn().mockResolvedValue(undefined),
    getSignedUrl: jest.fn().mockResolvedValue(['https://signed-url.com']),
  }),
};

jest.spyOn(admin, 'storage').mockReturnValue({
  bucket: jest.fn().mockReturnValue(mockBucket),
} as any);
```

## Conventions

- Un fichier test par function
- Nommage : `{functionName}.test.ts`
- Structure : `describe` par function, `describe` par scenario
- Nommage tests : "should X when Y"
- Toujours tester : succes, erreurs, authentification

## Commandes

```bash
# Lancer les tests
npm test

# Avec coverage
npm test -- --coverage

# Watch mode
npm test -- --watch

# Un fichier specifique
npm test -- createGame.test.ts
```

## References

- [firebase-functions-test](https://firebase.google.com/docs/functions/unit-testing)
- [Jest Documentation](https://jestjs.io/docs/getting-started)
