using LanguageDuel.Application.Repositories;

namespace LanguageDuel.Infrastructure.Repositories;

public sealed class UnitOfWork(ApplicationDbContext dbContext) : IUnitOfWork, IDisposable
{
    private readonly ApplicationDbContext _dbContext = dbContext;

    private readonly Dictionary<Type, object> _repositories = [];

    public IRepository<T> GetDbSet<T>() where T : class
    {
        Type type = typeof(T);
        if (!_repositories.TryGetValue(type, out object? value))
        {
            value = new Repository<T>(_dbContext);
            _repositories.Add(type, value);
        }
        return (IRepository<T>)value;
    }

    public async Task CommitAsync()
    {
        _ = await _dbContext.SaveChangesAsync();
    }

    public void Dispose()
    {
        _dbContext.Dispose();
    }
}
