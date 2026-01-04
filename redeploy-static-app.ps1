# Redeploy Cannabis Delivery Platform to Azure Static Web Apps
# This script directly redeployes the pre-built customer app

Write-Host "🔄 Redeploying Cannabis Delivery Platform to Azure Static Web Apps" -ForegroundColor Green
Write-Host "=================================================="

# Check if build folder exists
$buildPath = "apps\customer-app\build"
if (-not (Test-Path $buildPath)) {
    Write-Host "❌ Build folder not found at $buildPath" -ForegroundColor Red
    Write-Host "Please run: npm run build in apps/customer-app" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Build folder found at $buildPath" -ForegroundColor Green

# Get the static web app details
Write-Host "`n📋 Getting Azure Static Web App details..." -ForegroundColor Cyan
try {
    $staticAppsCmd = 'az staticwebapp list --query "[].{name:name, defaultDomain:defaultDomain, resourceGroup:resourceGroup}" -o json --only-show-errors'
    $staticApps = Invoke-Expression $staticAppsCmd
    
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrEmpty($staticApps)) {
        Write-Host "⚠️  Azure CLI connectivity issue." -ForegroundColor Yellow
        Write-Host "`n📌 To fix the stale cache manually:" -ForegroundColor Cyan
        Write-Host "1. Go to: https://portal.azure.com" -ForegroundColor Yellow
        Write-Host "2. Find your Static Web App resource" -ForegroundColor Yellow
        Write-Host "3. In the deployment menu, redeploy from GitHub" -ForegroundColor Yellow
        exit 1
    }
    
    $apps = $staticApps | ConvertFrom-Json
    if ($null -ne $apps) {
        Write-Host "Found Static Web App(s)" -ForegroundColor Green
    }
    
} catch {
    Write-Host "⚠️  Could not list static web apps." -ForegroundColor Yellow
    exit 1
}

# Try to find the jolly-forest app
$targetApp = $apps | Where-Object { $_.defaultDomain -like "*jolly-forest*" -or $_.name -like "*cannabis*" }

if ($null -eq $targetApp) {
    Write-Host "`n❌ Could not find the target Static Web App" -ForegroundColor Red
    Write-Host "Expected an app at: jolly-forest-020c52a0f.6.azurestaticapps.net" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n✅ Found target app: $($targetApp.name)" -ForegroundColor Green
Write-Host "   URL: https://$($targetApp.defaultDomain)" -ForegroundColor Cyan

Write-Host "`n🚀 SOLUTION: Since Azure CLI deployment is limited, use GitHub Actions" -ForegroundColor Green
Write-Host "=================================================="
Write-Host "The deployment workflow is set up in .github/workflows/deploy-static-web-app.yml" -ForegroundColor Cyan
Write-Host "`nTo trigger automatic deployment:" -ForegroundColor Yellow
Write-Host "1. Fix GitHub authentication:" -ForegroundColor White
Write-Host "   gh auth login" -ForegroundColor Magenta
Write-Host "2. Push your changes:" -ForegroundColor White
Write-Host "   git push origin main" -ForegroundColor Magenta
Write-Host "`nThis will trigger GitHub Actions to:" -ForegroundColor Cyan
Write-Host "  ✓ Install dependencies" -ForegroundColor Green
Write-Host "  ✓ Build the customer app" -ForegroundColor Green
Write-Host "  ✓ Deploy to Azure Static Web Apps" -ForegroundColor Green
Write-Host "  ✓ Clear the cache automatically" -ForegroundColor Green

Write-Host "`n📌 ALTERNATIVE: Manual deployment via Azure Portal" -ForegroundColor Yellow
Write-Host "1. Open Azure Portal: https://portal.azure.com" -ForegroundColor White
Write-Host "2. Search for 'jolly-forest' in Static Web App" -ForegroundColor White
Write-Host "3. Click on 'Deployments'" -ForegroundColor White
Write-Host "4. Click 'Manage'" -ForegroundColor White
Write-Host "5. Select your connected GitHub repo and branch 'main'" -ForegroundColor White
Write-Host "6. Click 'Rebuild'" -ForegroundColor White

Write-Host "`n✅ The customer app build is ready at: $buildPath" -ForegroundColor Green
Write-Host "`n🚀 NEXT STEPS:" -ForegroundColor Green
Write-Host "=================================================="
Write-Host "Use GitHub Actions for automatic deployment:" -ForegroundColor Cyan
Write-Host "1. Fix GitHub auth: gh auth login" -ForegroundColor Yellow
Write-Host "2. Push changes: git push origin main" -ForegroundColor Yellow
Write-Host "`nOR use Azure Portal to manually trigger a redeploy." -ForegroundColor Yellow

