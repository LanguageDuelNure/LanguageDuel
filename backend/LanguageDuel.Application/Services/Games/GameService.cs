using System.Collections.Concurrent;
using LanguageDuel.Application.Dtos.Games;
using LanguageDuel.Application.Dtos.Questions;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Repositories;
using LanguageDuel.Application.Services.Questions;
using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Services.Games;

public class GameService(INotificationService notificationService, IQuestionService questionService, IRepository<ApplicationUserLanguage> applicationUserLanguageRep, IDifficultyRepository difficultyRep) : IGameService
{
    private const int QuestionsCount = 20;
    
    private const int PlayersInGame = 2;
    
    private readonly ConcurrentDictionary<Guid, GameSessionDto> _games = new();
    
    private readonly ConcurrentDictionary<string, GameInvitationDto> _searchGroups = [];
    
    public async Task<Result> SendGameInvitationsAsync(Guid userId, Guid languageId)
    {
        var groups = Enumerable
            .Range(1, 10)
            .Select(i => languageId + "-" + i);

        string existingGroup = string.Empty;
        GameInvitationDto? gameInvitationDto = null;
        
        foreach (var group in groups)
        {
            _searchGroups.TryGetValue(group, out gameInvitationDto);
        }

        if (gameInvitationDto != null)
        {
            await notificationService
                .SendNotificationAsync(
                    existingGroup, 
                    "ReceiveGameInvitation",
                    new GameInvitationDto()
                    {
                        InviterUserId = gameInvitationDto.InviterUserId,
                        GameId = gameInvitationDto.GameId
                    });
            
            _games.TryGetValue(gameInvitationDto.GameId, out var existingGameSession);
            existingGameSession.Users.Add(new UserInGameDto()
            {
                Hp = QuestionsCount /  PlayersInGame,
            });

            await SendQuestionRecursiveAsync(gameInvitationDto.GameId, existingGameSession);
            
            return new Result();
        }
        var result = await CreateGameSessionAsync(userId, languageId);
        if (!result.IsSuccess)
        {
            return new Result()
            {
                Errors =  result.Errors
            };
        }
        
        var gameSession = result.Value;
        
        _games.TryAdd(gameInvitationDto.GameId, gameSession);
        
        var tasks = groups
            .Select(g => notificationService
                .SendNotificationAsync(
                    g,
                    "ReceiveGameInvitation",
                    new GameInvitationDto()
                    {
                        InviterUserId = userId,
                        GameId = gameInvitationDto.GameId
                    }));
        await Task.WhenAll(tasks);

        return new Result();
    }

    private async Task SendQuestionRecursiveAsync(Guid gameId, GameSessionDto gameSession, int questionIndex = 0)
    {
        if (questionIndex >= gameSession.Questions.Count)
            return;

        await notificationService.SendNotificationAsync(
            gameId.ToString(),
            "ReceiveQuestion",
            new GameStateDto
            {
                CurrentQuestion = gameSession.Questions[questionIndex]
            });
        
        var timer = gameSession.Timer;
        timer.Interval = 10000;
        timer.Elapsed += async (sender, e) =>
        {
            if (questionIndex < gameSession.Questions.Count)
            {
                await SendQuestionRecursiveAsync(gameId, gameSession, questionIndex + 1);
            }
        };
        timer.Start();
    }

    private async Task<Result<GameSessionDto>> CreateGameSessionAsync(Guid userId, Guid languageId)
    {
        var applicationUserLanguage = await applicationUserLanguageRep.GetAsync(userId, languageId);
        var difficulty = await difficultyRep.GetDifficultyLevelByRatingAsync(applicationUserLanguage.Rating);
        var getQuestionsResult =
            await questionService.GetRandomQuestionsAsync(languageId, difficulty.Id, QuestionsCount);
        if (!getQuestionsResult.IsSuccess)
        {
            return new Result<GameSessionDto>
            {
                Errors = getQuestionsResult.Errors
            };
        }
        var randomQuestions = (List<QuestionDto>)getQuestionsResult.Value;
        var gameSession = new GameSessionDto()
        {
            Users =
            [
                new UserInGameDto()
                {
                    Id = userId,
                    Hp = QuestionsCount /  PlayersInGame,
                }
            ],
            Questions = randomQuestions
        };

        return new Result<GameSessionDto>
        {
            Value =  gameSession
        };
    }
}