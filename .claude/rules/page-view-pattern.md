# Page/View Pattern Rules

Ces regles s'appliquent a la separation Page/View dans la couche Presentation.

## 1. Vue d'ensemble

Le pattern Page/View separe la logique (state management, navigation) de l'UI pure.

```
┌─────────────────────────────────────────────────────────────┐
│                         PAGE                                │
│  - ConsumerWidget / ConsumerStatefulWidget                  │
│  - State management (ref.watch, ref.read)                   │
│  - Navigation (GoRouter)                                    │
│  - Lifecycle (initState, dispose)                           │
│  - Callbacks vers providers                                 │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ Props (donnees + callbacks)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                         VIEW                                │
│  - StatelessWidget                                          │
│  - UI pure (widgets, layouts, animations)                   │
│  - Localization (AppLocalizations.of(context))              │
│  - Aucun state management                                   │
└─────────────────────────────────────────────────────────────┘
```

## 2. Responsabilites

| Composant | Responsabilite | Type |
|-----------|----------------|------|
| **Page** | Container avec state management, routing, providers | `ConsumerWidget` / `ConsumerStatefulWidget` |
| **View** | Widget pur, UI uniquement, pas de state management | `StatelessWidget` |

### Page (Container)

```dart
// ✅ Page = Container avec state management
class UserPage extends ConsumerWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State management
    final userState = ref.watch(userProvider);

    // Transformation state → View
    return userState.when(
      data: (user) => UserView(
        name: user.name,
        email: user.email,
        onEdit: () => ref.read(userProvider.notifier).edit(),
        onDelete: () => _confirmDelete(context, ref),
      ),
      loading: () => const LoadingView(),
      error: (e, s) => ErrorView(error: e),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    // Logique de navigation/dialog
    showDialog(...);
  }
}
```

### View (UI Pure)

```dart
// ✅ View = Widget pur
class UserView extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserView({
    super.key,
    required this.name,
    required this.email,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.userProfile)),
      body: Column(
        children: [
          Text(name),
          Text(email),
          ElevatedButton(onPressed: onEdit, child: Text(l10n.edit)),
          ElevatedButton(onPressed: onDelete, child: Text(l10n.delete)),
        ],
      ),
    );
  }
}
```

## 3. Regles de localisation (l10n)

| Type de donnee | Ou la gerer ? |
|----------------|---------------|
| **Labels statiques** (titres, boutons, textes fixes) | ✅ Dans la **View** via `AppLocalizations.of(context)!` |
| **Donnees dynamiques** (nom utilisateur, etat, erreurs) | ✅ Passees en **props** de la Page vers la View |

### Exemples

```dart
// ✅ BON : l10n dans la View pour labels statiques
class SettingsView extends StatelessWidget {
  final VoidCallback onBack;
  final Widget languageSelector;  // Widget dynamique

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),      // ✅ Label statique
        leading: BackButton(onPressed: onBack),
      ),
      body: Column(
        children: [
          Text(l10n.language),           // ✅ Label statique
          languageSelector,              // ✅ Widget dynamique passe en prop
        ],
      ),
    );
  }
}

// ✅ BON : Page simple sans l10n
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsView(
      onBack: () => context.pop(),
      languageSelector: const LanguageSelector(),
    );
  }
}
```

### Anti-patterns

```dart
// ❌ INTERDIT : Passer les labels l10n en props
class BadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BadView(
      title: l10n.settings,       // ❌ Label passe en prop
      buttonLabel: l10n.save,     // ❌ Label passe en prop
    );
  }
}

class BadView extends StatelessWidget {
  final String title;        // ❌ Devrait utiliser l10n directement
  final String buttonLabel;  // ❌ Devrait utiliser l10n directement
  // ...
}
```

## 4. Types de props

### Props obligatoires

| Type | Usage | Exemple |
|------|-------|---------|
| `VoidCallback` | Actions simples | `onBack`, `onSubmit`, `onDelete` |
| `ValueChanged<T>` | Actions avec parametre | `onSelect`, `onCodeChanged` |
| Data types | Donnees dynamiques | `String name`, `bool isLoading` |

