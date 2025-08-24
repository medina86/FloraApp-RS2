FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["FloraApp.Subscriber/FloraApp.Subscriber.csproj", "FloraApp.Subscriber/"]
COPY ["Flora.Models/Flora.Models.csproj", "Flora.Models/"]
RUN dotnet restore "FloraApp.Subscriber/FloraApp.Subscriber.csproj"
COPY . .
WORKDIR "/src/FloraApp.Subscriber"
RUN dotnet build "FloraApp.Subscriber.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "FloraApp.Subscriber.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "FloraApp.Subscriber.dll"]