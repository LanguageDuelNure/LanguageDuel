using System.Collections.Concurrent;
using System.Timers;
using AutoMapper;
using LanguageDuel.Application.Dtos.Answers;
using LanguageDuel.Application.Dtos.Games;
using LanguageDuel.Application.Dtos.Questions;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Repositories;
using LanguageDuel.Application.Services.Questions;
using LanguageDuel.Domain.Entities;
using Microsoft.Extensions.DependencyInjection;
using Timer = System.Timers.Timer;

namespace LanguageDuel.Application.Services.Games;

public class GameService(INotificationService notificationService, IServiceScopeFactory serviceScopeFactory) : IGameService
{
    private const int QuestionsCount = 6;
    
    private const int PlayersInGame = 2;

    private const int TimeForQuestionInSeconds = 1000000;
    
    private const int RatingRange = 5;
    
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

    public async Task<Result> ChooseAnswerAsync(Guid userId, Guid gameId, Guid answerId)
    {
        _games.TryGetValue(gameId, out var gameSession);
        var currentQuestion = gameSession.Questions[gameSession.CurrentQuestionIndex];
        var choosedAnswer = currentQuestion.Answers.FirstOrDefault(a => a.Id == answerId);
        var answerHaveAlreadyChosen = !currentQuestion.UserAnswers.TryAdd(userId, answerId);
        if (answerHaveAlreadyChosen)
        {
            return new Result()
            {
                Errors = [new Error
                {
                    Field = nameof(answerId),
                    Key = ErrorKey.AlreadyExists,
                    Message = "Answer have already chosen",
                }]
            };
        }
        if (choosedAnswer.IsCorrect)
        {
            foreach (var user in gameSession.Users.Where(user => user.Id != userId))
            {
                user.Hp--;
            }

            gameSession.CurrentQuestionIndex++;
            var timer = gameSession.Timer;
            timer?.Stop();
            timer?.Dispose();
            timer = new Timer(TimeForQuestionInSeconds * 1000);
            await SendQuestionRecursiveAsync(gameSession);
            return new Result();
        }

        var allChooseIncorrectQuestions = currentQuestion.UserAnswers.Count == PlayersInGame;
        if (allChooseIncorrectQuestions)
        {
            foreach (var user in gameSession.Users)
            {
                user.Hp--;
            }

            gameSession.CurrentQuestionIndex++;
            
            var timer = gameSession.Timer;
            timer?.Stop();
            timer?.Dispose();
            timer = new Timer(TimeForQuestionInSeconds * 1000);
            await SendQuestionRecursiveAsync(gameSession);
            return new Result();
        }
        
        await SendGameStateChangeAsync(gameSession);
        
        return new Result();
    }
    
    private static IEnumerable<string> GetGameGroups(Guid languageId, ApplicationUserLanguage? applicationUserLanguage)
    {
        var rating = applicationUserLanguage?.Rating ?? 0;
        var minimalRating = rating - RatingRange;
        return Enumerable
            .Range(minimalRating < 0 ? 0 : minimalRating, rating + RatingRange)
            .Select(i => languageId + "-" + i);
    }
    
