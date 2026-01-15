import 'package:freezed_annotation/freezed_annotation.dart';

import '../entities/player.dart';
import 'position.dart';

part 'move.freezed.dart';

/// A move played in the game
@freezed
abstract class Move with _$Move {
  const factory Move({
    required Position position,
    required PlayerMark mark,
    required DateTime timestamp,
    required int moveNumber,
  }) = _Move;
}
