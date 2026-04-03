namespace LanguageDuel.Infrastructure.Services;

public interface IFileService
{
    string? GetFileUrl(string fileName);
    Task<bool> SaveFile(Stream bytes, string fileName);
    bool Exists(string fileName);
    void DeleteFile(string fileName);
    bool IsValidSize(Stream bytes);
}