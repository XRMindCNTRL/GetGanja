#!/bin/bash

# Cannabis Delivery Platform - Azure App Service Production Setup Script
# Run this script to set up your production environment on Azure

echo "🚀 Setting up Cannabis Delivery Platform for Azure Production"
echo "============================================================"

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -d "backend" ]; then
    echo "❌ Error: Please run this script from the root directory of the cannabis-delivery-platform project"
    exit 1
fi

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first:"
    echo "   Windows: winget install -e --id Microsoft.AzureCLI"
    echo "   macOS: brew install azure-cli"
    echo "   Linux: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    exit 1
fi

echo "🔐 Step 1: Azure Authentication"
echo "Login to Azure CLI:"
az login --use-device-code

# Get subscription info
echo "📋 Available subscriptions:"
az account list --query "[].{name:name, id:id}" -o table
read -p "Enter your Azure Subscription ID: " subscription_id
az account set --subscription $subscription_id

# Create resource group
read -p "Enter resource group name (e.g., cannabis-delivery-rg): " resource_group
read -p "Enter Azure region (e.g., eastus, westus2): " location

echo "📍 Creating resource group: $resource_group in $location"
az group create --name $resource_group --location $location

echo "🔑 Step 2: Azure Resources Setup"
echo "Deploying Azure infrastructure using Bicep template..."

# Deploy Azure resources
az deployment group create \
  --resource-group $resource_group \
  --template-file infra/main.bicep \
  --parameters environmentName="production" \
  --query "properties.outputs" \
  -o json > azure-outputs.json

# Extract outputs
webapp_url=$(cat azure-outputs.json | jq -r '.webAppUrl.value')
database_connection=$(cat azure-outputs.json | jq -r '.databaseConnectionString.value')
keyvault_name=$(cat azure-outputs.json | jq -r '.keyVaultName.value')
storage_account=$(cat azure-outputs.json | jq -r '.storageAccountName.value')

echo "✅ Azure resources deployed successfully!"
echo "   Web App URL: https://$webapp_url"
echo "   Key Vault: $keyvault_name"
echo "   Storage Account: $storage_account"

echo ""
echo "🔑 Step 3: Azure Key Vault Secrets Setup"
echo "Setting up secrets in Key Vault..."

# Generate secrets
jwt_secret=$(openssl rand -base64 32)
db_password=$(openssl rand -base64 16)

# Store secrets in Key Vault
az keyvault secret set --vault-name $keyvault_name --name "jwt-secret" --value "$jwt_secret"
az keyvault secret set --vault-name $keyvault_name --name "db-password" --value "$db_password"

# Get storage connection string
storage_connection=$(az storage account show-connection-string --name $storage_account --resource-group $resource_group --query connectionString -o tsv)
az keyvault secret set --vault-name $keyvault_name --name "storage-connection-string" --value "$storage_connection"

echo "✅ Key Vault secrets configured"

echo ""
echo "📧 Step 4: Stripe Setup"
echo "1. Go to https://dashboard.stripe.com"
echo "2. Get your Secret Key and Publishable Key"
read -p "Enter your STRIPE_SECRET_KEY: " stripe_secret
read -p "Enter your STRIPE_PUBLISHABLE_KEY: " stripe_publishable

# Store Stripe secrets
az keyvault secret set --vault-name $keyvault_name --name "stripe-secret-key" --value "$stripe_secret"
az keyvault secret set --vault-name $keyvault_name --name "stripe-publishable-key" --value "$stripe_publishable"

echo ""
echo "🔥 Step 5: Firebase Setup"
echo "1. Go to https://console.firebase.google.com"
echo "2. Create/select project → Project Settings → General → Your apps"
echo "3. Copy Firebase config values:"
read -p "FIREBASE_API_KEY: " firebase_api_key
read -p "FIREBASE_AUTH_DOMAIN: " firebase_auth_domain
read -p "FIREBASE_PROJECT_ID: " firebase_project_id
read -p "FIREBASE_STORAGE_BUCKET: " firebase_storage_bucket
read -p "FIREBASE_MESSAGING_SENDER_ID: " firebase_messaging_sender_id
read -p "FIREBASE_APP_ID: " firebase_app_id
read -p "FIREBASE_VAPID_KEY: " firebase_vapid_key

# Store Firebase secrets
az keyvault secret set --vault-name $keyvault_name --name "firebase-api-key" --value "$firebase_api_key"
az keyvault secret set --vault-name $keyvault_name --name "firebase-auth-domain" --value "$firebase_auth_domain"
az keyvault secret set --vault-name $keyvault_name --name "firebase-project-id" --value "$firebase_project_id"
az keyvault secret set --vault-name $keyvault_name --name "firebase-storage-bucket" --value "$firebase_storage_bucket"
az keyvault secret set --vault-name $keyvault_name --name "firebase-messaging-sender-id" --value "$firebase_messaging_sender_id"
az keyvault secret set --vault-name $keyvault_name --name "firebase-app-id" --value "$firebase_app_id"
az keyvault secret set --vault-name $keyvault_name --name "firebase-vapid-key" --value "$firebase_vapid_key"

echo ""
echo "🗄️ Step 6: Database Setup"
echo "Setting up PostgreSQL database..."

# Create database connection string with password
full_db_connection="${database_connection/db-password/$db_password}"
az keyvault secret set --vault-name $keyvault_name --name "db-connection-string" --value "$full_db_connection"

