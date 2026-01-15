# Riverpod Performance Anti-Patterns

Ce document liste les anti-patterns Riverpod à éviter.

---

## 1. watch() dans les callbacks

### Anti-pattern : watch() dans onPressed

```dart
// CRITIQUE : watch() dans un callback - peut causer des rebuilds infinis
Widget build(BuildContext context, WidgetRef ref) {
  return ElevatedButton(
    onPressed: () {
      ref.watch(counterProvider.notifier).increment(); // JAMAIS !
    },
    child: const Text('Increment'),
  );
}
```

```dart
// BON : read() dans les callbacks
Widget build(BuildContext context, WidgetRef ref) {
  return ElevatedButton(
    onPressed: () {
      ref.read(counterProvider.notifier).increment();
    },
    child: const Text('Increment'),
  );
}
```

### Anti-pattern : watch() dans initState ou callbacks async

```dart
// MAUVAIS : watch() hors du build
Future<void> _loadData() async {
  final user = ref.watch(userProvider); // JAMAIS !
  await doSomething(user);
}
```

```dart
// BON : read() pour les opérations ponctuelles
Future<void> _loadData() async {
  final user = ref.read(userProvider);
  await doSomething(user);
}
```

---

## 2. watch() sans select()

### Anti-pattern : Observer tout l'état

```dart
// MAUVAIS : Rebuild si N'IMPORTE QUELLE propriété change
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(userProvider);

  // N'utilise que le nom, mais rebuild pour tout changement
  return Text(user.name);
}
```

```dart
// BON : Select pour la propriété utilisée
Widget build(BuildContext context, WidgetRef ref) {
  final name = ref.watch(userProvider.select((u) => u.name));

  return Text(name);
}
```

### Anti-pattern : Multiple watch sans select

```dart
// MAUVAIS : Rebuild complet à chaque changement
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(complexStateProvider);

  return Column(
    children: [
      Text(state.title),      // Utilise seulement title
      Text('${state.count}'), // Utilise seulement count
    ],
  );
}
```

```dart
// BON : Select séparés ou combinés
Widget build(BuildContext context, WidgetRef ref) {
  final title = ref.watch(complexStateProvider.select((s) => s.title));
  final count = ref.watch(complexStateProvider.select((s) => s.count));

  return Column(
    children: [
      Text(title),
      Text('$count'),
    ],
  );
}
```

---

## 3. Provider monolithique

### Anti-pattern : Tout dans un seul provider

```dart
// MAUVAIS : État global monolithique
class AppState {
  final User? user;
  final List<Product> products;
  final Cart cart;
  final Settings settings;
  final List<Notification> notifications;
  final ThemeMode theme;
  // ... tout ensemble
}

final appStateProvider = StateNotifierProvider<AppNotifier, AppState>(...);

// Problème : Changer le thème rebuild tous les widgets qui watch ce provider
```

```dart
// BON : Providers séparés par domaine
final userProvider = StateNotifierProvider<UserNotifier, User?>(...);
final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>(...);
final cartProvider = StateNotifierProvider<CartNotifier, Cart>(...);
final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>(...);
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Chaque widget n'observe que ce dont il a besoin
```

---

## 4. Oublier autoDispose

### Anti-pattern : Providers sans autoDispose pour données temporaires

```dart
// MAUVAIS : Reste en mémoire indéfiniment
final searchResultsProvider = FutureProvider.family<List<Item>, String>(
  (ref, query) async {
    return searchItems(query);
  },
);

// Problème : Chaque recherche crée un provider qui reste en mémoire
```

```dart
// BON : autoDispose pour libérer la mémoire
final searchResultsProvider = FutureProvider.autoDispose.family<List<Item>, String>(
  (ref, query) async {
    return searchItems(query);
  },
);
```

### Anti-pattern : Créer des providers dynamiquement sans cleanup

```dart
// MAUVAIS : Fuite mémoire progressive
Widget build(BuildContext context, WidgetRef ref) {
  // Nouveau provider pour chaque userId différent
  final user = ref.watch(userByIdProvider(userId));
  // Ces providers ne sont jamais libérés !
}
```

```dart
// BON : autoDispose sur les providers famille
final userByIdProvider = FutureProvider.autoDispose.family<User, String>(
  (ref, userId) async {
    return fetchUser(userId);
  },
);
```

---

## 5. AsyncValue mal géré

### Anti-pattern : Ignorer les états

```dart
// MAUVAIS : Ne gère pas loading et error
Widget build(BuildContext context, WidgetRef ref) {
  final asyncData = ref.watch(dataProvider);

  return Text(asyncData.value?.name ?? ''); // Crash potentiel, UX pauvre
}
```

```dart
// BON : Gestion complète
Widget build(BuildContext context, WidgetRef ref) {
  final asyncData = ref.watch(dataProvider);

  return asyncData.when(
    data: (data) => Text(data.name),
    loading: () => const CircularProgressIndicator(),
    error: (error, stack) => Text('Error: $error'),
  );
}
```

### Anti-pattern : Multiples when() imbriqués

```dart
// MAUVAIS : Complexe et difficile à maintenir
Widget build(BuildContext context, WidgetRef ref) {
  final userAsync = ref.watch(userProvider);
  final settingsAsync = ref.watch(settingsProvider);
  final dataAsync = ref.watch(dataProvider);

  return userAsync.when(
    data: (user) => settingsAsync.when(
      data: (settings) => dataAsync.when(
        data: (data) => Content(user: user, settings: settings, data: data),
        loading: () => const Loading(),
        error: (e, s) => Error(e),
      ),
      loading: () => const Loading(),
      error: (e, s) => Error(e),
    ),
    loading: () => const Loading(),
    error: (e, s) => Error(e),
  );
}
```

