import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/application/di/game_repository_providers.dart';
import '../../application/use_cases/check_ai_move_use_case.dart';
import '../../application/use_cases/continue_next_round_use_case.dart';
import '../../application/use_cases/play_move_use_case.dart';
import '../../application/use_cases/restart_game_use_case.dart';
import '../../application/use_cases/start_game_use_case.dart';

// =============================================================================
// Application Layer - Use Cases
// =============================================================================

/// Start game use case provider
final startGameUseCaseProvider = Provider<StartGameUseCase>((ref) {
  return StartGameUseCase(ref.read(matchRepositoryProvider));
});

/// Play move use case provider
final playMoveUseCaseProvider = Provider<PlayMoveUseCase>((ref) {
  return PlayMoveUseCase(
    ref.read(gameRepositoryProvider),
    ref.read(matchRepositoryProvider),
  );
});

/// Continue next round use case provider
final continueNextRoundUseCaseProvider = Provider<ContinueNextRoundUseCase>((
  ref,
) {
  return ContinueNextRoundUseCase(ref.read(matchRepositoryProvider));
});

/// Restart game use case provider
final restartGameUseCaseProvider = Provider<RestartGameUseCase>((ref) {
  return RestartGameUseCase(ref.read(startGameUseCaseProvider));
});

/// Check AI move use case provider
final checkAIMoveUseCaseProvider = Provider<CheckAIMoveUseCase>((ref) {
  return CheckAIMoveUseCase();
});
