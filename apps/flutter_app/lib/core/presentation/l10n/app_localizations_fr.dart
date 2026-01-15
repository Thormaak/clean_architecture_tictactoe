// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Morpion';

  @override
  String get playerX => 'Joueur X';

  @override
  String get playerO => 'Joueur O';

  @override
  String yourTurn(String player) {
    return 'Tour de $player';
  }

  @override
  String winner(String player) {
    return '$player gagne !';
  }

  @override
  String get draw => 'Match nul !';

  @override
  String get newGame => 'Nouvelle partie';

  @override
  String get restart => 'Recommencer';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get audioSettings => 'Audio';

  @override
  String get audioMusicVolume => 'Volume musique';

  @override
  String get audioSfxVolume => 'Volume effets';

  @override
  String get audioMute => 'Muet';

  @override
  String get audioClickSound => 'Sons de clic';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Moyen';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String get playAgainstAI => 'Contre l\'IA';

  @override
  String get twoPlayers => 'Joueur contre joueur';

  @override
  String get back => 'Retour';

  @override
  String get chooseDifficulty => 'Choisir la difficulté';

  @override
  String get difficultyEasySubtitle => 'Pour les débutants';

  @override
  String get difficultyMediumSubtitle => 'Un bon challenge';

  @override
  String get difficultyHardSubtitle => 'Presque imbattable';

  @override
  String get gameModeLocalSubtitle => 'À tour de rôle, même écran';

  @override
  String get gameModeAISubtitle => 'Défie l\'intelligence artificielle';

  @override
  String get victory => 'Victoire !';

  @override
  String wonInMoves(int count) {
    return 'Gagné en $count coups';
  }

  @override
  String get rematch => 'Revanche';

  @override
  String get menu => 'Menu';

  @override
  String get drawMessage => 'Match nul !';

  @override
  String gameEndedAfterMoves(int count) {
    return 'Partie terminée après $count coups';
  }

  @override
  String get aiThinking => 'L\'IA réfléchit...';

  @override
  String get undo => 'Annuler';

  @override
  String get gameModeLocal => 'Local';

  @override
  String get yourTurnLabel => 'À toi de jouer';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageFrench => 'Français';

  @override
  String get cancel => 'Annuler';

  @override
  String get bestOf => 'Best Of';

  @override
  String get bo1 => 'BO1';

  @override
  String get bo3 => 'BO3';

  @override
  String get bo5 => 'BO5';

  @override
  String roundOf(int current, int total) {
    return 'Manche $current sur $total';
  }

  @override
  String get continueMatch => 'Continuer';

  @override
  String get nextRound => 'Manche suivante';

  @override
  String matchWinner(String name) {
    return '$name remporte le match !';
  }

  @override
  String roundWinner(String name) {
    return '$name remporte la manche !';
  }

  @override
  String get roundDraw => 'Manche nulle';

  @override
  String get score => 'Score';

  @override
  String get finalScore => 'Score final';

  @override
  String winsToMatch(int count) {
    return 'Encore $count victoire pour le match';
  }

  @override
  String get chooseFormat => 'Choisir le format';

  @override
  String get bo1Subtitle => 'Partie unique';

  @override
  String get bo3Subtitle => 'Premier à 2 victoires';

  @override
  String get bo5Subtitle => 'Premier à 3 victoires';

  @override
  String get matchDraw => 'Match nul !';

  @override
  String get suddenDeath => 'Mort subite';

  @override
  String get errorInvalidMove => 'Mouvement invalide';

  @override
  String get errorGameOver => 'La partie est terminée';

  @override
  String get errorNoActiveRound => 'Aucun round actif';

  @override
  String get errorRoundInProgress => 'La manche est en cours';

  @override
  String get errorMatchAlreadyOver => 'Le match est déjà terminé';

  @override
  String get errorStartRoundFailed =>
      'Impossible de démarrer la manche suivante';

  @override
  String get errorCreateMatchFailed => 'Impossible de créer la partie';

  @override
  String get errorRestartFailed => 'Impossible de redémarrer la partie';

  @override
  String get errorUnexpected => 'Une erreur inattendue est survenue';

  @override
  String get errorPageNotFound => 'Page introuvable';

  @override
  String get errorGoHome => 'Retour à l\'accueil';

  @override
  String get versusLabel => 'VS';
}
