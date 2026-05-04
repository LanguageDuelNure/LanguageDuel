using System.Collections.Concurrent;
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
using Timer = System.Timers.Timer;

namespace LanguageDuel.Application.Services.Games;

public class GameService(INotificationService notificationService, IServiceScopeFactory serviceScopeFactory, IOptions<GameLogicOptions> gameLogicOptions) : IGameService, IDisposable
{
    private readonly GameLogicOptions _gameLogicOptions = gameLogicOptions.Value;

    private const int PlayersInGame = 2;
    private const int BeforeGameDelayMs = 1000;

    private readonly ConcurrentDictionary<Guid, GameSessionDto> _games = new();
    private readonly ConcurrentDictionary<string, GameInvitationDto> _searchGroups = [];
    private readonly SemaphoreSlim _matchmakingLock = new(1, 1);

    public async Task<IEnumerable<string>> GetSearchGroupsAsync(Guid userId, Guid languageId)
    {
        var serviceProvider = serviceScopeFactory.CreateScope().ServiceProvider;
        var applicationUserLanguageRep = serviceProvider.GetRequiredService<IRepository<ApplicationUserLanguage>>();
        var applicationUserLanguage = await applicationUserLanguageRep.GetAsync(userId, languageId);
        return GetGameGroups(languageId, applicationUserLanguage);
    }

    public string GetGameGroupAsync(Guid gameId)
    {
        return "game-id" + gameId;
    }

    public Result<Guid> GetGame(Guid userId)
    {
        var session = _games.Values
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
        var isFound = _games.TryGetValue(gameId, out var gameSession);

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
        await FinishGameAsync(gameSession);

        return new Result();
    }

    public async Task<Result> ChooseAnswerAsync(Guid userId, Guid gameId, Guid answerId)
    {
        _games.TryGetValue(gameId, out var gameSession);
        var currentQuestion = gameSession!.Questions[gameSession.CurrentQuestionIndex];
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

            return await MoveToNextQuestionAsync(gameSession);
        }

        var allChooseIncorrectQuestions = currentQuestion.UserAnswers.Count == PlayersInGame;
        if (allChooseIncorrectQuestions)
        {
            foreach (var user in gameSession.Users)
            {
                user.Hp--;
            }

            return await MoveToNextQuestionAsync(gameSession);
        }

