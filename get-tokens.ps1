# Get deployment tokens for all Static Web Apps
$ErrorActionPreference = "Continue"

# Set the correct subscription
az account set --subscription 2e0757c5-8619-4f8b-a484-4e12fe6ca133

$tokens = @{}

$apps = @("GetGanja", "cannabis-vendor-dashboard", "driver-app", "admin-app")

foreach ($app in $apps) {
    Write-Host "Getting token for $app..."
    $token = az staticwebapp show --name $app --query "properties.productionDeploymentToken" -o tsv 2>$null
    if ($token) {
        $tokens[$app] = $token
        Write-Host "  Token: $($token.Substring(0, 30))..."
    } else {
        Write-Host "  No token found!"
    }
}

# Save to file
$tokens | ConvertTo-Json | Out-File -FilePath "swa-tokens.json" -Encoding UTF8

Write-Host ""
Write-Host "Tokens saved to swa-tokens.json"
