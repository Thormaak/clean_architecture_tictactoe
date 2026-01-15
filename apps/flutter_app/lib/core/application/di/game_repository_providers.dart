import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tictactoe/features/rules/rules.dart';

import '../../../features/game/domain/repositories/i_game_repository.dart';
import '../../../features/game/domain/repositories/i_match_repository.dart';
import '../../../features/game/infrastructure/repositories/game_repository_impl.dart';
import '../../../features/game/infrastructure/repositories/match_repository_impl.dart';

// =============================================================================
// Infrastructure Layer - Repositories (DI)
// =============================================================================

/// Game engine provider (from rules module) - used by infrastructure
final gameEngineProvider = Provider<GameEngine>((ref) {
  return GameEngineImpl();
});

/// Match engine provider (from rules module) - used by infrastructure
final matchEngineProvider = Provider<MatchEngine>((ref) {
  return MatchEngineImpl(gameEngine: ref.read(gameEngineProvider));
});

/// Game repository provider
final gameRepositoryProvider = Provider<IGameRepository>((ref) {
  return GameRepositoryImpl(ref.read(gameEngineProvider));
});

/// Match repository provider
final matchRepositoryProvider = Provider<IMatchRepository>((ref) {
  return MatchRepositoryImpl(ref.read(matchEngineProvider));
});
