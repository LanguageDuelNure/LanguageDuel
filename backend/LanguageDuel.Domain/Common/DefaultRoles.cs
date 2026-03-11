using Microsoft.AspNetCore.Identity;

namespace LanguageDuel.Infrastructure.Common;

public class DefaultRoles
{
    public static readonly IdentityRole<Guid> UserRole = new()
    {
        Id = new Guid("86d0f57d-76eb-4803-ac6b-1cdc90d14d30"),
        Name = "User",
        NormalizedName = "USER"
    };

    public static readonly IdentityRole<Guid> AdminRole = new()
    {
        Id = new Guid("b8f4e7f2-a0ea-41c7-af71-448efbf4b00c"),
        Name = "Admin",
        NormalizedName = "ADMIN"
    };
}
