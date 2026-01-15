import 'package:freezed_annotation/freezed_annotation.dart';

import '../entities/player.dart';
import 'best_of.dart';
import 'game_mode.dart';

part 'game_config.freezed.dart';

/// Configuration for a game
@freezed
abstract class GameConfig with _$GameConfig {
  const factory GameConfig({
    required GameMode mode,
    required Player playerX,
    required Player playerO,
    @Default(PlayerMark.x) PlayerMark startingPlayer,
    @Default(BestOf.bo1) BestOf bestOf,
    Duration? turnTimeout,
  }) = _GameConfig;
}
