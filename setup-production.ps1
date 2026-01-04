# Cannabis Delivery Platform - Azure App Service Production Setup Script (PowerShell)
# Run this script to set up your production environment on Azure

Write-Host "Setting up Cannabis Delivery Platform for Azure Production" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green

# Check if we're in the right directory
if (!(Test-Path "package.json") -or !(Test-Path "backend")) {
    Write-Host "Error: Please run this script from the root directory of the cannabis-delivery-platform project" -ForegroundColor Red
    exit 1
}

# Check if Azure CLI is installed
try {
    $azVersion = az --version 2>$null
} catch {
    Write-Host "Azure CLI is not installed. Please install it first:" -ForegroundColor Red
    Write-Host "   Windows: winget install -e --id Microsoft.AzureCLI" -ForegroundColor Yellow
    Write-Host "   Download: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    exit 1
}

Write-Host "Step 1: Azure Authentication" -ForegroundColor Cyan
Write-Host "Login to Azure CLI:"
az login --use-device-code

# Get subscription info
Write-Host "Available subscriptions:" -ForegroundColor Cyan
az account list --query "[].{name:name, id:id}" -o table

$subscriptionId = "2e0757c5-8619-4f8b-a484-4e12fe6ca133"
az account set --subscription $subscriptionId

# Create resource group
$resourceGroup = "CannabisApp"
$location = "southafricanorth"


Write-Host "Creating resource group: $resourceGroup in $location" -ForegroundColor Cyan
az group create --name $resourceGroup --location $location

Write-Host "Step 2: Azure Resources Setup" -ForegroundColor Cyan
Write-Host "Deploying Azure infrastructure using Bicep template..."

# Deploy Azure resources
az deployment group create `
  --resource-group $resourceGroup `
  --template-file infra/main.bicep `
  --parameters environmentName="production" `
  --query "properties.outputs" `
  -o json > azure-outputs.json

# Extract outputs
$webappUrl = (Get-Content azure-outputs.json | ConvertFrom-Json).properties.outputs.webAppUrl.value
$databaseConnection = (Get-Content azure-outputs.json | ConvertFrom-Json).properties.outputs.databaseConnectionString.value
$keyvaultName = (Get-Content azure-outputs.json | ConvertFrom-Json).properties.outputs.keyVaultName.value
$storageAccount = (Get-Content azure-outputs.json | ConvertFrom-Json).properties.outputs.storageAccountName.value

Write-Host "Azure resources deployed successfully!" -ForegroundColor Green
Write-Host "   Web App URL: https://$webappUrl" -ForegroundColor White
Write-Host "   Key Vault: $keyvaultName" -ForegroundColor White
Write-Host "   Storage Account: $storageAccount" -ForegroundColor White

Write-Host "" -ForegroundColor White
Write-Host "Step 3: Azure Key Vault Secrets Setup" -ForegroundColor Cyan
Write-Host "Setting up secrets in Key Vault..."

# Generate secrets
$jwtSecret = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
$dbPassword = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})

# Store secrets in Key Vault
az keyvault secret set --vault-name $keyvaultName --name "jwt-secret" --value $jwtSecret
az keyvault secret set --vault-name $keyvaultName --name "db-password" --value $dbPassword

# Get storage connection string
$storageConnection = az storage account show-connection-string --name $storageAccount --resource-group $resourceGroup --query connectionString -o tsv
az keyvault secret set --vault-name $keyvaultName --name "storage-connection-string" --value $storageConnection

Write-Host "✅ Key Vault secrets configured" -ForegroundColor Green

Write-Host "" -ForegroundColor White
Write-Host "Step 4: Stripe Setup" -ForegroundColor Cyan
Write-Host "1. Go to https://dashboard.stripe.com" -ForegroundColor Yellow
Write-Host "2. Get your Secret Key and Publishable Key" -ForegroundColor Yellow
$stripeSecret = "sk_test_placeholder_stripe_secret_key"
$stripePublishable = "pk_test_placeholder_stripe_publishable_key"

# Store Stripe secrets
az keyvault secret set --vault-name $keyvaultName --name "stripe-secret-key" --value $stripeSecret
az keyvault secret set --vault-name $keyvaultName --name "stripe-publishable-key" --value $stripePublishable

Write-Host "" -ForegroundColor White
Write-Host "🔥 Step 5: Firebase Setup" -ForegroundColor Cyan
Write-Host "Configuring Firebase for push notifications..." -ForegroundColor White

# Set Firebase values from user-provided config
$firebaseApiKey = "AIzaSyDOYqmfLOzd7ZcVBtxXqFjPV_ISgfvGbAs"
$firebaseAuthDomain = "holoport-xr.firebaseapp.com"
$firebaseProjectId = "holoport-xr"
$firebaseStorageBucket = "holoport-xr.firebasestorage.app"
$firebaseMessagingSenderId = "472505634059"
$firebaseAppId = "1:472505634059:web:b66401166baf08442c260e"
$firebaseVapidKey = "placeholder-vapid-key"  # TODO: Get from Firebase console for push notifications

# Store placeholder Firebase secrets
az keyvault secret set --vault-name $keyvaultName --name "firebase-api-key" --value $firebaseApiKey
az keyvault secret set --vault-name $keyvaultName --name "firebase-auth-domain" --value $firebaseAuthDomain
az keyvault secret set --vault-name $keyvaultName --name "firebase-project-id" --value $firebaseProjectId
az keyvault secret set --vault-name $keyvaultName --name "firebase-storage-bucket" --value $firebaseStorageBucket
az keyvault secret set --vault-name $keyvaultName --name "firebase-messaging-sender-id" --value $firebaseMessagingSenderId
az keyvault secret set --vault-name $keyvaultName --name "firebase-app-id" --value $firebaseAppId
az keyvault secret set --vault-name $keyvaultName --name "firebase-vapid-key" --value $firebaseVapidKey

Write-Host "" -ForegroundColor White
Write-Host "Step 6: Database Setup" -ForegroundColor Cyan
Write-Host "Setting up PostgreSQL database..."

# Create database connection string with password
$fullDbConnection = $databaseConnection -replace "db-password", $dbPassword
az keyvault secret set --vault-name $keyvaultName --name "db-connection-string" --value $fullDbConnection

# Run database migrations
Write-Host "Running database migrations..." -ForegroundColor Cyan
Set-Location backend
if (Get-Command npx -ErrorAction SilentlyContinue) {
    npx prisma generate
    $env:DATABASE_URL = $fullDbConnection
    npx prisma db push
    Write-Host "Database schema deployed" -ForegroundColor Green
} else {
    Write-Host "npx not found. Please run these commands manually:" -ForegroundColor Yellow
    Write-Host "   cd backend; npx prisma generate; `$env:DATABASE_URL = `"$fullDbConnection`"; npx prisma db push" -ForegroundColor Yellow
}
Set-Location ..

