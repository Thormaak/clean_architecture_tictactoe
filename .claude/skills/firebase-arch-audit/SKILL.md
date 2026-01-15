---
name: firebase-arch-audit
description: Audit Firebase Cloud Functions Clean Architecture for violations, incorrect dependencies between layers, misplaced files, and naming convention issues. Use when reviewing backend architecture, checking layer boundaries, or validating feature structure.
allowed-tools: Read, Grep, Glob
---

# Firebase Architecture Audit Skill

Tu es un expert en Clean Architecture pour Firebase Cloud Functions. Quand ce skill est invoque, tu dois auditer le code backend pour identifier les violations architecturales et produire un rapport detaille.

## Processus d'audit

### Phase 1 : Scan de la structure

1. **Identifier les features**
   ```
   Glob: backend/functions/src/features/*/
   ```

2. **Verifier la structure de chaque feature**
   - Presence des 4 dossiers : domain/, application/, infrastructure/, presentation/
   - Presence du fichier index.ts avec les factories
   - Structure correcte de chaque sous-dossier

3. **Verifier le core**
   ```
   Glob: backend/functions/src/core/
   ```
   - Presence de errors/app-error.ts
   - Presence de firebase/admin.ts (init)

### Phase 2 : Audit des imports (CRITIQUE)

#### 2.1 Domain - Ne doit RIEN importer d'externe

```
Grep dans features/*/domain/:
- "from 'firebase-admin" → VIOLATION CRITIQUE
- "from 'firebase-functions" → VIOLATION CRITIQUE
- "from '.*infrastructure" → VIOLATION CRITIQUE
- "from '.*presentation" → VIOLATION CRITIQUE
- "from '.*application" → VIOLATION CRITIQUE
```

**Autorise dans Domain :** Types TypeScript purs uniquement

#### 2.2 Application - Ne doit importer que Domain

```
Grep dans features/*/application/:
- "from 'firebase-admin" → VIOLATION (doit passer par repository)
- "from 'firebase-functions" → VIOLATION
- "from '.*infrastructure" → VIOLATION
- "from '.*presentation" → VIOLATION
```

**Autorise dans Application :** Domain, core/errors

#### 2.3 Infrastructure - Ne doit importer que Domain

```
Grep dans features/*/infrastructure/:
- "from '.*application" → VIOLATION
- "from '.*presentation" → VIOLATION
```

**Autorise dans Infrastructure :** Domain, firebase-admin, packages externes

#### 2.4 Presentation - Ne doit pas importer Infrastructure directement

```
Grep dans features/*/presentation/:
- "from '.*infrastructure/repositories" → VIOLATION (doit utiliser factory)
- "from '.*infrastructure/data_sources" → VIOLATION
```

**Autorise dans Presentation :** Domain, Application, Core, feature/index.ts (factories)

### Phase 3 : Audit du pattern Factory

#### 3.1 Verifier les factories dans index.ts

```typescript
// Chaque feature doit avoir un index.ts avec :
// 1. Factory pour le repository
export function createGameRepository() { ... }

// 2. Factory pour chaque UseCase
export function createCreateGameUseCase() { ... }

// 3. Export des Cloud Functions
export { createGame } from './presentation/callable/...';
```

#### 3.2 Verifier l'utilisation des factories

```
Grep dans presentation/:
- "new.*Repository" → VIOLATION (doit utiliser factory)
- "new.*UseCase" → VIOLATION (doit utiliser factory)
```

**Correct :**
```typescript
const useCase = createGetGameUseCase();
```

### Phase 4 : Audit des conventions de nommage

#### 4.1 Fichiers

| Type | Pattern attendu |
|------|-----------------|
| Entity | `{name}.ts` |
| Repository interface | `{name}.repository.ts` |
| Repository impl | `{name}.repository.impl.ts` |
| UseCase | `{action}-{name}.usecase.ts` |
| Callable | `{action}-{name}.callable.ts` |
| HTTP | `{action}-{name}.http.ts` |
| Trigger | `on-{entity}-{event}.trigger.ts` |
| Scheduled | `{name}.scheduled.ts` |

#### 4.2 Classes

| Type | Pattern attendu |
|------|-----------------|
| Repository interface | `{Name}Repository` |
| Repository impl | `Firestore{Name}Repository` |
| UseCase | `{Action}{Name}UseCase` |

### Phase 5 : Audit de la logique metier

#### 5.1 Logique dans Presentation

```
Verifier dans presentation/:
- Calculs complexes dans les handlers → Devrait etre dans UseCase
- Acces direct a Firestore → Devrait etre dans Repository
- Validation metier → Devrait etre dans Domain ou UseCase
```

**Pattern correct pour handler :**
```typescript
export const createGame = onCall(async (request) => {
  // 1. Auth check
  if (!request.auth) throw new HttpsError('unauthenticated', '...');

  // 2. Input validation basique
  if (!request.data.name) throw new HttpsError('invalid-argument', '...');

  // 3. Delegation au UseCase
  const useCase = createCreateGameUseCase();
  const result = await useCase.execute(request.data);

  // 4. Retour
  return result;
});
```

#### 5.2 Repository interface dans le mauvais dossier

```
Grep: "implements.*Repository" dans domain/
→ Les implementations ne doivent PAS etre dans domain
```

#### 5.3 Entities avec logique Firebase

```
Grep dans domain/entities/:
- "Timestamp" from firebase-admin → VIOLATION (utiliser Date)
- "FieldValue" → VIOLATION
```

### Phase 6 : Audit des tests

```
Pour chaque fichier dans application/usecases/:
- Verifier existence de {name}.test.ts
- Verifier presence de describe/it/expect
- Verifier mock des repositories
```

## Format du rapport

```markdown
# Audit Clean Architecture Firebase

## Resume
- Features analysees : X
- Violations critiques : X
- Violations majeures : X
- Violations mineures : X
- Score architecture : X/100

---

## Violations critiques (a corriger immediatement)

### 1. [Description]
- **Feature** : {feature_name}
- **Fichier** : backend/functions/src/features/.../file.ts:42
- **Violation** : Domain importe firebase-admin
- **Code** :
  ```typescript
  import { Firestore } from 'firebase-admin/firestore'; // INTERDIT
  ```
- **Solution** : Utiliser uniquement des types purs dans Domain, deplacer l'acces Firestore dans Infrastructure

---

## Violations majeures

### 1. UseCase instancie directement dans handler
- **Fichier** : .../create-game.callable.ts:15
- **Code** :
  ```typescript
  const useCase = new CreateGameUseCase(new FirestoreGameRepository(getFirestore()));
  ```
- **Solution** : Utiliser la factory `createCreateGameUseCase()` depuis index.ts

---

## Violations mineures

### 1. Convention de nommage
- **Fichier** : createGame.usecase.ts
- **Attendu** : create-game.usecase.ts (kebab-case)

---

## Structure manquante

- [ ] Feature `lobby` : dossier `application/` manquant
- [ ] Feature `game` : fichier `index.ts` manquant

---

## Recommandations
1. Creer les factories manquantes dans index.ts
2. Deplacer la logique Firestore des handlers vers les repositories
3. Ajouter les tests pour les UseCases
```

## Niveaux de severite

| Niveau | Type de violation |
|--------|------------------|
| **Critique** | Import firebase-admin dans Domain, Dependance circulaire |
| **Majeur** | Import Infrastructure dans Presentation, Logique dans handler, Pas de factory |
| **Mineur** | Convention de nommage, Structure dossier incomplete |

## References

@firebase-architecture.md