### Props optionnelles

| Type | Usage | Exemple |
|------|-------|---------|
| `VoidCallback?` | Actions conditionnelles | `onJoin` (null si disabled) |
| `String?` | Donnees optionnelles | `errorMessage`, `guestName` |
| `Widget` | Slots pour widgets dynamiques | `languageSelector` |

## 5. Pages avec state local

Quand la Page a besoin de state local (TextField, Timer, animations), utiliser `ConsumerStatefulWidget`.

```dart
class LobbyChoicePage extends ConsumerStatefulWidget {
  const LobbyChoicePage({super.key});

  @override
  ConsumerState<LobbyChoicePage> createState() => _LobbyChoicePageState();
}

class _LobbyChoicePageState extends ConsumerState<LobbyChoicePage> {
  // State local dans la Page
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LobbyChoiceView(
      onBack: () => context.pop(),
      nicknameController: _nicknameController,  // Passe en prop
      onCreateLobby: _handleCreateLobby,
      onJoinLobby: _handleJoinLobby,
    );
  }

  Future<void> _handleCreateLobby() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isNotEmpty) {
      await ref.read(lobbyNotifierProvider.notifier).setNickname(nickname);
    }
    if (mounted) {
      const CreateLobbyRoute().push(context);
    }
  }
}
```

## 6. Navigation dans les Pages

```dart
class GamePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    // ✅ Navigation reactive dans build avec PostFrameCallback
    gameState.maybeWhen(
      finished: (result) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            ResultRoute(result).go(context);
          }
        });
      },
      orElse: () {},
    );

    return GameView(
      state: gameState,
      onCellTap: (index) => ref.read(gameProvider.notifier).play(index),
      onRestart: () => ref.read(gameProvider.notifier).restart(),
    );
  }
}
```

## 7. Structure des fichiers

```
lib/features/{feature}/presentation/
├── pages/
│   └── {name}_page.dart      # Container avec state management
├── views/
│   └── {name}_view.dart      # Widget pur (UI)
├── widgets/
│   └── {name}_widget.dart    # Composants reutilisables
└── providers/
    └── {name}_provider.dart  # State management
```

## 8. Conventions de nommage

| Type | Pattern | Exemple |
|------|---------|---------|
| Page | `{Name}Page` | `UserPage`, `SettingsPage` |
| View | `{Name}View` | `UserView`, `SettingsView` |
| Page file | `{name}_page.dart` | `user_page.dart` |
| View file | `{name}_view.dart` | `user_view.dart` |

## 9. Optimisations Performance

### Const constructors dans les Views

```dart
// ✅ View avec const constructor
class SettingsView extends StatelessWidget {
  final VoidCallback onBack;

  const SettingsView({super.key, required this.onBack});  // const!

  @override
  Widget build(BuildContext context) { ... }
}

// ✅ Page utilisant const
return const SettingsView(onBack: _handleBack);  // Evite rebuild inutile
```

### Select pour granularite fine

```dart
// ✅ Page avec select - rebuild uniquement si `isLoading` change
class UserPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(userProvider.select((s) => s.isLoading));
    final name = ref.watch(userProvider.select((s) => s.name));

    return UserView(isLoading: isLoading, name: name, ...);
  }
}
```

### Widgets statiques extraits

```dart
// ✅ Extraire les parties statiques
class GameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _GameHeader(),      // Widget const separe
        _GameBoard(board: board), // Widget dynamique
        const _GameFooter(),      // Widget const separe
      ],
    );
  }
}

class _GameHeader extends StatelessWidget {
  const _GameHeader();  // Pas de rebuild
  @override
  Widget build(BuildContext context) => ...;
}
```

---

## 10. Patterns de Mapping State → View

### AsyncValue mapping

```dart
// ✅ Pattern standard pour AsyncValue
class UsersPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUsers = ref.watch(usersProvider);

    return asyncUsers.when(
      data: (users) => UsersView(users: users, onRefresh: _refresh),
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(message: e.toString(), onRetry: _refresh),
    );
  }
}
```

### Freezed union mapping

