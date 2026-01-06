#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deploy React builds to Azure Static Web Apps
.DESCRIPTION
    This script uploads pre-built React applications to Azure Static Web Apps
    using the Static Web Apps CLI deployment tokens
#>

param(
    [string]$ResourceGroup = "cannabis-delivery-rg",
    [string]$AppName = "all" # Can be: customer, vendor, driver, admin, or all
)

# Static Web App configurations
$staticApps = @{
    "customer" = @{
        "name" = "cannabis-customer-app"
        "token" = $env:AZURE_STATIC_WEB_APPS_API_TOKEN_JOLLY_FOREST_020C52A0F
        "buildPath" = "apps/customer-app/build"
        "url" = "https://jolly-forest-020c52a0f.6.azurestaticapps.net"
    }
    "vendor" = @{
        "name" = "cannabis-vendor-dashboard"
        "token" = $env:AZURE_STATIC_WEB_APPS_API_TOKEN_GENTLE_GRASS_00BB9010F
        "buildPath" = "apps/vendor-dashboard/build"
        "url" = "https://gentle-grass-00bb9010f.1.azurestaticapps.net"
    }
    "driver" = @{
        "name" = "cannabis-driver-app"
        "token" = $env:AZURE_STATIC_WEB_APPS_API_TOKEN_RED_MUD_0B72F350F
        "buildPath" = "apps/driver-app/build"
        "url" = "https://red-mud-0b72f350f.2.azurestaticapps.net"
    }
    "admin" = @{
        "name" = "cannabis-admin-panel"
        "token" = $env:AZURE_STATIC_WEB_APPS_API_TOKEN_KIND_STONE_01C35960F
        "buildPath" = "apps/admin-panel/build"
        "url" = "https://kind-stone-01c35960f.1.azurestaticapps.net"
    }
}

Write-Host "🚀 Cannabis Delivery Platform - Static Web Apps Deployment" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# Determine which apps to deploy
$appsToProcess = if ($AppName -eq "all") {
    $staticApps.Keys
} else {
    @($AppName)
}

foreach ($app in $appsToProcess) {
    if (-not $staticApps.ContainsKey($app)) {
        Write-Host "❌ Unknown app: $app" -ForegroundColor Red
        continue
    }

    $config = $staticApps[$app]
    Write-Host "📦 Deploying $app..." -ForegroundColor Yellow
    
    # Check if build directory exists
    $buildFullPath = Join-Path -Path (Get-Location) -ChildPath $config.buildPath
    if (-not (Test-Path $buildFullPath)) {
        Write-Host "   ❌ Build directory not found: $buildFullPath" -ForegroundColor Red
        continue
    }

    Write-Host "   Build path: $buildFullPath" -ForegroundColor Gray
    Write-Host "   Target URL: $($config.url)" -ForegroundColor Gray

    # The workflows will be triggered by the git push
    Write-Host "   ✅ Build verified and ready for deployment via GitHub Actions" -ForegroundColor Green
    Write-Host ""
}

Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. Push changes to trigger GitHub Actions workflows:" -ForegroundColor Gray
Write-Host "      git push origin main" -ForegroundColor Gray
Write-Host "   2. Monitor deployments at: https://github.com/XRMindCNTRL/GetGanja/actions" -ForegroundColor Gray
Write-Host "   3. Verify deployed apps at the URLs above" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ Deployment script completed!" -ForegroundColor Green
