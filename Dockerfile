# Step 1: Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution and project files
COPY WeaponPaints.sln ./
COPY WeaponPaints.csproj ./

# Restore dependencies
RUN dotnet restore WeaponPaints.csproj

# Copy everything else
COPY . .

# Publish the app
RUN dotnet publish WeaponPaints.csproj -c Release -o /app/out

# Step 2: Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/out .

# Render expects the app to listen on port 10000
ENV ASPNETCORE_URLS=http://+:10000
EXPOSE 10000

ENTRYPOINT ["dotnet", "WeaponPaints.dll"]
