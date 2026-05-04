using LanguageDuel.WebApi.ValidationAttributes;

namespace LanguageDuel.WebApi.Requests.Users;

public class BanUserRequestModel
{
    public int Days { get; set; }
    
    [RequiredWithCode]
    public string Reason { get; set; }
}