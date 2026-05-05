// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get setupNameTitle => 'Встановіть відображуване ім\'я';

  @override
  String get setupNameSubtitle => 'Так вас бачитимуть інші дуелянти.';

  @override
  String get nameLabel => 'Ім\'я';

  @override
  String get nameHint => 'Ваше відображуване ім\'я';

  @override
  String get nameRequired => 'Ім\'я обов\'язкове';

  @override
  String get nameMinLen => 'Мінімум 3 символи';

  @override
  String get nameMaxLen => 'Максимум 32 символи';

  @override
  String get unexpectedError => 'Сталася непередбачена помилка.';

  @override
  String get continueToArena => 'Перейти на арену';

  @override
  String get createAccountTitle => 'Створити акаунт';

  @override
  String get joinArenaSubtitle => 'Приєднуйтесь до дуельної арени';

  @override
  String get emailLabel => 'Електронна пошта';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailRequired => 'Електронна пошта обов\'язкова';

  @override
  String get emailInvalid => 'Введіть дійсну електронну пошту';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get passwordHint => '••••••••';

  @override
  String get passwordRequired => 'Пароль обов\'язковий';

  @override
  String get passwordMinLen => 'Мінімум 8 символів';

  @override
  String get passwordComplexity => 'Повинен містити великі та малі літери';

  @override
  String get confirmPasswordLabel => 'Підтвердіть пароль';

  @override
  String get confirmPasswordRequired => 'Будь ласка, підтвердіть свій пароль';

  @override
  String get passwordMismatch => 'Паролі не збігаються';

  @override
  String get createAccountBtn => 'Створити акаунт';

  @override
  String get alreadyHaveAccount => 'Вже є акаунт? ';

  @override
  String get signInLink => 'Увійти';

  @override
  String get profileTitle => 'Профіль';

  @override
  String get notAuthenticated => 'Не автентифіковано';

  @override
  String get rolePlayer => 'Гравець';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get ratingsByLanguageTitle => 'Рейтинг за мовами';

  @override
  String get signOutBtn => 'Вийти';

  @override
  String get errorRetry => 'Повторити';

  @override
  String get statTotalMatches => 'Всього матчів';

  @override
  String get statTotalWins => 'Всього перемог';

  @override
  String get statCurrentRating => 'Поточний рейтинг';

  @override
  String get statBestRating => 'Найкращий рейтинг';

  @override
  String get diffEasy => 'Легко';

  @override
  String get diffMedium => 'Середньо';

  @override
  String get diffHard => 'Складно';

  @override
  String get diffVeryHard => 'Дуже складно';

  @override
  String ptsSuffix(int count) {
    return '$count очок';
  }

  @override
  String get statW => 'П';

  @override
  String get statG => 'І';

  @override
  String get statBest => 'Макс';

  @override
  String helloUser(String userName) {
    return 'Привіт, $userName 👋';
  }

  @override
  String get readyToDuel => 'Готові до дуелі?';

  @override
  String get quickDuel => 'ШВИДКА ДУЕЛЬ';

  @override
  String get challengeRandom =>
      'Киньте виклик випадковому супротивнику\nсхожого рівня навичок';

  @override
  String get noLanguages => 'Немає доступних мов';

  @override
  String get languageLabel => 'Мова';

  @override
  String get searchingOpponent => 'Пошук супротивника...';

  @override
  String get cancelBtn => 'Скасувати';

  @override
  String get findOpponentBtn => 'Знайти супротивника';

  @override
  String get statRating => 'Рейтинг';

  @override
  String get statWins => 'Перемоги';

  @override
  String get statPlayed => 'Зіграно';

  @override
  String get welcomeBackTitle => 'З поверненням';

  @override
  String get signInSubtitle => 'Увійдіть, щоб продовжити дуелі';

  @override
  String get connectionError =>
      'Не вдалося з\'єднатися з сервером. Перевірте підключення.';

  @override
  String get continueWithGoogle => 'Продовжити з Google';

  @override
  String get noAccount => 'Немає акаунта? ';

  @override
  String get registerLink => 'Зареєструватися';

  @override
  String get leaderboardTitle => 'Таблиця лідерів';

  @override
  String get globalRankings => 'Глобальний рейтинг — усі мови';

  @override
  String get allLanguages => 'Усі мови';

  @override
  String get noPlayers => 'Поки немає гравців';

  @override
  String winsCount(int count) {
    return '$count перемог';
  }

  @override
  String winsGamesRatio(int wins, int games) {
    return '$wins П / $games І';
  }

  @override
  String get checkEmailTitle => 'Перевірте пошту';

  @override
  String get checkEmailSubtitleFallback =>
      'Ми надіслали 6-значний код на вашу електронну адресу.';

  @override
  String emailSentTo(String email) {
    return 'Ми надіслали 6-значний код на\n$email';
  }

  @override
  String get resendSuccess => 'Новий код надіслано на вашу електронну пошту.';

  @override
  String get didntReceive => 'Не отримали? ';

  @override
  String get resendCode => 'Надіслати код ще раз';

  @override
  String get defaultDuelistName => 'Дуелянт';

  @override
  String get findingOpponent => 'Пошук супротивника...';

  @override
  String get matchingSkill => 'Підбираємо вам гравця зі схожими навичками';

  @override
  String get pointsGained => 'очок отримано';

  @override
  String get pointsLost => 'очок втрачено';

  @override
  String get noChange => 'без змін';

  @override
  String languageRatingSuffix(String language) {
    return 'Рейтинг: $language';
  }

  @override
  String get resultDraw => 'Нічия!';

  @override
  String get resultVictory => 'Перемога!';

  @override
  String get resultDefeat => 'Поразка';

  @override
  String get wellPlayed => 'Чудова гра!';

  @override
  String playerWins(String playerName) {
    return '$playerName перемагає';
  }

  @override
  String get roundSummary => 'Підсумок раунду';

  @override
  String questionReviewTitle(int num, String question) {
    return 'П$num: $question';
  }

  @override
  String yourAnswer(String answer) {
    return 'Ваша відповідь: $answer';
  }

  @override
  String correctAnswer(String answer) {
    return 'Правильна: $answer';
  }

  @override
  String get backToLobbyBtn => 'Повернутися до лобі';

  @override
  String get giveUpTitle => 'Здатися?';

  @override
  String get giveUpContent =>
      'Ви достроково завершите матч і втратите рейтингові очки.';

  @override
  String get giveUpBtn => 'Здатися';

  @override
  String get matchFoundTitle => 'МАТЧ ЗНАЙДЕНО';

  @override
  String get youPlayer => 'Ви';

  @override
  String get unknownOpponent => '...';

  @override
  String get vsText => 'ПРОТИ';

  @override
  String get preparingFirstQuestion => 'Готуємо перше питання...';

  @override
  String opponentAnswered(String opponentName) {
    return '$opponentName відповів(-ла)';
  }

  @override
  String get nextQuestionIncoming => 'Наступне питання вже близько...';

  @override
  String opponentsAnswer(String opponentName) {
    return 'Відповідь: $opponentName';
  }

  @override
  String get bothPickedThis => 'Обидва обрали це';

  @override
  String get settingsLanguage => 'Мова';

  @override
  String get langEnglish => 'English';

  @override
  String get langUkrainian => 'Українська';

  @override
  String get navPlay => 'Грати';

  @override
  String get navLeaderboard => 'Таблиця лідерів';

  @override
  String get navProfile => 'Профіль';

  @override
  String get editNameTitle => 'Змінити імʼя';

  @override
  String get editNameHint => 'Ваше ігрове імʼя';

  @override
  String get saveBtn => 'Зберегти';

  @override
  String get nameSavedSuccess => 'Імʼя успішно оновлено';

  @override
  String get nameSaveError => 'Не вдалося зберегти імʼя. Спробуйте ще раз.';

  @override
  String get avatarUploadError =>
      'Не вдалося завантажити аватар. Спробуйте ще раз.';

  @override
  String get changeAvatarTooltip => 'Змінити аватар';

  @override
  String get adminBadge => 'АДМІН';

  @override
  String get adminUsersTitle => 'Управління користувачами';

  @override
  String get adminLoadingUsers => 'Завантаження користувачів…';

  @override
  String adminUserCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count користувача',
      many: '$count користувачів',
      few: '$count користувачі',
      one: '1 користувач',
    );
    return '$_temp0';
  }

  @override
  String get adminSearchHint => 'Пошук за ім\'ям або email…';

  @override
  String get adminBannedLabel => 'ЗАБЛОКОВАНО';

  @override
  String adminBannedUntil(String date) {
    return 'Заблоковано до $date';
  }

  @override
  String get adminBan => 'Бан';

  @override
  String get adminUnban => 'Розбанити';

  @override
  String adminBanSuccess(String name) {
    return '$name заблоковано';
  }

  @override
  String adminUnbanSuccess(String name) {
    return '$name розблоковано';
  }

  @override
  String get adminBanDialogTitle => 'Заблокувати користувача';

  @override
  String get adminBanQuickSelect => 'Швидкий вибір';

  @override
  String adminDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count днів',
      few: '$count дні',
      one: '1 день',
    );
    return '$_temp0';
  }

  @override
  String get adminBanDaysHint => 'Введіть кількість днів';

  @override
  String get adminDaysSuffix => 'днів';

  @override
  String get adminBanDaysError => 'Введіть коректну кількість днів (≥ 1)';

  @override
  String get adminCancel => 'Скасувати';

  @override
  String get adminConfirmBan => 'Підтвердити бан';

  @override
  String get adminNoUsers => 'Користувачів не знайдено';

  @override
  String adminNoResults(String query) {
    return 'Немає результатів для \"$query\"';
  }

  @override
  String get navAdmin => 'Адмін';

  @override
  String get bannedTitle => 'Акаунт заблоковано';

  @override
  String get bannedMessage => 'Ваш акаунт було обмежено для пошуку ігор.';

  @override
  String bannedUntilMessage(String date) {
    return 'Ваш акаунт було обмежено для пошуку ігор до $date.';
  }

  @override
  String get matchHistoryTitle => 'Історія матчів';

  @override
  String get myTicketsTitle => 'Мої тікети';

  @override
  String get manageTicketsAdmin => 'Управління тікетами (Адмін)';

  @override
  String banReasonLabel(String reason) {
    return 'Причина: $reason';
  }

  @override
  String get noMatchHistory => 'Історію матчів не знайдено';

  @override
  String get victoryLabel => 'ПЕРЕМОГА';

  @override
  String get defeatLabel => 'ПОРАЗКА';

  @override
  String get matchDetailsTitle => 'Деталі матчу';

  @override
  String get failedLoadDetails => 'Не вдалося завантажити деталі';

  @override
  String get newTicketTitle => 'Новий тікет';

  @override
  String get ticketIssueHint => 'Опишіть вашу проблему...';

  @override
  String get submitBtn => 'Надіслати';

  @override
  String get noTicketsFound => 'Тікети не знайдено';

  @override
  String ticketIdLabel(String id) {
    return 'Тікет #$id';
  }

  @override
  String ticketStatusTitle(String status) {
    return 'Тікет $status';
  }

  @override
  String get errorLoadingTicket => 'Помилка завантаження тікета';

  @override
  String get messageHint => 'Повідомлення...';

  @override
  String get manageTicketsTitle => 'Управління тікетами';

  @override
  String get ticketStatusOpen => 'Відкриті';

  @override
  String get ticketStatusInProgress => 'В процесі';

  @override
  String get ticketStatusClosed => 'Закриті';

  @override
  String get noMessages => 'Немає повідомлень';
}
