#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

# Download the latest version of the tracer but don't install yet
ENV TRACER_VERSION=2.19.0
RUN curl -Lo /tmp/datadog-dotnet-apm.deb https://github.com/DataDog/dd-trace-dotnet/releases/download/v${TRACER_VERSION}/datadog-dotnet-apm_${TRACER_VERSION}_amd64.deb

WORKDIR /src
COPY "dotnet-6-serilog.csproj" .
RUN dotnet restore "dotnet-6-serilog.csproj"
COPY . .
RUN dotnet build "dotnet-6-serilog.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "dotnet-6-serilog.csproj" -c Release -o /app/publish

FROM base AS final

# Install the tracer
COPY --from=build /tmp/datadog-dotnet-apm.deb /tmp/datadog-dotnet-apm.deb
RUN mkdir -p /opt/datadog \
    && mkdir -p /var/log/datadog \
    && dpkg -i /tmp/datadog-dotnet-apm.deb \
    && rm /tmp/datadog-dotnet-apm.deb

# Enable the tracer
ENV CORECLR_ENABLE_PROFILING=1
ENV CORECLR_PROFILER={846F5F1C-F9AE-4B07-969E-05C26BC060D8}
ENV CORECLR_PROFILER_PATH=/opt/datadog/Datadog.Trace.ClrProfiler.Native.so
ENV DD_DOTNET_TRACER_HOME=/opt/datadog

WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "dotnet-6-serilog.dll"]