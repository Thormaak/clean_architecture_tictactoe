import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_failures.freezed.dart';

/// Union de types représentant les différentes erreurs possibles pour StartGame
@freezed
sealed class StartGameFailure with _$StartGameFailure implements Exception {
  /// Erreur lors de la création du match
  const factory StartGameFailure.createMatchFailed() =
      StartGameCreateMatchFailed;

  /// Erreur inattendue
  const factory StartGameFailure.unexpected() = StartGameUnexpected;
}

/// Union de types représentant les différentes erreurs possibles pour PlayMove
@freezed
sealed class PlayMoveFailure with _$PlayMoveFailure implements Exception {
  /// Erreur lorsqu'aucun round actif n'existe
  const factory PlayMoveFailure.noActiveRound() = PlayMoveNoActiveRound;

  /// Erreur lorsque la partie est terminée
  const factory PlayMoveFailure.gameOver() = PlayMoveGameOver;

  /// Erreur de mouvement invalide
  const factory PlayMoveFailure.invalidMove() = PlayMoveInvalidMove;

  /// Erreur inattendue
  const factory PlayMoveFailure.unexpected() = PlayMoveUnexpected;
}

/// Union de types représentant les différentes erreurs possibles pour ContinueNextRound
@freezed
sealed class ContinueNextRoundFailure
    with _$ContinueNextRoundFailure
    implements Exception {
  /// Erreur lorsque le round est toujours en cours
  const factory ContinueNextRoundFailure.roundInProgress() =
      ContinueNextRoundRoundInProgress;

  /// Erreur lorsque le match est déjà terminé
  const factory ContinueNextRoundFailure.matchAlreadyOver() =
      ContinueNextRoundMatchAlreadyOver;

  /// Erreur lors du démarrage du round
  const factory ContinueNextRoundFailure.startRoundFailed() =
      ContinueNextRoundStartRoundFailed;

  /// Erreur inattendue
  const factory ContinueNextRoundFailure.unexpected() =
      ContinueNextRoundUnexpected;
}

/// Union de types représentant les différentes erreurs possibles pour RestartGame
@freezed
sealed class RestartGameFailure with _$RestartGameFailure implements Exception {
  /// Erreur lors du redémarrage
  const factory RestartGameFailure.restartFailed() = RestartGameRestartFailed;

  /// Erreur inattendue
  const factory RestartGameFailure.unexpected() = RestartGameUnexpected;
}

/// Union de types représentant les différentes erreurs possibles pour CheckAIMove
@freezed
sealed class CheckAIMoveFailure with _$CheckAIMoveFailure implements Exception {
  /// Erreur lors de la vérification du mouvement IA
  const factory CheckAIMoveFailure.checkFailed() = CheckAIMoveCheckFailed;

  /// Erreur inattendue
  const factory CheckAIMoveFailure.unexpected() = CheckAIMoveUnexpected;
}

/// Union de types représentant les erreurs UI liées au jeu
sealed class GameFailure implements Exception {
  const GameFailure();

  /// Erreurs lors du démarrage du match
  const factory GameFailure.startGame(StartGameFailure failure) =
      GameStartGameFailure;

  /// Erreurs lors d'un mouvement
  const factory GameFailure.playMove(PlayMoveFailure failure) =
      GamePlayMoveFailure;

  /// Erreurs lors de la continuité du match
  const factory GameFailure.continueNextRound(
    ContinueNextRoundFailure failure,
  ) = GameContinueNextRoundFailure;

  /// Erreurs lors du redémarrage du match
  const factory GameFailure.restartGame(RestartGameFailure failure) =
      GameRestartGameFailure;

  T when<T>({
    required T Function(StartGameFailure failure) startGame,
    required T Function(PlayMoveFailure failure) playMove,
    required T Function(ContinueNextRoundFailure failure) continueNextRound,
    required T Function(RestartGameFailure failure) restartGame,
  }) {
    final self = this;
    if (self is GameStartGameFailure) {
      return startGame(self.failure);
    }
    if (self is GamePlayMoveFailure) {
      return playMove(self.failure);
    }
    if (self is GameContinueNextRoundFailure) {
      return continueNextRound(self.failure);
    }
    if (self is GameRestartGameFailure) {
      return restartGame(self.failure);
    }
    throw StateError('Unhandled GameFailure: $runtimeType');
  }
}

class GameStartGameFailure extends GameFailure {
  final StartGameFailure failure;

  const GameStartGameFailure(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameStartGameFailure && other.failure == failure);

  @override
  int get hashCode => Object.hash(runtimeType, failure);
}

class GamePlayMoveFailure extends GameFailure {
  final PlayMoveFailure failure;

  const GamePlayMoveFailure(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GamePlayMoveFailure && other.failure == failure);

  @override
  int get hashCode => Object.hash(runtimeType, failure);
}

class GameContinueNextRoundFailure extends GameFailure {
  final ContinueNextRoundFailure failure;

  const GameContinueNextRoundFailure(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameContinueNextRoundFailure && other.failure == failure);

  @override
  int get hashCode => Object.hash(runtimeType, failure);
}

class GameRestartGameFailure extends GameFailure {
  final RestartGameFailure failure;

  const GameRestartGameFailure(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameRestartGameFailure && other.failure == failure);

  @override
  int get hashCode => Object.hash(runtimeType, failure);
}
