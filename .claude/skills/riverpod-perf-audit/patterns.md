# Riverpod Performance Patterns

Ce document détaille les patterns d'optimisation Riverpod.

---

## 1. Select Pattern

### Pattern : Rebuild ciblé avec select()

```dart
class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuild UNIQUEMENT si 'name' change
    final userName = ref.watch(userProvider.select((user) => user.name));

    // Rebuild UNIQUEMENT si 'avatarUrl' change
    final avatarUrl = ref.watch(userProvider.select((user) => user.avatarUrl));

    return Column(
      children: [
        Avatar(url: avatarUrl),
        Text(userName),
      ],
    );
  }
}
```

### Pattern : Select multiple valeurs

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Combine plusieurs valeurs en un seul select
  final (name, email) = ref.watch(
    userProvider.select((user) => (user.name, user.email)),
  );

  return Column(
    children: [
      Text(name),
      Text(email),
    ],
  );
}
```

### Pattern : Select sur collections

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Rebuild seulement si le nombre d'items change
  final itemCount = ref.watch(
    itemsProvider.select((items) => items.length),
  );

  // Rebuild seulement si un item spécifique change
  final firstItem = ref.watch(
    itemsProvider.select((items) => items.isNotEmpty ? items.first : null),
  );

  return Text('$itemCount items');
}
```

---

## 2. Read Pattern

### Pattern : read() dans les callbacks

```dart
class CounterPage extends ConsumerWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Column(
      children: [
        Text('Count: $count'),
        ElevatedButton(
          // read() = pas de rebuild quand le provider change
          onPressed: () => ref.read(counterProvider.notifier).increment(),
          child: const Text('Increment'),
        ),
        ElevatedButton(
          // read() pour accéder à un autre provider
          onPressed: () {
            final user = ref.read(userProvider);
            ref.read(analyticsProvider).logEvent('clicked', user.id);
          },
          child: const Text('Track'),
        ),
      ],
    );
  }
}
```

---

## 3. Provider Granularity Pattern

### Pattern : Providers séparés par domaine

```dart
// Au lieu d'un gros AppState
// Séparer en providers spécialisés

// User domain
final userProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  return UserNotifier(ref.read(userRepositoryProvider));
});

// Products domain
final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>((ref) {
  return ProductsNotifier(ref.read(productRepositoryProvider));
});

// Cart domain
final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier();
});

// Derived state via computed provider
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.items.fold(0, (sum, item) => sum + item.price);
});
```

### Pattern : Provider dérivé pour calculs

```dart
// Provider principal
final itemsProvider = StateNotifierProvider<ItemsNotifier, List<Item>>((ref) {
  return ItemsNotifier();
});

// Providers dérivés (computed)
final activeItemsProvider = Provider<List<Item>>((ref) {
  final items = ref.watch(itemsProvider);
  return items.where((item) => item.isActive).toList();
});

final itemCountProvider = Provider<int>((ref) {
  return ref.watch(itemsProvider).length;
});

// Usage - rebuild uniquement si activeItems change
final activeItems = ref.watch(activeItemsProvider);
```

---

## 4. Family Pattern

### Pattern : Provider avec paramètre

```dart
// Provider famille pour données paramétrées
final userByIdProvider = FutureProvider.family<User, String>((ref, userId) async {
  return ref.read(userRepositoryProvider).getUser(userId);
});

// Usage
@override
Widget build(BuildContext context, WidgetRef ref) {
  final userAsync = ref.watch(userByIdProvider(userId));

  return userAsync.when(
    data: (user) => UserCard(user: user),
    loading: () => const CircularProgressIndicator(),
    error: (error, stack) => Text('Error: $error'),
  );
}
```

### Pattern : Family avec autoDispose

```dart
// Se libère automatiquement quand plus écouté
final searchResultsProvider = FutureProvider.autoDispose.family<List<Item>, String>(
  (ref, query) async {
    // Debounce la recherche
    await Future.delayed(const Duration(milliseconds: 300));

    // Vérifie si toujours actif
    if (!ref.state.hasValue) return [];

    return ref.read(searchRepositoryProvider).search(query);
  },
);
```

---

## 5. AsyncValue Pattern

### Pattern : Gestion complète avec when()

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final asyncData = ref.watch(dataProvider);

  return asyncData.when(
    data: (data) => DataWidget(data: data),
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (error, stack) => ErrorWidget(
      error: error,
      onRetry: () => ref.invalidate(dataProvider),
    ),
  );
}
```

### Pattern : AsyncValue avec valeur par défaut

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Affiche les anciennes données pendant le refresh
  final data = ref.watch(dataProvider).valueOrNull;
  final isLoading = ref.watch(dataProvider).isLoading;

  if (data == null) {
    return const LoadingScreen();
  }

  return Stack(
    children: [
      DataWidget(data: data),
      if (isLoading)
        const Positioned(
          top: 0,
          child: LinearProgressIndicator(),
        ),
    ],
  );
}
```

