using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Domain.Common;

public static class DefaultUsers
{
    public static readonly ApplicationUser[] Users = [
    new ApplicationUser
    {
        UserName = "user1@test.com",
        NormalizedUserName = "USER1@TEST.COM",
        Email = "user1@test.com",
        NormalizedEmail = "USER1@TEST.COM",
        EmailConfirmed = true,
        Name = "Alex Ivanov",
        SecurityStamp = Guid.NewGuid().ToString()
    },
    new ApplicationUser
    {
        UserName = "user2@test.com",
        NormalizedUserName = "USER2@TEST.COM",
        Email = "user2@test.com",
        NormalizedEmail = "USER2@TEST.COM",
        EmailConfirmed = true,
        Name = "Maria Kovalchuk",
        SecurityStamp = Guid.NewGuid().ToString()
    },
    new ApplicationUser
    {
        UserName = "user3@test.com",
        NormalizedUserName = "USER3@TEST.COM",
        Email = "user3@test.com",
        NormalizedEmail = "USER3@TEST.COM",
        EmailConfirmed = true,
        Name = "Dmitry Savchenko",
        SecurityStamp = Guid.NewGuid().ToString()
    },
    new ApplicationUser
    {
        UserName = "user4@test.com",
        NormalizedUserName = "USER4@TEST.COM",
        Email = "user4@test.com",
        NormalizedEmail = "USER4@TEST.COM",
        EmailConfirmed = true,
        Name = "Anna Petrenko",
        SecurityStamp = Guid.NewGuid().ToString()
    },
    new ApplicationUser
    {
        UserName = "user5@test.com",
        NormalizedUserName = "USER5@TEST.COM",
        Email = "user5@test.com",
        NormalizedEmail = "USER5@TEST.COM",
        EmailConfirmed = true,
        Name = "Sergey Bondar",
        SecurityStamp = Guid.NewGuid().ToString()
    }
];

    public static readonly ApplicationUser[] AdminUsers = [
        new ApplicationUser
        {
            Id = Guid.Parse("5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b"),
            UserName = "nikitatitarenko81@gmail.com",
            NormalizedUserName = "NIKITATITARENKO81@GMAIL.COM",
            Email = "nikitatitarenko81@gmail.com",
            NormalizedEmail = "NIKITATITARENKO81@GMAIL.COM",
            EmailConfirmed = true,
            Name = "Main Admin",
            SecurityStamp = Guid.NewGuid().ToString()
        }
    ];
}