# Run database migrations
echo "Running database migrations..."
cd backend
if command -v npx &> /dev/null; then
    npx prisma generate
    DATABASE_URL="$full_db_connection" npx prisma db push
    echo "✅ Database schema deployed"
else
    echo "⚠️  npx not found. Please run these commands manually:"
    echo "   cd backend && npx prisma generate && DATABASE_URL='$full_db_connection' npx prisma db push"
fi
cd ..

echo ""
echo "📝 Creating local environment files for development..."

# Create .env file for backend (local development)
cat > backend/.env << EOF
# Database
DATABASE_URL="$full_db_connection"

# Authentication
JWT_SECRET="$jwt_secret"
JWT_EXPIRES_IN=7d
BCRYPT_ROUNDS=12

# Stripe Payments
STRIPE_SECRET_KEY="$stripe_secret"
STRIPE_PUBLISHABLE_KEY="$stripe_publishable"
STRIPE_WEBHOOK_SECRET="whsec_..."

# Firebase Configuration
FIREBASE_API_KEY="$firebase_api_key"
FIREBASE_AUTH_DOMAIN="$firebase_auth_domain"
FIREBASE_PROJECT_ID="$firebase_project_id"
FIREBASE_STORAGE_BUCKET="$firebase_storage_bucket"
FIREBASE_MESSAGING_SENDER_ID="$firebase_messaging_sender_id"
FIREBASE_APP_ID="$firebase_app_id"
FIREBASE_VAPID_KEY="$firebase_vapid_key"

# CORS Configuration
FRONTEND_URL="https://$webapp_url"
VENDOR_URL="https://$webapp_url"
DRIVER_URL="https://$webapp_url"
ADMIN_URL="https://$webapp_url"

# Application Settings
NODE_ENV=production
PORT=5000
EOF

echo "✅ Backend .env file created"

# Create environment files for frontend apps
cat > apps/customer-app/.env << EOF
REACT_APP_API_URL=https://$webapp_url
REACT_APP_STRIPE_PUBLISHABLE_KEY="$stripe_publishable"
REACT_APP_FIREBASE_API_KEY="$firebase_api_key"
REACT_APP_FIREBASE_AUTH_DOMAIN="$firebase_auth_domain"
REACT_APP_FIREBASE_PROJECT_ID="$firebase_project_id"
REACT_APP_FIREBASE_STORAGE_BUCKET="$firebase_storage_bucket"
REACT_APP_FIREBASE_MESSAGING_SENDER_ID="$firebase_messaging_sender_id"
REACT_APP_FIREBASE_APP_ID="$firebase_app_id"
REACT_APP_FIREBASE_VAPID_KEY="$firebase_vapid_key"
EOF

echo "✅ Customer App .env file created"

# Create minimal .env files for other apps
echo "REACT_APP_API_URL=https://$webapp_url" > apps/vendor-dashboard/.env
echo "REACT_APP_API_URL=https://$webapp_url" > apps/driver-app/.env
echo "REACT_APP_API_URL=https://$webapp_url" > apps/admin-panel/.env

echo "✅ All .env files created"

echo ""
echo "🗄️ Step 5: Database Setup"
echo "Running database migrations..."

cd backend
if command -v npx &> /dev/null; then
    npx prisma generate
    npx prisma db push
    echo "✅ Database schema deployed"
else
    echo "⚠️  npx not found. Please run these commands manually:"
    echo "   cd backend && npx prisma generate && npx prisma db push"
fi

cd ..

echo ""
echo "🚀 Step 6: Deployment Instructions"
echo "=================================="
echo ""
echo "1. Backend Deployment:"
echo "   cd backend"
echo "   vercel --prod"
echo ""
echo "2. Frontend Deployments:"
echo "   cd apps/customer-app && vercel --prod"
echo "   cd apps/vendor-dashboard && vercel --prod"
echo "   cd apps/driver-app && vercel --prod"
echo "   cd apps/admin-panel && vercel --prod"
echo ""
echo "3. Environment Variables in Vercel:"
echo "   - Go to Vercel Dashboard → Your Project → Settings → Environment Variables"
echo "   - Copy the values from backend/.env to the Vercel environment variables"
echo ""
echo "4. Stripe Webhook Setup:"
echo "   - Go to Stripe Dashboard → Webhooks"
echo "   - Add endpoint: https://cannabis-api.vercel.app/payments/webhook"
echo "   - Copy the webhook secret to STRIPE_WEBHOOK_SECRET in Vercel"
echo ""
echo "5. Domain Setup (Optional):"
echo "   - Purchase domain name"
echo "   - Add to Vercel: Project → Settings → Domains"
echo "   - Configure DNS records as instructed by Vercel"

echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "Your Cannabis Delivery Platform is ready for production!"
echo ""
echo "Live URLs (after deployment):"
echo "• Customer App: https://cannabis-customer.vercel.app"
echo "• Vendor Dashboard: https://cannabis-vendor.vercel.app"
echo "• Driver App: https://cannabis-driver.vercel.app"
echo "• Admin Panel: https://cannabis-admin.vercel.app"
echo "• Backend API: https://cannabis-api.vercel.app"
echo ""
echo "Next steps:"
echo "1. Deploy all applications using the commands above"
echo "2. Set up Stripe webhooks"
echo "3. Configure custom domain (optional)"
echo "4. Run load tests: artillery run load-test.yml"
echo "5. Monitor performance and user feedback"
