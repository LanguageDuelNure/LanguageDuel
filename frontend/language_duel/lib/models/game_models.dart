class LanguageDto {
  final String id;
  final String name;
  final int rating;

  LanguageDto({required this.id, required this.name, required this.rating});

  factory LanguageDto.fromJson(Map<String, dynamic> j) => LanguageDto(
        id: j['id'] as String,
        name: j['name'] as String,
        rating: j['rating'] as int? ?? 0,
      );
}

class GameStateAnswerDto {
  final String id;
  final String name;

  GameStateAnswerDto({required this.id, required this.name});

  factory GameStateAnswerDto.fromJson(Map<String, dynamic> j) =>
      GameStateAnswerDto(
        id: j['id'] as String,
        name: j['name'] as String,
      );
}

class GameStateQuestionDto {
  final String id;
  final String name;
  final List<GameStateAnswerDto> answers;
  final Map<String, String> userAnswers;

  GameStateQuestionDto({
    required this.id,
    required this.name,
    required this.answers,
    required this.userAnswers,
  });

  factory GameStateQuestionDto.fromJson(Map<String, dynamic> j) {
    final rawAnswers = j['answers'] as List<dynamic>? ?? [];
    final rawUserAnswers = j['userAnswers'] as Map<String, dynamic>? ?? {};
    return GameStateQuestionDto(
      id: j['id'] as String,
      name: j['name'] as String,
      answers: rawAnswers
          .map((a) => GameStateAnswerDto.fromJson(a as Map<String, dynamic>))
          .toList(),
      userAnswers: rawUserAnswers.map((k, v) => MapEntry(k, v as String)),
    );
  }
}

// Now includes rating from server (GameSessionUserDto.Rating)
class GameSessionUserDto {
  final String id;
  final String name;
  final int hp;
  final int rating;

  GameSessionUserDto({
    required this.id,
    required this.name,
    required this.hp,
    required this.rating,
  });

  factory GameSessionUserDto.fromJson(Map<String, dynamic> j) =>
      GameSessionUserDto(
        id: j['id'] as String,
        name: j['name'] as String,
        hp: j['hp'] as int? ?? 100,
        rating: j['rating'] as int? ?? 0,
      );
}

class GameStateDto {
  final GameStateQuestionDto currentQuestion;
  final List<GameSessionUserDto> users;
  final int timeRemainingInSeconds;

  GameStateDto({
    required this.currentQuestion,
    required this.users,
    required this.timeRemainingInSeconds,
  });

  factory GameStateDto.fromJson(Map<String, dynamic> j) => GameStateDto(
        currentQuestion: GameStateQuestionDto.fromJson(
            j['currentQuestion'] as Map<String, dynamic>),
        users: (j['users'] as List<dynamic>? ?? [])
            .map((u) => GameSessionUserDto.fromJson(u as Map<String, dynamic>))
            .toList(),
        timeRemainingInSeconds: j['timeRemainingInSeconds'] as int? ?? 0,
      );
}

class GameInvitationDto {
  final String inviterUserId;
  final String? gameId;

  GameInvitationDto({required this.inviterUserId, this.gameId});

  factory GameInvitationDto.fromJson(Map<String, dynamic> j) =>
      GameInvitationDto(
        inviterUserId: j['inviterUserId'] as String,
        gameId: j['gameId'] as String?,
      );
}

class AnswerDto {
  final String id;
  final String name;
  final bool isCorrect;

  AnswerDto({required this.id, required this.name, required this.isCorrect});

  factory AnswerDto.fromJson(Map<String, dynamic> j) => AnswerDto(
        id: j['id'] as String,
        name: j['name'] as String,
        isCorrect: j['isCorrect'] as bool? ?? false,
      );
}

class QuestionDto {
  final String id;
  final String name;
  final List<AnswerDto> answers;
  final Map<String, String> userAnswers;

  QuestionDto({
    required this.id,
    required this.name,
    required this.answers,
    required this.userAnswers,
  });

  factory QuestionDto.fromJson(Map<String, dynamic> j) {
    final rawAnswers = j['answers'] as List<dynamic>? ?? [];
    final rawUserAnswers = j['userAnswers'] as Map<String, dynamic>? ?? {};
    return QuestionDto(
      id: j['id'] as String,
      name: j['name'] as String,
      answers: rawAnswers
          .map((a) => AnswerDto.fromJson(a as Map<String, dynamic>))
          .toList(),
      userAnswers: rawUserAnswers.map((k, v) => MapEntry(k, v as String)),
    );
  }
}

class GameResultDto {
  final String? winnerUserId;
  final String? winnerUserName;
  final int ratingChangeAfterWinOrLoss;
  final List<QuestionDto> questions;

  GameResultDto({
    this.winnerUserId,
    this.winnerUserName,
    required this.ratingChangeAfterWinOrLoss,
    required this.questions,
  });

  factory GameResultDto.fromJson(Map<String, dynamic> j) => GameResultDto(
        winnerUserId: j['winnerUserId'] as String?,
        winnerUserName: j['winnerUserName'] as String?,
        ratingChangeAfterWinOrLoss:
            j['ratingChangeAfterWinOrLoss'] as int? ?? 0,
        questions: (j['questions'] as List<dynamic>? ?? [])
            .map((q) => QuestionDto.fromJson(q as Map<String, dynamic>))
            .toList(),
      );
}