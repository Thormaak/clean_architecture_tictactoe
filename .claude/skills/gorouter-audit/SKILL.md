---
name: gorouter-audit
description: Audit GoRouter navigation for issues like hardcoded routes, missing guards, orphan routes, and navigation anti-patterns. Use when reviewing navigation architecture or checking route configuration.
allowed-tools: Read, Grep, Glob
---

# GoRouter Navigation Audit Skill

Tu es un expert en navigation Flutter avec GoRouter. Quand ce skill est invoque, tu dois auditer le code de navigation pour identifier les problemes et produire un rapport detaille.

## Processus d'audit

### Phase 1 : Scan de la configuration

1. **Localiser la configuration router**
   ```
   Grep: "GoRouter\(" dans lib/
   Glob: lib/**/router*.dart
   Glob: lib/**/routes*.dart
   ```

2. **Verifier la structure**
   - Presence d'un fichier de constantes de routes
   - Configuration centralisee vs dispersee

### Phase 2 : Audit des routes hardcodees

```
Grep dans lib/:
- "context\.go\(['\"]/" → Route hardcodee (doit utiliser Routes.xxx)
- "context\.push\(['\"]/" → Route hardcodee
- "context\.goNamed\(" → OK si utilise des constantes
```

### Phase 3 : Audit des parametres

```
Grep:
- "pathParameters\['.*'\]!" → Verifier gestion du null
- "state\.extra as" → Verifier gestion du null/type
- "queryParameters\['.*'\]" → Verifier valeurs par defaut
```

### Phase 4 : Audit des guards

```
Verifier:
- Presence d'un redirect global pour auth
- Guards sur les routes protegees
- Redirection apres login/logout
```

### Phase 5 : Audit des anti-patterns

```
Grep:
- "Navigator\.of\(context\)\.push" → Interdit avec GoRouter
- "Navigator\.push\(" → Interdit avec GoRouter
- "context\.go\(" dans initState sans PostFrameCallback → Crash potentiel
```

### Phase 6 : Audit des routes orphelines

```
1. Lister toutes les routes definies
2. Grep pour chaque route utilisee dans le code
3. Identifier les routes jamais appelees
```

### Phase 7 : Audit de la gestion d'erreurs

```
Verifier:
- Presence d'un errorBuilder
- Gestion des routes invalides
- Deep link fallbacks
```

## Format du rapport

```markdown
# Audit Navigation GoRouter

## Resume
- Routes analysees : X
- Problemes critiques : X
- Problemes majeurs : X
- Problemes mineurs : X

---

## Problemes critiques

### 1. [Description]
- **Fichier** : path/to/file.dart:42
- **Code actuel** :
  ```dart
  context.go('/game/123');
  ```
- **Probleme** : Route hardcodee
- **Solution** :
  ```dart
  context.go(Routes.gameById('123'));
  ```

---

## Problemes majeurs
...

## Problemes mineurs
...

## Routes orphelines
...

## Recommandations
1. ...
2. ...
```

## Niveaux de severite

| Niveau | Type de probleme |
|--------|-----------------|
| **Critique** | Navigator.push avec GoRouter, navigation dans initState sans guard |
| **Majeur** | Routes hardcodees, pas de errorBuilder, state.extra sans null check |
| **Mineur** | Routes non utilisees, conventions de nommage |

## References

@.claude/rules/gorouter-patterns.md
