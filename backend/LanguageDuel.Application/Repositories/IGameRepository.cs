using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Repositories;

public interface IGameRepository : IRepository<Game>
{
    Task<Game?> GetGameByIdAsync(Guid gameId);
    Task<IEnumerable<Game>> GetGamesByUserAsync(Guid userId);
}