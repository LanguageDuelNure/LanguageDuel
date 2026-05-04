using LanguageDuel.WebApi.ValidationAttributes;

namespace LanguageDuel.WebApi.Requests.Users;

public class UpdateUserProfileRequestModel
{
    [RequiredWithCode]
    public string Name { get; set; }
    
    public IFormFile? Icon { get; set; }
    
    public string? IconName { get; set; }
}