```dart
// ✅ Pattern pour Freezed unions
class LobbyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lobbyProvider);

    return state.when(
      initial: () => const LoadingView(),
      waiting: (code) => WaitingView(code: code, onCancel: _cancel),
      ready: (lobby) => ReadyView(lobby: lobby),
      error: (msg) => ErrorView(message: msg),
    );
  }
}
```

### Transformation de donnees

```dart
// ✅ Transformer dans la Page, pas dans la View
class OrdersPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    // Transformation ici, pas dans la View
    final pendingCount = orders.where((o) => o.isPending).length;
    final totalAmount = orders.fold(0.0, (sum, o) => sum + o.amount);

    return OrdersView(
      orders: orders,
      pendingCount: pendingCount,
      totalAmount: totalAmount,
    );
  }
}
```

---

## 11. Composition de Views

### Slots pour widgets dynamiques

```dart
// ✅ View avec slots
class SettingsView extends StatelessWidget {
  final VoidCallback onBack;
  final Widget languageSelector;  // Slot
  final Widget themeSelector;     // Slot

  const SettingsView({
    super.key,
    required this.onBack,
    required this.languageSelector,
    required this.themeSelector,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        languageSelector,  // Widget injecte
        themeSelector,     // Widget injecte
      ],
    );
  }
}

// Page injecte les widgets concrets
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsView(
      onBack: () => context.pop(),
      languageSelector: const LanguageSelector(),
      themeSelector: const ThemeSelector(),
    );
  }
}
```

### Builder pattern pour listes

```dart
// ✅ View avec builder
class ItemListView extends StatelessWidget {
  final List<Item> items;
  final Widget Function(Item) itemBuilder;  // Builder

  const ItemListView({
    super.key,
    required this.items,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) => itemBuilder(items[i]),
    );
  }
}
```

---

## 12. Extension l10n (optionnel)

```dart
// core/extensions/context_extensions.dart
extension LocalizationX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

// Usage dans View
class UserView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(context.l10n.userName);  // Plus concis
  }
}
```

---

## 13. Testabilite

### View testable en isolation

```dart
// test/presentation/views/user_view_test.dart
testWidgets('UserView displays name', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const UserView(
        name: 'Alice',
        onEdit: _noop,
      ),
    ),
  );

  expect(find.text('Alice'), findsOneWidget);
});
```

### Page testable avec mocks

```dart
// test/presentation/pages/user_page_test.dart
testWidgets('UserPage shows loading', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userProvider.overrideWith((_) => const AsyncLoading()),
      ],
      child: const MaterialApp(home: UserPage()),
    ),
  );

  expect(find.byType(LoadingView), findsOneWidget);
});
```

---

## 14. Decision rapide

```
Ou mettre ce code ?
│
├─ State management (ref.watch/read) ──────► PAGE
├─ Navigation (context.push/pop/go) ───────► PAGE
├─ Controllers (TextField, Animation) ─────► PAGE (state local)
├─ Timers, Streams subscriptions ──────────► PAGE (dispose)
├─ Callbacks vers providers ───────────────► PAGE
│
├─ Labels statiques (titres, boutons) ─────► VIEW (l10n)
├─ Layout, Scaffold, AppBar ───────────────► VIEW
├─ Animations UI (flutter_animate) ────────► VIEW
├─ Theme, couleurs, styles ────────────────► VIEW
└─ Widgets enfants ────────────────────────► VIEW
```

---

## Checklist

- [ ] Chaque Page a une View correspondante
- [ ] Views sont des `StatelessWidget`
- [ ] Pages sont des `ConsumerWidget` ou `ConsumerStatefulWidget`
- [ ] Labels statiques utilisent `AppLocalizations.of(context)!` dans la View
- [ ] Donnees dynamiques passees en props de Page vers View
- [ ] Aucun `ref.watch`/`ref.read` dans les Views
- [ ] Navigation geree dans les Pages (pas dans les Views)
- [ ] State local (controllers, timers) dans les Pages
- [ ] `const` constructors sur les Views
- [ ] `select()` pour granularite fine des rebuilds
- [ ] Transformations de donnees dans la Page
