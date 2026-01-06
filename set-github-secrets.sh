#!/bin/bash

# GitHub CLI script to set Azure Static Web Apps deployment tokens
# Requires: gh CLI installed and authenticated

echo "Setting GitHub Secrets for Azure Static Web Apps..."
echo ""

# Define secrets to set
secrets=(
    "AZURE_STATIC_WEB_APPS_API_TOKEN_JOLLY_FOREST_020C52A0F:5c35309226457fe0e8712e65e528a263e5d1f0632db6ab07acec2a6de7724a9f04-6fd313f7-bb7d-40c7-b1f1-1dfe075c0edc00f0832083f9ac0f:Customer App (GetGanja)"
    "AZURE_STATIC_WEB_APPS_API_TOKEN_GENTLE_GRASS_00BB9010F:3f727ed038e71436ea159114a56f61f950d428e6016c803b6cf9a295af72c55801-4b6ea0ba-a0f9-4f6b-847a-98ffb7a3647200f191500bb9010f:Vendor Dashboard (gentle-grass)"
    "AZURE_STATIC_WEB_APPS_API_TOKEN_KIND_STONE_01C35960F:812d6e9c42efb1f1d7639234afbb9cf8948adb480fdea0df80fd9b015a91b41a01-00d3c145-9ff1-4f4a-ae1e-51c231e70f4600f221901c35960f:Admin Panel (kind-stone)"
)

# Set each secret
for secret in "${secrets[@]}"; do
    IFS=':' read -r name value app <<< "$secret"
    
    echo "Setting: $name"
    echo "App: $app"
    
    if echo "$value" | gh secret set "$name" 2>/dev/null; then
        echo "✓ Successfully set"
    else
        echo "✗ Failed to set secret"
    fi
    
    echo ""
done

echo "All secrets configured!"
echo ""
echo "Next steps:"
echo "1. Trigger deployments by pushing to main:"
echo "   - Push changes to apps/customer-app/** → triggers orange-mud-083f9ac0f"
echo "   - Push changes to apps/vendor-dashboard/** → triggers gentle-grass-00bb9010f"
echo "   - Push changes to apps/admin-panel/** → triggers kind-stone-01c35960f"
echo ""
echo "2. Or manually trigger workflows in GitHub Actions"
