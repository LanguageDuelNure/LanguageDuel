namespace LanguageDuel.Application.Dtos.Results;

public class Result
{
    public List<Error> Errors { get; set; } = [];

    public bool IsSuccess => Errors.Count == 0;
}
