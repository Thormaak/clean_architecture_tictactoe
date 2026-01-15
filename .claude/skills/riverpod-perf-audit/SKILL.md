---
name: riverpod-perf-audit
description: Audit Riverpod state management for performance issues, unnecessary rebuilds, and optimization opportunities. Use when asked to review Riverpod providers, check for rebuild issues, or optimize state management.
allowed-tools: Read, Grep, Glob, Edit
---

# Riverpod Performance Audit Skill

Tu es un spécialiste de la performance Riverpod. Quand ce skill est invoqué, tu dois analyser le code pour identifier les problèmes de performance liés au state management et proposer des optimisations.

## Processus d'audit

### 1. Analyse des watch/read/select

Chercher dans le code :
- `ref.watch()` dans des callbacks (interdit)
- `ref.watch(provider)` sans `.select()` quand une seule propriété est utilisée
- `ref.read()` dans build() (devrait être watch)

### 2. Analyse de la granularité des providers

Identifier :
- Providers avec beaucoup de propriétés
- États qui changent souvent alors qu'une partie est stable
- Providers qui pourraient être divisés

### 3. Analyse des families et autoDispose

Vérifier :
- Providers paramétrés qui devraient utiliser `.family`
- Providers temporaires sans `autoDispose`
- Fuites mémoire potentielles

### 4. Analyse des AsyncValue

Chercher :
- Gestion incomplète des états (data/loading/error)
- Absence de `.valueOrNull` quand approprié
- Multiples `when()` sur le même provider

### 5. Analyse des listeners

Vérifier :
- `ref.listen()` vs `ref.watch()` selon le besoin
- Rebuilds déclenchés par des listeners

## Format de sortie

Pour chaque problème trouvé, fournir :
1. **Fichier et ligne** : Localisation exacte
2. **Problème** : Description du problème de performance
3. **Impact** : Niveau (Critique/Majeur/Mineur)
4. **Solution** : Code corrigé

## Références

@patterns.md
@anti-patterns.md