Write-Host "" -ForegroundColor White
Write-Host "Creating local environment files for development..." -ForegroundColor Cyan

# Create .env file for backend (local development)
$backendEnv = @'
# Database
DATABASE_URL='$fullDbConnection'

# Authentication
JWT_SECRET='$jwtSecret'
JWT_EXPIRES_IN=7d
BCRYPT_ROUNDS=12

# Stripe Payments
STRIPE_SECRET_KEY='$stripeSecret'
STRIPE_PUBLISHABLE_KEY='$stripePublishable'
STRIPE_WEBHOOK_SECRET=whsec_...

# Firebase Configuration
FIREBASE_API_KEY='$firebaseApiKey'
FIREBASE_AUTH_DOMAIN='$firebaseAuthDomain'
FIREBASE_PROJECT_ID='$firebaseProjectId'
FIREBASE_STORAGE_BUCKET='$firebaseStorageBucket'
FIREBASE_MESSAGING_SENDER_ID='$firebaseMessagingSenderId'
FIREBASE_APP_ID='$firebaseAppId'
FIREBASE_VAPID_KEY='$firebaseVapidKey'

# CORS Configuration
FRONTEND_URL=https://'$webappUrl'
VENDOR_URL=https://'$webappUrl'
DRIVER_URL=https://'$webappUrl'
ADMIN_URL=https://'$webappUrl'

# Application Settings
NODE_ENV=production
PORT=5000
'@

$backendEnv | Out-File -FilePath "backend/.env" -Encoding UTF8
Write-Host "Backend .env file created" -ForegroundColor Green


# Create environment files for frontend apps
$frontendEnv = @'
REACT_APP_API_URL=https://'$webappUrl'
REACT_APP_STRIPE_PUBLISHABLE_KEY='$stripePublishable'
REACT_APP_FIREBASE_API_KEY='$firebaseApiKey'
REACT_APP_FIREBASE_AUTH_DOMAIN='$firebaseAuthDomain'
REACT_APP_FIREBASE_PROJECT_ID='$firebaseProjectId'
REACT_APP_FIREBASE_STORAGE_BUCKET='$firebaseStorageBucket'
REACT_APP_FIREBASE_MESSAGING_SENDER_ID='$firebaseMessagingSenderId'
REACT_APP_FIREBASE_APP_ID='$firebaseAppId'
REACT_APP_FIREBASE_VAPID_KEY='$firebaseVapidKey'
'@

$frontendEnv | Out-File -FilePath "apps/customer-app/.env" -Encoding UTF8
Write-Host "Customer App .env file created" -ForegroundColor Green


# Create minimal .env files for other apps
"REACT_APP_API_URL=https://$webappUrl" | Out-File -FilePath "apps/vendor-dashboard/.env" -Encoding UTF8
"REACT_APP_API_URL=https://$webappUrl" | Out-File -FilePath "apps/driver-app/.env" -Encoding UTF8
"REACT_APP_API_URL=https://$webappUrl" | Out-File -FilePath "apps/admin-panel/.env" -Encoding UTF8

Write-Host "All .env files created" -ForegroundColor Green

Write-Host "" -ForegroundColor White
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green
Write-Host "" -ForegroundColor White
Write-Host "Your Azure infrastructure is ready!" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Run the deployment script: .\deploy-azure.ps1" -ForegroundColor White
Write-Host "2. Configure Stripe webhooks" -ForegroundColor White
Write-Host "3. Set up custom domain (optional)" -ForegroundColor White
Write-Host "4. Test your applications" -ForegroundColor White
