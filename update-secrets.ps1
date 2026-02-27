# GitHub CLI script to set Azure Static Web Apps deployment tokens
# Updated with actual tokens from Azure Portal

Write-Host "Setting GitHub Secrets for Azure Static Web Apps..." -ForegroundColor Green
Write-Host ""

# Define secrets to set with actual tokens
$secrets = @(
    @{
        Name  = "AZURE_STATIC_WEB_APPS_API_TOKEN_DELIGHTFUL_POND_0BD190410"
        Value = "370f3eec41ed046d183460c9a98b946bc763e0838d03f14819f02123b855186202-ca2fb954-a4db-4f87-b76f-f92770e06b6601018210bd190410"
        App   = "Customer App (delightful-pond)"
    },
    @{
        Name  = "AZURE_STATIC_WEB_APPS_API_TOKEN_GENTLE_GRASS_00BB9010F"
        Value = "3f727ed038e71436ea159114a56f61f950d428e6016c803b6cf9a295af72c55801-4b6ea0ba-a0f9-4f6b-847a-98ffb7a3647200f191500bb9010f"
        App   = "Vendor Dashboard (gentle-grass)"
    },
    @{
        Name  = "AZURE_STATIC_WEB_APPS_API_TOKEN_KIND_STONE_01C35960F"
        Value = "812d6e9c42efb1f1d7639234afbb9cf8948adb480fdea0df80fd9b015a91b41a01-00d3c145-9ff1-4f4a-ae1e-51c231e70f4600f221901c35960f"
        App   = "Admin Panel (kind-stone)"
    },
    @{
        Name  = "AZURE_STATIC_WEB_APPS_API_TOKEN_RED_MUD_0B72F350F"
        Value = "452db612e45b78566ec454f80005e6a2ea2e8cd1fdec1d77e1dc186a327a3de402-2b9b1aa9-68c1-4098-8bb1-504e67ed873300f10320b72f350f"
        App   = "Driver App (red-mud)"
    }
)

# Set each secret
foreach ($secret in $secrets) {
    Write-Host "Setting: $($secret.Name)" -ForegroundColor Cyan
    Write-Host "App: $($secret.App)" -ForegroundColor Gray

    try {
        # Use gh CLI to set the secret
        gh secret set $secret.Name --body $secret.Value
        Write-Host "✓ Successfully set" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to set secret: $_" -ForegroundColor Red
    }

    Write-Host ""
}

Write-Host "All secrets configured with actual tokens!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Push changes to trigger deployments"
Write-Host "2. Monitor GitHub Actions for deployment status"
