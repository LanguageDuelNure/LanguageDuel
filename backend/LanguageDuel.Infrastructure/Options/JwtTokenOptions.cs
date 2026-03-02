namespace LanguageDuel.Infrastructure.Options;

public class JwtTokenOptions
{
    public string Key { get; set; } = string.Empty;
    public string Issuer { get; set; } = string.Empty;
    public string Audience { get; set; } = string.Empty;
    public int ExpiresDay { get; set; }

}
