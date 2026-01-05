# Open a FRESH PowerShell (Win+X, then choose PowerShell)
# Copy and paste this entire script:

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Creating Azure Service Principal for GitHub CI" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$sub = "2e0757c5-8619-4f8b-a484-4e12fe6ca133"

Write-Host "Step 1: Browser will open for MFA login..." -ForegroundColor Yellow
Write-Host "  - Complete the MFA challenge in your browser" -ForegroundColor Yellow
Write-Host "  - Return to this PowerShell window when done" -ForegroundColor Yellow
Write-Host ""

# Login with browser
az login --use-device-code --allow-no-subscriptions

Write-Host ""
Write-Host "Step 2: Creating Service Principal..." -ForegroundColor Yellow

# Create service principal
$sp = az ad sp create-for-rbac `
  --name "cannabis-github-ci-$(Get-Random 10000)" `
  --role Contributor `
  --scopes "/subscriptions/$sub" `
  --output json | ConvertFrom-Json

# Create clean JSON
$creds = @{
    clientId       = $sp.appId
    clientSecret   = $sp.password
    subscriptionId = $sp.subscription
    tenantId       = $sp.tenant
} | ConvertTo-Json

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "✅ SUCCESS! Service Principal Created" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Copy this JSON and paste in GitHub Secrets:" -ForegroundColor Cyan
Write-Host ""
Write-Host $creds
Write-Host ""
Write-Host "1. Go to: https://github.com/XRMindCNTRL/GetGanja" -ForegroundColor Yellow
Write-Host "2. Settings → Secrets and Variables → Actions" -ForegroundColor Yellow
Write-Host "3. New repository secret" -ForegroundColor Yellow
Write-Host "4. Name: AZURE_CREDENTIALS" -ForegroundColor Yellow
Write-Host "5. Paste the JSON above" -ForegroundColor Yellow
Write-Host ""
$creds | Set-Clipboard
Write-Host "📌 (Already copied to clipboard)" -ForegroundColor Green
