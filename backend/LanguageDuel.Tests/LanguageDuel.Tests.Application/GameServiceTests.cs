using System.Collections.Concurrent;
using AutoMapper;
using LanguageDuel.Application.Dtos.Answers;
using LanguageDuel.Application.Dtos.Games;
using LanguageDuel.Application.Dtos.Questions;
using LanguageDuel.Application.Dtos.Results;
using LanguageDuel.Application.Options;
using LanguageDuel.Application.Repositories;
using LanguageDuel.Application.Services;
using LanguageDuel.Application.Services.ApplicationUserLanguages;
using LanguageDuel.Application.Services.ApplicationUserOpponents;
using LanguageDuel.Application.Services.Games;
using LanguageDuel.Application.Services.Questions;
using LanguageDuel.Domain.Entities;
using Microsoft.Extensions.Options;
using Moq;
using Xunit;

namespace LanguageDuel.Tests.Application;

public class GameServiceTests : BaseServiceTests
{
    private readonly Mock<INotificationService> _notificationServiceMock = new();
    private readonly Mock<IGameSessionStorage> _storageMock = new();
    private readonly Mock<IGameRepository> _gameRepMock = new();
    private readonly Mock<IRepository<ApplicationUserLanguage>> _userLanguageRepMock = new();
    private readonly Mock<IDifficultyRepository> _difficultyRepMock = new();
    private readonly Mock<IUserService> _userServiceMock = new();
    private readonly Mock<IApplicationUserLanguageService> _userLangServiceMock = new();
    private readonly Mock<IApplicationUserOpponentService> _userOpponentServiceMock = new();
    private readonly Mock<IQuestionService> _questionServiceMock = new();
    private readonly Mock<IRepository<Language>> _languageRepMock = new();
    private readonly Mock<IUnitOfWork> _unitOfWorkMock = new();

    private readonly ConcurrentDictionary<Guid, GameSessionDto> _gamesStorage = new();
    private readonly ConcurrentDictionary<string, GameInvitationDto> _searchGroupsStorage = new();

    private readonly GameService _service;

    public GameServiceTests()
    {
        var options = Options.Create(new GameLogicOptions
        {
            QuestionsCount = 10,
            RatingRange = 100,
            TimeForQuestionInSeconds = 15,
            QuestionDelayMs = 1,
            RatingChangeAfterWinOrLoss = 25
        });

        _storageMock.Setup(s => s.Games).Returns(_gamesStorage);
        _storageMock.Setup(s => s.SearchGroups).Returns(_searchGroupsStorage);

        _service = new GameService(
            _notificationServiceMock.Object,
            _storageMock.Object,
            _gameRepMock.Object,
            _userLanguageRepMock.Object,
            _difficultyRepMock.Object,
            _userServiceMock.Object,
            _userLangServiceMock.Object,
            _userOpponentServiceMock.Object,
            _questionServiceMock.Object,
            _languageRepMock.Object,
            _unitOfWorkMock.Object,
            GetMapper(),
            options);
    }

    [Fact]
    public void GetGame_ActiveGameExists_ReturnsGameId()
    {
        var userId = Guid.NewGuid();
        var gameId = Guid.NewGuid();
        var session = new GameSessionDto { Id = gameId, Users = [new() { Id = userId }] };
        _gamesStorage.TryAdd(gameId, session);

        var result = _service.GetGame(userId);

        Assert.True(result.IsSuccess);
        Assert.Equal(gameId, result.Value);
    }

    [Fact]
    public void GetGame_UserNotInGame_ReturnsNotFoundError()
    {
        var userId = Guid.NewGuid();

        var result = _service.GetGame(userId);

        Assert.False(result.IsSuccess);
        Assert.Contains(result.Errors, e => e.Key == ErrorKey.NotFound);
    }

    [Fact]
    public async Task GiveUpAsync_UserInGame_ReturnsSuccessAndFinishesGame()
    {
        var userId = Guid.NewGuid();
        var gameId = Guid.NewGuid();
        var session = new GameSessionDto
        {
            Id = gameId,
            Users = [new() { Id = userId, Hp = 2 }, new() { Id = Guid.NewGuid(), Hp = 2 }],
            Questions = [],
            Timer = new System.Timers.Timer()
        };
        _gamesStorage.TryAdd(gameId, session);

        var result = await _service.GiveUpAsync(userId, gameId);

        Assert.True(result.IsSuccess);
        Assert.True(session.Users.First(u => u.Id == userId).IsGiveUp);
        _unitOfWorkMock.Verify(u => u.CommitAsync(), Times.Once);
    }

    [Fact]
    public async Task GiveUpAsync_GameDoesNotExist_ReturnsNotFoundError()
    {
        var gameId = Guid.NewGuid();

        var result = await _service.GiveUpAsync(Guid.NewGuid(), gameId);

        Assert.False(result.IsSuccess);
        Assert.Equal("Game not found", result.Errors.First().Message);
    }

    [Fact]
    public async Task GiveUpAsync_UserNotBelongToGame_ReturnsForbiddenError()
    {
        var gameId = Guid.NewGuid();
        var gameSession = new GameSessionDto { Id = gameId, Users = [] };
        _gamesStorage.TryAdd(gameId, gameSession);

        var result = await _service.GiveUpAsync(Guid.NewGuid(), gameId);

        Assert.False(result.IsSuccess);
        Assert.Equal(ErrorKey.Forbidden, result.Errors.First().Key);
    }