        await HandleGameStateAsync(gameSession);
        return new Result();
    }

    private async Task<Result> MoveToNextQuestionAsync(GameSessionDto gameSession)
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

        await HandleGameStateAsync(gameSession);
        return new Result();
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
            _searchGroups.Remove(group, out _);
        }
        return new Result();
    }

    public async Task<Result<IEnumerable<GameResultListItemDto>>> GetGamesHistory(Guid userId)
    {
        var serviceProvider = serviceScopeFactory.CreateScope().ServiceProvider;
        var gameRep = serviceProvider.GetRequiredService<IGameRepository>();
        var mapper = serviceProvider.GetRequiredService<IMapper>();
        var games = (await gameRep.GetGamesByUserAsync(userId)).ToList();

        var dto = mapper.Map<List<GameResultListItemDto>>(games);

        for (int i = 0; i < dto.Count; i++)
        {
            FillGameParticipantDetails(userId, games[i], dto[i]);
        }

        return new Result<IEnumerable<GameResultListItemDto>>()
        {
            Value = dto,
        };
    }
    
    public async Task<Result<GameResultDto>> GetGameHistory(Guid userId, Guid gameId)
    {
        var serviceProvider = serviceScopeFactory.CreateScope().ServiceProvider;
        var gameRep = serviceProvider.GetRequiredService<IGameRepository>();
        var mapper = serviceProvider.GetRequiredService<IMapper>();
        var game = await gameRep.GetGameByIdAsync(gameId);
        if (game == null)
        {
            return new Result<GameResultDto>()
            {
                Errors = [new Error
                {
                    Key = ErrorKey.NotFound,
                    Message = "Game not found",
                }]
            };
        }

        var dto = mapper.Map<GameResultDto>(game);
        
        FillQuestionsWithAnswers(dto, game);
        
        FillGameParticipantDetails(userId, game, dto);

        return new Result<GameResultDto>()
        {
            Value = dto,
        };
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
        var serviceProvider = serviceScopeFactory.CreateScope().ServiceProvider;
        var applicationUserLanguageRep = serviceProvider.GetRequiredService<IRepository<ApplicationUserLanguage>>();
        var applicationUserLanguage = await applicationUserLanguageRep.GetAsync(userId, languageId);
        var groups = await GetSearchGroupsAsync(userId, languageId);
        var groupsList = groups.ToList();

        await _matchmakingLock.WaitAsync();
        try
        {
            GameInvitationDto? gameInvitationDto = null;

            foreach (var group in groupsList)
            {
                _searchGroups.TryGetValue(group, out gameInvitationDto);
                if (gameInvitationDto == null) continue;
                break;
            }

            if (gameInvitationDto != null)
            {
                if (gameInvitationDto.InviterUserId == userId)
                {
                    return new Result
                    {
                        Errors = [new Error
                        {
                            Message = "You can't play with yourself",
                            Key = ErrorKey.AlreadyExists,
                        }]
                    };
                }

                // Remove both players from all search groups
                foreach (var group in groupsList)
                    _searchGroups.Remove(group, out _);

                var opponentGroups = await GetSearchGroupsAsync(gameInvitationDto.InviterUserId, languageId);
                var opponentGroupsList = opponentGroups.ToList();
                foreach (var group in opponentGroupsList)
                    _searchGroups.Remove(group, out _);

                var difficultyRep = serviceProvider.GetRequiredService<IDifficultyRepository>();
                var difficultyLevel = await difficultyRep.GetDifficultyLevelByRatingAsync(applicationUserLanguage?.Rating ?? 0);
                var result = await CreateGameSessionAsync(languageId, difficultyLevel.Id);
                if (!result.IsSuccess)
                    return new Result { Errors = result.Errors };

                var gameSession = result.Value;
                _games.TryAdd(gameSession.Id, gameSession);

                var userService = serviceProvider.GetRequiredService<IUserService>();
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

                var invitation = new GameInvitationDto
                {
                    InviterUserId = userId,
                    GameId = gameSession.Id
                };

                // Send to player 2 (current user) via one of their search groups
                await notificationService.SendNotificationAsync(
                    groupsList.First(),
                    "ReceiveGameInvitation",
                    invitation);

                // Send to player 1 (original searcher) via one of their search groups
                await notificationService.SendNotificationAsync(
                    opponentGroupsList.First(),
                    "ReceiveGameInvitation",
                    invitation);

                await Task.Delay(BeforeGameDelayMs);
                await MoveToNextQuestionAsync(gameSession);

                return new Result();
            }

            // No match found — add self to search groups and broadcast null-gameId invite
            var searchTasks = groupsList.Select(g =>
            {
                var gameInvitation = new GameInvitationDto
                {
                    InviterUserId = userId,
                    GameId = null,
                };
                _searchGroups.TryAdd(g, gameInvitation);
                return notificationService.SendNotificationAsync(g, "ReceiveGameInvitation", gameInvitation);
            });
            await Task.WhenAll(searchTasks);
        }
        finally
        {
            _matchmakingLock.Release();
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

    private async Task ChangeUsersRatingAsync(GameSessionDto gameSession)
    {
        var serviceProvider = serviceScopeFactory.CreateScope().ServiceProvider;
        var unitOfWork = serviceProvider.GetRequiredService<IUnitOfWork>();
        var userService = serviceProvider.GetRequiredService<IUserService>();
        var applicationUserLanguageService = serviceProvider.GetRequiredService<IApplicationUserLanguageService>();
        var applicationUserOpponentService = serviceProvider.GetRequiredService<IApplicationUserOpponentService>();

        var isDraw = gameSession.Users.All(u => u.Hp == 0);
        foreach (var user in gameSession.Users)
        {
            int ratingChange;
            var isWin = !isDraw && user is { Hp: > 0, IsGiveUp: false };
            if (isWin)
            {
                ratingChange = _gameLogicOptions.RatingChangeAfterWinOrLoss;
            }
            else
            {
                ratingChange = isDraw ? 0 : -_gameLogicOptions.RatingChangeAfterWinOrLoss;
            }
            await userService.UpdateUserStatisticAsync(user.Id, isWin);
            await applicationUserLanguageService.UpdateStatisticsAsync(user.Id, gameSession.LanguageId, ratingChange);
        }

        await applicationUserOpponentService.UpdateStatisticsAsync(gameSession.Users[0].Id, gameSession.Users[1].Id);
        await unitOfWork.CommitAsync();
    }
    
    private async Task SaveGameAsync(GameSessionDto gameSession)
    {
        var serviceProvider = serviceScopeFactory.CreateScope().ServiceProvider;
        var mapper = serviceProvider.GetRequiredService<IMapper>();
        var game = mapper.Map<Game>(gameSession);
        
        var winUser = gameSession.Users.FirstOrDefault(u => u.Hp != 0 && !u.IsGiveUp);
        var user = game.GameApplicationUsers
            .FirstOrDefault(gau => gau.ApplicationUserId == winUser?.Id);
        if (user != null)
        {
            user.IsWin = true;
        }
        
        foreach (var question in gameSession.Questions)
        {
            foreach (var userAnswer in question.UserAnswers.Select(ua => new { UserId = ua.Key, AnswerId = ua.Value }))
            {
                var answer = game.GameQuestions
                    .Where(q => q.QuestionId == question.Id)
                    .SelectMany(q =>
                        q.GameAnswers.Where(ga => ga.AnswerId == userAnswer.AnswerId))
                    .FirstOrDefault();
                answer.ApplicationUserId = userAnswer.UserId;
            }
        }
        
        var unitOfWork = serviceProvider.GetRequiredService<IUnitOfWork>();
        var gameRep = serviceProvider.GetRequiredService<IRepository<Game>>();
        
        gameRep.Add(game);
        await unitOfWork.CommitAsync();
    }

    private async Task HandleGameStateAsync(GameSessionDto gameSession)
    {
        if (gameSession.Users.Any(u => u.Hp == 0))
        {
            await FinishGameAsync(gameSession);
            return;
        }

        await SendGameStateChangeAsync(gameSession);
    }

    private async Task FinishGameAsync(GameSessionDto gameSession)
    {
        gameSession.Timer.Dispose();
        gameSession.Questions
            .RemoveRange(gameSession.CurrentQuestionIndex, gameSession.Questions.Count - gameSession.CurrentQuestionIndex);
        await ChangeUsersRatingAsync(gameSession);
        await SaveGameAsync(gameSession);
        await SendGameResultAsync(gameSession);
        _games.Remove(gameSession.Id, out _);
    }

    public async Task<Result> SendGameStateAsync(Guid gameId)
    {
        await SendGameStateChangeAsync(_games[gameId]);
        return new Result();
    }

    private async Task SendGameStateChangeAsync(GameSessionDto gameSession, Guid? correctAnswerId = null)
    {
        var serviceProvider = serviceScopeFactory.CreateScope().ServiceProvider;
        var mapper = serviceProvider.GetRequiredService<IMapper>();
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
                    : _gameLogicOptions.TimeForQuestionInSeconds - questionDuration.Seconds,
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
        var serviceProvider = serviceScopeFactory.CreateScope().ServiceProvider;
        var questionService = serviceProvider.GetRequiredService<IQuestionService>();
        var languageRep = serviceProvider.GetRequiredService<IRepository<Language>>();

        var getQuestionsResult = await questionService.GetRandomQuestionsAsync(languageId, difficultyLevelId, _gameLogicOptions.QuestionsCount);
        if (!getQuestionsResult.IsSuccess)
        {
            return new Result<GameSessionDto>
            {
                Errors = getQuestionsResult.Errors
            };
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
            Timer = new Timer(_gameLogicOptions.TimeForQuestionInSeconds * 1000),
        };

        gameSession.Timer.Elapsed += async void (_, _) =>
        {
            foreach (var user in gameSession.Users)
            {
                user.Hp--;
            }
            await MoveToNextQuestionAsync(gameSession);
        };
        gameSession.Timer.AutoReset = false;

        return new Result<GameSessionDto>
        {
            Value = gameSession
        };
    }

    public void Dispose()
    {
        _matchmakingLock.Dispose();
        GC.SuppressFinalize(this);
    }
}