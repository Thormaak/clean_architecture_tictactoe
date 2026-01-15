import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'TicTacToe'**
  String get appTitle;

  /// Name of player X
  ///
  /// In en, this message translates to:
  /// **'Player X'**
  String get playerX;

  /// Name of player O
  ///
  /// In en, this message translates to:
  /// **'Player O'**
  String get playerO;

  /// Indicates whose turn it is
  ///
  /// In en, this message translates to:
  /// **'{player}\'s turn'**
  String yourTurn(String player);

  /// Announces the winner
  ///
  /// In en, this message translates to:
  /// **'{player} wins!'**
  String winner(String player);

  /// Announces a draw game
  ///
  /// In en, this message translates to:
  /// **'It\'s a draw!'**
  String get draw;

  /// Button to start a new game
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// Button to restart the current game
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// Settings menu title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Audio settings section title
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audioSettings;

  /// Music volume label
  ///
  /// In en, this message translates to:
  /// **'Music volume'**
  String get audioMusicVolume;

  /// Sound effects volume label
  ///
  /// In en, this message translates to:
  /// **'SFX volume'**
  String get audioSfxVolume;

  /// Mute audio label
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get audioMute;

  /// Toggle click sound effects label
  ///
  /// In en, this message translates to:
  /// **'Click sound'**
  String get audioClickSound;

  /// Easy difficulty level
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// Medium difficulty level
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// Hard difficulty level
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// Option to play against AI
  ///
  /// In en, this message translates to:
  /// **'VS AI'**
  String get playAgainstAI;

  /// Option for two player mode
  ///
  /// In en, this message translates to:
  /// **'Two Players'**
  String get twoPlayers;

  /// Back button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Title for difficulty selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose Difficulty'**
  String get chooseDifficulty;

  /// Subtitle for easy difficulty
  ///
  /// In en, this message translates to:
  /// **'For beginners'**
  String get difficultyEasySubtitle;

  /// Subtitle for medium difficulty
  ///
  /// In en, this message translates to:
  /// **'A good challenge'**
  String get difficultyMediumSubtitle;

  /// Subtitle for hard difficulty
  ///
  /// In en, this message translates to:
  /// **'Almost unbeatable'**
  String get difficultyHardSubtitle;

  /// Subtitle for local multiplayer mode
  ///
  /// In en, this message translates to:
  /// **'Same device, take turns'**
  String get gameModeLocalSubtitle;

  /// Subtitle for AI mode
  ///
  /// In en, this message translates to:
  /// **'Test your skills against AI'**
  String get gameModeAISubtitle;

  /// Victory message
  ///
  /// In en, this message translates to:
  /// **'Victory!'**
  String get victory;

  /// Message showing number of moves to win
  ///
  /// In en, this message translates to:
  /// **'Won in {count} moves'**
  String wonInMoves(int count);

  /// Button to play again
  ///
  /// In en, this message translates to:
  /// **'Rematch'**
  String get rematch;

  /// Button to return to main menu
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// Draw game message for overlay
  ///
  /// In en, this message translates to:
  /// **'It\'s a Draw!'**
  String get drawMessage;

  /// Message showing game duration in moves
  ///
  /// In en, this message translates to:
  /// **'Game ended after {count} moves'**
  String gameEndedAfterMoves(int count);

  /// Message shown when AI is processing
  ///
  /// In en, this message translates to:
  /// **'AI is thinking...'**
  String get aiThinking;

  /// Undo button label
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Local game mode label
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get gameModeLocal;

  /// Label indicating it's the player's turn
  ///
  /// In en, this message translates to:
  /// **'Your Turn'**
  String get yourTurnLabel;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// French language option
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Best of label for match configuration
  ///
  /// In en, this message translates to:
  /// **'Best Of'**
  String get bestOf;

  /// Best of 1 label
  ///
  /// In en, this message translates to:
  /// **'BO1'**
  String get bo1;

  /// Best of 3 label
  ///
  /// In en, this message translates to:
  /// **'BO3'**
  String get bo3;

  /// Best of 5 label
  ///
  /// In en, this message translates to:
  /// **'BO5'**
  String get bo5;

  /// Current round indicator
  ///
  /// In en, this message translates to:
  /// **'Round {current} of {total}'**
  String roundOf(int current, int total);

  /// Button to continue to next round
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueMatch;

  /// Button to go to the next round in Best Of match
  ///
  /// In en, this message translates to:
  /// **'Next round'**
  String get nextRound;

  /// Message when a player wins the match
  ///
  /// In en, this message translates to:
  /// **'{name} wins the match!'**
  String matchWinner(String name);

  /// Message when a player wins a round
  ///
  /// In en, this message translates to:
  /// **'{name} wins the round!'**
  String roundWinner(String name);

  /// Message when a round ends in a draw
  ///
  /// In en, this message translates to:
  /// **'Round ended in a draw'**
  String get roundDraw;

  /// Score label
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// Final score label
  ///
  /// In en, this message translates to:
  /// **'Final Score'**
  String get finalScore;

  /// Wins needed to win the match
  ///
  /// In en, this message translates to:
  /// **'{count} more win to match'**
  String winsToMatch(int count);

  /// Title for Best Of selection page
  ///
  /// In en, this message translates to:
  /// **'Choose Format'**
  String get chooseFormat;

  /// Subtitle for Best of 1
  ///
  /// In en, this message translates to:
  /// **'Single game'**
  String get bo1Subtitle;

  /// Subtitle for Best of 3
  ///
  /// In en, this message translates to:
  /// **'First to 2 wins'**
  String get bo3Subtitle;

  /// Subtitle for Best of 5
  ///
  /// In en, this message translates to:
  /// **'First to 3 wins'**
  String get bo5Subtitle;

  /// Title when a match ends in a draw
  ///
  /// In en, this message translates to:
  /// **'Match Draw!'**
  String get matchDraw;

  /// Label for single game (BO1) mode
  ///
  /// In en, this message translates to:
  /// **'Sudden Death'**
  String get suddenDeath;

  /// Error shown when a move is invalid
  ///
  /// In en, this message translates to:
  /// **'Invalid move'**
  String get errorInvalidMove;

  /// Error shown when the game is already over
  ///
  /// In en, this message translates to:
  /// **'Game is over'**
  String get errorGameOver;

  /// Error shown when no round is active
  ///
  /// In en, this message translates to:
  /// **'No active round'**
  String get errorNoActiveRound;

  /// Error shown when a round is not finished yet
  ///
  /// In en, this message translates to:
  /// **'Round is still in progress'**
  String get errorRoundInProgress;

  /// Error shown when the match has already ended
  ///
  /// In en, this message translates to:
  /// **'Match is already over'**
  String get errorMatchAlreadyOver;

  /// Error shown when starting the next round fails
  ///
  /// In en, this message translates to:
  /// **'Failed to start next round'**
  String get errorStartRoundFailed;

  /// Error shown when creating a new game fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create game'**
  String get errorCreateMatchFailed;

  /// Error shown when restarting the game fails
  ///
  /// In en, this message translates to:
  /// **'Failed to restart game'**
  String get errorRestartFailed;

  /// Generic unexpected error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get errorUnexpected;

  /// Message shown for unknown routes
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get errorPageNotFound;

  /// Button label to return home from error page
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get errorGoHome;

  /// Short label between player cards
  ///
  /// In en, this message translates to:
  /// **'VS'**
  String get versusLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
