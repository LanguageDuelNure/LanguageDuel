using System.Security.Claims;
using LanguageDuel.Application.Dtos.Results;
using Microsoft.AspNetCore.Mvc;

namespace LanguageDuel.WebApi.Controllers;

public class BaseController : ControllerBase
{
    [NonAction]
    public ActionResult HandleErrors(Result result)
    {
        var error = result.Errors.FirstOrDefault();
        if (error == null)
        {
            result.Errors.Add(new Error
            {
                Key = ErrorKey.UnexpectedError,
                Message = "An unexpected error occurred.",
            });
            return StatusCode(500, result);
        }

        return error.Key switch
        {
            ErrorKey.ReferenceItself or ErrorKey.RepeatedValue or
            ErrorKey.Required or ErrorKey.AnsestorAsASubEntitie or
            ErrorKey.InvalidStringLength or ErrorKey.IncorrectLoginOrPassword or
            ErrorKey.AlreadyConfirmed or ErrorKey.InvalidType or
            ErrorKey.Incorrect or ErrorKey.BadRequest
            or ErrorKey.Forbidden or ErrorKey.AlreadyChosen or 
            ErrorKey.DoNotMatch => BadRequest(result),
            ErrorKey.Banned => StatusCode(403, result),
            ErrorKey.AlreadyExists => Conflict(result),
            ErrorKey.NotFound => NotFound(result),
            ErrorKey.UnexpectedError or _ => StatusCode(500, result),
        };
    }

    [NonAction]
    public Guid GetUserId()
    {
        return new Guid(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
    }
}
