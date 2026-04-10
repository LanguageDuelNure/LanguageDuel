import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

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
    Locale('uk'),
  ];

  /// No description provided for @setupNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your display name'**
  String get setupNameTitle;

  /// No description provided for @setupNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is how other duelists will see you.'**
  String get setupNameSubtitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Your display name'**
  String get nameHint;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @nameMinLen.
  ///
  /// In en, this message translates to:
  /// **'Minimum 3 characters'**
  String get nameMinLen;

  /// No description provided for @nameMaxLen.
  ///
  /// In en, this message translates to:
  /// **'Maximum 32 characters'**
  String get nameMaxLen;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedError;

  /// No description provided for @continueToArena.
  ///
  /// In en, this message translates to:
  /// **'Continue to Arena'**
  String get continueToArena;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccountTitle;

  /// No description provided for @joinArenaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the dueling arena'**
  String get joinArenaSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLen.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters'**
  String get passwordMinLen;

  /// No description provided for @passwordComplexity.
  ///
  /// In en, this message translates to:
  /// **'Must have upper and lowercase letters'**
  String get passwordComplexity;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @createAccountBtn.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountBtn;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInLink;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @notAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Not authenticated'**
  String get notAuthenticated;

  /// No description provided for @rolePlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get rolePlayer;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @ratingsByLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Ratings by language'**
  String get ratingsByLanguageTitle;

  /// No description provided for @signOutBtn.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutBtn;

  /// No description provided for @errorRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get errorRetry;

  /// No description provided for @statTotalMatches.
  ///
  /// In en, this message translates to:
  /// **'Total matches'**
  String get statTotalMatches;

  /// No description provided for @statTotalWins.
  ///
  /// In en, this message translates to:
  /// **'Total wins'**
  String get statTotalWins;

  /// No description provided for @statCurrentRating.
  ///
  /// In en, this message translates to:
  /// **'Current rating'**
  String get statCurrentRating;

  /// No description provided for @statBestRating.
  ///
  /// In en, this message translates to:
  /// **'Best rating'**
  String get statBestRating;

  /// No description provided for @diffEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get diffEasy;

  /// No description provided for @diffMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get diffMedium;

  /// No description provided for @diffHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get diffHard;

  /// No description provided for @diffVeryHard.
  ///
  /// In en, this message translates to:
  /// **'Very Hard'**
  String get diffVeryHard;

  /// No description provided for @ptsSuffix.
  ///
  /// In en, this message translates to:
  /// **'{count} pts'**
  String ptsSuffix(int count);

  /// No description provided for @statW.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get statW;

  /// No description provided for @statG.
  ///
  /// In en, this message translates to:
  /// **'G'**
  String get statG;

  /// No description provided for @statBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get statBest;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {userName} 👋'**
  String helloUser(String userName);

  /// No description provided for @readyToDuel.
  ///
  /// In en, this message translates to:
  /// **'Ready to duel?'**
  String get readyToDuel;

  /// No description provided for @quickDuel.
  ///
  /// In en, this message translates to:
  /// **'QUICK DUEL'**
  String get quickDuel;

  /// No description provided for @challengeRandom.
  ///
  /// In en, this message translates to:
  /// **'Challenge a random opponent\nof similar skill level'**
  String get challengeRandom;

  /// No description provided for @noLanguages.
  ///
  /// In en, this message translates to:
  /// **'No languages available'**
  String get noLanguages;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @searchingOpponent.
  ///
  /// In en, this message translates to:
  /// **'Searching for opponent...'**
  String get searchingOpponent;

  /// No description provided for @cancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelBtn;

  /// No description provided for @findOpponentBtn.
  ///
  /// In en, this message translates to:
  /// **'Find Opponent'**
  String get findOpponentBtn;

  /// No description provided for @statRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get statRating;

  /// No description provided for @statWins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get statWins;

  /// No description provided for @statPlayed.
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get statPlayed;

  /// No description provided for @welcomeBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBackTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your duels'**
  String get signInSubtitle;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not reach server. Check your connection.'**
  String get connectionError;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @registerLink.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerLink;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @globalRankings.
  ///
  /// In en, this message translates to:
  /// **'Global rankings — all languages'**
  String get globalRankings;

  /// No description provided for @allLanguages.
  ///
  /// In en, this message translates to:
  /// **'All languages'**
  String get allLanguages;

  /// No description provided for @noPlayers.
  ///
  /// In en, this message translates to:
  /// **'No players yet'**
  String get noPlayers;

  /// No description provided for @winsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} wins'**
  String winsCount(int count);

  /// No description provided for @winsGamesRatio.
  ///
  /// In en, this message translates to:
  /// **'{wins} W / {games} G'**
  String winsGamesRatio(int wins, int games);

  /// No description provided for @checkEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkEmailTitle;

  /// No description provided for @checkEmailSubtitleFallback.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to your email address.'**
  String get checkEmailSubtitleFallback;

  /// No description provided for @emailSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to\n{email}'**
  String emailSentTo(String email);

  /// No description provided for @resendSuccess.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent to your email.'**
  String get resendSuccess;

  /// No description provided for @didntReceive.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive it? '**
  String get didntReceive;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @defaultDuelistName.
  ///
  /// In en, this message translates to:
  /// **'Duelist'**
  String get defaultDuelistName;

  /// No description provided for @findingOpponent.
  ///
  /// In en, this message translates to:
  /// **'Finding opponent...'**
  String get findingOpponent;

  /// No description provided for @matchingSkill.
  ///
  /// In en, this message translates to:
  /// **'Matching you with a player of similar skill'**
  String get matchingSkill;

  /// No description provided for @pointsGained.
  ///
  /// In en, this message translates to:
  /// **'points gained'**
  String get pointsGained;

  /// No description provided for @pointsLost.
  ///
  /// In en, this message translates to:
  /// **'points lost'**
  String get pointsLost;

  /// No description provided for @noChange.
  ///
  /// In en, this message translates to:
  /// **'no change'**
  String get noChange;

  /// No description provided for @languageRatingSuffix.
  ///
  /// In en, this message translates to:
  /// **'{language} rating'**
  String languageRatingSuffix(String language);

  /// No description provided for @resultDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw!'**
  String get resultDraw;

  /// No description provided for @resultVictory.
  ///
  /// In en, this message translates to:
  /// **'Victory!'**
  String get resultVictory;

  /// No description provided for @resultDefeat.
  ///
  /// In en, this message translates to:
  /// **'Defeat'**
  String get resultDefeat;

  /// No description provided for @wellPlayed.
  ///
  /// In en, this message translates to:
  /// **'Well played!'**
  String get wellPlayed;

  /// No description provided for @playerWins.
  ///
  /// In en, this message translates to:
  /// **'{playerName} wins'**
  String playerWins(String playerName);

  /// No description provided for @roundSummary.
  ///
  /// In en, this message translates to:
  /// **'Round Summary'**
  String get roundSummary;

  /// No description provided for @questionReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Q{num}: {question}'**
  String questionReviewTitle(int num, String question);

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer: {answer}'**
  String yourAnswer(String answer);

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct: {answer}'**
  String correctAnswer(String answer);

  /// No description provided for @backToLobbyBtn.
  ///
  /// In en, this message translates to:
  /// **'Back to Lobby'**
  String get backToLobbyBtn;

  /// No description provided for @giveUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Give up?'**
  String get giveUpTitle;

  /// No description provided for @giveUpContent.
  ///
  /// In en, this message translates to:
  /// **'You will forfeit the match and lose rating points.'**
  String get giveUpContent;

  /// No description provided for @giveUpBtn.
  ///
  /// In en, this message translates to:
  /// **'Give Up'**
  String get giveUpBtn;

  /// No description provided for @matchFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'MATCH FOUND'**
  String get matchFoundTitle;

  /// No description provided for @youPlayer.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youPlayer;

  /// No description provided for @unknownOpponent.
  ///
  /// In en, this message translates to:
  /// **'...'**
  String get unknownOpponent;

  /// No description provided for @vsText.
  ///
  /// In en, this message translates to:
  /// **'VS'**
  String get vsText;

  /// No description provided for @preparingFirstQuestion.
  ///
  /// In en, this message translates to:
  /// **'Preparing first question...'**
  String get preparingFirstQuestion;

  /// No description provided for @opponentAnswered.
  ///
  /// In en, this message translates to:
  /// **'{opponentName} answered'**
  String opponentAnswered(String opponentName);

  /// No description provided for @nextQuestionIncoming.
  ///
  /// In en, this message translates to:
  /// **'Next question incoming...'**
  String get nextQuestionIncoming;

  /// No description provided for @opponentsAnswer.
  ///
  /// In en, this message translates to:
  /// **'{opponentName}\'s answer'**
  String opponentsAnswer(String opponentName);

  /// No description provided for @bothPickedThis.
  ///
  /// In en, this message translates to:
  /// **'Both picked this'**
  String get bothPickedThis;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langUkrainian.
  ///
  /// In en, this message translates to:
  /// **'Українська'**
  String get langUkrainian;

  /// No description provided for @navPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get navPlay;

  /// No description provided for @navLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get navLeaderboard;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;
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
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
