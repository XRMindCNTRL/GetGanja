# Azure Deployment Script for Cannabis Delivery Platform (PowerShell)
# This script deploys all applications to Azure App Service and Static Web Apps

Write-Host "🚀 Azure Deployment Script" -ForegroundColor Green
Write-Host "==========================" -ForegroundColor Green

# Check if Azure CLI is installed
try {
    $azVersion = az --version 2>$null
} catch {
    Write-Host "❌ Azure CLI is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

# Check if we're in the right directory
if (!(Test-Path "package.json") -or !(Test-Path "backend")) {
    Write-Host "❌ Error: Please run this script from the root directory of the cannabis-delivery-platform project" -ForegroundColor Red
    exit 1
}

# Set Azure subscription
az account set --subscription "2e0757c5-8619-4f8b-a484-4e12fe6ca133"

# Load configuration from azure-outputs.json if it exists
if (Test-Path "azure-outputs.json") {
    Write-Host "📋 Loading Azure configuration..." -ForegroundColor Cyan
    $config = Get-Content azure-outputs.json | ConvertFrom-Json
    $resourceGroup = $config.properties.outputs.resourceGroup.value
    $webappName = $config.properties.outputs.webAppName.value
    $webappUrl = $config.properties.outputs.webAppUrl.value
} else {
    Write-Host "⚠️  azure-outputs.json not found. Using default values..." -ForegroundColor Yellow
    $resourceGroup = "CannabisApp"
    $webappName = "cannabis-delivery-api"
    $webappUrl = "cannabis-delivery-api.azurewebsites.net"
}

if ([string]::IsNullOrEmpty($resourceGroup) -or [string]::IsNullOrEmpty($webappName)) {
    Write-Host "❌ Azure configuration not found. Please run setup-production.ps1 first." -ForegroundColor Red
    exit 1
}

Write-Host "📍 Deploying to Resource Group: $resourceGroup" -ForegroundColor Cyan
Write-Host "🌐 Web App: $webappName" -ForegroundColor Cyan

Write-Host "" -ForegroundColor White
Write-Host "🔧 Step 1: Backend Deployment" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

Set-Location backend

# Install dependencies
Write-Host "Installing backend dependencies..." -ForegroundColor Cyan
npm install

# Build the application (if build script exists)
if (Test-Path "package.json") {
    $packageJson = Get-Content "package.json" | ConvertFrom-Json
    if ($packageJson.scripts -and $packageJson.scripts.build) {
        Write-Host "Building backend application..." -ForegroundColor Cyan
        npm run build
    }
}

# Deploy to Azure App Service
Write-Host "Deploying backend to Azure App Service..." -ForegroundColor Cyan
az webapp up `
  --resource-group $resourceGroup `
  --name $webappName `
  --runtime "NODE:18-lts" `
  --os-type Linux `
  --location "southafricanorth"

Set-Location ..

Write-Host "" -ForegroundColor White
Write-Host "🎨 Step 2: Frontend Deployments" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

# Function to deploy static web app
function Deploy-FrontendApp {
    param (
        [string]$appName,
        [string]$appDir
    )

    Write-Host "Deploying $appName..." -ForegroundColor Cyan

    Set-Location $appDir

    # Install dependencies
    if (Test-Path "package.json") {
        npm install

        # Build the application
        $packageJson = Get-Content "package.json" | ConvertFrom-Json
        if ($packageJson.scripts -and $packageJson.scripts.build) {
            npm run build
        }
    }

    # Deploy to Azure Static Web Apps
    if ($appName -eq "customer-app") {
        $staticAppName = "GetGanja"
    } else {
        $staticAppName = "cannabis-$($appName -replace '_','-')"
    }
    Write-Host "Creating/updating Azure Static Web App: $staticAppName" -ForegroundColor Cyan

    # Check if static web app already exists
    $existingApp = az staticwebapp show --name $staticAppName --resource-group $resourceGroup 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Updating existing Static Web App..." -ForegroundColor Cyan
        az staticwebapp appsettings set `
          --name $staticAppName `
          --resource-group $resourceGroup `
          --setting REACT_APP_API_URL="https://$webappUrl" `
          --setting REACT_APP_NODE_ENV="production"
    } else {
        Write-Host "Creating new Static Web App..." -ForegroundColor Cyan
        az staticwebapp create `
          --name $staticAppName `
          --resource-group $resourceGroup `
          --location "southafricanorth" `
          --source . `
          --output-location "build" `
          --login-with-github false `
          --sku "Free"
    }

    Set-Location ..
}

# Deploy all frontend applications
Deploy-FrontendApp "customer-app" "apps/customer-app"
Deploy-FrontendApp "vendor-dashboard" "apps/vendor-dashboard"
Deploy-FrontendApp "driver-app" "apps/driver-app"
Deploy-FrontendApp "admin-panel" "apps/admin-panel"

Write-Host "" -ForegroundColor White
Write-Host "✅ Deployment Complete!" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green
Write-Host "" -ForegroundColor White
Write-Host "Your applications have been deployed to Azure:" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "🔗 Backend API: https://$webappUrl" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "🎨 Frontend Applications:" -ForegroundColor Cyan
Write-Host "• Customer App: Check Azure Portal → Static Web Apps" -ForegroundColor White
Write-Host "• Vendor Dashboard: Check Azure Portal → Static Web Apps" -ForegroundColor White
Write-Host "• Driver App: Check Azure Portal → Static Web Apps" -ForegroundColor White
Write-Host "• Admin Panel: Check Azure Portal → Static Web Apps" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "📊 Monitoring:" -ForegroundColor Cyan
Write-Host "• Application Insights: Configured automatically" -ForegroundColor White
Write-Host "• View logs: az webapp log tail --resource-group $resourceGroup --name $webappName" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "🔧 Useful Commands:" -ForegroundColor Cyan
Write-Host "• Check app status: az webapp show --resource-group $resourceGroup --name $webappName" -ForegroundColor White
Write-Host "• Restart backend: az webapp restart --resource-group $resourceGroup --name $webappName" -ForegroundColor White
Write-Host "• View static apps: az staticwebapp list --resource-group $resourceGroup" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Verify all applications are accessible" -ForegroundColor White
Write-Host "2. Set up custom domains if needed" -ForegroundColor White
Write-Host "3. Configure CDN for better performance" -ForegroundColor White
Write-Host "4. Set up monitoring alerts in Application Insights" -ForegroundColor White
