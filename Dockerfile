# Step 1: Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project and restore dependencies
COPY WeaponPaints.sln ./
COPY WeaponPaints.csproj ./
RUN dotnet restore WeaponPaints.csproj

# Copy everything
COPY . .

# Publish as self-contained for Linux x64
RUN dotnet publish WeaponPaints.csproj -c Release -r linux-x64 --self-contained true -o /app/out

# Step 2: Runtime stage (just use Debian base image)
FROM debian:bookworm-slim
WORKDIR /app

# Install dependencies needed for .NET self-contained apps
RUN apt-get update && apt-get install -y \
    libicu72 \
    libssl3 \
    libkrb5-3 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Copy published output
COPY --from=build /app/out .

# Expose port
EXPOSE 10000
ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

ENTRYPOINT ["./WeaponPaints"]
