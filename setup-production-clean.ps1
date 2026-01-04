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
az deployment group create --resource-group $resourceGroup --template-file infra/main.bicep --parameters environmentName="production" --query "properties.outputs" -o json > azure-outputs.json

# Extract outputs
$webappUrl = (Get-Content azure-outputs.json | ConvertFrom-Json).properties.outputs.webAppUrl.value
$databaseConnection = (Get-Content azure-outputs.json | ConvertFrom-Json).properties.outputs.databaseConnectionString.value
$keyvaultName = (Get-Content azure-outputs.json | ConvertFrom-Json).properties.outputs.keyVaultName.value
$storageAccount = (Get-Content azure-outputs.json | ConvertFrom-Json).properties.outputs.storageAccountName.value

Write-Host "Web App URL: $webappUrl" -ForegroundColor Green
Write-Host "Key Vault: $keyvaultName" -ForegroundColor Green
Write-Host "Storage Account: $storageAccount" -ForegroundColor Green

Write-Host "Step 3: Environment Variables Setup" -ForegroundColor Cyan

# Generate secure secrets
$jwtSecret = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([System.Guid]::NewGuid().ToString() + [System.Guid]::NewGuid().ToString()))
$databasePassword = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([System.Guid]::NewGuid().ToString()))

# Store secrets in Key Vault
az keyvault secret set --vault-name $keyvaultName --name "jwt-secret" --value $jwtSecret
az keyvault secret set --vault-name $keyvaultName --name "database-password" --value $databasePassword

# Prompt for external service credentials
$stripeSecret = Read-Host "Enter your Stripe Secret Key"
$stripePublishable = Read-Host "Enter your Stripe Publishable Key"
$firebaseApiKey = Read-Host "Enter your Firebase API Key"
$firebaseAuthDomain = Read-Host "Enter your Firebase Auth Domain"
$firebaseProjectId = Read-Host "Enter your Firebase Project ID"
$firebaseStorageBucket = Read-Host "Enter your Firebase Storage Bucket"
$firebaseMessagingSenderId = Read-Host "Enter your Firebase Messaging Sender ID"
$firebaseAppId = Read-Host "Enter your Firebase App ID"
$firebaseVapidKey = Read-Host "Enter your Firebase VAPID Key"

# Store external secrets
az keyvault secret set --vault-name $keyvaultName --name "stripe-secret-key" --value $stripeSecret
az keyvault secret set --vault-name $keyvaultName --name "stripe-publishable-key" --value $stripePublishable
az keyvault secret set --vault-name $keyvaultName --name "firebase-api-key" --value $firebaseApiKey
az keyvault secret set --vault-name $keyvaultName --name "firebase-auth-domain" --value $firebaseAuthDomain
az keyvault secret set --vault-name $keyvaultName --name "firebase-project-id" --value $firebaseProjectId
az keyvault secret set --vault-name $keyvaultName --name "firebase-storage-bucket" --value $firebaseStorageBucket
az keyvault secret set --vault-name $keyvaultName --name "firebase-messaging-sender-id" --value $firebaseMessagingSenderId
az keyvault secret set --vault-name $keyvaultName --name "firebase-app-id" --value $firebaseAppId
az keyvault secret set --vault-name $keyvaultName --name "firebase-vapid-key" --value $firebaseVapidKey

# Create environment files
$backendEnv = @"
JWT_SECRET=$jwtSecret
DATABASE_URL=$databaseConnection
STRIPE_SECRET_KEY=$stripeSecret
STRIPE_PUBLISHABLE_KEY=$stripePublishable
FIREBASE_API_KEY=$firebaseApiKey
FIREBASE_AUTH_DOMAIN=$firebaseAuthDomain
FIREBASE_PROJECT_ID=$firebaseProjectId
FIREBASE_STORAGE_BUCKET=$firebaseStorageBucket
FIREBASE_MESSAGING_SENDER_ID=$firebaseMessagingSenderId
FIREBASE_APP_ID=$firebaseAppId
FIREBASE_VAPID_KEY=$firebaseVapidKey
AZURE_STORAGE_CONNECTION_STRING=$storageAccount
FRONTEND_URL=https://$webappUrl
VENDOR_URL=https://$webappUrl
DRIVER_URL=https://$webappUrl
ADMIN_URL=https://$webappUrl
NODE_ENV=production
PORT=5000
"@

$backendEnv | Out-File -FilePath "backend/.env" -Encoding UTF8
Write-Host "Backend .env file created" -ForegroundColor Green

# Create environment files for frontend apps
$frontendEnv = @"
REACT_APP_API_URL=https://$webappUrl
REACT_APP_STRIPE_PUBLISHABLE_KEY=$stripePublishable
REACT_APP_FIREBASE_API_KEY=$firebaseApiKey
REACT_APP_FIREBASE_AUTH_DOMAIN=$firebaseAuthDomain
REACT_APP_FIREBASE_PROJECT_ID=$firebaseProjectId
REACT_APP_FIREBASE_STORAGE_BUCKET=$firebaseStorageBucket
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=$firebaseMessagingSenderId
REACT_APP_FIREBASE_APP_ID=$firebaseAppId
REACT_APP_FIREBASE_VAPID_KEY=$firebaseVapidKey
"@

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
Write-Host "1. Run the deployment script: .\deploy-azure-clean.ps1" -ForegroundColor White
Write-Host "2. Configure Stripe webhooks" -ForegroundColor White
Write-Host "3. Set up custom domain (optional)" -ForegroundColor White
Write-Host "4. Test your applications" -ForegroundColor White
