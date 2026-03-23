using System.Collections.Concurrent;
using AutoMapper;
using LanguageDuel.Application.Dtos.Games;
using LanguageDuel.Application.Dtos.Questions;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Options;
using LanguageDuel.Application.Repositories;
using LanguageDuel.Application.Services.ApplicationUserLanguages;
using LanguageDuel.Application.Services.Questions;
using LanguageDuel.Domain.Entities;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;
using Timer = System.Timers.Timer;

namespace LanguageDuel.Application.Services.Games;

public class GameService(INotificationService notificationService, IServiceScopeFactory serviceScopeFactory, IOptions<GameLogicOptions> gameLogicOptions) : IGameService
{
    private readonly GameLogicOptions _gameLogicOptions = gameLogicOptions.Value;
    
    private const int PlayersInGame = 2;
    
    private const int BeforeGameDelayMs = 1000;
    
    private readonly ConcurrentDictionary<Guid, GameSessionDto> _games = new();
    
    private readonly ConcurrentDictionary<string, GameInvitationDto> _searchGroups = [];

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

    // FIX 2: Guard against null session when user has no active game.
    // Previously this crashed with NullReferenceException, causing GET /api/games/current
    // to return 500 instead of a clean 204/404.
    public Result<Guid> GetGame(Guid userId)
    {
        var session = _games.Values
            .FirstOrDefault(g => 
                g.Users.Any(u => u.Id == userId));

        if (session == null)
        {
            return new Result<Guid>
            {
                Errors = [new Error
                {
                    Key = ErrorKey.NotFound,
                    Message = "No active game found for this user.",
                }]
            };
        }

        return new Result<Guid>
        {
            Value = session.Id
        };
    }

