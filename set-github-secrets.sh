#!/bin/bash

# GitHub CLI script to set Azure Static Web Apps deployment tokens
# Requires: gh CLI installed and authenticated

echo "Setting GitHub Secrets for Azure Static Web Apps..."
echo ""

# Set secrets using gh CLI
echo "Setting AZURE_STATIC_WEB_APPS_API_TOKEN_DELIGHTFUL_POND_0BD190410..."
echo "PLACEHOLDER_TOKEN_FOR_DELIGHTFUL_POND" | gh secret set AZURE_STATIC_WEB_APPS_API_TOKEN_DELIGHTFUL_POND_0BD190410

echo "Setting AZURE_STATIC_WEB_APPS_API_TOKEN_GENTLE_GRASS_00BB9010F..."
echo "3f727ed038e71436ea159114a56f61f950d428e6016c803b6cf9a295af72c55801-4b6ea0ba-a0f9-4f6b-847a-98ffb7a3647200f191500bb9010f" | gh secret set AZURE_STATIC_WEB_APPS_API_TOKEN_GENTLE_GRASS_00BB9010F

echo "Setting AZURE_STATIC_WEB_APPS_API_TOKEN_KIND_STONE_01C35960F..."
echo "812d6e9c42efb1f1d7639234afbb9cf8948adb480fdea0df80fd9b015a91b41a01-00d3c145-9ff1-4f4a-ae1e-51c231e70f4600f221901c35960f" | gh secret set AZURE_STATIC_WEB_APPS_API_TOKEN_KIND_STONE_01C35960F

echo "Setting AZURE_STATIC_WEB_APPS_API_TOKEN_RED_MUD_0B72F350F..."
echo "PLACEHOLDER_TOKEN_FOR_RED_MUD" | gh secret set AZURE_STATIC_WEB_APPS_API_TOKEN_RED_MUD_0B72F350F

echo ""
echo "All secrets configured!"
echo ""
echo "Next steps:"
echo "1. Replace PLACEHOLDER_TOKEN_FOR_DELIGHTFUL_POND and PLACEHOLDER_TOKEN_FOR_RED_MUD with actual tokens from Azure"
echo "2. Trigger deployments by pushing to main:"
echo "   - Push changes to apps/customer-app/** → triggers delightful-pond"
echo "   - Push changes to apps/vendor-dashboard/** → triggers gentle-grass"
echo "   - Push changes to apps/driver-app/** → triggers red-mud"
echo "   - Push changes to apps/admin-panel/** → triggers kind-stone"
echo ""
echo "3. Or manually trigger workflows in GitHub Actions"