    [Fact]
    public async Task ChooseAnswerAsync_CorrectAnswer_ReducesOpponentHpAndMovesToNext()
    {
        var userId = Guid.NewGuid();
        var opponentId = Guid.NewGuid();
        var gameId = Guid.NewGuid();
        var answerId = Guid.NewGuid();

        var session = new GameSessionDto
        {
            Id = gameId,
            CurrentQuestionIndex = 0,
            Timer = new System.Timers.Timer(),
            Users = [new() { Id = userId, Hp = 2 }, new() { Id = opponentId, Hp = 2 }],
            Questions = [
                new QuestionDto
                {
                    Answers = [new() { Id = answerId, IsCorrect = true }],
                    UserAnswers = new Dictionary<Guid, Guid>()
                },
                new QuestionDto { Answers = [], UserAnswers = new Dictionary<Guid, Guid>() }
            ]
        };
        _gamesStorage.TryAdd(gameId, session);

        var result = await _service.ChooseAnswerAsync(userId, gameId, answerId);

        Assert.True(result.IsSuccess);
        Assert.Equal(1, session.Users.First(u => u.Id == opponentId).Hp);
        Assert.Equal(1, session.CurrentQuestionIndex);
    }

    [Fact]
    public async Task ChooseAnswerAsync_GameNotFound_ReturnsNotFoundError()
    {
        var result = await _service.ChooseAnswerAsync(Guid.NewGuid(), Guid.NewGuid(), Guid.NewGuid());

        Assert.False(result.IsSuccess);
        Assert.Equal(ErrorKey.NotFound, result.Errors.First().Key);
    }

    [Fact]
    public async Task ChooseAnswerAsync_OpponentAlreadySelectedIncorrectAnswer_ReturnsAlreadyChosenError()
    {
        var gameId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var opponentId = Guid.NewGuid();
        var answerId = Guid.NewGuid();

        var gameSession = new GameSessionDto
        {
            Id = gameId,
            CurrentQuestionIndex = 0,
            Questions = [
                new QuestionDto 
                { 
                    Id = Guid.NewGuid(), 
                    Answers = [new AnswerDto { Id = answerId, IsCorrect = false }],
                    UserAnswers = new Dictionary<Guid, Guid> { { opponentId, answerId } }
                } 
            ]
        };
        _gamesStorage.TryAdd(gameId, gameSession);

        var result = await _service.ChooseAnswerAsync(userId, gameId, answerId);

        Assert.False(result.IsSuccess);
        Assert.Equal(ErrorKey.AlreadyChosen, result.Errors.First().Key);
    }
    
    [Fact]
    public async Task ChooseAnswerAsync_UserAlreadyAnswered_ReturnsAlreadyExistsError()
    {
        var gameId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var answerId = Guid.NewGuid();

        var gameSession = new GameSessionDto
        {
            Id = gameId,
            CurrentQuestionIndex = 0,
            Questions = [
                new QuestionDto 
                { 
                    Answers = [new AnswerDto { Id = answerId }],
                    UserAnswers = new Dictionary<Guid, Guid> { { userId, Guid.NewGuid() } }
                } 
            ]
        };
        _gamesStorage.TryAdd(gameId, gameSession);

        var result = await _service.ChooseAnswerAsync(userId, gameId, answerId);

        Assert.False(result.IsSuccess);
        Assert.Equal(ErrorKey.AlreadyExists, result.Errors.First().Key);
    }

    [Fact]
    public async Task GetSearchGroupsAsync_ReturnsValidRatingRange()
    {
        var userId = Guid.NewGuid();
        var langId = Guid.NewGuid();
        var rating = 50;
        _userLanguageRepMock.Setup(r => r.GetAsync(userId, langId))
            .ReturnsAsync(new ApplicationUserLanguage { Rating = rating });

        var result = await _service.GetSearchGroupsAsync(userId, langId);

        Assert.Equal(151, result.Count());
    }

    [Fact]
    public async Task GetGameHistory_GameExists_ReturnsGameResult()
    {
        var userId = Guid.NewGuid();
        var gameId = Guid.NewGuid();
        var game = new Game
        {
            Id = gameId,
            GameApplicationUsers = [
                new() { ApplicationUserId = userId, ApplicationUser = new() { Name = "User" }, IsWin = true },
                new() { ApplicationUserId = Guid.NewGuid(), ApplicationUser = new() { Name = "Opponent" } }
            ],
            GameQuestions = []
        };
        _gameRepMock.Setup(r => r.GetGameByIdAsync(gameId)).ReturnsAsync(game);

        var result = await _service.GetGameHistory(userId, gameId);

        Assert.True(result.IsSuccess);
        Assert.True(result.Value.IsVictory);
        Assert.Equal("User", result.Value.YourName);
    }

    [Fact]
    public async Task GetGameHistory_GameNotFound_ReturnsNotFound()
    {
        var gameId = Guid.NewGuid();
        _gameRepMock.Setup(r => r.GetGameByIdAsync(gameId)).ReturnsAsync((Game)null!);

        var result = await _service.GetGameHistory(Guid.NewGuid(), gameId);

        Assert.False(result.IsSuccess);
        Assert.Equal(ErrorKey.NotFound, result.Errors.First().Key);
    }
}