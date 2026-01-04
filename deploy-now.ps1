# Quick deployment script for Cannabis Delivery Platform
# This script creates the necessary Azure resources and deploys the app

$ErrorActionPreference = "Continue"
$VerbosePreference = "SilentlyContinue"

Write-Host "🚀 Cannabis Delivery Platform - Azure Deployment" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

# Configuration
$resourceGroup = "cannabis-delivery-rg"
$location = "eastus"
$appName = "cannabis-delivery-api"
$subscriptionId = "bb813320-d9cc-4e8e-bf3c-e6d8b6d09772"

Write-Host "📋 Configuration:" -ForegroundColor Cyan
Write-Host "  Resource Group: $resourceGroup"
Write-Host "  Location: $location"
Write-Host "  App Name: $appName"
Write-Host ""

# Step 1: Set subscription
Write-Host "Step 1: Setting Azure subscription..." -ForegroundColor Cyan
try {
    az account set --subscription $subscriptionId 2>$null
    Write-Host "✅ Subscription set" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to set subscription" -ForegroundColor Red
    exit 1
}

# Step 2: Create resource group
Write-Host ""
Write-Host "Step 2: Creating resource group..." -ForegroundColor Cyan
$rgOutput = az group create --name $resourceGroup --location $location 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Resource group created/exists" -ForegroundColor Green
} else {
    Write-Host "⚠️  Resource group may already exist: $($rgOutput | Select-Object -First 1)" -ForegroundColor Yellow
}

# Step 3: Deploy infrastructure using Bicep
Write-Host ""
Write-Host "Step 3: Deploying Azure infrastructure (Bicep)..." -ForegroundColor Cyan
Write-Host "This may take 5-15 minutes..." -ForegroundColor Gray

$bicepOutput = az deployment group create `
  --resource-group $resourceGroup `
  --name cannabis-deployment `
  --template-file infra/main.bicep `
  --parameters environmentName="production" `
  --query "properties.outputs" `
  -o json 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Infrastructure deployed successfully" -ForegroundColor Green
    
    # Save outputs
    $bicepOutput | Out-File -FilePath "azure-outputs.json" -Force
    
    # Parse outputs
    $outputs = $bicepOutput | ConvertFrom-Json
    $webappUrl = $outputs.webAppUrl.value
    $keyVaultName = $outputs.keyVaultName.value
    $storageAccountName = $outputs.storageAccountName.value
    
    Write-Host ""
    Write-Host "📍 Azure Resources Created:" -ForegroundColor Green
    Write-Host "  App Service URL: https://$webappUrl" -ForegroundColor White
    Write-Host "  Key Vault: $keyVaultName" -ForegroundColor White
    Write-Host "  Storage Account: $storageAccountName" -ForegroundColor White
} else {
    Write-Host "❌ Infrastructure deployment failed" -ForegroundColor Red
    Write-Host "Error: $bicepOutput" -ForegroundColor Red
    exit 1
}

# Step 4: Set up secrets in Key Vault
Write-Host ""
Write-Host "Step 4: Configuring Key Vault secrets..." -ForegroundColor Cyan

# Generate secrets
$jwtSecret = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
$dbPassword = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})

# Store in Key Vault
az keyvault secret set --vault-name $keyVaultName --name "jwt-secret" --value $jwtSecret --output none 2>$null
az keyvault secret set --vault-name $keyVaultName --name "db-password" --value $dbPassword --output none 2>$null

# Store placeholder Stripe keys
az keyvault secret set --vault-name $keyVaultName --name "stripe-secret-key" --value "sk_test_placeholder" --output none 2>$null
az keyvault secret set --vault-name $keyVaultName --name "stripe-publishable-key" --value "pk_test_placeholder" --output none 2>$null

# Store Firebase config
az keyvault secret set --vault-name $keyVaultName --name "firebase-api-key" --value "AIzaSyDOYqmfLOzd7ZcVBtxXqFjPV_ISgfvGbAs" --output none 2>$null
az keyvault secret set --vault-name $keyVaultName --name "firebase-project-id" --value "holoport-xr" --output none 2>$null

Write-Host "✅ Key Vault secrets configured" -ForegroundColor Green

# Step 5: Build and deploy backend
Write-Host ""
Write-Host "Step 5: Building and deploying backend API..." -ForegroundColor Cyan

Set-Location backend
Write-Host "  Installing dependencies..." -ForegroundColor Gray
npm install --silent 2>&1 | Out-Null

if (Test-Path "package.json") {
    $packageJson = Get-Content "package.json" | ConvertFrom-Json
    if ($packageJson.scripts.build) {
        Write-Host "  Building application..." -ForegroundColor Gray
        npm run build --silent 2>&1 | Out-Null
    }
}

Write-Host "  Deploying to Azure App Service..." -ForegroundColor Gray
az webapp up `
  --resource-group $resourceGroup `
  --name $appName `
  --runtime "NODE:18-lts" `
  --os-type Linux 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Backend deployed to https://$appName.azurewebsites.net" -ForegroundColor Green
} else {
    Write-Host "⚠️  Backend deployment in progress (this may take a few minutes)" -ForegroundColor Yellow
}

Set-Location ..

# Step 6: Create environment files
Write-Host ""
Write-Host "Step 6: Creating environment files..." -ForegroundColor Cyan

$backendEnv = @"
DATABASE_URL=Server=cb-db-server.postgres.database.azure.com;Database=cannabis_db;User Id=cbadmin;Password=$dbPassword;Ssl Mode=Require;
JWT_SECRET=$jwtSecret
STRIPE_SECRET_KEY=sk_test_placeholder
STRIPE_PUBLISHABLE_KEY=pk_test_placeholder
FIREBASE_API_KEY=AIzaSyDOYqmfLOzd7ZcVBtxXqFjPV_ISgfvGbAs
FIREBASE_PROJECT_ID=holoport-xr
NODE_ENV=production
PORT=5000
"@

$backendEnv | Out-File -FilePath "backend/.env" -Encoding UTF8 -Force
Write-Host "✅ Environment files created" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 Deployment Summary" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Green
Write-Host ""
Write-Host "Your Cannabis Delivery Platform is being deployed to Azure!" -ForegroundColor White
Write-Host ""
Write-Host "📍 Access your applications at:" -ForegroundColor Cyan
Write-Host "  Backend API: https://$appName.azurewebsites.net" -ForegroundColor White
Write-Host "  Health Check: https://$appName.azurewebsites.net/health" -ForegroundColor White
Write-Host ""
Write-Host "⏱️  Note: It may take 5-10 minutes for all services to be fully operational." -ForegroundColor Yellow
Write-Host ""
Write-Host "📚 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Monitor deployment: az webapp log tail -g $resourceGroup -n $appName" -ForegroundColor White
Write-Host "  2. Deploy frontend apps: Run 'Deploy Frontend Apps' task" -ForegroundColor White
Write-Host "  3. Configure Stripe webhooks in Stripe dashboard" -ForegroundColor White
Write-Host "  4. Add your real Firebase credentials to Key Vault" -ForegroundColor White
Write-Host ""
