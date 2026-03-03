using LanguageDuel.Infrastructure.Common;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace LanguageDuel.Infrastructure.EntityTypeConfigurations;

public class RoleConfiguration : IEntityTypeConfiguration<IdentityRole>
{
    public void Configure(EntityTypeBuilder<IdentityRole> builder)
    {
        builder.HasData(DefaultRoles.UserRole);
        builder.HasData(DefaultRoles.AdminRole);
    }
}
