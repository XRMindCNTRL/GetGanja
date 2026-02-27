# Generate deployment tokens for Azure Static Web Apps
# Run this script to create deployment tokens

$ErrorActionPreference = "Continue"

$staticWebApps = @(
    @{ Name = "GetGanja"; VariableName = "AZURE_STATIC_WEB_APPS_API_TOKEN_ORANGE_MUD_083F9AC0F" },
    @{ Name = "cannabis-vendor-dashboard"; VariableName = "AZURE_STATIC_WEB_APPS_API_TOKEN_GENTLE_GRASS_00BB9010F" },
    @{ Name = "driver-app"; VariableName = "AZURE_STATIC_WEB_APPS_API_TOKEN_RED_MUD_0B72F350F" },
    @{ Name = "admin-app"; VariableName = "AZURE_STATIC_WEB_APPS_API_TOKEN_KIND_STONE_01C35960F" }
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Azure SWA Deployment Token Generator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($swa in $staticWebApps) {
    Write-Host "Processing: $($swa.Name)" -ForegroundColor Yellow
    
    try {
        # Generate a new deployment token
        $token = az staticwebapp show --name $swa.Name --query "properties.productionDeploymentToken" 2>$null
        
        if ($token -and $token.Length -gt 10) {
            Write-Host "  Token found: $($token.Substring(0, 20))..." -ForegroundColor Green
            Write-Host "  Variable name: $($swa.VariableName)" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "  ADD THIS TO GITHUB REPO SECRETS:" -ForegroundColor Red
            Write-Host "  Name: $($swa.VariableName)" -ForegroundColor White
            Write-Host "  Value: $token" -ForegroundColor White
            Write-Host ""
        } else {
            Write-Host "  No token found. The SWA might not be linked to GitHub." -ForegroundColor Red
            Write-Host "  Go to Azure Portal > SWA > Deployment > Link to GitHub" -ForegroundColor Yellow
            Write-Host ""
        }
    } catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host "1. Go to GitHub > Settings > Secrets and variables > Actions" -ForegroundColor White
Write-Host "2. Create new Repository Secrets with the names above" -ForegroundColor White
Write-Host "3. Copy the token values from Azure Portal" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