    public async Task<Result> ChooseAnswerAsync(Guid userId, Guid gameId, Guid answerId)
    {
        _games.TryGetValue(gameId, out var gameSession);
        var currentQuestion = gameSession.Questions[gameSession.CurrentQuestionIndex];
        var chosenAnswer = currentQuestion.Answers.FirstOrDefault(a => a.Id == answerId);
        
        var isOpponentSelectedThisAnswer = currentQuestion.UserAnswers.ContainsValue(answerId);
        if (isOpponentSelectedThisAnswer)
        {
            return new Result()
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
            return new Result()
            {
                Errors = [new Error
                {
                    Field = nameof(answerId),
                    Key = ErrorKey.AlreadyExists,
                    Message = "You have already chosen answer",
                }]
            };
        }
        
        if (chosenAnswer.IsCorrect)
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

    // FIX 3: Enumerable.Range second argument is a COUNT not an end value.
    // Old code: Range(start, rating + RatingRange) produced wrong number of groups,
    // meaning the two players could generate non-matching group key sets.
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
    
    public async Task<Result> SendGameInvitationsAsync(Guid userId, Guid languageId)
    {
        var serviceProvider = serviceScopeFactory.CreateScope().ServiceProvider;
        var applicationUserLanguageRep = serviceProvider.GetRequiredService<IRepository<ApplicationUserLanguage>>();
        
        var applicationUserLanguage = await applicationUserLanguageRep.GetAsync(userId, languageId);

        var groups = await GetSearchGroupsAsync(userId, languageId);

        string existingGroup = string.Empty;
        GameInvitationDto? gameInvitationDto = null;

        var groupsList = groups.ToList();
        foreach (var group in groupsList)
        {
            _searchGroups.TryGetValue(group, out gameInvitationDto);
            if (gameInvitationDto == null)
            {
                continue;
            }

            existingGroup = group;
            break;
        }

        if (gameInvitationDto != null)
        {
            foreach (var group in groupsList)
            {
                _searchGroups.Remove(group, out _);
            }

            var opponentGroups = await GetSearchGroupsAsync(gameInvitationDto.InviterUserId, languageId);
            foreach (var group in opponentGroups)
            {
                _searchGroups.Remove(group, out _);
            }

            var difficultyRep = serviceProvider.GetRequiredService<IDifficultyRepository>();
            var difficultyLevel = await difficultyRep.GetDifficultyLevelByRatingAsync(applicationUserLanguage?.Rating ?? 0);
            var result = await CreateGameSessionAsync(languageId, difficultyLevel.Id);
            if (!result.IsSuccess)
            {
                return new Result
                {
                    Errors =  result.Errors
                };
            }
        
            var gameSession = result.Value;
        
            _games.TryAdd(gameSession.Id, gameSession);
            
            var userService = serviceProvider.GetRequiredService<IUserService>();
            var getFirstUserResult = await userService.GetUserDtoAsync(userId);
            var getSecondUserResult = await userService.GetUserDtoAsync(gameInvitationDto.InviterUserId);
            if (!getFirstUserResult.IsSuccess || !getSecondUserResult.IsSuccess)
            {
                return new Result();
            }
            var firstUser = getFirstUserResult.Value;
            var secondUser = getSecondUserResult.Value;
            gameSession.Users.AddRange([
                new GameSessionUserDto()
                {
                    Id =  userId,
                    Hp = _gameLogicOptions.QuestionsCount /  PlayersInGame,
                    Name = firstUser.Name,
                    Rating = firstUser.LanguageRatings.FirstOrDefault(lr => lr.LanguageId == languageId)?.Rating ?? 0,
                },
                new GameSessionUserDto()
                {
                    Id =  gameInvitationDto.InviterUserId,
                    Hp = _gameLogicOptions.QuestionsCount /  PlayersInGame,
                    Name = secondUser.Name,
                    Rating = secondUser.LanguageRatings.FirstOrDefault(lr => lr.LanguageId == languageId)?.Rating ?? 0,
                },
            ]);
            await notificationService
                .SendNotificationAsync(
                    existingGroup,
                    "ReceiveGameInvitation",
                    new GameInvitationDto()
                    {
                        InviterUserId = userId,
                        GameId = gameSession.Id
                    });
            await Task.Delay(BeforeGameDelayMs);

            await MoveToNextQuestionAsync(gameSession);
            
            return new Result();
        }
        
        var tasks = groupsList
            .Select(g =>
            {
                var gameInvitation = new GameInvitationDto()
                {
                    InviterUserId = userId,
                    GameId = null,
                };
                _searchGroups.TryAdd(g, gameInvitation);
                return notificationService
                    .SendNotificationAsync(
                        g,
                        "ReceiveGameInvitation",
                        gameInvitation);
            });
        await Task.WhenAll(tasks);

        return new Result();
    }

    private async Task<Result> ChangeUsersRatingAsync(GameSessionDto gameSession)
    {
        var isDraw = gameSession.Users.All(u => u.Hp == 0);
        if (isDraw)
        {
            return new Result();
        }
        
        var serviceProvider = serviceScopeFactory.CreateScope().ServiceProvider;
        var applicationUserLanguageService = serviceProvider.GetRequiredService<IApplicationUserLanguageService>();

        foreach (var user in gameSession.Users)
        {
            int ratingChange;
            if (user.Hp == 0)
            {
                ratingChange = -_gameLogicOptions.RatingChangeAfterWinOrLoss;
            }
            else
            {
                ratingChange = _gameLogicOptions.RatingChangeAfterWinOrLoss;
            }
            await applicationUserLanguageService.ChangeUsersRatingAsync(user.Id, gameSession.LanguageId, ratingChange);
        }

        return new Result();
    }

    private async Task HandleGameStateAsync(GameSessionDto gameSession)
    {
        if (gameSession.Users.Any(u => u.Hp == 0))
        {
            gameSession.Timer.Dispose();
            await ChangeUsersRatingAsync(gameSession);
            await SendGameResultAsync(gameSession);
            _games.Remove(gameSession.Id, out _);
            return;
        }
        
        await SendGameStateChangeAsync(gameSession);
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
                CurrentQuestion = gameSession.CurrentQuestionIndex < 0 ? null : mapper.Map<GameStateQuestionDto>(gameSession.Questions[gameSession.CurrentQuestionIndex]),
                Users =  gameSession.Users,
                TimeRemainingInSeconds = gameSession.CurrentQuestionIndex < 0 ? null : _gameLogicOptions.TimeForQuestionInSeconds - questionDuration.Seconds,
                CorrectAnswerId = correctAnswerId
            });
    }

    private async Task SendGameResultAsync(GameSessionDto gameSession)
    {
        var winner = gameSession.Users.FirstOrDefault(u => u.Hp != 0);
        await notificationService
            .SendNotificationAsync(
                GetGameGroupAsync(gameSession.Id),
                "ReceiveGameResult",
                new GameResultDto()
                {
                    Questions = gameSession.Questions.Take(gameSession.CurrentQuestionIndex).ToList(),
                    WinnerUserId = winner?.Id,
                    WinnerUserName = winner?.Name,
                    RatingChangeAfterWinOrLoss = _gameLogicOptions.RatingChangeAfterWinOrLoss,
                });
    }

    private async Task<Result<GameSessionDto>> CreateGameSessionAsync(Guid languageId, Guid difficultyLevelId)
    {
        var serviceProvider = serviceScopeFactory.CreateScope().ServiceProvider;
        var questionService = serviceProvider.GetRequiredService<IQuestionService>();
        
        var getQuestionsResult =
            await questionService.GetRandomQuestionsAsync(languageId, difficultyLevelId, _gameLogicOptions.QuestionsCount);
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
            LanguageId =  languageId,
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
            Value =  gameSession
        };
    }
}