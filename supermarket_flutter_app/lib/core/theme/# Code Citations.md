# Code Citations

## License: unknown
https://github.com/alternyx/alternyx/blob/c91de4faa832ebdbe43ed41d9735852279b333d0/alternyx/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.
```


## License: unknown
https://github.com/schomme/SimpleGrade/blob/ad15c95b959b1771acf91ad04a2c84afd63222ef/SimpleGradeApi/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.
```


## License: unknown
https://github.com/alternyx/alternyx/blob/c91de4faa832ebdbe43ed41d9735852279b333d0/alternyx/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.
```


## License: unknown
https://github.com/schomme/SimpleGrade/blob/ad15c95b959b1771acf91ad04a2c84afd63222ef/SimpleGradeApi/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.
```


## License: unknown
https://github.com/alternyx/alternyx/blob/c91de4faa832ebdbe43ed41d9735852279b333d0/alternyx/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.
```


## License: unknown
https://github.com/schomme/SimpleGrade/blob/ad15c95b959b1771acf91ad04a2c84afd63222ef/SimpleGradeApi/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.
```


## License: unknown
https://github.com/alternyx/alternyx/blob/c91de4faa832ebdbe43ed41d9735852279b333d0/alternyx/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.
```


## License: unknown
https://github.com/schomme/SimpleGrade/blob/ad15c95b959b1771acf91ad04a2c84afd63222ef/SimpleGradeApi/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.
```


## License: unknown
https://github.com/alternyx/alternyx/blob/c91de4faa832ebdbe43ed41d9735852279b333d0/alternyx/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.
```


## License: unknown
https://github.com/schomme/SimpleGrade/blob/ad15c95b959b1771acf91ad04a2c84afd63222ef/SimpleGradeApi/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.
```


## License: unknown
https://github.com/alternyx/alternyx/blob/c91de4faa832ebdbe43ed41d9735852279b333d0/alternyx/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.
```


## License: unknown
https://github.com/schomme/SimpleGrade/blob/ad15c95b959b1771acf91ad04a2c84afd63222ef/SimpleGradeApi/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.
```


## License: unknown
https://github.com/Ahmedsheekhaal/test/blob/f154f1f7339a0cd985babe98b6aff07c7036771b/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/alternyx/alternyx/blob/c91de4faa832ebdbe43ed41d9735852279b333d0/alternyx/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/Ahmedsheekhaal/test/blob/f154f1f7339a0cd985babe98b6aff07c7036771b/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/schomme/SimpleGrade/blob/ad15c95b959b1771acf91ad04a2c84afd63222ef/SimpleGradeApi/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/alternyx/alternyx/blob/c91de4faa832ebdbe43ed41d9735852279b333d0/alternyx/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/Ahmedsheekhaal/test/blob/f154f1f7339a0cd985babe98b6aff07c7036771b/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/schomme/SimpleGrade/blob/ad15c95b959b1771acf91ad04a2c84afd63222ef/SimpleGradeApi/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/alternyx/alternyx/blob/c91de4faa832ebdbe43ed41d9735852279b333d0/alternyx/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/Ahmedsheekhaal/test/blob/f154f1f7339a0cd985babe98b6aff07c7036771b/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/schomme/SimpleGrade/blob/ad15c95b959b1771acf91ad04a2c84afd63222ef/SimpleGradeApi/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/alternyx/alternyx/blob/c91de4faa832ebdbe43ed41d9735852279b333d0/alternyx/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/Ahmedsheekhaal/test/blob/f154f1f7339a0cd985babe98b6aff07c7036771b/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/schomme/SimpleGrade/blob/ad15c95b959b1771acf91ad04a2c84afd63222ef/SimpleGradeApi/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/alternyx/alternyx/blob/c91de4faa832ebdbe43ed41d9735852279b333d0/alternyx/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/Ahmedsheekhaal/test/blob/f154f1f7339a0cd985babe98b6aff07c7036771b/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/schomme/SimpleGrade/blob/ad15c95b959b1771acf91ad04a2c84afd63222ef/SimpleGradeApi/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/alternyx/alternyx/blob/c91de4faa832ebdbe43ed41d9735852279b333d0/alternyx/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/Ahmedsheekhaal/test/blob/f154f1f7339a0cd985babe98b6aff07c7036771b/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```


## License: unknown
https://github.com/schomme/SimpleGrade/blob/ad15c95b959b1771acf91ad04a2c84afd63222ef/SimpleGradeApi/Program.cs

```
Excellent! ✅ Here's your complete SQL Server connection setup:

## **1. appsettings.json** (Connection String)
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost\\SQLEXPRESS;Database=SupermarketDB;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Connection String Breakdown:**
- `Server=localhost\SQLEXPRESS` - Your SQL Server instance
- `Database=SupermarketDB` - Your database
- `Trusted_Connection=True` - Windows Authentication (Active Directory)
- `TrustServerCertificate=True` - Trust self-signed certificates

## **2. Program.cs** (Dependency Injection)
```csharp
using Microsoft.EntityFrameworkCore;
using SupermarketAPI.Data;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapControllers();

app.Run();
```

## **3. AppDbContext.cs** (Database Context)
The `OnConfig
```

