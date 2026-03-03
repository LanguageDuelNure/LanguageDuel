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
            ErrorKey.Incorrect => BadRequest(result),
            ErrorKey.AlreadyExists => Conflict(result),
            ErrorKey.NotFound => NotFound(result),
            ErrorKey.UnexpectedError or _ => StatusCode(500, result),
        };
    }
}
