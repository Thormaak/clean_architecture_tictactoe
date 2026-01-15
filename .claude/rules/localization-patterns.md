# Localization Patterns Rules

Ces regles s'appliquent a l'internationalisation (i18n) du projet Flutter.

## 1. Structure des fichiers

### Organisation

```
flutter_app/lib/
├── core/
│   └── l10n/
│       ├── app_en.arb          # Fichier source (anglais)
│       ├── app_fr.arb          # Traduction francaise
│       └── l10n.yaml           # Configuration
│
└── generated/
    └── l10n/
        ├── app_localizations.dart
        ├── app_localizations_en.dart
        └── app_localizations_fr.dart
```

### Configuration l10n.yaml

```yaml
arb-dir: lib/core/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-dir: lib/generated/l10n
synthetic-package: false
nullable-getter: false
```

## 2. Format ARB

### Structure de base

```json
{
  "@@locale": "en",

  "appTitle": "TicTacToe",
  "@appTitle": {
    "description": "The application title"
  },

  "welcomeMessage": "Welcome, {username}!",
  "@welcomeMessage": {
    "description": "Welcome message with username",
    "placeholders": {
      "username": {
        "type": "String",
        "example": "John"
      }
    }
  }
}
```

### Placeholders

```json
{
  "itemCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@itemCount": {
    "description": "Number of items",
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  },

  "price": "Price: {amount}",
  "@price": {
    "placeholders": {
      "amount": {
        "type": "double",
        "format": "currency",
        "optionalParameters": {
          "symbol": "$",
          "decimalDigits": 2
        }
      }
    }
  },

  "dateFormat": "Created on {date}",
  "@dateFormat": {
    "placeholders": {
      "date": {
        "type": "DateTime",
        "format": "yMMMd"
      }
    }
  }
}
```

### Pluriels

```json
{
  "playerScore": "{score, plural, =0{No points} =1{1 point} other{{score} points}}",
  "@playerScore": {
    "placeholders": {
      "score": {
        "type": "int"
      }
    }
  },

  "remainingMoves": "{count, plural, =0{No moves left} =1{1 move remaining} other{{count} moves remaining}}",
  "@remainingMoves": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}
```

### Select (gender, etc.)

```json
{
  "playerTurn": "{gender, select, male{His turn} female{Her turn} other{Their turn}}",
  "@playerTurn": {
    "placeholders": {
      "gender": {
        "type": "String"
      }
    }
  }
}
```

## 3. Utilisation dans le code

### Acces aux traductions

```dart
import 'package:flutter/material.dart';
import 'package:tictactoe/generated/l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Text(l10n.appTitle),
        Text(l10n.welcomeMessage('Alice')),
        Text(l10n.itemCount(5)),
      ],
    );
  }
}
```

### Extension pour acces simplifie

```dart
// core/extensions/context_extensions.dart

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

// Utilisation
Text(context.l10n.appTitle);
```

### Configuration MaterialApp

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tictactoe/generated/l10n/app_localizations.dart';

MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  locale: settingsProvider.locale, // Depuis les settings
)
```

## 4. Gestion de la locale

### Provider de locale

```dart
// features/settings/presentation/providers/locale_provider.dart

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null);

  void setLocale(Locale locale) {
    state = locale;
  }

  void useSystemLocale() {
    state = null; // null = utiliser la locale systeme
  }
}
```

### Persistance

```dart
class LocaleNotifier extends StateNotifier<Locale?> {
  final SharedPreferences _prefs;
  static const _key = 'app_locale';

  LocaleNotifier(this._prefs) : super(null) {
    _loadLocale();
  }

  void _loadLocale() {
    final code = _prefs.getString(_key);
    if (code != null) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_key, locale.languageCode);
    state = locale;
  }
}
```

## 5. Patterns a suivre

### Bon : Utiliser les traductions

```dart
// Bon
Text(context.l10n.gameOver);
Text(context.l10n.playerWins(playerName));

