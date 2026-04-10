// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get setupNameTitle => 'Set your display name';

  @override
  String get setupNameSubtitle => 'This is how other duelists will see you.';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameHint => 'Your display name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get nameMinLen => 'Minimum 3 characters';

  @override
  String get nameMaxLen => 'Maximum 32 characters';

  @override
  String get unexpectedError => 'An unexpected error occurred.';

  @override
  String get continueToArena => 'Continue to Arena';

  @override
  String get createAccountTitle => 'Create account';

  @override
  String get joinArenaSubtitle => 'Join the dueling arena';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => '••••••••';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLen => 'Minimum 8 characters';

  @override
  String get passwordComplexity => 'Must have upper and lowercase letters';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get createAccountBtn => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get signInLink => 'Sign In';

  @override
  String get profileTitle => 'Profile';

  @override
  String get notAuthenticated => 'Not authenticated';

  @override
  String get rolePlayer => 'Player';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get ratingsByLanguageTitle => 'Ratings by language';

  @override
  String get signOutBtn => 'Sign Out';

  @override
  String get errorRetry => 'Retry';

  @override
  String get statTotalMatches => 'Total matches';

  @override
  String get statTotalWins => 'Total wins';

  @override
  String get statCurrentRating => 'Current rating';

  @override
  String get statBestRating => 'Best rating';

  @override
  String get diffEasy => 'Easy';

  @override
  String get diffMedium => 'Medium';

  @override
  String get diffHard => 'Hard';

  @override
  String get diffVeryHard => 'Very Hard';

  @override
  String ptsSuffix(int count) {
    return '$count pts';
  }

  @override
  String get statW => 'W';

  @override
  String get statG => 'G';

  @override
  String get statBest => 'Best';

  @override
  String helloUser(String userName) {
    return 'Hello, $userName 👋';
  }

  @override
  String get readyToDuel => 'Ready to duel?';

  @override
  String get quickDuel => 'QUICK DUEL';

  @override
  String get challengeRandom =>
      'Challenge a random opponent\nof similar skill level';

  @override
  String get noLanguages => 'No languages available';

  @override
  String get languageLabel => 'Language';

  @override
  String get searchingOpponent => 'Searching for opponent...';

  @override
  String get cancelBtn => 'Cancel';

  @override
  String get findOpponentBtn => 'Find Opponent';

  @override
  String get statRating => 'Rating';

  @override
  String get statWins => 'Wins';

  @override
  String get statPlayed => 'Played';

  @override
  String get welcomeBackTitle => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to continue your duels';

  @override
  String get connectionError =>
      'Could not reach server. Check your connection.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get registerLink => 'Register';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get globalRankings => 'Global rankings — all languages';

  @override
  String get allLanguages => 'All languages';

  @override
  String get noPlayers => 'No players yet';

  @override
  String winsCount(int count) {
    return '$count wins';
  }

  @override
  String winsGamesRatio(int wins, int games) {
    return '$wins W / $games G';
  }

  @override
  String get checkEmailTitle => 'Check your email';

  @override
  String get checkEmailSubtitleFallback =>
      'We sent a 6-digit code to your email address.';

  @override
  String emailSentTo(String email) {
    return 'We sent a 6-digit code to\n$email';
  }

  @override
  String get resendSuccess => 'A new code has been sent to your email.';

  @override
  String get didntReceive => 'Didn\'t receive it? ';

  @override
  String get resendCode => 'Resend code';

  @override
  String get defaultDuelistName => 'Duelist';

  @override
  String get findingOpponent => 'Finding opponent...';

  @override
  String get matchingSkill => 'Matching you with a player of similar skill';

  @override
  String get pointsGained => 'points gained';

  @override
  String get pointsLost => 'points lost';

  @override
  String get noChange => 'no change';

  @override
  String languageRatingSuffix(String language) {
    return '$language rating';
  }

  @override
  String get resultDraw => 'Draw!';

  @override
  String get resultVictory => 'Victory!';

  @override
  String get resultDefeat => 'Defeat';

  @override
  String get wellPlayed => 'Well played!';

  @override
  String playerWins(String playerName) {
    return '$playerName wins';
  }

  @override
  String get roundSummary => 'Round Summary';

  @override
  String questionReviewTitle(int num, String question) {
    return 'Q$num: $question';
  }

  @override
  String yourAnswer(String answer) {
    return 'Your answer: $answer';
  }

  @override
  String correctAnswer(String answer) {
    return 'Correct: $answer';
  }

  @override
  String get backToLobbyBtn => 'Back to Lobby';

  @override
  String get giveUpTitle => 'Give up?';

  @override
  String get giveUpContent =>
      'You will forfeit the match and lose rating points.';

  @override
  String get giveUpBtn => 'Give Up';

  @override
  String get matchFoundTitle => 'MATCH FOUND';

  @override
  String get youPlayer => 'You';

  @override
  String get unknownOpponent => '...';

  @override
  String get vsText => 'VS';

  @override
  String get preparingFirstQuestion => 'Preparing first question...';

  @override
  String opponentAnswered(String opponentName) {
    return '$opponentName answered';
  }

  @override
  String get nextQuestionIncoming => 'Next question incoming...';

  @override
  String opponentsAnswer(String opponentName) {
    return '$opponentName\'s answer';
  }

  @override
  String get bothPickedThis => 'Both picked this';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get langEnglish => 'English';

  @override
  String get langUkrainian => 'Українська';

  @override
  String get navPlay => 'Play';

  @override
  String get navLeaderboard => 'Leaderboard';

  @override
  String get navProfile => 'Profile';

  @override
  String get editNameTitle => 'Edit Name';

  @override
  String get editNameHint => 'Your display name';

  @override
  String get saveBtn => 'Save';

  @override
  String get nameSavedSuccess => 'Name updated successfully';

  @override
  String get nameSaveError => 'Failed to save name. Please try again.';

  @override
  String get avatarUploadError => 'Failed to upload avatar. Please try again.';

  @override
  String get changeAvatarTooltip => 'Change avatar';

  @override
  String get adminBadge => 'ADMIN';

  @override
  String get adminUsersTitle => 'User Management';

  @override
  String get adminLoadingUsers => 'Loading users…';

  @override
  String adminUserCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count users',
      one: '1 user',
    );
    return '$_temp0';
  }

  @override
  String get adminSearchHint => 'Search by name or email…';

  @override
  String get adminBannedLabel => 'BANNED';

  @override
  String adminBannedUntil(String date) {
    return 'Banned until $date';
  }

  @override
  String get adminBan => 'Ban';

  @override
  String get adminUnban => 'Unban';

  @override
  String adminBanSuccess(String name) {
    return '$name has been banned';
  }

  @override
  String adminUnbanSuccess(String name) {
    return '$name has been unbanned';
  }

  @override
  String get adminBanDialogTitle => 'Ban User';

  @override
  String get adminBanQuickSelect => 'Quick select';

  @override
  String adminDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get adminBanDaysHint => 'Enter number of days';

  @override
  String get adminDaysSuffix => 'days';

  @override
  String get adminBanDaysError => 'Please enter a valid number of days (≥ 1)';

  @override
  String get adminCancel => 'Cancel';

  @override
  String get adminConfirmBan => 'Confirm Ban';

  @override
  String get adminNoUsers => 'No users found';

  @override
  String adminNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get navAdmin => 'Admin';
}
