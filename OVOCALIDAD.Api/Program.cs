using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using OVOCALIDAD.Api.Security;
using OVOCALIDAD.Application.Interfaces;
using OVOCALIDAD.Application.Services;
using OVOCALIDAD.Infrastructure.Data;
using OVOCALIDAD.Infrastructure.Repositories;
using OVOCALIDAD.Infrastructure.StoredProcedures;

var builder = WebApplication.CreateBuilder(args);


//---------------------------------------------------------
// Controllers
//---------------------------------------------------------

builder.Services.AddControllers();


//---------------------------------------------------------
// Swagger
//---------------------------------------------------------

builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen(options =>
{
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Ingrese el token JWT."
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

var jwtKey = builder.Configuration["Jwt:Key"]
    ?? throw new InvalidOperationException("Jwt:Key no está configurado.");

var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "OVOCALIDAD.Api";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "OVOCALIDAD.Web";

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = jwtIssuer,
            ValidateAudience = true,
            ValidAudience = jwtAudience,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            ClockSkew = TimeSpan.FromMinutes(1)
        };
    });

builder.Services.AddAuthorization();


//---------------------------------------------------------
// Infrastructure
//---------------------------------------------------------

builder.Services.AddScoped<SqlConnectionFactory>();

builder.Services.AddScoped<StoredProcedureExecutor>();

builder.Services.AddScoped<LoteStoredProcedure>();

builder.Services.AddScoped<EvaluacionStoredProcedure>();

builder.Services.AddScoped<EspecificacionTecnicaStoredProcedure>();

builder.Services.AddScoped<SeguridadStoredProcedure>();
builder.Services.AddScoped<AuthStoredProcedure>();


//---------------------------------------------------------
// Repository
//---------------------------------------------------------

builder.Services.AddScoped<ILoteRepository, LoteRepository>();

builder.Services.AddScoped<IEvaluacionRepository, EvaluacionRepository>();

builder.Services.AddScoped<IEspecificacionTecnicaRepository, EspecificacionTecnicaRepository>();

builder.Services.AddScoped<ISeguridadRepository, SeguridadRepository>();
builder.Services.AddScoped<IAuthRepository, AuthRepository>();


//---------------------------------------------------------
// Services
//---------------------------------------------------------

builder.Services.AddScoped<ILoteService, LoteService>();

builder.Services.AddScoped<IEvaluacionService, EvaluacionService>();

builder.Services.AddScoped<IEspecificacionTecnicaService, EspecificacionTecnicaService>();

builder.Services.AddScoped<ISeguridadService, SeguridadService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IPasswordService, OVOCALIDAD.Infrastructure.Security.PasswordService>();
builder.Services.AddScoped<ITokenService, JwtTokenService>();


var app = builder.Build();


//---------------------------------------------------------
// Pipeline
//---------------------------------------------------------

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();

    app.UseSwaggerUI(options =>
    {
        options.DocumentTitle = "OVOCALIDAD API";

        options.SwaggerEndpoint(
            "/swagger/v1/swagger.json",
            "OVOCALIDAD API v1");
    });
}

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();