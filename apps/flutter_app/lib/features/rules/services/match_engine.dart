import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/entities/game_state.dart';
import '../domain/entities/match_state.dart';
import '../domain/entities/player.dart';
import '../domain/value_objects/best_of.dart';
import '../domain/value_objects/game_config.dart';
import '../domain/value_objects/game_result.dart';
import '../domain/value_objects/match_result.dart';
import 'game_engine.dart';

part 'match_engine.freezed.dart';

/// Result of a match engine operation
@freezed
sealed class MatchEngineResult with _$MatchEngineResult {
  const factory MatchEngineResult.success(MatchState newState) =
      MatchEngineSuccess;
  const factory MatchEngineResult.failure(MatchEngineError error) =
      MatchEngineFailure;
}

/// Errors that can occur in the match engine
@freezed
sealed class MatchEngineError with _$MatchEngineError {
  const factory MatchEngineError.matchAlreadyOver() =
      MatchEngineErrorMatchAlreadyOver;
  const factory MatchEngineError.roundInProgress() =
      MatchEngineErrorRoundInProgress;
  const factory MatchEngineError.noRoundToComplete() =
      MatchEngineErrorNoRoundToComplete;
}

/// Engine for managing multi-round matches
abstract class MatchEngine {
  /// Creates a new match
  MatchState createMatch(GameConfig config);

  /// Starts the next round in a match
  MatchEngineResult startNextRound(MatchState match);

  /// Records round completion and updates scores
  MatchState completeRound(MatchState match, GameState completedRound);
}

/// Default implementation of MatchEngine
class MatchEngineImpl implements MatchEngine {
  final GameEngine _gameEngine;
  final String Function() _idGenerator;

  MatchEngineImpl({GameEngine? gameEngine, String Function()? idGenerator})
    : _gameEngine = gameEngine ?? GameEngineImpl(),
      _idGenerator =
          idGenerator ??
          (() => DateTime.now().millisecondsSinceEpoch.toString());

  @override
  MatchState createMatch(GameConfig config) {
    final matchId = _idGenerator();
    final firstRound = _gameEngine.createGame(config);

    return MatchState(
      matchId: matchId,
      config: config,
      completedRounds: const [],
      currentRound: firstRound,
      playerXScore: 0,
      playerOScore: 0,
      currentRoundNumber: 1,
      result: const MatchResult.ongoing(),
      startedAt: DateTime.now(),
    );
  }

  @override
  MatchEngineResult startNextRound(MatchState match) {
    if (match.isMatchOver) {
      return const MatchEngineResult.failure(
        MatchEngineError.matchAlreadyOver(),
      );
    }

    if (match.currentRound != null && !match.currentRound!.isGameOver) {
      return const MatchEngineResult.failure(
        MatchEngineError.roundInProgress(),
      );
    }

    // Create config for new round with alternating starting player
    final newConfig = match.config.copyWith(
      startingPlayer: match.nextRoundStartingPlayer,
    );

    final newRound = _gameEngine.createGame(newConfig);

    final newState = match.copyWith(
      currentRound: newRound,
      currentRoundNumber: match.currentRoundNumber + 1,
    );

    return MatchEngineResult.success(newState);
  }

  @override
  MatchState completeRound(MatchState match, GameState completedRound) {
    if (!completedRound.isGameOver) {
      return match;
    }

    // Calculate new scores
    var playerXScore = match.playerXScore;
    var playerOScore = match.playerOScore;

    completedRound.result.when(
      ongoing: () {},
      win: (winner, _) {
        if (winner == PlayerMark.x) {
          playerXScore++;
        } else {
          playerOScore++;
        }
      },
      draw: () {
        // No points on draw - only wins count
      },
    );

    final newCompletedRounds = [...match.completedRounds, completedRound];

    // Check if match is over
    final matchResult = _checkMatchResult(
      playerXScore: playerXScore,
      playerOScore: playerOScore,
      bestOf: match.config.bestOf,
      roundsPlayed: newCompletedRounds.length,
    );

    return match.copyWith(
      completedRounds: newCompletedRounds,
      currentRound: completedRound,
      playerXScore: playerXScore,
      playerOScore: playerOScore,
      result: matchResult,
      endedAt: matchResult is! MatchResultOngoing ? DateTime.now() : null,
    );
  }

  MatchResult _checkMatchResult({
    required int playerXScore,
    required int playerOScore,
    required BestOf bestOf,
    required int roundsPlayed,
  }) {
    // Check for decisive winner (reached roundsToWin threshold)
    if (playerXScore >= bestOf.roundsToWin && playerXScore > playerOScore) {
      return const MatchResult.playerXWins();
    }
    if (playerOScore >= bestOf.roundsToWin && playerOScore > playerXScore) {
      return const MatchResult.playerOWins();
    }

    // After max rounds, match MUST end - whoever has more points wins
    if (roundsPlayed >= bestOf.maxRounds) {
      if (playerXScore > playerOScore) {
        return const MatchResult.playerXWins();
      } else if (playerOScore > playerXScore) {
        return const MatchResult.playerOWins();
      } else {
        return const MatchResult.draw();
      }
    }

    return const MatchResult.ongoing();
  }
}
