namespace LanguageDuel.Application.Repositories;

public interface IUnitOfWork
{
    Task CommitAsync();
}