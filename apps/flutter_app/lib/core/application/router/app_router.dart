import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tictactoe/features/rules/rules.dart';

import '../../presentation/l10n/app_localizations.dart';
import '../../../features/game/presentation/pages/home_page.dart';
import '../../../features/game/presentation/pages/difficulty_page.dart';
import '../../../features/game/presentation/pages/best_of_selection_page.dart';
import '../../../features/settings/presentation/pages/settings_page.dart';
import '../../../features/game/presentation/pages/game_page.dart';

part 'app_router.g.dart';

/// Home route - entry point
@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<SettingsRoute>(path: 'settings'),
    TypedGoRoute<DifficultyRoute>(path: 'difficulty'),
    TypedGoRoute<BestOfSelectionRoute>(path: 'best-of'),
    TypedGoRoute<GameRoute>(path: 'game'),
  ],
)
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

/// Settings route
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsPage();
}

/// Difficulty selection route
class DifficultyRoute extends GoRouteData with $DifficultyRoute {
  const DifficultyRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DifficultyPage();
}

/// Best Of selection route
class BestOfSelectionRoute extends GoRouteData with $BestOfSelectionRoute {
  final GameMode $extra;

  const BestOfSelectionRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      BestOfSelectionPage(gameMode: $extra);
}

/// Parameters for starting a game
class GameParams {
  final GameMode mode;
  final BestOf bestOf;

  const GameParams({required this.mode, this.bestOf = BestOf.bo1});
}

/// Game route with GameParams parameter via $extra
class GameRoute extends GoRouteData with $GameRoute {
  final GameParams $extra;

  const GameRoute(this.$extra);

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      GamePage(gameMode: $extra.mode, bestOf: $extra.bestOf);
}

/// Provides the app router instance
@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: $appRoutes,
    errorBuilder: (context, state) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n.errorPageNotFound),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => const HomeRoute().go(context),
                child: Text(l10n.errorGoHome),
              ),
            ],
          ),
        ),
      );
    },
  );
}
