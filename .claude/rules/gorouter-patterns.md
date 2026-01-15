# GoRouter Type-Safe Navigation Rules

Ces regles s'appliquent a la navigation avec GoRouter et go_router_builder (type-safe routing).

## 1. Dependances

```yaml
# pubspec.yaml
dependencies:
  go_router: ^14.0.0

dev_dependencies:
  go_router_builder: ^2.4.0
  build_runner: ^2.4.0
```

## 2. Structure des fichiers

```
lib/
├── core/
│   └── router/
│       ├── app_router.dart       # Routes et configuration
│       └── app_router.g.dart     # Code genere (ne pas modifier)
│
└── features/{feature}/
    └── presentation/
        └── pages/
            └── {name}_page.dart  # Pages routables
```

## 3. Definition des routes

### Pattern TypedGoRoute

```dart
// core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'app_router.g.dart';

/// Route racine avec routes enfants
@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<SettingsRoute>(path: 'settings'),
    TypedGoRoute<GameRoute>(path: 'game/:id'),
    TypedGoRoute<LobbyRoute>(
      path: 'lobby',
      routes: [
        TypedGoRoute<CreateLobbyRoute>(path: 'create'),
        TypedGoRoute<JoinLobbyRoute>(path: 'join'),
      ],
    ),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}
```

### Route simple

```dart
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}
```

## 4. Types de parametres

### Path parameters (dans le chemin)

Variables definies dans le path avec `:nom` → champs required.

```dart
// Path: 'game/:id'
@TypedGoRoute<GameDetailRoute>(path: 'game/:id')
class GameDetailRoute extends GoRouteData with $GameDetailRoute {
  final String id;  // Path parameter (required)

  const GameDetailRoute({required this.id});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      GameDetailPage(gameId: id);
}

// Navigation → /game/abc123
const GameDetailRoute(id: 'abc123').go(context);
```

### Query parameters (hors du chemin)

Variables non definies dans le path → query string optionnelle.

```dart
// Path: 'search'
@TypedGoRoute<SearchRoute>(path: 'search')
class SearchRoute extends GoRouteData with $SearchRoute {
  final String? query;    // Query parameter (optional)
  final int? page;        // Query parameter (optional)

  const SearchRoute({this.query, this.page});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      SearchPage(query: query, page: page ?? 1);
}

// Navigation → /search?query=test&page=2
const SearchRoute(query: 'test', page: 2).go(context);
```

### $extra (objets complexes)

Pour passer des objets non-serialisables (entites, enums complexes).

```dart
// Path: 'game'
@TypedGoRoute<GameRoute>(path: 'game')
class GameRoute extends GoRouteData with $GameRoute {
  final GameMode $extra;  // Nom special $extra

  const GameRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      GamePage(gameMode: $extra);
}

// Navigation
GameRoute(GameMode.vsAI(difficulty: AIDifficulty.hard)).go(context);
```

**Attention** : `$extra` ne supporte PAS le deep linking (liens externes, browser back). Utiliser uniquement pour navigation interne.

### Combiner les 3 types

```dart
@TypedGoRoute<ProductRoute>(path: 'product/:id')
class ProductRoute extends GoRouteData with $ProductRoute {
  final String id;           // Path parameter (required)
  final String? variant;     // Query parameter (optional)
  final ProductData? $extra; // Extra data (optional)

  const ProductRoute({
    required this.id,
    this.variant,
    this.$extra,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ProductPage(id: id, variant: variant, data: $extra);
}

// Navigation → /product/abc?variant=red
ProductRoute(id: 'abc', variant: 'red', $extra: productData).go(context);
```

## 5. Navigation

### Methodes disponibles

```dart
// go() - Remplace la pile de navigation
const HomeRoute().go(context);
const SettingsRoute().go(context);

// push() - Empile sur la navigation actuelle
const SettingsRoute().push(context);

// push<T>() - Avec valeur de retour
final result = await const ConfirmRoute().push<bool>(context);

// pushReplacement() - Remplace la route actuelle
const NewRoute().pushReplacement(context);
```

### Pop (retour)

```dart
// Retour simple
context.pop();

// Retour avec resultat
context.pop(true);

// Verifier si peut pop
if (context.canPop()) {
  context.pop();
} else {
  const HomeRoute().go(context);
}
```

### Patterns interdits

```dart
// INTERDIT - Strings en dur
context.go('/game/123');

// INTERDIT - Navigator avec GoRouter
Navigator.of(context).push(...);
Navigator.of(context).pop();  // Utiliser context.pop()

// INTERDIT - Navigation dans initState sans PostFrameCallback
@override
void initState() {
  super.initState();
  const HomeRoute().go(context);  // CRASH
}

// BON - Avec PostFrameCallback
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) const HomeRoute().go(context);
  });
}
```

## 6. Configuration du router

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: $appRoutes,  // Variable generee automatiquement
    debugLogDiagnostics: kDebugMode,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Page not found'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => const HomeRoute().go(context),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
```

## 7. Guards et redirections

```dart
@riverpod
GoRouter appRouter(Ref ref) {
  final isLoggedIn = ref.watch(authProvider).isLoggedIn;

  return GoRouter(
    routes: $appRoutes,
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }
      if (isLoggedIn && isAuthRoute) {
        return '/';
      }
      return null;
    },
  );
}
```

## 8. ShellRoute pour navigation persistante

```dart
@TypedShellRoute<MainShellRoute>(
  routes: [
    TypedGoRoute<HomeTabRoute>(path: '/home'),
    TypedGoRoute<SearchTabRoute>(path: '/search'),
    TypedGoRoute<ProfileTabRoute>(path: '/profile'),
  ],
)
class MainShellRoute extends ShellRouteData {
  const MainShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return MainShell(
      currentPath: state.matchedLocation,
      child: navigator,
    );
  }
}
```

## 9. Generation du code

Apres chaque modification des routes :

```bash
# Generation unique
dart run build_runner build --delete-conflicting-outputs

# Watch mode (regeneration auto)
dart run build_runner watch --delete-conflicting-outputs
```

## 10. Tests de navigation

```dart
testWidgets('should navigate to settings', (tester) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: $appRoutes,
  );

  await tester.pumpWidget(
    MaterialApp.router(routerConfig: router),
  );

  // Navigation type-safe
  const SettingsRoute().go(tester.element(find.byType(MaterialApp)));
  await tester.pumpAndSettle();

  expect(find.byType(SettingsPage), findsOneWidget);
});
```

## Checklist

- [ ] Toutes les routes utilisent `@TypedGoRoute`
- [ ] Classes de route avec mixin genere `$RouteName`
- [ ] Constructeurs `const` sur toutes les routes
- [ ] Path parameters comme champs required
- [ ] Query parameters comme champs optionnels
- [ ] `$extra` uniquement pour objets complexes (pas de deep linking)
- [ ] Navigation via `RouteClass().go/push(context)`
- [ ] `context.pop()` pour retour (pas `Navigator.pop()`)
- [ ] `errorBuilder` configure
- [ ] `build_runner` execute apres modifications des routes
