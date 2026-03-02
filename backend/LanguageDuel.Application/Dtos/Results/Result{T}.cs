namespace LanguageDuel.Application.Dtos.Results;

public class Result<T>
{
    public T Value { get; set; } = default!;

    public List<Error> Errors { get; set; } = [];

    public bool IsSuccess => Errors.Count == 0;

    public static implicit operator Result(Result<T> result)
    {
        return new Result { Errors = result.Errors };
    }
}