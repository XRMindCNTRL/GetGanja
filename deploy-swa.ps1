# Simple Azure Static Web App Deployment
# Run this script to build and deploy each app

param(
    [string]$AppName = "all",
    [string]$SubscriptionId = ""
)

$ErrorActionPreference = "Stop"

# Azure Static Web Apps configuration - use YOUR actual SWA names
$swaConfigs = @{
    "customer-app" = @{
        AppFolder = "apps/customer-app"
        SWAName = "GetGanja"
    }
    "vendor-dashboard" = @{
        AppFolder = "apps/vendor-dashboard"
        SWAName = "cannabis-vendor-dashboard"
    }
    "driver-app" = @{
        AppFolder = "apps/driver-app"
        SWAName = "driver-app"
    }
    "admin-panel" = @{
        AppFolder = "apps/admin-panel"
        SWAName = "admin-app"
    }
}

$rootDir = "C:\Users\pc\Desktop\cannabis-delivery-platform"

# Login to Azure
Write-Host "Logging into Azure..." -ForegroundColor Cyan
if ($SubscriptionId) {
    az account set --subscription $SubscriptionId
} else {
    az login
}

# Get deployment token for a specific SWA
function Get-DeploymentToken {
    param([string]$SwaName)
    
    $token = az staticwebapp show `
        --name $SwaName `
        --query "properties.repositoryToken" `
        -o tsv 2>$null
    
    if (-not $token) {
        # Try to get the production token
        $token = az staticwebapp show `
            --name $SwaName `
            --query "properties.productionDeploymentToken" `
            -o tsv 2>$null
    }
    
    return $token
}

# Deploy a single app
function Deploy-App {
    param([string]$AppKey, [string]$Config)
    
    $appFolder = $Config.AppFolder
    $swaName = $Config.SWAName
    
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "Deploying: $AppKey -> $swaName" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    
    # Build the app
    $appPath = Join-Path $rootDir $appFolder
    Write-Host "Building app at: $appPath" -ForegroundColor Yellow
    
    Push-Location $appPath
    
    # Install dependencies
    Write-Host "Installing npm packages..." -ForegroundColor Yellow
    npm ci
    
    # Build
    Write-Host "Building React app..." -ForegroundColor Yellow
    npm run build
    
    Pop-Location
    
    # Get deployment token
    Write-Host "Getting deployment token..." -ForegroundColor Yellow
    $token = Get-DeploymentToken -SwaName $swaName
    
    if (-not $token) {
        Write-Host "ERROR: Could not get deployment token for $swaName" -ForegroundColor Red
        Write-Host "Make sure the Static Web App exists and you have access" -ForegroundColor Red
        return $false
    }
    
    # Deploy using Oryx build
    Write-Host "Deploying to Azure..." -ForegroundColor Yellow
    $buildPath = Join-Path $appPath "build"
    
    az staticwebapp up `
        --name $swaName `
        --source $buildPath `
        --token $token `
        --api-location ""
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: $AppKey deployed!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "FAILED: $AppKey deployment failed" -ForegroundColor Red
        return $false
    }
}

# Main
if ($AppName -eq "all") {
    Write-Host "Deploying ALL apps..." -ForegroundColor Cyan
    foreach ($key in $swaConfigs.Keys) {
        $config = $swaConfigs[$key]
        Deploy-App -AppKey $key -Config $config
    }
} else {
    if ($swaConfigs.ContainsKey($AppName)) {
        $config = $swaConfigs[$AppName]
        Deploy-App -AppKey $AppName -Config $config
    } else {
        Write-Host "Unknown app: $AppName" -ForegroundColor Red
        Write-Host "Available apps: $($swaConfigs.Keys -join ', ')" -ForegroundColor Yellow
    }
}

Write-Host "`nDone!" -ForegroundColor Cyan
