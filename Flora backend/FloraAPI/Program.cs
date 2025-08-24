using Flora.Models.Requests;
using Flora.Services;
using Flora.Services.Database;
using Flora.Services.Database.Seeders;
using Flora.Services.Interfaces;
using Flora.Services.Services;
using FloraAPI.Filters;
using Mapster;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using QuestPDF.Infrastructure;
using DotNetEnv;
using Microsoft.OpenApi.Writers;

string GetEnv(string defaultValue, params string[] keys)
{
    foreach (var k in keys)
    {
        var v = Environment.GetEnvironmentVariable(k);
        if (!string.IsNullOrWhiteSpace(v)) return v;
    }
    return defaultValue;
}

var builder = WebApplication.CreateBuilder(args);
DotNetEnv.Env.Load();

builder.Configuration
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.json", optional: true, reloadOnChange: true)
    .AddEnvironmentVariables();

QuestPDF.Settings.License = LicenseType.Community;

builder.Services.AddMapster();
TypeAdapterConfig<ProductRequest, Product>.NewConfig()
    .Ignore(dest => dest.Images);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContextFactory<FLoraDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IRoleService, RoleService>();
builder.Services.AddTransient<ICategoryService, CategoryService>();
builder.Services.AddTransient<IProductService, ProductService>();
builder.Services.AddTransient<IOccasionService, OccasionService>();
builder.Services.AddTransient<IFavoriteService, FavoriteService>();
builder.Services.AddTransient<ICartItemService, CartItemService>();
builder.Services.AddTransient<ICartService, CartService>();
builder.Services.AddTransient<IOrderService, OrderService>();
builder.Services.AddTransient<ICustomBouquetService, CustomBouquetService>();
builder.Services.AddTransient<IDecorationRequestService, DecorationRequestService>();
builder.Services.AddTransient<IDecorationSuggestionService, DecorationSuggestionService>();
builder.Services.AddTransient<IDonationCampaignService, DonationCampaignService>();
builder.Services.AddTransient<IDonationService, DonationService>();
builder.Services.AddTransient<IBlogPostService, BlogPostService>();
builder.Services.AddTransient<IBlogCommentService, BlogCommentService>();
builder.Services.AddTransient<IStatisticsService, StatisticsService>();
builder.Services.AddTransient<IRecommendationService, RecommendationService>();
builder.Services.AddTransient<IDecorationSelectionService, DecorationSelectionService>();

// Ostali servisi
builder.Services.AddTransient<IBlobService, BlobService>();
builder.Services.AddTransient<PayPalService>();
builder.Services.AddTransient<IRabbitMQService, RabbitMQService>();

// PayPal konfiguracija
var paypalClientId = GetEnv(
    builder.Configuration["PayPal:ClientID"],
    "PAYPAL_CLIENT_ID"
);
var paypalSecretKey = GetEnv(
    builder.Configuration["PayPal:SecretKey"],
    "PAYPAL_SECRET_KEY"
);

builder.Configuration["PayPal:ClientID"] = paypalClientId;
builder.Configuration["PayPal:SecretKey"] = paypalSecretKey;

// Blob konfiguracija
var blobConnectionString = Environment.GetEnvironmentVariable("AZURE_BLOB_CONNECTION_STRING");
builder.Configuration["AzureBlobStorage:ConnectionString"] = blobConnectionString;

// Kontroleri i swagger
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("BasicAuthentication", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "basic",
        In = ParameterLocation.Header,
        Description = "Basic Authorization header using the Bearer scheme."
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "BasicAuthentication" } },
            new string[] { }
        }
    });
});

// Auth
builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);
builder.Services.AddAuthorization();

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});
builder.Services.AddHttpContextAccessor();

var app = builder.Build();

//Migrations
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<FLoraDbContext>();

    dbContext.Database.EnsureCreated();
    dbContext.Database.Migrate();
    
}

app.UseCors("AllowAll");

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<FLoraDbContext>();

}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();