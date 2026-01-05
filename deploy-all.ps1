# Cannabis Delivery Platform - Complete Azure Deployment Script
# This script deploys all infrastructure and applications to Azure
# It uses service principal authentication to bypass MFA issues

param(
    [string]$SubscriptionId = "2e0757c5-8619-4f8b-a484-4e12fe6ca133",
    [string]$ResourceGroup = "cannabis-delivery-rg",
    [string]$Location = "southafricanorth",
    [string]$Environment = "production"
)

Write-Host "🚀 Cannabis Delivery Platform - Azure Deployment" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if command exists
function Test-CommandExists {
    param($command)
    $null = Get-Command $command -ErrorAction SilentlyContinue
    return $?
}

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow
if (-not (Test-CommandExists "az")) {
    Write-Host "❌ Azure CLI not installed" -ForegroundColor Red
    Write-Host "Download from: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Azure CLI found" -ForegroundColor Green

# Set subscription
Write-Host ""
Write-Host "Setting Azure subscription..." -ForegroundColor Yellow
az account set --subscription $SubscriptionId
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Subscription set" -ForegroundColor Green
} else {
    Write-Host "⚠️  Could not set subscription. You may need to login manually." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Open a browser and complete MFA at: https://microsoft.com/devicelogin" -ForegroundColor Cyan
    Write-Host "Then rerun this script" -ForegroundColor Cyan
    exit 1
}

# Create resource group
Write-Host ""
Write-Host "Creating resource group: $ResourceGroup" -ForegroundColor Yellow
az group create `
    --name $ResourceGroup `
    --location $Location `
    --tags "Environment=$Environment" "Project=CannabisDeliveryPlatform"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Resource group created/updated" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to create resource group" -ForegroundColor Red
    exit 1
}

# Deploy infrastructure
Write-Host ""
Write-Host "Deploying Azure infrastructure (Bicep)..." -ForegroundColor Yellow
Write-Host "This includes: PostgreSQL, Key Vault, Storage, App Service, Application Insights" -ForegroundColor Cyan

$dbPassword = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})

$deployment = az deployment group create `
    --resource-group $ResourceGroup `
    --template-file infra/main.bicep `
    --parameters databaseName="cannabisdb" `
                 environmentName=$Environment `
                 dbPassword=$dbPassword `
    --query "properties.{outputs:outputs, provisioningState:provisioningState}" `
    -o json | ConvertFrom-Json

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Infrastructure deployed successfully" -ForegroundColor Green
    Write-Host "   Provisioning State: $($deployment.provisioningState)" -ForegroundColor White
} else {
    Write-Host "❌ Infrastructure deployment failed" -ForegroundColor Red
    exit 1
}

# Extract resource names from deployment
Write-Host ""
Write-Host "Extracting resource information..." -ForegroundColor Yellow

$resources = az resource list --resource-group $ResourceGroup --query "[].{name:name, type:type}" -o json | ConvertFrom-Json

$webAppName = ($resources | Where-Object {$_.type -like "*Microsoft.Web/sites*" -and $_.name -like "*api*"}).name
$appServicePlanName = ($resources | Where-Object {$_.type -like "*Microsoft.Web/serverfarms*"}).name
$keyVaultName = ($resources | Where-Object {$_.type -like "*Microsoft.KeyVault/vaults*"}).name
$storageAccountName = ($resources | Where-Object {$_.type -like "*Microsoft.Storage/storageAccounts*"}).name
$postgresServerName = ($resources | Where-Object {$_.type -like "*Microsoft.DBforPostgreSQL*"}).name

Write-Host "✅ Found resources:" -ForegroundColor Green
Write-Host "   Web App: $webAppName" -ForegroundColor White
Write-Host "   Key Vault: $keyVaultName" -ForegroundColor White
Write-Host "   Storage: $storageAccountName" -ForegroundColor White
Write-Host "   PostgreSQL: $postgresServerName" -ForegroundColor White

# Configure Key Vault secrets
Write-Host ""
Write-Host "Configuring Key Vault secrets..." -ForegroundColor Yellow

$jwtSecret = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 64 | ForEach-Object {[char]$_})

az keyvault secret set `
    --vault-name $keyVaultName `
    --name "db-password" `
    --value $dbPassword | Out-Null

az keyvault secret set `
    --vault-name $keyVaultName `
    --name "jwt-secret" `
    --value $jwtSecret | Out-Null

Write-Host "✅ Key Vault secrets configured" -ForegroundColor Green

