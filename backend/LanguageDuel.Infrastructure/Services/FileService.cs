using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using SixLabors.ImageSharp;

namespace LanguageDuel.Infrastructure.Services;

public class FileService : IFileService
{
    private const string FilePath = "uploads";
    
    private const int MaxFileSize = 2048;

    private static readonly string[] ValidFileExtensions = { ".jpg", ".jpeg", ".png", ".webp", ".gif" };

    private readonly string _path;

    private readonly string _baseUrl;

    public FileService(IWebHostEnvironment environment, IHttpContextAccessor accessor)
    {
        var request = accessor?.HttpContext?.Request;
        if (request != null)
        {
            _baseUrl = new Uri(new Uri($"{request.Scheme}://{request.Host}"), FilePath.Replace("\\", "/")).ToString();
        }

        _path = Path.Combine(environment.WebRootPath, FilePath);
    }
    
    public string? GetFileUrl(string fileName)
    {
        string? fileNameWithExtension = null;

        foreach (var extension in ValidFileExtensions)
        {
            if (Exists(fileName + extension))
            {
                fileNameWithExtension = fileName + extension;
                break;
            }
        }

        if (fileNameWithExtension == null)
        {
            return null;
        }

        return new Uri(
            new Uri(_baseUrl.EndsWith('/') ? _baseUrl : _baseUrl + "/"),
            fileNameWithExtension.Replace("\\", "/")).ToString();
    }
    
    public async Task<bool> SaveFile(Stream bytes, string fileName)
    {
        var fileNameWithoutExtension = Path.Combine(Path.GetDirectoryName(fileName) ?? string.Empty, Path.GetFileNameWithoutExtension(fileName));
        foreach (var extension in ValidFileExtensions)
        {
            if (Exists(fileNameWithoutExtension + extension))
            {
                DeleteFile(fileNameWithoutExtension + extension);
                break;
            }
        }
        
        var fullPath = Path.Combine(_path, fileName);
        
        var directoryPath = Path.GetDirectoryName(fullPath);
    
        if (directoryPath != null)
        {
            Directory.CreateDirectory(directoryPath);
        }
    
        await using var fileStream = File.Create(fullPath);
    
        bytes.Position = 0;
        await bytes.CopyToAsync(fileStream);

        return true;
    }
    
    public bool Exists(string fileName)
    {
        return File.Exists(Path.Combine(_path, fileName));
    }

    public void DeleteFile(string fileName)
    {
        File.Delete(Path.Combine(_path, fileName));
    }
    
    public bool IsValidSize(Stream bytes)
    {
        using var image = Image.Load(bytes);
        bytes.Position = 0;

        if (image.Width > MaxFileSize || image.Height > MaxFileSize)
        {
            return false;
        }

        return true;
    }
}