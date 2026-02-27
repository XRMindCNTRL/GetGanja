# Azure Static Web Apps Deployment Script
# This script builds and deploys each React app to its corresponding Static Web App

$ErrorActionPreference = "Stop"

# Configuration - Update these with your actual Azure SWA names
$apps = @(
    @{
        Name = "customer-app"
        AppFolder = "apps/customer-app"
        SWAName = "GetGanja"
        OutputLocation = "build"
    },
    @{
        Name = "vendor-dashboard"
        AppFolder = "apps/vendor-dashboard"
        SWAName = "cannabis-vendor-dashboard"
        OutputLocation = "build"
    },
    @{
        Name = "driver-app"
        AppFolder = "apps/driver-app"
        SWAName = "driver-app"
        OutputLocation = "build"
    },
    @{
        Name = "admin-panel"
        AppFolder = "apps/admin-panel"
        SWAName = "admin-app"
        OutputLocation = "build"
    }
)

Write-Host "=== Azure Static Web Apps Deployment ===" -ForegroundColor Cyan

# Login to Azure (if not already logged in)
$account = az account show 2>$null
if (-not $account) {
    Write-Host "Please login to Azure..." -ForegroundColor Yellow
    az login
}

# Select subscription if needed
$subscriptionId = "YOUR_SUBSCRIPTION_ID"  # Replace with your subscription ID
az account set --subscription $subscriptionId

foreach ($app in $apps) {
    Write-Host "`n=== Deploying $($app.Name) to $($app.SWAName) ===" -ForegroundColor Green
    
    $appPath = Join-Path $PSScriptRoot $app.AppFolder
    
    if (-not (Test-Path $appPath)) {
        Write-Host "Warning: App folder not found: $appPath" -ForegroundColor Red
        continue
    }
    
    # Install dependencies
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    Push-Location $appPath
    npm ci
    if ($LASTEXITCODE -ne 0) {
        Write-Host "npm ci failed" -ForegroundColor Red
        Pop-Location
        continue
    }
    
    # Build the app
    Write-Host "Building app..." -ForegroundColor Yellow
    npm run build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed" -ForegroundColor Red
        Pop-Location
        continue
    }
    
    Pop-Location
    
    # Deploy to Azure Static Web App
    Write-Host "Deploying to Azure..." -ForegroundColor Yellow
    $outputLoc = $app.OutputLocation
    
    az staticwebapp browse `
        --name $app.SWAName `
        --output-location $outputLoc `
        --api-location "" `
        --branch "main"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Deployed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Deployment failed" -ForegroundColor Red
    }
}

Write-Host "`n=== Deployment Complete ===" -ForegroundColor Cyan
