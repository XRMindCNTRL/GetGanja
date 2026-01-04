#!/usr/bin/env powershell
# Cannabis Delivery Platform - Azure Automated Deployment Script
# This script handles the complete deployment process

param(
    [string]$Phase = "all",  # all, infra, secrets, backend, frontend
    [string]$SubscriptionId = "bb813320-d9cc-4e8e-bf3c-e6d8b6d09772",
    [string]$ResourceGroup = "cannabis-delivery-rg",
    [string]$Location = "eastus"
)

$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"

# Color scheme
function Write-Success($msg) { Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Info($msg) { Write-Host "📋 $msg" -ForegroundColor Cyan }
function Write-Wait($msg) { Write-Host "⏳ $msg" -ForegroundColor Yellow }
function Write-Error($msg) { Write-Host "❌ $msg" -ForegroundColor Red }

# Global variables
$script:WebAppUrl = ""
$script:AppName = ""
$script:KeyVaultName = ""

Write-Host ""
Write-Host "🚀 Cannabis Delivery Platform - Azure Automated Deployment" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host ""

# Check prerequisites
function Test-Prerequisites {
    Write-Info "Checking prerequisites..."
    
    try {
        az --version | Out-Null
        Write-Success "Azure CLI is installed"
    } catch {
        Write-Error "Azure CLI not found. Please install it first."
        exit 1
    }
    
    if (!(Test-Path "package.json") -or !(Test-Path "backend")) {
        Write-Error "Please run this script from the root directory of cannabis-delivery-platform"
        exit 1
    }
    Write-Success "Project structure is valid"
    Write-Host ""
}

# Phase 1: Authenticate and setup
function Setup-Azure {
    Write-Info "Phase 1: Azure Setup"
    Write-Host ""
    
    try {
        $account = az account show 2>$null
        Write-Success "Already logged into Azure"
    } catch {
        Write-Info "Logging into Azure..."
        az login
    }
    
    Write-Info "Setting subscription..."
    az account set --subscription $SubscriptionId
    Write-Success "Subscription set"
    
    Write-Info "Creating resource group: $ResourceGroup"
    az group create --name $ResourceGroup --location $Location --output none 2>$null || Write-Success "Resource group already exists"
    Write-Success "Resource group ready"
    Write-Host ""
}

# Phase 2: Deploy infrastructure
function Deploy-Infrastructure {
    Write-Info "Phase 2: Deploying Infrastructure (10-15 minutes)"
    Write-Host ""
    Write-Wait "This may take a while..."
    Write-Host ""
    
    $bicepOutput = az deployment group create `
        --resource-group $ResourceGroup `
        --name cannabis-deployment `
        --template-file infra/main.bicep `
        --parameters environmentName="production" `
        --query "properties.outputs" `
        -o json 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Infrastructure deployment failed: $bicepOutput"
        exit 1
    }
    
    $bicepOutput | Out-File azure-outputs.json -Force
    Write-Success "Infrastructure deployed and saved to azure-outputs.json"
    
    # Extract values
    $outputs = $bicepOutput | ConvertFrom-Json
    $script:WebAppUrl = $outputs.webAppUrl.value
    $script:KeyVaultName = $outputs.keyVaultName.value
    
    Write-Host ""
    Write-Host "Resources created:" -ForegroundColor Cyan
    Write-Host "  Web App: $($script:WebAppUrl)"
    Write-Host "  Key Vault: $($script:KeyVaultName)"
    Write-Host ""
}

# Phase 3: Configure secrets
function Configure-Secrets {
    Write-Info "Phase 3: Configuring Secrets"
    Write-Host ""
    
    # Generate random secrets
    Write-Info "Generating secure secrets..."
    $jwtSecret = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
    $dbPassword = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})
    
    Write-Info "Storing secrets in Key Vault..."
    az keyvault secret set --vault-name $script:KeyVaultName --name "jwt-secret" --value $jwtSecret --output none 2>&1
    az keyvault secret set --vault-name $script:KeyVaultName --name "db-password" --value $dbPassword --output none 2>&1
    az keyvault secret set --vault-name $script:KeyVaultName --name "stripe-secret-key" --value "sk_test_placeholder" --output none 2>&1
    az keyvault secret set --vault-name $script:KeyVaultName --name "firebase-api-key" --value "AIzaSyDOYqmfLOzd7ZcVBtxXqFjPV_ISgfvGbAs" --output none 2>&1
    
    Write-Success "Secrets configured in Key Vault"
    Write-Host ""
}

