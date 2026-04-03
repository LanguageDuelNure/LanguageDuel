using System.ComponentModel.DataAnnotations;

namespace LanguageDuel.WebApi.Requests.Users;

public class UpdateUserProfileRequestModel
{
    [Required]
    public string Name { get; set; }
    
    public IFormFile? Icon { get; set; }
    
    public string? IconName { get; set; }
}