// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TicTacToe';

  @override
  String get playerX => 'Player X';

  @override
  String get playerO => 'Player O';

  @override
  String yourTurn(String player) {
    return '$player\'s turn';
  }

  @override
  String winner(String player) {
    return '$player wins!';
  }

  @override
  String get draw => 'It\'s a draw!';

  @override
  String get newGame => 'New Game';

  @override
  String get restart => 'Restart';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get audioSettings => 'Audio';

  @override
  String get audioMusicVolume => 'Music volume';

  @override
  String get audioSfxVolume => 'SFX volume';

  @override
  String get audioMute => 'Mute';

  @override
  String get audioClickSound => 'Click sound';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get playAgainstAI => 'VS AI';

  @override
  String get twoPlayers => 'Two Players';

  @override
  String get back => 'Back';

  @override
  String get chooseDifficulty => 'Choose Difficulty';

  @override
  String get difficultyEasySubtitle => 'For beginners';

  @override
  String get difficultyMediumSubtitle => 'A good challenge';

  @override
  String get difficultyHardSubtitle => 'Almost unbeatable';

  @override
  String get gameModeLocalSubtitle => 'Same device, take turns';

  @override
  String get gameModeAISubtitle => 'Test your skills against AI';

  @override
  String get victory => 'Victory!';

  @override
  String wonInMoves(int count) {
    return 'Won in $count moves';
  }

  @override
  String get rematch => 'Rematch';

  @override
  String get menu => 'Menu';

  @override
  String get drawMessage => 'It\'s a Draw!';

  @override
  String gameEndedAfterMoves(int count) {
    return 'Game ended after $count moves';
  }

  @override
  String get aiThinking => 'AI is thinking...';

  @override
  String get undo => 'Undo';

  @override
  String get gameModeLocal => 'Local';

  @override
  String get yourTurnLabel => 'Your Turn';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get cancel => 'Cancel';

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
    return 'Round $current of $total';
  }

  @override
  String get continueMatch => 'Continue';

  @override
  String get nextRound => 'Next round';

  @override
  String matchWinner(String name) {
    return '$name wins the match!';
  }

  @override
  String roundWinner(String name) {
    return '$name wins the round!';
  }

  @override
  String get roundDraw => 'Round ended in a draw';

  @override
  String get score => 'Score';

  @override
  String get finalScore => 'Final Score';

  @override
  String winsToMatch(int count) {
    return '$count more win to match';
  }

  @override
  String get chooseFormat => 'Choose Format';

  @override
  String get bo1Subtitle => 'Single game';

  @override
  String get bo3Subtitle => 'First to 2 wins';

  @override
  String get bo5Subtitle => 'First to 3 wins';

  @override
  String get matchDraw => 'Match Draw!';

  @override
  String get suddenDeath => 'Sudden Death';

  @override
  String get errorInvalidMove => 'Invalid move';

  @override
  String get errorGameOver => 'Game is over';

  @override
  String get errorNoActiveRound => 'No active round';

  @override
  String get errorRoundInProgress => 'Round is still in progress';

  @override
  String get errorMatchAlreadyOver => 'Match is already over';

  @override
  String get errorStartRoundFailed => 'Failed to start next round';

  @override
  String get errorCreateMatchFailed => 'Failed to create game';

  @override
  String get errorRestartFailed => 'Failed to restart game';

  @override
  String get errorUnexpected => 'An unexpected error occurred';

  @override
  String get errorPageNotFound => 'Page not found';

  @override
  String get errorGoHome => 'Go Home';

  @override
  String get versusLabel => 'VS';
}
