using LanguageDuel.Domain.Entities;

namespace LanguageDuel.Domain.Common;

public static class DefaultLanguages
{
    public static readonly Language EnglishLanguage = new()
    {
        Id = new Guid("c89e1824-b7bb-4a91-a34b-5f49d43902b0"),
        Name = "English",
    };

    public static readonly Language SpanishLanguage = new()
    {
        Id = new Guid("9ecb06bf-5648-47f1-b3b7-9face8bebb83"),
        Name = "Spanish",
    };
}