// Bon : Boutons et labels
ElevatedButton(
  onPressed: onStart,
  child: Text(context.l10n.startGame),
);
```

### Mauvais : Strings en dur

```dart
// INTERDIT - String hardcodee
Text('Game Over');

// INTERDIT - Concatenation manuelle
Text('Player $name wins!');

// INTERDIT - Dans le code
throw Exception('Invalid move'); // Utiliser des codes d'erreur
```

### Exceptions et logs

```dart
// Les messages d'erreur techniques restent en anglais (logs)
logger.error('Failed to connect: $error');

// Les messages utilisateur sont localises
showSnackBar(context.l10n.connectionError);

// Exceptions avec codes
class GameException implements Exception {
  final String code; // 'invalid_move', 'game_full'
  GameException(this.code);

  String getMessage(AppLocalizations l10n) {
    switch (code) {
      case 'invalid_move': return l10n.errorInvalidMove;
      case 'game_full': return l10n.errorGameFull;
      default: return l10n.errorUnknown;
    }
  }
}
```

## 6. Conventions de nommage ARB

### Prefixes par contexte

```json
{
  "commonCancel": "Cancel",
  "commonConfirm": "Confirm",
  "commonError": "An error occurred",

  "gameTitle": "Game",
  "gameStart": "Start Game",
  "gameOver": "Game Over",
  "gamePlayerTurn": "{player}'s turn",

  "settingsTitle": "Settings",
  "settingsLanguage": "Language",
  "settingsDarkMode": "Dark Mode",

  "authLogin": "Login",
  "authLogout": "Logout",
  "authEmailRequired": "Email is required",

  "errorNetwork": "Network error",
  "errorUnknown": "Something went wrong"
}
```

### Groupement logique

```json
{
  "@@locale": "en",

  "_____COMMON_____": "Common strings used across the app",
  "commonOk": "OK",
  "commonCancel": "Cancel",

  "_____GAME_____": "Game feature strings",
  "gameTitle": "Game",

  "_____SETTINGS_____": "Settings feature strings",
  "settingsTitle": "Settings"
}
```

## 7. Workflow de traduction

### 1. Ajouter une string (developpeur)

```json
// app_en.arb (source)
{
  "newFeatureTitle": "New Feature",
  "@newFeatureTitle": {
    "description": "Title for the new feature screen"
  }
}
```

### 2. Generer le code

```bash
flutter gen-l10n
```

### 3. Ajouter les traductions

```json
// app_fr.arb
{
  "newFeatureTitle": "Nouvelle Fonctionnalite"
}
```

### 4. Verifier les traductions manquantes

```bash
# Les clefs manquantes dans app_fr.arb utiliseront app_en.arb par defaut
# Le build affichera des warnings pour les clefs manquantes
```

## 8. Tests de localisation

```dart
testWidgets('should display localized text in French', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MyWidget(),
    ),
  );

  expect(find.text('Nouvelle Partie'), findsOneWidget);
});

testWidgets('should handle plurals correctly', (tester) async {
  await tester.pumpWidget(/* ... */);

  // Test avec 0
  expect(find.text('No items'), findsOneWidget);

  // Test avec 1
  expect(find.text('1 item'), findsOneWidget);

  // Test avec plusieurs
  expect(find.text('5 items'), findsOneWidget);
});
```

## Checklist

- [ ] Toutes les strings UI sont dans les fichiers ARB
- [ ] Aucune string hardcodee dans les widgets
- [ ] Descriptions `@key` pour chaque traduction
- [ ] Placeholders documentes avec type et exemple
- [ ] Pluriels geres avec la syntaxe ICU
- [ ] Extension `context.l10n` utilisee pour acces simple
- [ ] Locale persistee dans les preferences
- [ ] Tests avec differentes locales
- [ ] Fichier de traduction FR a jour avec EN
- [ ] `flutter gen-l10n` execute apres modifications ARB
