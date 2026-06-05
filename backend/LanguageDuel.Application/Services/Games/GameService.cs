using AutoMapper;
using LanguageDuel.Application.Dtos.Games;
using LanguageDuel.Application.Dtos.Questions;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Options;
using LanguageDuel.Application.Repositories;
using LanguageDuel.Application.Services.ApplicationUserLanguages;
using LanguageDuel.Application.Services.ApplicationUserOpponents;
using LanguageDuel.Application.Services.Questions;
using LanguageDuel.Domain.Entities;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;

namespace LanguageDuel.Application.Services.Games;

public class GameService(
    INotificationService notificationService,
    IGameSessionStorage storage,
    IGameRepository gameRep,
    IRepository<ApplicationUserLanguage> applicationUserLanguageRep,
    IDifficultyRepository difficultyRep,
    IUserService userService,
    IQuestionService questionService,
    IRepository<Language> languageRep,
    IMapper mapper,
    IServiceScopeFactory serviceScopeFactory,
    IOptions<GameLogicOptions> gameLogicOptions) : IGameService
{
    private readonly GameLogicOptions _gameLogicOptions = gameLogicOptions.Value;

    private const int PlayersInGame = 2;
    private const int BeforeGameDelayMs = 1000;

    public async Task<IEnumerable<string>> GetSearchGroupsAsync(Guid userId, Guid languageId)
    {
        var applicationUserLanguage = await applicationUserLanguageRep.GetAsync(userId, languageId);
        return GetGameGroups(languageId, applicationUserLanguage);
    }

    public string GetGameGroupAsync(Guid gameId)
    {
        return "game-id" + gameId;
    }

    public Result<Guid> GetGame(Guid userId)
    {
        var session = storage.Games.Values
            .FirstOrDefault(g => g.Users.Any(u => u.Id == userId));

        return session == null
            ? new Result<Guid>
            {
                Errors = [new Error
                {
                    Key = ErrorKey.NotFound,
                    Message = "No active game found for this user.",
                }]
            }
            : new Result<Guid>
            {
                Value = session.Id
            };
    }

    public async Task<Result> GiveUpAsync(Guid userId, Guid gameId)
    {
        var isFound = storage.Games.TryGetValue(gameId, out var gameSession);

        if (!isFound)
        {
            return new Result
            {
                Errors = [new Error
                {
                    Key = ErrorKey.NotFound,
                    Message = "Game not found",
                }]
            };
        }

        var user = gameSession!.Users.FirstOrDefault(u => u.Id == userId);
        if (user == null)
        {
            return new Result
            {
                Errors = [new Error
                {
                    Key = ErrorKey.Forbidden,
                    Message = "User not belong to this game",
                }]
            };
        }

        user.IsGiveUp = true;
        gameSession.Timer.Stop();

        using var scope = serviceScopeFactory.CreateScope();
        await FinishGameInternalAsync(gameSession, scope.ServiceProvider);

        return new Result();
    }

    public async Task<Result> ChooseAnswerAsync(Guid userId, Guid gameId, Guid answerId)
    {
        storage.Games.TryGetValue(gameId, out var gameSession);
        if (gameSession == null)
        {
            return new Result
            {
                Errors = [new Error
                {
                    Key = ErrorKey.NotFound,
                    Message = "Game not found",
                }]
            };
        }
        
        var currentQuestion = gameSession.Questions[gameSession.CurrentQuestionIndex];
        var chosenAnswer = currentQuestion.Answers.FirstOrDefault(a => a.Id == answerId);

        var isOpponentSelectedThisAnswer = currentQuestion.UserAnswers.ContainsValue(answerId);
        if (isOpponentSelectedThisAnswer)
        {
            return new Result
            {
                Errors = [new Error
                {
                    Field = nameof(answerId),
                    Key = ErrorKey.AlreadyChosen,
                    Message = "Opponent has already chosen this answer and it is incorrect",
                }]
            };
        }

        var isAnswerSelected = !currentQuestion.UserAnswers.TryAdd(userId, answerId);
        if (isAnswerSelected)
        {
            return new Result
            {
                Errors = [new Error
                {
                    Field = nameof(answerId),
                    Key = ErrorKey.AlreadyExists,
                    Message = "You have already chosen answer",
                }]
            };
        }

        if (chosenAnswer!.IsCorrect)
        {
            foreach (var user in gameSession.Users.Where(user => user.Id != userId))
            {
                user.Hp--;
            }

            return await ExecuteScopedAction(gameSession, (s) => MoveToNextQuestionInternalAsync(gameSession, s));
        }

        var allChooseIncorrectQuestions = currentQuestion.UserAnswers.Count == PlayersInGame;
        if (allChooseIncorrectQuestions)
        {
            foreach (var user in gameSession.Users)
            {
                user.Hp--;
            }

            return await ExecuteScopedAction(gameSession, (s) => MoveToNextQuestionInternalAsync(gameSession, s));
        }

        await SendGameStateChangeAsync(gameSession);
        return new Result();
    }

    private async Task<Result> ExecuteScopedAction(GameSessionDto gameSession, Func<IServiceProvider, Task<Result>> action)
    {
        using var scope = serviceScopeFactory.CreateScope();
        return await action(scope.ServiceProvider);
    }

    private async Task<Result> MoveToNextQuestionInternalAsync(GameSessionDto gameSession, IServiceProvider sp)
    {
        gameSession.Timer.Stop();
        Guid? correctAnswerId = null;
        if (gameSession.CurrentQuestionIndex >= 0)
        {
            correctAnswerId = gameSession
                .Questions[gameSession.CurrentQuestionIndex]
                .Answers
                .Where(a => a.IsCorrect)
                .Select(a => a.Id)
                .First();
        }

        await SendGameStateChangeAsync(gameSession, correctAnswerId);
        await Task.Delay(_gameLogicOptions.QuestionDelayMs);

        gameSession.CurrentQuestionIndex++;
        gameSession.Timer.Start();
        gameSession.CurrentQuestionStartDateTime = DateTime.UtcNow;

        return await HandleGameStateInternalAsync(gameSession, sp);
    }

    private async Task<Result> HandleGameStateInternalAsync(GameSessionDto gameSession, IServiceProvider sp)
    {
        if (gameSession.Users.Any(u => u.Hp == 0))
        {
            await FinishGameInternalAsync(gameSession, sp);
        }
        else
        {
            await SendGameStateChangeAsync(gameSession);
        }
        return new Result();
    }

    private async Task FinishGameInternalAsync(GameSessionDto gameSession, IServiceProvider sp)
    {
        gameSession.Timer.Dispose();
        gameSession.Questions.RemoveRange(gameSession.CurrentQuestionIndex, gameSession.Questions.Count - gameSession.CurrentQuestionIndex);
        
        var userService = sp.GetRequiredService<IUserService>();
        var userLanguageService = sp.GetRequiredService<IApplicationUserLanguageService>();
        var userOpponentService = sp.GetRequiredService<IApplicationUserOpponentService>();
        var unitOfWork = sp.GetRequiredService<IUnitOfWork>();
        var gameRep = sp.GetRequiredService<IGameRepository>();

        var isDraw = gameSession.Users.All(u => u.Hp == 0);
        foreach (var user in gameSession.Users)
        {
            bool isWin = !isDraw && user is { Hp: > 0, IsGiveUp: false };
            int ratingChange = isWin 
                ? _gameLogicOptions.RatingChangeAfterWinOrLoss 
                : (isDraw ? 0 : -_gameLogicOptions.RatingChangeAfterWinOrLoss);

            await userService.UpdateUserStatisticAsync(user.Id, isWin);
            await userLanguageService.UpdateStatisticsAsync(user.Id, gameSession.LanguageId, ratingChange);
        }

        await userOpponentService.UpdateStatisticsAsync(gameSession.Users[0].Id, gameSession.Users[1].Id);

        var game = mapper.Map<Game>(gameSession);
        var winUser = gameSession.Users.FirstOrDefault(u => u.Hp != 0 && !u.IsGiveUp);
        var dbUser = game.GameApplicationUsers.FirstOrDefault(gau => gau.ApplicationUserId == winUser?.Id);
        
        if (dbUser != null) dbUser.IsWin = true;

        foreach (var question in gameSession.Questions)
        {
            foreach (var userAnswer in question.UserAnswers.Select(ua => new { UserId = ua.Key, AnswerId = ua.Value }))
            {
                var answer = game.GameQuestions
                    .Where(q => q.QuestionId == question.Id)
                    .SelectMany(q => q.GameAnswers.Where(ga => ga.AnswerId == userAnswer.AnswerId))
                    .FirstOrDefault();
                if (answer != null) answer.ApplicationUserId = userAnswer.UserId;
            }
        }

        gameRep.Add(game);
        await unitOfWork.CommitAsync();
        await SendGameResultAsync(gameSession);
        storage.Games.Remove(gameSession.Id, out _);
    }

    private IEnumerable<string> GetGameGroups(Guid languageId, ApplicationUserLanguage? applicationUserLanguage)
    {
        var rating = applicationUserLanguage?.Rating ?? 0;
        var start = Math.Max(0, rating - _gameLogicOptions.RatingRange);
        var end = rating + _gameLogicOptions.RatingRange;
        return Enumerable
            .Range(start, end - start + 1)
            .Select(i => languageId + "-" + i);
    }

    public async Task<Result> RemoveFromSearchGroupsAsync(Guid userId, Guid languageId)
    {
        var groups = await GetSearchGroupsAsync(userId, languageId);
        foreach (var group in groups)
        {
            storage.SearchGroups.Remove(group, out _);
        }
        return new Result();
    }

    public async Task<Result<IEnumerable<GameResultListItemDto>>> GetGamesHistory(Guid userId)
    {
        var games = (await gameRep.GetGamesByUserAsync(userId)).ToList();
        var dto = mapper.Map<List<GameResultListItemDto>>(games);

        for (int i = 0; i < dto.Count; i++)
        {
            FillGameParticipantDetails(userId, games[i], dto[i]);
        }

        return new Result<IEnumerable<GameResultListItemDto>> { Value = dto };
    }

    public async Task<Result<GameResultDto>> GetGameHistory(Guid userId, Guid gameId)
    {
        var game = await gameRep.GetGameByIdAsync(gameId);
        if (game == null)
        {
            return new Result<GameResultDto>
            {
                Errors = [new Error { Key = ErrorKey.NotFound, Message = "Game not found" }]
            };
        }

        var dto = mapper.Map<GameResultDto>(game);
        FillQuestionsWithAnswers(dto, game);
        FillGameParticipantDetails(userId, game, dto);

        return new Result<GameResultDto> { Value = dto };
    }

    private static void FillGameParticipantDetails(Guid userId, Game game, GameResultDto dto)
    {
        var winUserId = game.GameApplicationUsers.FirstOrDefault(gu => gu.IsWin)?.ApplicationUserId;
        dto.IsVictory = userId == winUserId;
        dto.OpponentName = game.GameApplicationUsers.FirstOrDefault(gu => gu.ApplicationUserId != userId)?.ApplicationUser.Name!;
        dto.YourName = game.GameApplicationUsers.FirstOrDefault(gu => gu.ApplicationUserId == userId)?.ApplicationUser.Name!;
    }

    private static void FillGameParticipantDetails(Guid userId, Game game, GameResultListItemDto dto)
    {
        var winUserId = game.GameApplicationUsers.FirstOrDefault(gu => gu.IsWin)?.ApplicationUserId;
        dto.IsVictory = userId == winUserId;
        dto.OpponentName = game.GameApplicationUsers.FirstOrDefault(gu => gu.ApplicationUserId == winUserId)?.ApplicationUser.Name!;
        dto.YourName = game.GameApplicationUsers.FirstOrDefault(gu => gu.ApplicationUserId == userId)?.ApplicationUser.Name!;
    }

    public async Task<Result> SendGameInvitationsAsync(Guid userId, Guid languageId)
    {
        var applicationUserLanguage = await applicationUserLanguageRep.GetAsync(userId, languageId);
        var groups = await GetSearchGroupsAsync(userId, languageId);
        var groupsList = groups.ToList();

        await storage.MatchmakingLock.WaitAsync();
        try
        {
            GameInvitationDto? gameInvitationDto = null;

            foreach (var group in groupsList)
            {
                storage.SearchGroups.TryGetValue(group, out gameInvitationDto);
                if (gameInvitationDto == null) continue;
                break;
            }

            if (gameInvitationDto != null)
            {
                if (gameInvitationDto.InviterUserId == userId)
                {
                    return new Result
                    {
                        Errors = [new Error { Message = "You can't play with yourself", Key = ErrorKey.AlreadyExists }]
                    };
                }

                foreach (var group in groupsList)
                    storage.SearchGroups.Remove(group, out _);

                var opponentGroups = await GetSearchGroupsAsync(gameInvitationDto.InviterUserId, languageId);
                var opponentGroupsList = opponentGroups.ToList();
                foreach (var group in opponentGroupsList)
                    storage.SearchGroups.Remove(group, out _);

                var difficultyLevel = await difficultyRep.GetDifficultyLevelByRatingAsync(applicationUserLanguage?.Rating ?? 0);
                var result = await CreateGameSessionAsync(languageId, difficultyLevel.Id);
                if (!result.IsSuccess)
                    return new Result { Errors = result.Errors };

                var gameSession = result.Value;
                storage.Games.TryAdd(gameSession.Id, gameSession);

                var getFirstUserResult = await userService.GetUserDtoAsync(userId);
                var getSecondUserResult = await userService.GetUserDtoAsync(gameInvitationDto.InviterUserId);
                if (!getFirstUserResult.IsSuccess || !getSecondUserResult.IsSuccess)
                    return new Result();

                var firstUser = getFirstUserResult.Value;
                var secondUser = getSecondUserResult.Value;
                gameSession.Users.AddRange([
                    new GameSessionUserDto
                    {
                        Id = userId,
                        Hp = _gameLogicOptions.QuestionsCount / PlayersInGame,
                        Name = firstUser.Name,
                        Rating = firstUser.LanguageRatings.FirstOrDefault(lr => lr.LanguageId == languageId)?.Rating ?? 0,
                        ImageUrl = firstUser.ImageUrl,
                    },
                    new GameSessionUserDto
                    {
                        Id = gameInvitationDto.InviterUserId,
                        Hp = _gameLogicOptions.QuestionsCount / PlayersInGame,
                        Name = secondUser.Name,
                        Rating = secondUser.LanguageRatings.FirstOrDefault(lr => lr.LanguageId == languageId)?.Rating ?? 0,
                        ImageUrl = secondUser.ImageUrl,
                    },
                ]);

                var invitation = new GameInvitationDto { InviterUserId = userId, GameId = gameSession.Id };

                await notificationService.SendNotificationAsync(groupsList.First(), "ReceiveGameInvitation", invitation);
                await notificationService.SendNotificationAsync(opponentGroupsList.First(), "ReceiveGameInvitation", invitation);

                await Task.Delay(BeforeGameDelayMs);
                await ExecuteScopedAction(gameSession, (s) => MoveToNextQuestionInternalAsync(gameSession, s));

                return new Result();
            }

            var searchTasks = groupsList.Select(g =>
            {
                var gameInvitation = new GameInvitationDto { InviterUserId = userId, GameId = null };
                storage.SearchGroups.TryAdd(g, gameInvitation);
                return notificationService.SendNotificationAsync(g, "ReceiveGameInvitation", gameInvitation);
            });
            await Task.WhenAll(searchTasks);
        }
        finally
        {
            storage.MatchmakingLock.Release();
        }

        return new Result();
    }

    private static void FillQuestionsWithAnswers(GameResultDto dto, Game game)
    {
        foreach (var questionDto in dto.Questions)
        {
            var gameQuestion = game.GameQuestions.FirstOrDefault(gq => gq.QuestionId == questionDto.Id);
            if (gameQuestion == null) continue;

            var userAnswersForQuestion = gameQuestion.GameAnswers
                .Where(ga => ga.ApplicationUserId.HasValue)
                .Select(ga => new { UserId = ga.ApplicationUserId!.Value, ga.AnswerId });

            foreach (var ua in userAnswersForQuestion)
            {
                questionDto.UserAnswers.TryAdd(ua.UserId, ua.AnswerId);
            }
        }
    }

    public async Task<Result> SendGameStateAsync(Guid gameId)
    {
        await SendGameStateChangeAsync(storage.Games[gameId]);
        return new Result();
    }

    private async Task SendGameStateChangeAsync(GameSessionDto gameSession, Guid? correctAnswerId = null)
    {
        var questionDuration = DateTime.UtcNow - gameSession.CurrentQuestionStartDateTime;
        await notificationService.SendNotificationAsync(
            GetGameGroupAsync(gameSession.Id),
            "GameStateChanged",
            new GameStateDto
            {
                CurrentQuestion = gameSession.CurrentQuestionIndex < 0
                    ? null
                    : mapper.Map<GameStateQuestionDto>(gameSession.Questions[gameSession.CurrentQuestionIndex]),
                Users = gameSession.Users,
                TimeRemainingInSeconds = gameSession.CurrentQuestionIndex < 0
                    ? null
                    : _gameLogicOptions.TimeForQuestionInSeconds - (int)questionDuration.TotalSeconds,
                CorrectAnswerId = correctAnswerId,
                LanguageName = gameSession.LanguageName,
            });
    }

    private async Task SendGameResultAsync(GameSessionDto gameSession)
    {
        var winner = gameSession.Users.FirstOrDefault(u => u.Hp != 0 && !u.IsGiveUp);
        await notificationService.SendNotificationAsync(
            GetGameGroupAsync(gameSession.Id),
            "ReceiveGameResult",
            new GameResultSessionDto
            {
                Questions = [.. gameSession.Questions.Take(gameSession.CurrentQuestionIndex)],
                WinnerUserId = winner?.Id,
                WinnerUserName = winner?.Name,
                RatingChangeAfterWinOrLoss = _gameLogicOptions.RatingChangeAfterWinOrLoss,
                IsGiveUp = gameSession.Users.Any(u => u.IsGiveUp),
            });
    }

    private async Task<Result<GameSessionDto>> CreateGameSessionAsync(Guid languageId, Guid difficultyLevelId)
    {
        var getQuestionsResult = await questionService.GetRandomQuestionsAsync(languageId, difficultyLevelId, _gameLogicOptions.QuestionsCount);
        if (!getQuestionsResult.IsSuccess)
        {
            return new Result<GameSessionDto> { Errors = getQuestionsResult.Errors };
        }

        var randomQuestions = (List<QuestionDto>)getQuestionsResult.Value;
        var gameSession = new GameSessionDto
        {
            Id = Guid.NewGuid(),
            LanguageId = languageId,
            LanguageName = (await languageRep.GetAsync(languageId)).Name,
            DifficultyLevelId = difficultyLevelId,
            Questions = randomQuestions,
            CurrentQuestionIndex = -1,
            Timer = new System.Timers.Timer(_gameLogicOptions.TimeForQuestionInSeconds * 1000),
        };

        gameSession.Timer.Elapsed += async (_, _) =>
        {
            using var scope = serviceScopeFactory.CreateScope();
            foreach (var user in gameSession.Users) user.Hp--;
            await MoveToNextQuestionInternalAsync(gameSession, scope.ServiceProvider);
        };
        gameSession.Timer.AutoReset = false;

        return new Result<GameSessionDto> { Value = gameSession };
    }
}