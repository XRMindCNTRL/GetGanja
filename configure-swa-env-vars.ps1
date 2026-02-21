# Configure Environment Variables for Azure Static Web Apps
# This script sets all required environment variables for the 4 Static Web Apps
# Prerequisites: Azure CLI (az) must be installed and authenticated

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Cannabis Delivery Platform - Static Web Apps Environment Setup  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if Azure CLI is installed
try {
    $azVersion = az version --output json 2>$null | ConvertFrom-Json
    Write-Host "✓ Azure CLI is installed (version $($azVersion.'azure-cli'))" -ForegroundColor Green
}
catch {
    Write-Host "✗ Azure CLI is not installed or not in PATH" -ForegroundColor Red
    Write-Host "  Please install Azure CLI: https://learn.microsoft.com/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray

# Check Azure authentication
Write-Host ""
Write-Host "Checking Azure authentication..." -ForegroundColor Yellow
try {
    $account = az account show --output json 2>$null | ConvertFrom-Json
    Write-Host "✓ Authenticated as: $($account.user.name)" -ForegroundColor Green
    Write-Host "  Subscription: $($account.name) ($($account.id))" -ForegroundColor Gray
}
catch {
    Write-Host "✗ Not authenticated to Azure" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please authenticate first:" -ForegroundColor Yellow
    Write-Host "  az login --use-device-code" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

# Define Static Web Apps
$staticWebApps = @(
    @{
        ResourceGroup = "cannabis-delivery-rg"
        Name          = "orange-mud-083f9ac0f"
        DisplayName   = "Customer App"
        FolderName    = "customer-app"
    },
    @{
        ResourceGroup = "cannabis-delivery-rg"
        Name          = "gentle-grass-00bb9010f"
        DisplayName   = "Vendor Dashboard"
        FolderName    = "vendor-dashboard"
    },
    @{
        ResourceGroup = "cannabis-delivery-rg"
        Name          = "red-mud-0b72f350f"
        DisplayName   = "Driver App"
        FolderName    = "driver-app"
    },
    @{
        ResourceGroup = "cannabis-delivery-rg"
        Name          = "kind-stone-01c35960f"
        DisplayName   = "Admin Panel"
        FolderName    = "admin-panel"
    }
)

# Gather configuration values
Write-Host "Step 1: Gather Configuration Values" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Please provide the following values:" -ForegroundColor Yellow
Write-Host ""

# API URL
Write-Host "Backend API URL:" -ForegroundColor Cyan
Write-Host "  Current: https://getganja.azurewebsites.net" -ForegroundColor Gray
$apiUrl = Read-Host "  Enter API URL (or press Enter to use default)"
if ([string]::IsNullOrWhiteSpace($apiUrl)) {
    $apiUrl = "https://getganja.azurewebsites.net"
}
Write-Host "  ✓ Set to: $apiUrl" -ForegroundColor Green
Write-Host ""

# Stripe Key
Write-Host "Stripe Public Key:" -ForegroundColor Cyan
Write-Host "  Format: pk_test_* (development) or pk_live_* (production)" -ForegroundColor Gray
$stripeKey = Read-Host "  Enter Stripe public key"
if ([string]::IsNullOrWhiteSpace($stripeKey)) {
    Write-Host "  ⚠ Warning: Stripe key not provided. Payments will not work." -ForegroundColor Yellow
} else {
    Write-Host "  ✓ Set to: $($stripeKey.Substring(0,10))..." -ForegroundColor Green
}
Write-Host ""

# Firebase Configuration
Write-Host "Firebase Configuration:" -ForegroundColor Cyan
Write-Host "  Get these values from Firebase Console: https://console.firebase.google.com" -ForegroundColor Gray
Write-Host ""

$firebaseApiKey = Read-Host "  1. API Key (REACT_APP_FIREBASE_API_KEY)"
if ([string]::IsNullOrWhiteSpace($firebaseApiKey)) {
    Write-Host "  ⚠ Warning: Firebase API Key not provided. Authentication will not work." -ForegroundColor Yellow
} else {
    Write-Host "  ✓ Set to: $($firebaseApiKey.Substring(0,10))..." -ForegroundColor Green
}

$firebaseAuthDomain = Read-Host "  2. Auth Domain (REACT_APP_FIREBASE_AUTH_DOMAIN)"
if ([string]::IsNullOrWhiteSpace($firebaseAuthDomain)) {
    Write-Host "  ⚠ Warning: Firebase Auth Domain not provided." -ForegroundColor Yellow
} else {
    Write-Host "  ✓ Set to: $firebaseAuthDomain" -ForegroundColor Green
}

$firebaseProjectId = Read-Host "  3. Project ID (REACT_APP_FIREBASE_PROJECT_ID)"
if ([string]::IsNullOrWhiteSpace($firebaseProjectId)) {
    Write-Host "  ⚠ Warning: Firebase Project ID not provided." -ForegroundColor Yellow
} else {
    Write-Host "  ✓ Set to: $firebaseProjectId" -ForegroundColor Green
}

$firebaseStorageBucket = Read-Host "  4. Storage Bucket (REACT_APP_FIREBASE_STORAGE_BUCKET)"
if ([string]::IsNullOrWhiteSpace($firebaseStorageBucket)) {
    Write-Host "  ⚠ Warning: Firebase Storage Bucket not provided." -ForegroundColor Yellow
} else {
    Write-Host "  ✓ Set to: $firebaseStorageBucket" -ForegroundColor Green
}

$firebaseMessagingSenderId = Read-Host "  5. Messaging Sender ID (REACT_APP_FIREBASE_MESSAGING_SENDER_ID)"
if ([string]::IsNullOrWhiteSpace($firebaseMessagingSenderId)) {
    Write-Host "  ⚠ Warning: Firebase Messaging Sender ID not provided." -ForegroundColor Yellow
} else {
    Write-Host "  ✓ Set to: $($firebaseMessagingSenderId.Substring(0,10))..." -ForegroundColor Green
}

$firebaseAppId = Read-Host "  6. App ID (REACT_APP_FIREBASE_APP_ID)"
if ([string]::IsNullOrWhiteSpace($firebaseAppId)) {
    Write-Host "  ⚠ Warning: Firebase App ID not provided." -ForegroundColor Yellow
} else {
    Write-Host "  ✓ Set to: $($firebaseAppId.Substring(0,10))..." -ForegroundColor Green
}

# Azure Maps Key (for Driver App)
Write-Host ""
Write-Host "Azure Maps Key (for Driver App only):" -ForegroundColor Cyan
Write-Host "  Get from Azure Portal > Azure Maps > Shared key authentication" -ForegroundColor Gray
$azureMapsKey = Read-Host "  Enter Azure Maps key (optional, only needed for driver-app)"
if (-not [string]::IsNullOrWhiteSpace($azureMapsKey)) {
    Write-Host "  ✓ Set to: $($azureMapsKey.Substring(0,10))..." -ForegroundColor Green
}

Write-Host ""
Write-Host "────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

# Confirmation
Write-Host "Step 2: Review and Confirm" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Summary of values to configure:" -ForegroundColor Yellow
Write-Host "  • Backend API URL: $apiUrl" -ForegroundColor Cyan
Write-Host "  • Stripe Key: $(if ([string]::IsNullOrWhiteSpace($stripeKey)) { '⚠ NOT SET' } else { '✓ SET' })" -ForegroundColor Cyan
Write-Host "  • Firebase API Key: $(if ([string]::IsNullOrWhiteSpace($firebaseApiKey)) { '⚠ NOT SET' } else { '✓ SET' })" -ForegroundColor Cyan
Write-Host "  • Firebase Auth Domain: $(if ([string]::IsNullOrWhiteSpace($firebaseAuthDomain)) { '⚠ NOT SET' } else { '✓ SET' })" -ForegroundColor Cyan
Write-Host "  • Firebase Project ID: $(if ([string]::IsNullOrWhiteSpace($firebaseProjectId)) { '⚠ NOT SET' } else { '✓ SET' })" -ForegroundColor Cyan
Write-Host "  • Firebase Storage Bucket: $(if ([string]::IsNullOrWhiteSpace($firebaseStorageBucket)) { '⚠ NOT SET' } else { '✓ SET' })" -ForegroundColor Cyan
Write-Host "  • Firebase Messaging Sender ID: $(if ([string]::IsNullOrWhiteSpace($firebaseMessagingSenderId)) { '⚠ NOT SET' } else { '✓ SET' })" -ForegroundColor Cyan
Write-Host "  • Firebase App ID: $(if ([string]::IsNullOrWhiteSpace($firebaseAppId)) { '⚠ NOT SET' } else { '✓ SET' })" -ForegroundColor Cyan
Write-Host "  • Azure Maps Key: $(if ([string]::IsNullOrWhiteSpace($azureMapsKey)) { '⚠ NOT SET (optional)' } else { '✓ SET' })" -ForegroundColor Cyan
Write-Host ""

$confirm = Read-Host "Do you want to proceed with configuring all 4 apps? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "Configuration cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

# Step 3: Configure each app
Write-Host "Step 3: Configure Static Web Apps" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host ""

$totalApps = $staticWebApps.Count
$successCount = 0
$failureCount = 0

foreach ($i = 0; $i -lt $staticWebApps.Count; $i++) {
    $app = $staticWebApps[$i]
    $appNumber = $i + 1
    
    Write-Host "[$appNumber/$totalApps] Configuring: $($app.DisplayName)" -ForegroundColor Cyan
    Write-Host "  Resource: $($app.Name)" -ForegroundColor Gray
    Write-Host "  Folder: apps/$($app.FolderName)" -ForegroundColor Gray
    Write-Host ""
    
    # Build settings for this app
    $settings = @{
        "REACT_APP_API_URL" = $apiUrl
    }
    
    if (-not [string]::IsNullOrWhiteSpace($stripeKey)) {
        $settings["REACT_APP_STRIPE_PUBLIC_KEY"] = $stripeKey
    }
    
    if (-not [string]::IsNullOrWhiteSpace($firebaseApiKey)) {
        $settings["REACT_APP_FIREBASE_API_KEY"] = $firebaseApiKey
    }
    
    if (-not [string]::IsNullOrWhiteSpace($firebaseAuthDomain)) {
        $settings["REACT_APP_FIREBASE_AUTH_DOMAIN"] = $firebaseAuthDomain
    }
    
    if (-not [string]::IsNullOrWhiteSpace($firebaseProjectId)) {
        $settings["REACT_APP_FIREBASE_PROJECT_ID"] = $firebaseProjectId
    }
    
    if (-not [string]::IsNullOrWhiteSpace($firebaseStorageBucket)) {
        $settings["REACT_APP_FIREBASE_STORAGE_BUCKET"] = $firebaseStorageBucket
    }
    
    if (-not [string]::IsNullOrWhiteSpace($firebaseMessagingSenderId)) {
        $settings["REACT_APP_FIREBASE_MESSAGING_SENDER_ID"] = $firebaseMessagingSenderId
    }
    
    if (-not [string]::IsNullOrWhiteSpace($firebaseAppId)) {
        $settings["REACT_APP_FIREBASE_APP_ID"] = $firebaseAppId
    }
    
    # Driver App specific
    if ($app.FolderName -eq "driver-app" -and -not [string]::IsNullOrWhiteSpace($azureMapsKey)) {
        $settings["REACT_APP_AZURE_MAPS_KEY"] = $azureMapsKey
    }
    
    # Set each variable
    $settingCount = 0
    foreach ($key in $settings.Keys) {
        try {
            az staticwebapp appsettings set `
                --name $app.Name `
                --resource-group $app.ResourceGroup `
                --setting-names "$key=$($settings[$key])" `
                --output none 2>$null
            
            Write-Host "    ✓ $key" -ForegroundColor Green
            $settingCount++
        }
        catch {
            Write-Host "    ✗ $key - Failed" -ForegroundColor Red
            Write-Host "      Error: $_" -ForegroundColor DarkRed
        }
    }
    
    if ($settingCount -eq $settings.Count) {
        Write-Host ""
        Write-Host "  ✓ All variables configured ($settingCount/$($settings.Count))" -ForegroundColor Green
        $successCount++
    } else {
        Write-Host ""
        Write-Host "  ⚠ Partial configuration ($settingCount/$($settings.Count))" -ForegroundColor Yellow
        $failureCount++
    }
    
    Write-Host ""
}

Write-Host "────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

# Summary
Write-Host "Configuration Complete!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  ✓ Successfully configured: $successCount/$totalApps apps" -ForegroundColor Green
if ($failureCount -gt 0) {
    Write-Host "  ⚠ Partially configured: $failureCount/$totalApps apps" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Your Static Web Apps will use these environment variables immediately"
Write-Host "  2. The apps should now be able to connect to the backend API"
Write-Host "  3. Test each app in a browser:"
Write-Host "     • Customer: https://orange-mud-083f9ac0f.4.azurestaticapps.net"
Write-Host "     • Vendor: https://gentle-grass-00bb9010f.1.azurestaticapps.net"
Write-Host "     • Driver: https://red-mud-0b72f350f.2.azurestaticapps.net"
Write-Host "     • Admin: https://kind-stone-01c35960f.1.azurestaticapps.net"
Write-Host "  4. Open browser DevTools (F12) > Console to check for errors"
Write-Host "  5. If you need to update values later, run this script again"
Write-Host ""

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
