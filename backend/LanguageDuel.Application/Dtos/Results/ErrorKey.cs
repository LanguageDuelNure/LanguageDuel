using System.Runtime.Serialization;
using System.Text.Json.Serialization;

namespace LanguageDuel.Application.Dtos.Results;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum ErrorKey
{
    [EnumMember(Value = "ALREADY_EXISTS")]
    AlreadyExists,

    [EnumMember(Value = "NOT_FOUND")]
    NotFound,

    [EnumMember(Value = "REPEATED_VALUE")]
    RepeatedValue,

    [EnumMember(Value = "REFERENCE_ITSELF")]
    ReferenceItself,

    [EnumMember(Value = "ANSESTOR_AS_A_SUB_ENTITIE")]
    AnsestorAsASubEntitie,

    [EnumMember(Value = "UNEXPECTED_ERROR")]
    UnexpectedError,

    [EnumMember(Value = "REQUIRED")]
    Required,

    [EnumMember(Value = "INVALID_TYPE")]
    InvalidType,

    [EnumMember(Value = "ALREADY_CONFIRMED")]
    AlreadyConfirmed,

    [EnumMember(Value = "INCORRECT")]
    Incorrect,

    [EnumMember(Value = "INCORRECT_LOGIN_OR_PASSWORD")]
    IncorrectLoginOrPassword,

    [EnumMember(Value = "INVALID_STRING_LENGTH")]
    InvalidStringLength,

    [EnumMember(Value = "DO_NOT_MATCH")]
    DoNotMatch
}