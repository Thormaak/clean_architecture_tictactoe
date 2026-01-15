---
name: clean-arch-audit
description: Audit Flutter Clean Architecture for violations, incorrect dependencies between layers, misplaced files, and naming convention issues. Use when reviewing architecture, checking layer boundaries, or validating feature structure.
allowed-tools: Read, Grep, Glob
---

# Clean Architecture Audit Skill

Tu es un expert en Clean Architecture Flutter. Quand ce skill est invoqué, tu dois auditer le code pour identifier les violations architecturales et produire un rapport détaillé.

## Processus d'audit

### Phase 1 : Scan de la structure

1. **Identifier les features**
   ```
   Glob: lib/features/*/
   ```

2. **Vérifier la structure de chaque feature**
   - Présence des 4 dossiers : domain/, application/, infrastructure/, presentation/
   - Structure correcte de chaque sous-dossier

### Phase 2 : Audit des imports (CRITIQUE)

#### 2.1 Domain - Ne doit rien importer d'externe

```
Grep dans lib/features/*/domain/:
- "import 'package:flutter" → VIOLATION CRITIQUE
- "import 'package:cloud_firestore" → VIOLATION CRITIQUE
- "import 'package:firebase" → VIOLATION CRITIQUE
- "import 'package:dio" → VIOLATION CRITIQUE
- "import 'package:http" → VIOLATION CRITIQUE
- "import '.*infrastructure" → VIOLATION CRITIQUE
- "import '.*presentation" → VIOLATION CRITIQUE
- "import '.*application" → VIOLATION (domain ne doit pas connaître application)
```

#### 2.2 Application - Ne doit importer que Domain

```
Grep dans lib/features/*/application/:
- "import '.*infrastructure" → VIOLATION
- "import '.*presentation" → VIOLATION
- "import 'package:flutter" → VIOLATION (sauf foundation.dart)
```

#### 2.3 Infrastructure - Ne doit importer que Domain

```
Grep dans lib/features/*/infrastructure/:
- "import '.*application" → VIOLATION
- "import '.*presentation" → VIOLATION
```

#### 2.4 Presentation - Ne doit pas importer Infrastructure directement

```
Grep dans lib/features/*/presentation/:
- "import '.*infrastructure" → VIOLATION (doit passer par DI)
```

### Phase 3 : Audit du placement des fichiers

#### 3.1 Entities mal placées

```
Grep: "@JsonSerializable" ou "@freezed.*fromJson" dans domain/entities/
→ Les entities ne doivent PAS avoir de sérialisation JSON
```

#### 3.2 Repository interfaces mal placées

```
Grep: "implements.*Repository" dans domain/
→ Les implémentations ne doivent PAS être dans domain
```

#### 3.3 Models dans le mauvais dossier

```
Grep: "fromJson" ou "toJson" dans domain/
→ Les DTOs/Models doivent être dans infrastructure/models/
```

### Phase 4 : Audit des conventions de nommage

#### 4.1 Use Cases
```
Glob: lib/features/*/application/use_cases/*.dart
Vérifier: Nom de fichier = {action}_{name}_use_case.dart
Vérifier: Classe = {Action}{Name}UseCase
```

#### 4.2 Repositories
```
Glob: lib/features/*/domain/repositories/*.dart
Vérifier: Nom = {name}_repository.dart (interface)

Glob: lib/features/*/infrastructure/repositories/*.dart
Vérifier: Nom = {name}_repository_impl.dart (implementation)
```

### Phase 5 : Audit de la logique métier

#### 5.1 Logique dans Presentation
```
Grep dans presentation/:
- Calculs complexes dans build()
- Validation métier dans les widgets
→ Devrait être dans Domain ou Application
```

#### 5.2 Use Cases trop simples
```
Vérifier que les Use Cases apportent de la valeur
- Simple proxy vers repository = peut-être inutile
- Orchestration de plusieurs repos = correct
```

## Format du rapport

```markdown
# Audit Clean Architecture

## Résumé
- Features analysées : X
- Violations critiques : X
- Violations majeures : X
- Violations mineures : X
- Score architecture : X/100

---

## Violations critiques (à corriger immédiatement)

### 1. [Description]
- **Feature** : {feature_name}
- **Fichier** : path/to/file.dart:42
- **Violation** : Domain importe Infrastructure
- **Code** :
  ```dart
  import 'package:cloud_firestore/cloud_firestore.dart'; // INTERDIT
  ```
- **Solution** : Déplacer dans Infrastructure, utiliser interface dans Domain

---

## Violations majeures

...

## Violations mineures

...

## Recommandations
1. ...
2. ...
```

## Niveaux de sévérité

| Niveau | Type de violation |
|--------|------------------|
| **Critique** | Import interdit dans Domain, Dépendance circulaire |
| **Majeur** | Import Infrastructure dans Presentation, Entity avec JSON |
| **Mineur** | Convention de nommage, Structure dossier incomplète |

## Références

@layer-rules.md
@violations.md
