# GitHub CLI script to set Azure Static Web Apps deployment tokens
# Requires: gh CLI installed and authenticated

Write-Host "Setting GitHub Secrets for Azure Static Web Apps..." -ForegroundColor Green
Write-Host ""

# Define secrets to set
$secrets = @(
    @{
        Name  = "AZURE_STATIC_WEB_APPS_API_TOKEN_JOLLY_FOREST_020C52A0F"
        Value = "5c35309226457fe0e8712e65e528a263e5d1f0632db6ab07acec2a6de7724a9f04-6fd313f7-bb7d-40c7-b1f1-1dfe075c0edc00f0832083f9ac0f"
        App   = "Customer App (GetGanja)"
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
    }
)

# Set each secret
foreach ($secret in $secrets) {
    Write-Host "Setting: $($secret.Name)" -ForegroundColor Cyan
    Write-Host "App: $($secret.App)" -ForegroundColor Gray
    
    try {
        # Use gh CLI to set the secret
        $secret.Value | gh secret set $secret.Name
        Write-Host "✓ Successfully set" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to set secret: $_" -ForegroundColor Red
    }
    
    Write-Host ""
}

Write-Host "All secrets configured!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Trigger deployments by pushing to main:"
Write-Host "   - Push changes to apps/customer-app/** → triggers orange-mud-083f9ac0f"
Write-Host "   - Push changes to apps/vendor-dashboard/** → triggers gentle-grass-00bb9010f"
Write-Host "   - Push changes to apps/admin-panel/** → triggers kind-stone-01c35960f"
Write-Host ""
Write-Host "2. Or manually trigger workflows in GitHub Actions"
