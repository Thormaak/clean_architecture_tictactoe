# TicTacToe

Jeu de morpion moderne en Flutter, avec Clean Architecture, animations et audio.

> **🚀 Pour tester rapidement** : Sautez directement a la section [Quick Start](#-quick-start-pour-testeurs)

## Fonctionnalites

- **Multijoueur local** (deux joueurs sur le meme appareil)
- **Adversaire IA** avec 3 niveaux de difficulte (Easy, Medium, Hard)
- **Systeme de match** au meilleur de 1, 3 ou 5 rounds
- **Mode Sudden Death** en cas d'egalite sur un match
- **Audio immersif**
  - Musique de fond
  - Effets sonores (placement, erreur, game over, click)
  - Reglages audio configurables (volume musique/SFX, mute)
- **Localisation** francais / anglais avec switch dynamique
- **Animations et effets visuels**
  - Confetti sur victoire
  - Titres animes avec effet neon
  - Transitions fluides
  - Ligne de victoire animee
- **Design system gaming**
  - Theme dark avec couleurs neon (cyan, pink, purple)
  - Composants UI reutilisables et consistants
  - Gradients et effets visuels modernes
- **Responsive design**
  - Support mobile et tablette
  - Gestion des orientations portrait/paysage
  - Breakpoints adaptatifs

## Stack technique

- **Flutter** + **Dart**
- **State management**: Riverpod v3 (NotifierProvider)
- **Navigation**: GoRouter avec routes typees
- **Immutabilite**: Freezed
- **Architecture**: Clean Architecture + Feature-first
- **Gestion d'erreurs**: result_dart (Either pattern)
- **Audio**: just_audio
- **Animations**: flutter_animate
- **Localisation**: flutter_localizations + intl
- **Persistance locale**: shared_preferences
- **Tests**: mocktail pour les mocks
- **Monorepo**: Melos + FVM

## Structure du projet

```
tictactoe/
├── apps/
│   └── flutter_app/
│       └── lib/
│           ├── core/         # Widgets partages, router, l10n
│           └── features/
│               ├── rules/    # Logique de jeu pure Dart
│               ├── game/     # UI et logique de partie
│               └── settings/ # Preferences utilisateur
├── docs/
└── melos.yaml
```

## Documentation projet

Resume rapide:
- Architecture Clean + feature-first (domain/application/infrastructure/presentation).
- Organisation du monorepo et structure des dossiers cles.
- Commandes Melos/FVM pour setup, generation, tests.
- Conventions de contribution et localisation.

Pour le detail, voir `docs/project-documentation.md`.

## Ameliorations possibles

- **Grilles alternatives**: 4x4, 5x5, 9x9, avec regles adaptees.
- **Mode tournoi**: classement local, historique, statistiques.
- **Defis quotidiens**: grille/mode impose, score de reussite.
- **Accessibilite**: contrastes, tailles de police, haptics parametrables.
- **Personnalisation**: themes alternatifs, skins, sons personnalisables.
- **Replay**: historique des parties avec possibilite de rejouer les coups.

## 🚀 Quick Start (pour testeurs)

**Prerequis** : [FVM](https://fvm.app/) et [Melos](https://melos.invertase.dev/) doivent etre installes (voir [section installation detaillee](#-installation-detaillee-developpeurs)).

```bash
# Clone le repo
git clone <url-du-repo>
cd tictactoe

# Installe FVM (si pas deja fait)
dart pub global activate fvm

# Installe la version Flutter du projet
cd apps/flutter_app
fvm install
cd ../..

# Installe Melos (si pas deja fait)
fvm dart pub global activate melos

# Lance tout (deps + generation + app)
melos run start
```

Cette derniere commande fait TOUT automatiquement :
1. ✅ Installe toutes les dependances
2. ✅ **Genere les fichiers Freezed/Riverpod/GoRouter** (OBLIGATOIRE pour la compilation)
3. ✅ Genere les fichiers de localisation (FR/EN)
4. ✅ Lance l'application sur le device par defaut

L'application devrait se lancer automatiquement !

---

## 📋 Installation detaillee (developpeurs)

### Prerequis

- **FVM** (Flutter Version Manager)
- **Flutter** installe via FVM
- **Melos** pour le monorepo
- **Android Studio** (SDK + emulators) pour Android
- **Xcode** (macOS) pour iOS

### Premiere installation

```bash
# 1. Installer FVM
dart pub global activate fvm

# 2. Installer la version Flutter du projet
cd apps/flutter_app
fvm install
cd ../..

# 3. Installer Melos
fvm dart pub global activate melos

# 4. Setup complet + lancement
melos run start
```

**Note importante** : Ne sautez pas l'etape 4 ! La commande `melos run start` (ou `melos prepare`) est OBLIGATOIRE au moins une fois pour generer les fichiers Freezed/Riverpod/GoRouter. Sans eux, le projet ne compilera pas.

### Commandes de developpement

#### Generation de code

Le projet utilise la generation de code pour Freezed, Riverpod et GoRouter.

```bash
# Generation unique
melos gen

# Mode watch (regenere automatiquement lors des modifications)
melos gen:watch
```

**Important** : Apres toute modification de :
- Classes `@freezed` (entites, value objects)
- Providers Riverpod avec annotations
- Routes GoRouter

Vous devez relancer `melos gen` ou utiliser `melos gen:watch`.

#### Lancer l'application

```bash
# Methode recommandee : tout-en-un (generation + lancement)
melos run start

# Ou manuellement (APRES avoir fait 'melos prepare' au moins une fois)
cd apps/flutter_app
fvm flutter run

# Ou sur un device specifique (APRES generation)
fvm flutter run -d <device_id>
```

**Important** : Les commandes `fvm flutter run` necessitent que les fichiers generes (Freezed/Riverpod/GoRouter) existent deja.
- **Premiere fois** : Utilisez `melos run start` OU faites d'abord `melos prepare`
- **Ensuite** : Vous pouvez utiliser directement `fvm flutter run`

## 🧪 Tests

**Prerequis** : Avoir lance `melos prepare` ou `melos run start` au moins une fois (pour la generation de code).

```bash
# Lancer tous les tests
melos test

# Lancer les tests avec couverture
melos test:coverage
```

## 📱 Guide testeur (Android / iOS)

### Etape 1 : Installation (une seule fois)

Si FVM et Melos ne sont pas encore installes :

```bash
# Installer FVM
dart pub global activate fvm

# Installer la version Flutter du projet
cd apps/flutter_app
fvm install
cd ../..

# Installer Melos
fvm dart pub global activate melos
```

### Etape 2 : Premier lancement (OBLIGATOIRE)

```bash
# Depuis la racine du projet
melos run start
```

**Cette etape est OBLIGATOIRE la premiere fois** car elle :
- ✅ Installe les dependances
- ✅ **Genere les fichiers Freezed/Riverpod/GoRouter** (sans eux, l'app ne compile pas)
- ✅ Genere les fichiers de localisation
- ✅ Lance l'application

L'application se lancera automatiquement sur le device par defaut.

### Etape 3 : Relancer sur un device specifique (optionnel)

**Uniquement apres avoir fait l'etape 2 au moins une fois.**

```bash
# Verifier les devices disponibles
fvm flutter devices

# Lancer sur un device specifique (la generation a deja ete faite a l'etape 2)
cd apps/flutter_app
fvm flutter run -d <device_id>
```

**OU si c'est votre premiere fois ET que vous voulez choisir le device :**

```bash
# D'abord : generer les fichiers (une seule fois)
melos prepare

# Ensuite : lancer sur le device specifique
cd apps/flutter_app
fvm flutter run -d <device_id>
```

**Exemples de devices :**
- **Android emulateur** : Creer un AVD dans Android Studio
- **iOS simulateur** (macOS uniquement) : Lancer depuis Xcode
- **Appareil reel Android** : Activer mode developpeur + USB debugging
- **Appareil reel iOS** (macOS uniquement) : Provisioning valide requis

### Scenarios de test recommandes

Fonctionnalites a tester :

- ✅ **Multijoueur local** : Demarrer une partie et verifier l'alternance des tours
- ✅ **IA (3 niveaux)** : Tester Easy, Medium, Hard
- ✅ **Systeme de match** : Best of 1, 3, 5 rounds
- ✅ **Sudden Death** : Forcer une egalite pour voir le round bonus
- ✅ **Localisation** : Basculer FR/EN dans Settings
- ✅ **Audio** : Musique de fond + SFX (placement, erreur, victoire)
- ✅ **Animations** : Confetti sur victoire, ligne de victoire animee
- ✅ **Responsive** : Tester en portrait et paysage
- ✅ **Settings** : Regler volumes, mute, changer langue

## Licence

MIT
