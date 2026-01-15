import 'package:freezed_annotation/freezed_annotation.dart';

import '../value_objects/best_of.dart';
import '../value_objects/game_config.dart';
import '../value_objects/game_result.dart';
import '../value_objects/match_result.dart';
import 'game_state.dart';
import 'player.dart';

part 'match_state.freezed.dart';

/// Complete state of a match (multiple rounds)
@freezed
abstract class MatchState with _$MatchState {
  const factory MatchState({
    required String matchId,
    required GameConfig config,
    required List<GameState> completedRounds,
    required GameState? currentRound,
    required int playerXScore,
    required int playerOScore,
    required int currentRoundNumber,
    required MatchResult result,
    required DateTime startedAt,
    DateTime? endedAt,
  }) = _MatchState;

  const MatchState._();

  /// Best of configuration
  BestOf get bestOf => config.bestOf;

  /// Rounds needed to win the match
  int get roundsToWin => bestOf.roundsToWin;

  /// Maximum possible rounds
  int get maxRounds => bestOf.maxRounds;

  /// Is the match over?
  bool get isMatchOver => result is! MatchResultOngoing;

  /// Is the current round over?
  bool get isRoundOver => currentRound?.isGameOver ?? false;

  /// Is waiting for next round to start (round over but match continues)?
  bool get awaitingNextRound => isRoundOver && !isMatchOver;

  /// Is this a single game match (BO1)?
  bool get isSingleGame => bestOf == BestOf.bo1;

  /// Get starting player for next round
  /// The loser of the previous round starts the next one
  /// On draw, alternate from the previous starting player
  PlayerMark get nextRoundStartingPlayer {
    if (completedRounds.isEmpty) {
      return config.startingPlayer;
    }

    final lastRound = completedRounds.last;
    return lastRound.result.when(
      ongoing: () => config.startingPlayer,
      win: (winner, _) => winner == PlayerMark.x ? PlayerMark.o : PlayerMark.x,
      draw:
          () =>
              lastRound.config.startingPlayer == PlayerMark.x
                  ? PlayerMark.o
                  : PlayerMark.x,
    );
  }

  /// Total rounds played (completed + current if in progress)
  int get totalRoundsPlayed {
    final current = currentRound != null && !isRoundOver ? 1 : 0;
    return completedRounds.length + current;
  }
}
