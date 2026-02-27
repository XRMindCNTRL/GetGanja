# Create deployment tokens for all Static Web Apps
$ErrorActionPreference = "Continue"

# Set the correct subscription
az account set --subscription 2e0757c5-8619-4f8b-a484-4e12fe6ca133

$tokens = @{}

$apps = @("GetGanja", "cannabis-vendor-dashboard", "driver-app", "admin-app")

Write-Host "Creating deployment tokens..." -ForegroundColor Cyan

foreach ($app in $apps) {
    Write-Host "Creating token for $app..."
    
    # Create a new deployment token
    $token = az staticwebapp create-deployment-token --name $app --query "properties.productionDeploymentToken" -o tsv 2>$null
    
    if ($token -and $token.Length -gt 10) {
        $tokens[$app] = $token
        Write-Host "  Token created: $($token.Substring(0, 30))..." -ForegroundColor Green
    } else {
        # Try to get existing token
        $token = az staticwebapp show --name $app --query "properties.productionDeploymentToken" -o tsv 2>$null
        if ($token -and $token.Length -gt 10) {
            $tokens[$app] = $token
            Write-Host "  Using existing token: $($token.Substring(0, 30))..." -ForegroundColor Yellow
        } else {
            Write-Host "  No token found - will need manual setup!" -ForegroundColor Red
        }
    }
}

# Save to file
$tokens | ConvertTo-Json | Out-File -FilePath "swa-tokens.json" -Encoding UTF8

Write-Host ""
Write-Host "Tokens saved to swa-tokens.json" -ForegroundColor Green
Write-Host ""
Write-Host "Now you need to:" -ForegroundColor Yellow
Write-Host "1. Add these tokens to GitHub secrets" -ForegroundColor White
Write-Host "2. Trigger deployments by pushing to main" -ForegroundColor White