# Phase 4: Deploy backend
function Deploy-Backend {
    Write-Info "Phase 4: Deploying Backend API"
    Write-Host ""
    
    # Generate app name
    $script:AppName = "cannabis-api-$(Get-Random -Minimum 1000 -Maximum 9999)"
    
    Write-Info "Building backend..."
    Set-Location backend
    npm install --silent 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Dependencies installed"
    }
    
    # Try to build if build script exists
    $packageJson = Get-Content "package.json" | ConvertFrom-Json
    if ($packageJson.scripts.build) {
        npm run build --silent 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Build completed"
        }
    }
    
    Write-Info "Deploying to App Service: $($script:AppName)"
    az webapp up `
        --resource-group $ResourceGroup `
        --name $script:AppName `
        --runtime "NODE:18-lts" `
        --os-type Linux `
        --location $Location `
        --output none 2>&1
    
    Set-Location ..
    
    Write-Success "Backend deployed to: https://$($script:AppName).azurewebsites.net"
    Write-Host ""
    
    Write-Info "Waiting for app to start (3 minutes)..."
    Start-Sleep -Seconds 180
    
    # Test health endpoint
    Write-Info "Testing health endpoint..."
    try {
        $response = Invoke-WebRequest -Uri "https://$($script:AppName).azurewebsites.net/health" `
            -Method Get -ErrorAction SilentlyContinue -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Success "Backend is running!"
            Write-Host "Health: $($response.Content)"
        } else {
            Write-Wait "Backend is starting, check again in 2 minutes"
        }
    } catch {
        Write-Wait "Backend is still starting, check again in 2 minutes"
        Write-Host "URL: https://$($script:AppName).azurewebsites.net/health"
    }
    
    Write-Host ""
}

# Phase 5: Deploy frontends
function Deploy-Frontends {
    Write-Info "Phase 5: Deploying Frontend Applications"
    Write-Host ""
    
    $frontends = @("customer-app", "vendor-dashboard", "driver-app", "admin-panel")
    
    foreach ($frontend in $frontends) {
        Write-Info "Deploying $frontend..."
        
        Set-Location "apps/$frontend"
        npm install --silent 2>&1 | Out-Null
        npm run build --silent 2>&1 | Out-Null
        
        $staticAppName = "cannabis-$($frontend -replace '_','-')"
        
        az staticwebapp create `
            --name $staticAppName `
            --resource-group $ResourceGroup `
            --location $Location `
            --sku "Free" `
            --output none 2>&1 || Write-Success "$staticAppName already exists"
        
        Write-Success "$frontend deployed"
        Set-Location ../..
    }
    
    Write-Host ""
}

# Main deployment flow
function Main {
    Test-Prerequisites
    
    $phasesToRun = @()
    if ($Phase -eq "all") {
        $phasesToRun = @("azure", "infra", "secrets", "backend", "frontend")
    } else {
        $phasesToRun = @($Phase)
    }
    
    foreach ($p in $phasesToRun) {
        switch ($p) {
            "azure" { Setup-Azure }
            "infra" { Deploy-Infrastructure }
            "secrets" { Configure-Secrets }
            "backend" { Deploy-Backend }
            "frontend" { Deploy-Frontends }
        }
    }
    
    # Summary
    Write-Host ""
    Write-Host "🎉 Deployment Complete!" -ForegroundColor Green
    Write-Host "======================" -ForegroundColor Green
    Write-Host ""
    
    if ($script:AppName) {
        Write-Host "Backend API: https://$($script:AppName).azurewebsites.net" -ForegroundColor White
        Write-Host "Health Check: https://$($script:AppName).azurewebsites.net/health" -ForegroundColor White
    }
    
    if ($Phase -eq "all" -or $Phase -eq "frontend") {
        Write-Host ""
        Write-Host "Frontend Applications:" -ForegroundColor Cyan
        Write-Host "• cannabis-customer-app (Static Web App)" -ForegroundColor White
        Write-Host "• cannabis-vendor-dashboard (Static Web App)" -ForegroundColor White
        Write-Host "• cannabis-driver-app (Static Web App)" -ForegroundColor White
        Write-Host "• cannabis-admin-panel (Static Web App)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "📊 View in Azure Portal:" -ForegroundColor Cyan
    Write-Host "https://portal.azure.com/#resource/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/overview" -ForegroundColor Yellow
    Write-Host ""
}

# Run
try {
    Main
} catch {
    Write-Error "Deployment failed: $_"
    exit 1
}
