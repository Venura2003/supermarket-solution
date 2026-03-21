# Use the official image as a parent image
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy csproj and restore
COPY ["SupermarketAPI/SupermarketAPI.csproj", "SupermarketAPI/"]
RUN dotnet restore "SupermarketAPI/SupermarketAPI.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/SupermarketAPI"
RUN dotnet build "SupermarketAPI.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SupermarketAPI.csproj" -c Release -o /app/publish \
	&& cp -r /src/SupermarketAPI/wwwroot /app/publish/wwwroot

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
EXPOSE 80
EXPOSE 443
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SupermarketAPI.dll"]