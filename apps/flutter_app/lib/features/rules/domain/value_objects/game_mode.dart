import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_mode.freezed.dart';

/// AI difficulty level
enum AIDifficulty { easy, medium, hard }

/// Game mode
@freezed
sealed class GameMode with _$GameMode {
  /// Local game (2 players on same device)
  const factory GameMode.local() = GameModeLocal;

  /// Game against AI
  const factory GameMode.vsAI({
    @Default(AIDifficulty.medium) AIDifficulty difficulty,
  }) = GameModeVsAI;
}
