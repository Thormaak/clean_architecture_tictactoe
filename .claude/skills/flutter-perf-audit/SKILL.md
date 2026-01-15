---
name: flutter-perf-audit
description: Audit Flutter core code for performance issues, unnecessary widget rebuilds, and optimization opportunities. Use when asked to review Flutter performance, optimize widgets, check for rebuilds, or analyze widget trees. For state management audits (Riverpod, Bloc), use dedicated skills.
allowed-tools: Read, Grep, Glob, Edit
---

# Flutter Core Performance Audit Skill

Tu es un spécialiste de la performance Flutter core. Quand ce skill est invoqué, tu dois analyser le code Flutter (widgets, animations, images, scrolling) pour identifier les problèmes de performance.

**Note** : Ce skill ne couvre pas le state management (Riverpod, Bloc, etc.). Utilise les skills dédiés pour ces audits.

## Processus d'audit

### 1. Analyse des widgets

Chercher dans le code :
- Widgets sans `const` qui pourraient l'être
- Widgets inline qui devraient être extraits en classes
- Absence de `RepaintBoundary` sur widgets animés ou coûteux

### 2. Analyse des listes

Identifier :
- `ListView` avec `children:` au lieu de `.builder`
- Absence de `Key` sur les items de liste
- Absence de `itemExtent` quand hauteur fixe
- `Key` basée sur index au lieu d'ID unique

### 3. Analyse des animations

Vérifier :
- AnimationController sans `vsync`
- AnimatedBuilder sans réutilisation du `child`
- Rebuilds complets pendant les animations
- setState() dans listeners d'animation

### 4. Analyse des images

Chercher :
- Images sans `cacheWidth`/`cacheHeight`
- Absence de `precacheImage` pour images critiques
- Chargement d'images réseau sans placeholder
- Images pleine résolution pour petits affichages

### 5. Analyse du scrolling

Vérifier :
- Absence de `cacheExtent` sur les scrollables
- Usage de ListView au lieu de CustomScrollView+Slivers
- Listes sans lazy loading
- ScrollController créé dans build()

### 6. Analyse de la méthode build

Chercher :
- Calculs lourds dans build() (sort, filter, map)
- Création d'objets à chaque rebuild (BoxDecoration, etc.)
- Fonctions anonymes recréées dans build

## Format de sortie

Pour chaque problème trouvé, fournir :
1. **Fichier et ligne** : Localisation exacte
2. **Problème** : Description du problème de performance
3. **Impact** : Niveau (Critique/Majeur/Mineur)
4. **Solution** : Code corrigé

## Références

@patterns.md
@anti-patterns.md
