using System.Net;
using System.Text;
using FluentValidation;
using FluentValidation.AspNetCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Serilog;
using SupermarketAPI.Data;
using SupermarketAPI.Middleware;
using SupermarketAPI.Services;
using SupermarketAPI.Validators;

var builder = WebApplication.CreateBuilder(args);

// Disable file watching for appsettings.json to avoid inotify/file descriptor limit crash on Render
builder.Host.ConfigureAppConfiguration((hostingContext, config) =>
{
    config.Sources.Clear();
    config.AddJsonFile("appsettings.json", optional: false, reloadOnChange: false);
    config.AddJsonFile($"appsettings.{hostingContext.HostingEnvironment.EnvironmentName}.json", optional: true, reloadOnChange: false);
    config.AddEnvironmentVariables();
});

// Configure Serilog (sinks defined in configuration to avoid duplicate outputs)
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .Enrich.FromLogContext()
    .CreateLogger();
// Ensure model validation errors return JSON
builder.Services.Configure<ApiBehaviorOptions>(options =>
{
    options.InvalidModelStateResponseFactory = context =>
    {
        var errors = context.ModelState
            .Where(e => e.Value != null && e.Value.Errors.Count > 0)
            .Select(e => new {
                Field = e.Key,
                Errors = e.Value!.Errors.Select(er => er.ErrorMessage)
            });
        var result = new
        {
            Success = false,
            Message = "Validation failed.",
            Errors = errors,
            Timestamp = DateTime.UtcNow
        };
        return new BadRequestObjectResult(result);
    };
});

builder.Host.UseSerilog();

// On Render, the runtime provides the listening port via PORT.
var renderPort = Environment.GetEnvironmentVariable("PORT");
if (!string.IsNullOrWhiteSpace(renderPort))
{
    builder.WebHost.UseUrls($"http://0.0.0.0:{renderPort}");
}

// Configuration
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

var jwtSettings = builder.Configuration.GetSection("JwtSettings");
// WARNING: For production, set JwtSettings__SecretKey as an environment variable on Render.
var secretKey = jwtSettings["SecretKey"] ??
    builder.Configuration["JwtSettings:SecretKey"] ??
    builder.Configuration["JwtSettings__SecretKey"] ??
    builder.Configuration["Jwt:Key"] ??
    builder.Configuration["Jwt__Key"] ??
    throw new InvalidOperationException("JWT secret key not configured. Set JwtSettings__SecretKey as an environment variable on Render.");
var jwtIssuer = jwtSettings["Issuer"] ??
    builder.Configuration["JwtSettings:Issuer"] ??
    builder.Configuration["JwtSettings__Issuer"] ??
    builder.Configuration["Jwt:Issuer"] ??
    builder.Configuration["Jwt__Issuer"] ??
    "SupermarketAPI";
var jwtAudience = jwtSettings["Audience"] ??
    builder.Configuration["JwtSettings:Audience"] ??
    builder.Configuration["JwtSettings__Audience"] ??
    builder.Configuration["Jwt:Audience"] ??
    builder.Configuration["Jwt__Audience"] ??
    "SupermarketAPIUsers";

// Database
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString, sqlOptions =>
    {
        sqlOptions.EnableRetryOnFailure(); // Enable transient error resiliency
    })
);

// Authentication - JWT
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtIssuer,
        ValidAudience = jwtAudience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey))
    };
});

// Authorization
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
    options.AddPolicy("EmployeeOrAdmin", policy => policy.RequireRole("Employee", "Admin"));
});

// Services

// CORS Configuration - Allow All Origins (for development/deployment ease)
// CORS Configuration - Allow only Netlify and local dev origins in production
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend",
        policy =>
        {
            var allowedOrigins = new[] {
                "https://incredible-kataifi-a63f72.netlify.app", // Netlify
                "https://supermarkrt-solution.vercel.app", // Vercel old
                "https://supermarket-green-phi.vercel.app", // Vercel new
                "http://localhost:3000", // Local dev
                "http://localhost:5000", // Local Flutter web
                "http://127.0.0.1:5000"
            };
            policy.WithOrigins(allowedOrigins)
                  .AllowAnyMethod()
                  .AllowAnyHeader()
                  .AllowCredentials();
        });
});

builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<ICategoryService, CategoryService>();
builder.Services.AddScoped<IOrderService, OrderService>();
builder.Services.AddScoped<IEmployeeService, EmployeeService>();
builder.Services.AddScoped<ISaleService, SaleService>();
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<ICartService, CartService>();
builder.Services.AddScoped<IPurchaseOrderService, PurchaseOrderService>();
builder.Services.AddScoped<IReportService, ReportService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<IPayrollService, PayrollService>();

// FluentValidation
builder.Services.AddValidatorsFromAssemblyContaining<CreateSaleDtoValidator>();
builder.Services.AddFluentValidationAutoValidation();

// Controllers
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
    });
builder.Services.AddEndpointsApiExplorer();

// 🔥 Swagger with JWT Support
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Supermarket API",
        Version = "v1",
        Description = "ASP.NET Core Web API for Supermarket Management System",
        Contact = new OpenApiContact
        {
            Name = "Supermarket Team",
            Email = "support@supermarket.local"
        }
    });

    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Enter: Bearer {your JWT token}"
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
            new string[] {}
        }
    });
});

var app = builder.Build();

// Set up custom font resolver for PDFSharpCore (only once at startup)
PdfSharpCore.Fonts.GlobalFontSettings.FontResolver = new CustomFontResolver();

// Apply migrations and seed data
using (var scope = app.Services.CreateScope())
{
    try
    {
        var services = scope.ServiceProvider;
        var db = services.GetRequiredService<AppDbContext>();
        // apply any pending migrations
        await db.Database.MigrateAsync();

        // seed categories (idempotent)
        await SeedData.SeedCategories(db);

        // seed default admin user
        var authService = services.GetRequiredService<IAuthService>();
        await authService.SeedDefaultAdminAsync();
    }
    catch (Exception ex)
    {
        Log.Error(ex, "Database initialization failed during startup. API will keep running for diagnostics.");
    }
}

// Middleware
app.UseMiddleware<ExceptionMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger(options =>
    {
        options.SerializeAsV2 = false;
        options.RouteTemplate = "swag        flutter build web --releaseger/{documentName}/swagger.json";
    });
    
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "Supermarket API v1");
        options.RoutePrefix = "swagger";
        options.DefaultModelsExpandDepth(2);
        options.DefaultModelExpandDepth(2);
        options.DocExpansion(Swashbuckle.AspNetCore.SwaggerUI.DocExpansion.List);
        options.DisplayOperationId();
    });
}

// Render terminates SSL at the proxy, so HTTPS redirection is safe and recommended.


// Serve static files (images, css, js, etc.) with CORS headers for images
app.UseStaticFiles(new StaticFileOptions
{
    OnPrepareResponse = ctx =>
    {
        ctx.Context.Response.Headers.Append("Access-Control-Allow-Origin", "*");
    }
});

app.UseHttpsRedirection();

// Use CORS before Authorization
app.UseCors("AllowFrontend");

app.UseAuthentication(); // ⚠️ Must be before Authorization
app.UseAuthorization();

app.MapGet("/api/health", () => Results.Ok(new
{
    status = "ok",
    timestamp = DateTime.UtcNow
}));

app.MapControllers();

app.Run();
