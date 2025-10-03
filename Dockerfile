# Step 1: Build the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY WeaponPaints.csproj ./
RUN dotnet restore WeaponPaints.csproj

# Copy everything else
COPY . .

# Publish as self-contained single file app
RUN dotnet publish WeaponPaints.csproj -c Release -r linux-x64 --self-contained true \
    /p:PublishSingleFile=true \
    /p:PublishTrimmed=true \
    -o /app/out

# Step 2: Runtime container
FROM debian:bookworm-slim AS runtime
WORKDIR /app

# Install required native libs
RUN apt-get update && apt-get install -y \
    libicu72 \
    libssl3 \
    zlib1g \
    libkrb5-3 \
    && rm -rf /var/lib/apt/lists/*

# Copy published output
COPY --from=build /app/out .

# Make sure binary is executable
RUN chmod +x ./WeaponPaints

# Expose a port (if needed)
EXPOSE 8080

# Start your app
ENTRYPOINT ["./WeaponPaints"]
