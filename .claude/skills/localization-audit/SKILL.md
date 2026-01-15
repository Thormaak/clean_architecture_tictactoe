---
name: localization-audit
description: Audit Flutter localization for hardcoded strings, missing translations, and i18n best practices. Use when reviewing internationalization or checking for untranslated text.
allowed-tools: Read, Grep, Glob
---

# Localization Audit Skill

Tu es un expert en internationalisation Flutter. Quand ce skill est invoque, tu dois auditer le code pour identifier les problemes de localisation et produire un rapport detaille.

## Processus d'audit

### Phase 1 : Scan de la configuration

1. **Localiser les fichiers ARB**
   ```
   Glob: lib/**/l10n/*.arb
   Glob: lib/**/*.arb
   ```

2. **Verifier la configuration**
   ```
   Glob: **/l10n.yaml
   Read: pubspec.yaml (section flutter > generate)
   ```

3. **Lister les locales supportees**
   - Compter les fichiers ARB par locale
   - Verifier la coherence

### Phase 2 : Audit des strings hardcodees

```
Grep dans lib/**/presentation/:
- "Text\(['\"][A-Z]" → String hardcodee potentielle
- "Text\(['\"][a-z]" → String hardcodee potentielle
- "'[A-Z][a-z]+ [a-z]+'" → Phrase hardcodee
- "title: ['\"]" → Titre hardcode
- "label: ['\"]" → Label hardcode
- "hintText: ['\"]" → Hint hardcode
- "errorText: ['\"]" → Error hardcode

Exclure:
- Patterns regex
- Constantes de routes
- Logs et debugPrint
- Keys et identifiants
```

### Phase 3 : Comparaison des fichiers ARB

```
1. Lire le fichier source (app_en.arb)
2. Extraire toutes les clefs (sans @)
3. Pour chaque autre locale (app_fr.arb, etc.):
   - Verifier que toutes les clefs existent
   - Lister les clefs manquantes
   - Lister les clefs en trop (orphelines)
```

### Phase 4 : Audit des placeholders

```
Verifier dans les ARB:
- Chaque placeholder a une description
- Les types sont specifies (String, int, double, DateTime)
- Les pluriels utilisent la syntaxe ICU correcte
```

### Phase 5 : Audit de l'utilisation

```
Grep:
- "AppLocalizations\.of\(context\)" → Utilisation correcte
- "context\.l10n\." → Extension (si definie)
- Sans import de AppLocalizations → Potentiel oubli
```

### Phase 6 : Audit des bonnes pratiques

```
Verifier:
- Extension context.l10n definie et utilisee
- Locale persistee (SharedPreferences)
- Gestion du fallback
- Tests de localisation
```

## Format du rapport

```markdown
# Audit Localisation

## Resume
- Locales supportees : en, fr
- Clefs de traduction : X
- Strings hardcodees : X
- Traductions manquantes : X

---

## Strings hardcodees (CRITIQUE)

### 1. String non localisee
- **Fichier** : lib/features/game/presentation/views/game_view.dart:42
- **Code** :
  ```dart
  Text('Game Over')
  ```
- **Solution** :
  ```dart
  Text(context.l10n.gameOver)
  ```

---

## Traductions manquantes

### Locale: fr
Clefs manquantes par rapport a en:
- `newFeatureTitle`
- `settingsSubtitle`
- `errorNetworkMessage`

---

## Clefs orphelines

### Locale: fr
Clefs presentes en fr mais pas en en:
- `oldFeature` (a supprimer)

---

## Placeholders sans documentation

- `welcomeMessage` : placeholder `{name}` sans description
- `itemCount` : placeholder `{count}` sans type

---

## Problemes de syntaxe ICU

### 1. Pluriel mal forme
- **Fichier** : app_en.arb
- **Clef** : `itemCount`
- **Actuel** : `"{count} items"`
- **Correct** : `"{count, plural, =0{No items} =1{1 item} other{{count} items}}"`

---

## Recommandations

1. Ajouter les X traductions manquantes en francais
2. Supprimer les X clefs orphelines
3. Documenter les X placeholders
4. Localiser les X strings hardcodees
```

## Niveaux de severite

| Niveau | Type de probleme |
|--------|-----------------|
| **Critique** | String hardcodee visible par l'utilisateur |
| **Majeur** | Traduction manquante, pluriel incorrect |
| **Mineur** | Placeholder sans doc, clef orpheline |

## Patterns a ignorer

Ces patterns ne sont PAS des strings hardcodees :

```dart
// Routes
context.go('/home');

// Keys
Key('game-board');

// Logs
debugPrint('Debug: $value');
logger.info('Processing...');

// Regex
RegExp(r'^[a-z]+$');

// Identifiants
'user_id';
'game_status';

// Assets
'assets/images/logo.png';

// Packages
'package:flutter/material.dart';
```

## References

@.claude/rules/localization-patterns.md
