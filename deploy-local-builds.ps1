# Deploy local builds to Azure Static Web Apps
# This bypasses GitHub Actions which has billing issues

Write-Host "Deploying local builds to Azure Static Web Apps..." -ForegroundColor Cyan
Write-Host ""

# First, get deployment tokens for each app
$tokenGetGanja = az staticwebapp show --name GetGanja --resource-group CannabisApp --query "properties.productionDeploymentToken" -o tsv 2>$null
$tokenVendorDashboard = az staticwebapp show --name cannabis-vendor-dashboard --resource-group CannabisApp --query "properties.productionDeploymentToken" -o tsv 2>$null
$tokenDriverApp = az staticwebapp show --name driver-app --resource-group CannabisApp --query "properties.productionDeploymentToken" -o tsv 2>$null
$tokenAdminApp = az staticwebapp show --name admin-app --resource-group CannabisApp --query "properties.productionDeploymentToken" -o tsv 2>$null

Write-Host "Deployment tokens retrieved" -ForegroundColor Green
Write-Host ""

# Deploy Customer App (GetGanja)
Write-Host "Deploying Customer App (GetGanja)..." -ForegroundColor Yellow
if ($tokenGetGanja) {
    az staticwebapp appsettings set --name GetGanja --resource-group CannabisApp --setting-name "AZURE_STATIC_WEB_APPS_API_TOKEN" --setting-value $tokenGetGanja 2>$null
    # Use swa deploy if available, otherwise show manual instructions
    Write-Host "Token for GetGanja: $tokenGetGanja"
} else {
    Write-Host "No token available for GetGanja - need to create one" -ForegroundColor Red
}

Write-Host ""

# Deploy Vendor Dashboard
Write-Host "Deploying Vendor Dashboard..." -ForegroundColor Yellow
if ($tokenVendorDashboard) {
    Write-Host "Token for vendor-dashboard: $tokenVendorDashboard"
} else {
    Write-Host "No token available for vendor-dashboard - need to create one" -ForegroundColor Red
}

Write-Host ""

# Deploy Driver App
Write-Host "Deploying Driver App..." -ForegroundColor Yellow
if ($tokenDriverApp) {
    Write-Host "Token for driver-app: $tokenDriverApp"
} else {
    Write-Host "No token available for driver-app - need to create one" -ForegroundColor Red
}

Write-Host ""

# Deploy Admin App
Write-Host "Deploying Admin App..." -ForegroundColor Yellow
if ($tokenAdminApp) {
    Write-Host "Token for admin-app: $tokenAdminApp"
} else {
    Write-Host "No token available for admin-app - need to create one" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "To deploy, we need to create deployment tokens." -ForegroundColor Yellow
Write-Host "Please follow these steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Go to Azure Portal" -ForegroundColor White
Write-Host "2. Search for each Static Web App" -ForegroundColor White
Write-Host "3. Go to Deployment > Deployment tokens" -ForegroundColor White
Write-Host "4. Click 'Generate token'" -ForegroundColor White
Write-Host "5. Copy the token and use it with Azure CLI" -ForegroundColor White
Write-Host ""
Write-Host "Or we can use the Azure Static Web Apps CLI (swa) to deploy" -ForegroundColor Cyan
