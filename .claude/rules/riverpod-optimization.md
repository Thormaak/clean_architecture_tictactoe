# Riverpod Performance Rules

Ces règles s'appliquent aux projets utilisant Riverpod pour le state management.

## 1. watch vs read vs select

### select() - Rebuild ciblé (recommandé)

```dart
// Rebuild UNIQUEMENT si 'isLoading' change
final isLoading = ref.watch(userProvider.select((state) => state.isLoading));

// Rebuild UNIQUEMENT si 'name' change
final userName = ref.watch(userProvider.select((user) => user.name));
```

### watch() - Rebuild complet

```dart
// Rebuild si N'IMPORTE QUELLE propriété change
// À utiliser seulement si tout l'état est nécessaire
final user = ref.watch(userProvider);
```

### read() - Pas de rebuild (callbacks)

```dart
// TOUJOURS read() dans les callbacks
onPressed: () => ref.read(counterProvider.notifier).increment(),
onTap: () => ref.read(authProvider.notifier).logout(),
```

## 2. JAMAIS watch() dans un callback

```dart
// INTERDIT - Peut causer des rebuilds infinis
onPressed: () => ref.watch(provider.notifier).doSomething(), // JAMAIS

// CORRECT
onPressed: () => ref.read(provider.notifier).doSomething(),
```

## 3. Providers granulaires

```dart
// MAUVAIS : Un provider monolithique
class AppState {
  final User user;
  final List<Product> products;
  final Cart cart;
  final Settings settings;
}

final appProvider = StateNotifierProvider<AppNotifier, AppState>(...);

// BON : Providers séparés par domaine
final userProvider = StateNotifierProvider<UserNotifier, User>(...);
final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>(...);
final cartProvider = StateNotifierProvider<CartNotifier, Cart>(...);
final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>(...);
```

## 4. AsyncValue handling efficace

```dart
// BON : Pattern when() avec gestion complète
final asyncData = ref.watch(dataProvider);

return asyncData.when(
  data: (data) => DataWidget(data: data),
  loading: () => const LoadingWidget(),
  error: (error, stack) => ErrorWidget(error: error),
);

// BON : Valeur par défaut avec valueOrNull
final data = ref.watch(dataProvider).valueOrNull;
if (data == null) return const LoadingWidget();
return DataWidget(data: data);
```

## 5. Provider families et autoDispose

```dart
// BON : Family pour providers paramétrés
final userByIdProvider = FutureProvider.family<User, String>((ref, userId) async {
  return ref.read(userRepositoryProvider).getUser(userId);
});

// BON : autoDispose pour libérer la mémoire
final searchProvider = FutureProvider.autoDispose.family<List<Item>, String>((ref, query) async {
  return ref.read(searchRepositoryProvider).search(query);
});
```

## 6. keepAlive stratégique

```dart
final expensiveProvider = FutureProvider.autoDispose<ExpensiveData>((ref) async {
  // Garde en cache pendant 30 secondes après le dernier listener
  final link = ref.keepAlive();

  final timer = Timer(const Duration(seconds: 30), link.close);
  ref.onDispose(timer.cancel);

  return await fetchExpensiveData();
});
```

## 7. Éviter les rebuilds avec listen

```dart
// Si vous n'avez besoin que d'écouter sans rebuild
@override
Widget build(BuildContext context, WidgetRef ref) {
  ref.listen<AuthState>(authProvider, (previous, next) {
    if (next.isLoggedOut) {
      context.go('/login');
    }
  });

  // Le widget ne rebuild pas quand authProvider change
  return const HomeContent();
}
```

## Checklist rapide

- [ ] `select()` pour chaque propriété spécifique
- [ ] `read()` dans TOUS les callbacks (onPressed, onTap, etc.)
- [ ] JAMAIS `watch()` dans un callback
- [ ] Providers séparés par domaine
- [ ] `autoDispose` sur les providers temporaires
- [ ] `family` pour les providers paramétrés
- [ ] `listen()` quand rebuild non nécessaire
