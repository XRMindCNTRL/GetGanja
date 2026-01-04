#!/bin/bash

# Azure Deployment Script for Cannabis Delivery Platform
# This script deploys all applications to Azure App Service and Static Web Apps

echo "🚀 Azure Deployment Script"
echo "=========================="

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first."
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "package.json" ] || [ ! -d "backend" ]; then
    echo "❌ Error: Please run this script from the root directory of the cannabis-delivery-platform project"
    exit 1
fi

# Load configuration from azure-outputs.json if it exists
if [ -f "azure-outputs.json" ]; then
    echo "📋 Loading Azure configuration..."
    resource_group=$(cat azure-outputs.json | jq -r '.resourceGroup.value // empty' 2>/dev/null || echo "")
    webapp_name=$(cat azure-outputs.json | jq -r '.webAppName.value // empty' 2>/dev/null || echo "")
    webapp_url=$(cat azure-outputs.json | jq -r '.webAppUrl.value // empty' 2>/dev/null || echo "")
else
    echo "⚠️  azure-outputs.json not found. Please run setup-production.sh first."
    exit 1
fi

if [ -z "$resource_group" ] || [ -z "$webapp_name" ]; then
    echo "❌ Azure configuration not found. Please run setup-production.sh first."
    exit 1
fi

echo "📍 Deploying to Resource Group: $resource_group"
echo "🌐 Web App: $webapp_name"

echo ""
echo "🔧 Step 1: Backend Deployment"
echo "=============================="

cd backend

# Install dependencies
echo "Installing backend dependencies..."
npm install

# Build the application (if build script exists)
if npm run | grep -q "build"; then
    echo "Building backend application..."
    npm run build
fi

# Deploy to Azure App Service
echo "Deploying backend to Azure App Service..."
az webapp up \
  --resource-group $resource_group \
  --name $webapp_name \
  --runtime "NODE:18-lts" \
  --os-type Linux \
  --location $(az group show --name $resource_group --query location -o tsv)

cd ..

echo ""
echo "🎨 Step 2: Frontend Deployments"
echo "==============================="

# Function to deploy static web app
deploy_frontend() {
    local app_name=$1
    local app_dir=$2
    local build_dir="build"

    echo "Deploying $app_name..."

    cd $app_dir

    # Install dependencies
    if [ -f "package.json" ]; then
        npm install

        # Build the application
        if npm run | grep -q "build"; then
            npm run build
        fi
    fi

    # Deploy to Azure Static Web Apps
    static_app_name="cannabis-${app_name//_/-}"
    echo "Creating/updating Azure Static Web App: $static_app_name"

    # Check if static web app already exists
    if az staticwebapp show --name $static_app_name --resource-group $resource_group &>/dev/null; then
        echo "Updating existing Static Web App..."
        az staticwebapp appsettings set \
          --name $static_app_name \
          --resource-group $resource_group \
          --setting REACT_APP_API_URL="https://$webapp_url" \
          --setting REACT_APP_NODE_ENV="production"
    else
        echo "Creating new Static Web App..."
        az staticwebapp create \
          --name $static_app_name \
          --resource-group $resource_group \
          --location $(az group show --name $resource_group --query location -o tsv) \
          --source . \
          --output-location $build_dir \
          --login-with-github false \
          --sku "Free"
    fi

    cd ..
}

# Deploy all frontend applications
deploy_frontend "customer-app" "apps/customer-app"
deploy_frontend "vendor-dashboard" "apps/vendor-dashboard"
deploy_frontend "driver-app" "apps/driver-app"
deploy_frontend "admin-panel" "apps/admin-panel"

echo ""
echo "✅ Deployment Complete!"
echo "======================"
echo ""
echo "Your applications have been deployed to Azure:"
echo ""
echo "🔗 Backend API: https://$webapp_url"
echo ""
echo "🎨 Frontend Applications:"
echo "• Customer App: Check Azure Portal → Static Web Apps"
echo "• Vendor Dashboard: Check Azure Portal → Static Web Apps"
echo "• Driver App: Check Azure Portal → Static Web Apps"
echo "• Admin Panel: Check Azure Portal → Static Web Apps"
echo ""
echo "📊 Monitoring:"
echo "• Application Insights: Configured automatically"
echo "• View logs: az webapp log tail --resource-group $resource_group --name $webapp_name"
echo ""
echo "🔧 Useful Commands:"
echo "• Check app status: az webapp show --resource-group $resource_group --name $webapp_name"
echo "• Restart backend: az webapp restart --resource-group $resource_group --name $webapp_name"
echo "• View static apps: az staticwebapp list --resource-group $resource_group"
echo ""
echo "Next Steps:"
echo "1. Verify all applications are accessible"
echo "2. Set up custom domains if needed"
echo "3. Configure CDN for better performance"
echo "4. Set up monitoring alerts in Application Insights"
