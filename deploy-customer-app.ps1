# Deploy Customer App to Azure Static Web Apps
# Build and deploy apps to Azure

Write-Host "`n==== Cannabis Delivery Platform - App Deployment ====" -ForegroundColor Cyan

# Check Azure CLI
Write-Host "`n[1] Checking Azure CLI..." -ForegroundColor Yellow
az --version > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Azure CLI not installed. Install from: https://aka.ms/azcli" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Azure CLI ready" -ForegroundColor Green

# Check authentication
Write-Host "`n[2] Checking Azure authentication..." -ForegroundColor Yellow
az account show > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "    Logging in..." -ForegroundColor Yellow
    az login --use-device-code
}
Write-Host "[OK] Authenticated" -ForegroundColor Green

# Get app info
$appName = "orange-mud-083f9ac0f"
$resourceGroup = "cannabis-delivery-rg"
$buildDir = "apps/customer-app/build"

# Check build folder
Write-Host "`n[3] Checking build folder..." -ForegroundColor Yellow
if (-not (Test-Path $buildDir)) {
    Write-Host "[ERROR] Build folder not found at $buildDir" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path "$buildDir/index.html")) {
    Write-Host "[ERROR] index.html missing from build folder" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Build folder ready with index.html" -ForegroundColor Green

# Verify Azure resource
Write-Host "`n[4] Verifying Azure Static Web App resource..." -ForegroundColor Yellow
az staticwebapp show --name $appName --resource-group $resourceGroup > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Could not find Static Web App: $appName" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Found resource: $appName" -ForegroundColor Green

# Option 1: GitHub Actions (if committed)
Write-Host "`n[5] Deployment options:" -ForegroundColor Yellow
Write-Host "    OPTION 1: GitHub Actions (Auto-deploy on push to main)" -ForegroundColor Cyan
Write-Host "    OPTION 2: Deploy with SWA CLI (requires token)" -ForegroundColor Cyan
Write-Host "    OPTION 3: Use Azure Portal" -ForegroundColor Cyan

Write-Host "`n--- OPTION 1: GitHub Actions (Recommended) ---" -ForegroundColor Green
Write-Host "1. Stage and commit your changes:" -ForegroundColor Gray
Write-Host "   git add ." -ForegroundColor DarkYellow
Write-Host "   git commit -m 'Deploy customer app'" -ForegroundColor DarkYellow
Write-Host "   git push origin main" -ForegroundColor DarkYellow
Write-Host "2. GitHub Actions will auto-deploy" -ForegroundColor Gray
Write-Host "3. Check status: https://github.com/XRMindCNTRL/GetGanja/actions" -ForegroundColor Gray

Write-Host "`n--- OPTION 2: SWA CLI ---" -ForegroundColor Green
Write-Host "1. Get deployment token from Azure Portal:" -ForegroundColor Gray
Write-Host "   - Go to https://portal.azure.com" -ForegroundColor Gray
Write-Host "   - Search for: orange-mud-083f9ac0f" -ForegroundColor Gray
Write-Host "   - Go to Build > Build Details > Manage deployment token" -ForegroundColor Gray
Write-Host "   - Copy the token" -ForegroundColor Gray
Write-Host "`n2. Install SWA CLI: npm install -D @azure/static-web-apps-cli" -ForegroundColor Gray
Write-Host "`n3. Deploy: swa deploy --deployment-token TOKEN ./apps/customer-app/build" -ForegroundColor Gray

Write-Host "`n--- OPTION 3: Azure Portal Direct Upload ---" -ForegroundColor Green
Write-Host "1. Go to Azure Portal > orange-mud-083f9ac0f resource" -ForegroundColor Gray
Write-Host "2. Click 'Build' menu" -ForegroundColor Gray
Write-Host "3. Look for upload or deployment option" -ForegroundColor Gray

Write-Host "`n====================================================`n" -ForegroundColor Cyan