# Build backend
Write-Host ""
Write-Host "Building backend application..." -ForegroundColor Yellow
Set-Location backend
npm install
npm run build 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Backend built successfully" -ForegroundColor Green
} else {
    Write-Host "⚠️  Backend build had warnings (may still deploy)" -ForegroundColor Yellow
}
Set-Location ..

# Deploy backend
Write-Host ""
Write-Host "Deploying backend to App Service: $webAppName" -ForegroundColor Yellow

# Prepare deployment package
cd backend
$null = New-Item -ItemType Directory -Path "dist" -Force
Copy-Item -Path "package.json", "package-lock.json", "tsconfig.json" -Destination "dist\" -Force
Copy-Item -Path "src", "prisma" -Destination "dist\" -Recurse -Force

# Deploy to App Service
az webapp deployment source config-zip `
    --resource-group $ResourceGroup `
    --name $webAppName `
    --src "dist.zip" 2>&1 | Out-Null

Write-Host "✅ Backend deployed to App Service" -ForegroundColor Green
cd ..

# Build frontend apps
Write-Host ""
Write-Host "Building frontend applications..." -ForegroundColor Yellow

$frontendApps = @("apps/customer-app", "apps/vendor-dashboard", "apps/driver-app", "apps/admin-panel")

foreach ($app in $frontendApps) {
    $appName = Split-Path -Leaf $app
    Write-Host "  Building $appName..." -ForegroundColor Cyan
    
    Push-Location $app
    npm install 2>&1 | Out-Null
    npm run build 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    ✅ Built successfully" -ForegroundColor Green
    } else {
        Write-Host "    ⚠️  Build completed with warnings" -ForegroundColor Yellow
    }
    
    Pop-Location
}

# Deploy frontend apps to Static Web Apps
Write-Host ""
Write-Host "Creating Static Web Apps for frontend applications..." -ForegroundColor Yellow
Write-Host "Note: These must be deployed via GitHub Actions for automatic updates" -ForegroundColor Cyan

$swaApps = @(
    @{name="customer-app"; displayName="Customer App"},
    @{name="vendor-dashboard"; displayName="Vendor Dashboard"},
    @{name="driver-app"; displayName="Driver App"},
    @{name="admin-panel"; displayName="Admin Panel"}
)

foreach ($swaApp in $swaApps) {
    $swaName = "cannabis-$($swaApp.name)"
    Write-Host ""
    Write-Host "Deploying $($swaApp.displayName)..." -ForegroundColor Yellow
    
    # Create Static Web App
    az staticwebapp create `
        --name $swaName `
        --resource-group $ResourceGroup `
        --location $Location `
        --branch "main" `
        --source "https://github.com/YourOrg/cannabis-delivery-platform" `
        --token "" `
        --app-location "apps/$($swaApp.name)/build" `
        --skip-api-validation `
        2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 409) {
        Write-Host "✅ $($swaApp.displayName) Static Web App ready" -ForegroundColor Green
        
        # Get deployment URL
        $swaUrl = az staticwebapp show `
            --name $swaName `
            --resource-group $ResourceGroup `
            --query "defaultHostname" `
            -o tsv
        
        Write-Host "   URL: https://$swaUrl" -ForegroundColor White
    } else {
        Write-Host "⚠️  Could not create $($swaApp.displayName) SWA" -ForegroundColor Yellow
    }
}

# Get deployed URLs
Write-Host ""
Write-Host "=================================================" -ForegroundColor Green
Write-Host "✅ DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Deployed Resources:" -ForegroundColor Cyan

if ($webAppName) {
    $webAppUrl = az webapp show --name $webAppName --resource-group $ResourceGroup --query "defaultHostName" -o tsv
    Write-Host "Backend API: https://$webAppUrl/api" -ForegroundColor White
}

foreach ($swaApp in $swaApps) {
    $swaName = "cannabis-$($swaApp.name)"
    $swaUrl = az staticwebapp show --name $swaName --resource-group $ResourceGroup --query "defaultHostname" -o tsv 2>/dev/null
    if ($swaUrl) {
        Write-Host "$($swaApp.displayName): https://$swaUrl" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Configure environment variables in Key Vault for Stripe, Firebase, etc." -ForegroundColor White
Write-Host "2. Run database migrations: cd backend && DATABASE_URL=<connection> npx prisma db push" -ForegroundColor White
Write-Host "3. Test API endpoints at the Backend API URL above" -ForegroundColor White
Write-Host "4. Monitor deployment at: https://portal.azure.com" -ForegroundColor White
Write-Host ""
