# Step 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy sln and csproj
COPY WeaponPaints.sln ./
COPY WeaponPaints.csproj ./

# Restore dependencies
RUN dotnet restore WeaponPaints.csproj

# Copy the rest of the source
COPY . .

# Publish as fully self-contained Linux x64 app
RUN dotnet publish WeaponPaints.csproj -c Release -r linux-x64 --self-contained true /p:PublishSingleFile=true /p:PublishTrimmed=true -o /app/out

# Step 2: Runtime image
FROM debian:bookworm-slim AS runtime
WORKDIR /app

# Install any required runtime libs
RUN apt-get update && apt-get install -y \
    libicu72 \
    libssl3 \
    libkrb5-3 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Copy published output
COPY --from=build /app/out .

# Make sure binary is executable
RUN chmod +x ./WeaponPaints

# Expose port (adjust if your app listens elsewhere)
EXPOSE 10000

ENTRYPOINT ["./WeaponPaints"]
