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

builder.Services.AddSwaggerGen();


//---------------------------------------------------------
// Infrastructure
//---------------------------------------------------------

builder.Services.AddScoped<SqlConnectionFactory>();

builder.Services.AddScoped<StoredProcedureExecutor>();

builder.Services.AddScoped<LoteStoredProcedure>();

builder.Services.AddScoped<EvaluacionStoredProcedure>();

builder.Services.AddScoped<EspecificacionTecnicaStoredProcedure>();

builder.Services.AddScoped<SeguridadStoredProcedure>();


//---------------------------------------------------------
// Repository
//---------------------------------------------------------

builder.Services.AddScoped<ILoteRepository, LoteRepository>();

builder.Services.AddScoped<IEvaluacionRepository, EvaluacionRepository>();

builder.Services.AddScoped<IEspecificacionTecnicaRepository, EspecificacionTecnicaRepository>();

builder.Services.AddScoped<ISeguridadRepository, SeguridadRepository>();


//---------------------------------------------------------
// Services
//---------------------------------------------------------

builder.Services.AddScoped<ILoteService, LoteService>();

builder.Services.AddScoped<IEvaluacionService, EvaluacionService>();

builder.Services.AddScoped<IEspecificacionTecnicaService, EspecificacionTecnicaService>();

builder.Services.AddScoped<ISeguridadService, SeguridadService>();


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

app.UseAuthorization();

app.MapControllers();

app.Run();