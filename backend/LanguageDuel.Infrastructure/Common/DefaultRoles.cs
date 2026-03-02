using Microsoft.AspNetCore.Identity;

namespace LanguageDuel.Infrastructure.Common;

public class DefaultRoles
{
    public static readonly IdentityRole UserRole = new()
    {
        Id = "1",
        Name = "User",
        NormalizedName = "USER"
    };

    public static readonly IdentityRole AdminRole = new()
    {
        Id = "2",
        Name = "Admin",
        NormalizedName = "ADMIN"
    };
}