```dart
// BON : Utiliser un provider combiné
final combinedProvider = FutureProvider<CombinedData>((ref) async {
  final user = await ref.watch(userProvider.future);
  final settings = await ref.watch(settingsProvider.future);
  final data = await ref.watch(dataProvider.future);
  return CombinedData(user: user, settings: settings, data: data);
});

Widget build(BuildContext context, WidgetRef ref) {
  final combinedAsync = ref.watch(combinedProvider);

  return combinedAsync.when(
    data: (combined) => Content(
      user: combined.user,
      settings: combined.settings,
      data: combined.data,
    ),
    loading: () => const Loading(),
    error: (e, s) => Error(e),
  );
}
```

---

## 6. Mutation d'état

### Anti-pattern : Mutation directe de l'état

```dart
// MAUVAIS : Mutation de l'état existant
class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]);

  void addTodo(Todo todo) {
    state.add(todo); // MUTATION ! Riverpod ne détecte pas le changement
  }

  void removeTodo(String id) {
    state.removeWhere((t) => t.id == id); // MUTATION !
  }
}
```

```dart
// BON : Créer un nouvel état
class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]);

  void addTodo(Todo todo) {
    state = [...state, todo]; // Nouvel état
  }

  void removeTodo(String id) {
    state = state.where((t) => t.id != id).toList(); // Nouvel état
  }
}
```

### Anti-pattern : Mutation d'objets imbriqués

```dart
// MAUVAIS : Mutation imbriquée
void updateUserName(String name) {
  state.user.name = name; // MUTATION !
}
```

```dart
// BON : copyWith pour les objets imbriqués
void updateUserName(String name) {
  state = state.copyWith(
    user: state.user.copyWith(name: name),
  );
}
```

---

## 7. Provider dans build

### Anti-pattern : Créer des providers dans build

```dart
// MAUVAIS : Nouveau provider à chaque rebuild
Widget build(BuildContext context, WidgetRef ref) {
  final myProvider = Provider<int>((ref) => 42); // JAMAIS !
  final value = ref.watch(myProvider);
  return Text('$value');
}
```

```dart
// BON : Providers définis au top-level
final myProvider = Provider<int>((ref) => 42);

Widget build(BuildContext context, WidgetRef ref) {
  final value = ref.watch(myProvider);
  return Text('$value');
}
```

---

## 8. Circular dependencies

### Anti-pattern : Dépendances circulaires

```dart
// MAUVAIS : A dépend de B, B dépend de A
final providerA = Provider<A>((ref) {
  final b = ref.watch(providerB); // Dépend de B
  return A(b);
});

final providerB = Provider<B>((ref) {
  final a = ref.watch(providerA); // Dépend de A -> Erreur !
  return B(a);
});
```

```dart
// BON : Restructurer les dépendances
final sharedStateProvider = Provider<SharedState>((ref) => SharedState());

final providerA = Provider<A>((ref) {
  final shared = ref.watch(sharedStateProvider);
  return A(shared);
});

final providerB = Provider<B>((ref) {
  final shared = ref.watch(sharedStateProvider);
  return B(shared);
});
```

---

## 9. Ignorer onDispose

### Anti-pattern : Ressources non libérées

```dart
// MAUVAIS : Timer jamais annulé
final timerProvider = Provider<void>((ref) {
  Timer.periodic(Duration(seconds: 1), (timer) {
    print('tick');
  });
  // Timer continue même après dispose du provider !
});
```

```dart
// BON : Cleanup avec onDispose
final timerProvider = Provider<void>((ref) {
  final timer = Timer.periodic(Duration(seconds: 1), (timer) {
    print('tick');
  });

  ref.onDispose(() {
    timer.cancel();
  });
});
```

---

## 10. read() dans build

### Anti-pattern : read() pour des valeurs réactives

```dart
// MAUVAIS : Ne se met pas à jour quand le provider change
Widget build(BuildContext context, WidgetRef ref) {
  final count = ref.read(counterProvider); // Ne rebuild jamais !
  return Text('Count: $count');
}
```

```dart
// BON : watch() pour les valeurs affichées
Widget build(BuildContext context, WidgetRef ref) {
  final count = ref.watch(counterProvider);
  return Text('Count: $count');
}
```

---

## Checklist de détection

| Anti-pattern | Comment détecter | Impact |
|--------------|------------------|--------|
| watch() callback | `ref.watch` dans onPressed/onTap | Critique |
| watch() sans select | `ref.watch(provider)` sans `.select()` | Majeur |
| Provider monolithique | StateNotifier avec >5 propriétés | Majeur |
| Pas d'autoDispose | `FutureProvider.family` sans autoDispose | Majeur |
| AsyncValue ignoré | `.value` ou `.valueOrNull` sans fallback | Majeur |
| Mutation d'état | `.add()`, `.remove()` sur state | Critique |
| Provider dans build | `Provider((ref) =>` dans build() | Critique |
| Dépendances circulaires | Erreur runtime StackOverflow | Critique |
| onDispose manquant | Timer, Stream sans cleanup | Majeur |
| read() dans build | `ref.read()` pour affichage | Majeur |