    public async Task<Result> SendGameInvitationsAsync(Guid userId, Guid languageId)
    {
        var serviceProvider = serviceScopeFactory.CreateScope().ServiceProvider;
        var applicationUserLanguageRep = serviceProvider.GetRequiredService<IRepository<ApplicationUserLanguage>>();
        
        var applicationUserLanguage = await applicationUserLanguageRep.GetAsync(userId, languageId);

        var groups = await GetSearchGroupsAsync(userId, languageId);

        string existingGroup = string.Empty;
        GameInvitationDto? gameInvitationDto = null;
        
        foreach (var group in groups)
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
            var difficultyRep = serviceProvider.GetRequiredService<IDifficultyRepository>();
            var difficultyLevel = await difficultyRep.GetDifficultyLevelByRatingAsync(applicationUserLanguage?.Rating ?? 0);
            var result = await CreateGameSessionAsync(userId, languageId, difficultyLevel.Id);
            if (!result.IsSuccess)
            {
                return new Result()
                {
                    Errors =  result.Errors
                };
            }
        
            var gameSession = result.Value;
        
            _games.TryAdd(gameSession.Id, gameSession);
            
            await notificationService
                .SendNotificationAsync(
                    existingGroup, 
                    "ReceiveGameInvitation",
                    new GameInvitationDto()
                    {
                        InviterUserId = userId,
                        GameId = gameSession.Id
                    });
            var userRep = serviceProvider.GetRequiredService<IRepository<ApplicationUser>>();

            gameSession.Users.AddRange([
                new GameSessionUserDto()
                {
                    Id =  userId,
                    Hp = QuestionsCount /  PlayersInGame,
                    Name = (await userRep.GetAsync(userId)).Name,
                },
                new GameSessionUserDto()
                {
                    Id =  gameInvitationDto.InviterUserId,
                    Hp = QuestionsCount /  PlayersInGame,
                    Name = (await userRep.GetAsync(gameInvitationDto.InviterUserId)).Name,
                },
            ]);

            await SendQuestionRecursiveAsync(gameSession);
            
            return new Result();
        }
        
        var tasks = groups
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

    private async Task SendQuestionRecursiveAsync(GameSessionDto gameSession)
    {
        if (gameSession.Users.Any(u => u.Hp == 0))
        {
            await SendGameResultAsync(gameSession);
            return;
        }

        await SendGameStateChangeAsync(gameSession);
        
        var timer = gameSession.Timer;

        ElapsedEventHandler handler = null;
        handler = async void (sender, e) =>
        {
            timer.Elapsed -= handler; 
            timer.Stop();
            foreach (var user in gameSession.Users)
            {
                user.Hp--;
            }

            gameSession.CurrentQuestionIndex++;
            await SendQuestionRecursiveAsync(gameSession);
        };
        timer.Elapsed += handler;
        timer.AutoReset = false;
        timer.Start();
    }

    private async Task SendGameStateChangeAsync(GameSessionDto gameSession)
    {
        var serviceProvider = serviceScopeFactory.CreateScope().ServiceProvider;
        var mapper = serviceProvider.GetRequiredService<IMapper>();
        await notificationService.SendNotificationAsync(
            GetGameGroupAsync(gameSession.Id),
            "GameStateChanged",
            new GameStateDto
            {
                CurrentQuestion = mapper.Map<GameStateQuestionDto>(gameSession.Questions[gameSession.CurrentQuestionIndex]),
                Users =  gameSession.Users,
                TimeRemainingInSeconds = TimeForQuestionInSeconds,
            });
    }

    private async Task SendGameResultAsync(GameSessionDto gameSession)
    {
        await notificationService
            .SendNotificationAsync(
                GetGameGroupAsync(gameSession.Id),
                "ReceiveGameResult",
                new GameResultDto()
                {
                    Questions = gameSession.Questions.Take(gameSession.CurrentQuestionIndex).ToList(),
                    WinnerUserName = gameSession.Users.FirstOrDefault(u => u.Hp != 0)?.Name,
                });
    }

    private async Task<Result<GameSessionDto>> CreateGameSessionAsync(Guid userId, Guid languageId, Guid difficultyLevelId)
    {
        var serviceProvider = serviceScopeFactory.CreateScope().ServiceProvider;
        var questionService = serviceProvider.GetRequiredService<IQuestionService>();
        
        var getQuestionsResult =
            await questionService.GetRandomQuestionsAsync(languageId, difficultyLevelId, QuestionsCount);
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
            Questions = randomQuestions,
            Timer = new Timer(TimeForQuestionInSeconds * 1000),
        };

        return new Result<GameSessionDto>
        {
            Value =  gameSession
        };
    }
}