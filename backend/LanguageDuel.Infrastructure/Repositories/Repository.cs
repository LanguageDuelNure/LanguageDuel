using LanguageDuel.Application.Repositories;
using Microsoft.EntityFrameworkCore;

namespace LanguageDuel.Infrastructure.Repositories;

public class Repository<T>(ApplicationDbContext dbContext) : IRepository<T> where T : class
{
    protected DbSet<T> DbSet { get; set; } = dbContext.Set<T>();

    public void Add(T entity)
    {
        _ = DbSet.Add(entity);
    }

    public async Task<bool> Exists(params object[] keyValues)
    {
        T? entity = await DbSet.FindAsync(keyValues);
        return entity != null;
    }

    public void AddRange(IEnumerable<T> entities)
    {
        DbSet.AddRange(entities);
    }

    public void Remove(T entity)
    {
        _ = DbSet.Remove(entity);
    }

    public async Task<T?> GetAsync(params object[] keyValues)
    {
        return await DbSet.FindAsync(keyValues);
    }

    public async Task<IEnumerable<T>> GetAllAsync()
    {
        return await DbSet.ToListAsync();
    }
}
