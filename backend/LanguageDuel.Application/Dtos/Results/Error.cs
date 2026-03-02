namespace LanguageDuel.Application.Dtos.Results;

public class Error
{
    public string Message { get; set; } = string.Empty;

    public ErrorKey Key { get; set; }

    public string Field { get; set; } = string.Empty;

    public Dictionary<string, object> Parameters { get; set; } = [];
}