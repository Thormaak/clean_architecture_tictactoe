import '../domain/entities/game_state.dart';
import '../domain/value_objects/position.dart';
import 'player_strategy.dart';

/// Strategy for human players.
///
/// Human players provide their moves through UI interaction,
/// so this strategy always returns null and requires external input.
class HumanPlayerStrategy implements PlayerStrategy {
  const HumanPlayerStrategy();

  @override
  Future<Position?> getNextMove(GameState state) async => null;

  @override
  bool get requiresExternalInput => true;
}
