using System.Reflection;
using Microsoft.OpenApi.Models;

namespace LanguageDuel.WebApi.ServiceExtensions;

public static class SwaggerExtensions
{
    public static IServiceCollection AddSwaggerOpenApi(this IServiceCollection services)
    {
        services.AddSwaggerGen(c =>
        {
            var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
            var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
            c.IncludeXmlComments(xmlPath);

            c.SwaggerDoc("v1", new OpenApiInfo
            {
                Title = "LanguageDuel API",
                Version = "v1",
                Description = """
**API for web and mobile application "Language Duel", which allows users to practice their language skills by dueling with other users in real-time.**
* All endpoints for **Games, Users, Languages, DifficultyLevels, and Tickets** return a standardized response with defined input/output models and status codes.
### Real-time Communication (SignalR)
Gameplay is handled via **SignalR** at `/gameHub`. Use the following hub methods and listen for events:

Hub Methods (Client-to-Server):
* `StartSearchGameAsync(userId, languageId)` - Joins matchmaking groups based on rating.
* `StopSearchGameAsync(userId, languageId)` - Leaves matchmaking groups.

Events (Server-to-Client):
* `ReceiveGameInvitation` (triggered when an opponent is found or search starts):

                                  {
                                    "inviterUserId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                                    "gameId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
                                  }

* `GameStateChanged` (triggered on every turn or state update):

                                  {
                                    "currentQuestion": {
                                      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                                      "name": "What is the capital of France?",
                                      "answers": [
                                        { 
                                            "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6", 
                                            "name": "Paris" 
                                        }
                                      ],
                                      "userAnswers": {
                                        "3fa85f64-5717-4562-b3fc-2c963f66afa6": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
                                      }
                                    },
                                    "users": [
                                      {
                                        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                                        "name": "John Doe",
                                        "hp": 5,
                                        "rating": 1200,
                                        "isGiveUp": false,
                                        "imageUrl": "string"
                                      }
                                    ],
                                    "timeRemainingInSeconds": 15,
                                    "correctAnswerId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                                    "languageName": "English"
                                  }
                                  
* `ReceiveGameResult` (triggered when the game finishes):

                                  {
                                    "winnerUserId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                                    "winnerUserName": "John Doe",
                                    "isGiveUp": false,
                                    "ratingChangeAfterWinOrLoss": 25,
                                    "questions": [
                                      {
                                        "id": "77123456-e89b-12d3-a456-426614174000",
                                        "name": "What is the capital of Ukraine?",
                                        "answers": [
                                          {
                                            "id": "11123456-e89b-12d3-a456-426614174001",
                                            "name": "Kyiv",
                                            "isCorrect": true
                                          },
                                          {
                                            "id": "22223456-e89b-12d3-a456-426614174002",
                                            "name": "Lviv",
                                            "isCorrect": false
                                          }
                                        ],
                                        "userAnswers": {
                                          "3fa85f64-5717-4562-b3fc-2c963f66afa6": "11123456-e89b-12d3-a456-426614174001",
                                          "88523456-c72a-41d3-b123-556614174999": "22223456-e89b-12d3-a456-426614174002"
                                        }
                                      },
                                      {
                                        "id": "88123456-e89b-12d3-a456-426614174111",
                                        "name": "Which language is used for .NET development?",
                                        "answers": [
                                          {
                                            "id": "33323456-e89b-12d3-a456-426614174003",
                                            "name": "C#",
                                            "isCorrect": true
                                          },
                                          {
                                            "id": "44423456-e89b-12d3-a456-426614174004",
                                            "name": "Java",
                                            "isCorrect": false
                                          }
                                        ],
                                        "userAnswers": {
                                          "3fa85f64-5717-4562-b3fc-2c963f66afa6": "33323456-e89b-12d3-a456-426614174003",
                                          "88523456-c72a-41d3-b123-556614174999": "33323456-e89b-12d3-a456-426614174003"
                                        }
                                      }
                                    ]
                                  }

### Error Response Format:

                                  {
                                    "isSuccess": false,
                                    "errors": [
                                      {
                                        "message": "Human-readable description",
                                        "key": "Constant string for frontend mapping and localization.",
                                        "field": "The specific input field that caused the error",
                                        "parameters": {
                                          "additionalProp1": "string"
                                        }
                                      }
                                    ]
                                  }

* **Error Keys** - Specific error keys (NOT_FOUND, FORBIDDEN, etc.) are listed in each endpoint.
* **Global Error Key** - Any endpoint may return UNEXPECTED_ERROR key.
### Auth
All endpoints require a valid **JWT Bearer token** to be accessed, with the exception of **Auth** (Identity) endpoints (e.g., Login, Register), which are available for anonymous users.
"""
                                          });

                                          c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
                                          {
                                              Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
                                              Name = "Authorization",
                                              In = ParameterLocation.Header,
                                              Type = SecuritySchemeType.ApiKey,
                                              Scheme = "Bearer"
                                          });

                                          c.AddSecurityRequirement(new OpenApiSecurityRequirement
                                          {
                                              {
                                                  new OpenApiSecurityScheme
                                                  {
                                                      Reference = new OpenApiReference
                                                      {
                                                          Type = ReferenceType.SecurityScheme,
                                                          Id = "Bearer"
                                                      },
                                                      Scheme = "oauth2",
                                                      Name = "Bearer",
                                                      In = ParameterLocation.Header
                                                  },
                                                  new List<string>()
                                              }
                                          });
                                      });

                                      return services;
                                  }
                              }