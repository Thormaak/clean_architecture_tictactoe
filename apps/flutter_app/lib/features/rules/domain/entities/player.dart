import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';

/// The mark a player uses on the board
enum PlayerMark { x, o }

/// Represents a player in the game.
///
/// Player is a pure data class representing player information.
/// The behavior (how a player makes moves) is handled by [PlayerStrategy].
@freezed
abstract class Player with _$Player {
  const factory Player({
    required String id,
    required String name,
    required PlayerMark mark,
    @Default(0) int score,
  }) = _Player;
}
