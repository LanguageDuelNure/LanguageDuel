using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Application.Repositories;

public interface ILanguageRepository
{
    Task<IEnumerable<Language>> GetLanguagesWithRatingAsync(Guid userId);
}