### Pattern : AsyncValue combinés

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final userAsync = ref.watch(userProvider);
  final settingsAsync = ref.watch(settingsProvider);

  // Combine les deux AsyncValues
  return userAsync.when(
    data: (user) => settingsAsync.when(
      data: (settings) => ProfilePage(user: user, settings: settings),
      loading: () => const LoadingWidget(),
      error: (e, s) => ErrorWidget(error: e),
    ),
    loading: () => const LoadingWidget(),
    error: (e, s) => ErrorWidget(error: e),
  );
}
```

---

## 6. Listen Pattern

### Pattern : Écouter sans rebuild

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Écoute les changements sans rebuild
  ref.listen<AuthState>(authProvider, (previous, next) {
    if (next.isLoggedOut) {
      context.go('/login');
    }
    if (next.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.errorMessage!)),
      );
    }
  });

  // Le widget ne rebuild pas quand authProvider change
  return const HomeContent();
}
```

### Pattern : Listen avec fireImmediately

```dart
ref.listen<int>(
  counterProvider,
  (previous, next) {
    print('Counter changed from $previous to $next');
  },
  fireImmediately: true, // Appelé immédiatement avec la valeur actuelle
);
```

---

## 7. KeepAlive Pattern

### Pattern : Cache temporaire

```dart
final expensiveDataProvider = FutureProvider.autoDispose<ExpensiveData>((ref) async {
  // Garde en cache pendant 5 minutes après le dernier listener
  final link = ref.keepAlive();

  final timer = Timer(const Duration(minutes: 5), link.close);
  ref.onDispose(timer.cancel);

  return await fetchExpensiveData();
});
```

### Pattern : Cache conditionnel

```dart
final dataProvider = FutureProvider.autoDispose<Data>((ref) async {
  final data = await fetchData();

  // Garde en cache seulement si les données sont valides
  if (data.isValid) {
    ref.keepAlive();
  }

  return data;
});
```

---

## 8. Invalidation Pattern

### Pattern : Invalidation ciblée

```dart
// Invalider un provider spécifique
ElevatedButton(
  onPressed: () => ref.invalidate(userProvider),
  child: const Text('Refresh User'),
)

// Invalider un provider family spécifique
ElevatedButton(
  onPressed: () => ref.invalidate(userByIdProvider(userId)),
  child: const Text('Refresh This User'),
)
```

### Pattern : Refresh avec feedback

```dart
Future<void> _onRefresh() async {
  // Invalide et attend le nouveau résultat
  await ref.refresh(dataProvider.future);
}

RefreshIndicator(
  onRefresh: _onRefresh,
  child: ListView(...),
)
```

---

## 9. StateNotifier Pattern

### Pattern : État immutable

```dart
@freezed
class TodoState with _$TodoState {
  const factory TodoState({
    @Default([]) List<Todo> todos,
    @Default(false) bool isLoading,
    String? error,
  }) = _TodoState;
}

class TodoNotifier extends StateNotifier<TodoState> {
  TodoNotifier(this._repository) : super(const TodoState());

  final TodoRepository _repository;

  Future<void> loadTodos() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final todos = await _repository.getTodos();
      state = state.copyWith(todos: todos, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void addTodo(Todo todo) {
    state = state.copyWith(todos: [...state.todos, todo]);
  }

  void toggleTodo(String id) {
    state = state.copyWith(
      todos: state.todos.map((t) {
        return t.id == id ? t.copyWith(completed: !t.completed) : t;
      }).toList(),
    );
  }
}
```

---

## Résumé des patterns clés

| Pattern | Cas d'usage | Bénéfice |
|---------|-------------|----------|
| `select()` | Propriété spécifique | Rebuild ciblé |
| `read()` | Callbacks | Pas de rebuild |
| Granularité | États complexes | Isolation des rebuilds |
| `family` | Données paramétrées | Instances multiples |
| `autoDispose` | Données temporaires | Libération mémoire |
| `when()` | AsyncValue | Gestion complète |
| `listen()` | Side effects | Pas de rebuild |
| `keepAlive` | Cache temporaire | Performance réseau |
| `invalidate` | Refresh données | Contrôle fin du cache |
| Immutabilité | StateNotifier | Prédictibilité |
