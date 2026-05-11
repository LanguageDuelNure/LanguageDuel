using AutoMapper;
using Microsoft.Extensions.DependencyInjection;

namespace LanguageDuel.Tests.Application;

public class BaseServiceTests
{
    protected static IMapper GetMapper()
    {
        var services = new ServiceCollection();
        services.AddAutoMapper(_ => { }, AppDomain.CurrentDomain.GetAssemblies());
        services.AddLogging();
        var provider = services.BuildServiceProvider();
        return provider.GetRequiredService<IMapper>();
    }
}