# Deployment Fix Instructions

## Problem
The apps are returning 200 status but showing placeholder content ("Edit src/App.js") instead of actual React app content. This is because:
1. The Static Web Apps weren't properly deployed with built React apps
2. Deployment tokens aren't configured

## Solution - Two Options

### Option 1: Link SWA to GitHub (Recommended - Easiest)

1. **Go to Azure Portal**: https://portal.azure.com

2. **For each Static Web App**, do the following:
   - GetGanja (orange-mud-083f9ac0f.4.azurestaticapps.net)
   - cannabis-vendor-dashboard (gentle-grass-00bb9010f.1.azurestaticapps.net)
   - driver-app (red-mud-0b72f350f.2.azurestaticapps.net)
   - admin-app (kind-stone-01c35960f.1.azurestaticapps.net)

3. **Steps for each app:**
   - Open the Static Web App resource
   - Click **"Deployment"** in the left menu
   - Click **"Deployment center"**
   - Select **"GitHub"** as the source
   - Click **"Authorize"** and follow prompts
   - Select your repository and branch (main)
   - This automatically creates deployment tokens!

4. **Trigger deployment:**
   - Push any change to main branch, or
   - Go to GitHub Actions and manually trigger a workflow run

### Option 2: Manual Token Setup

1. **Generate tokens in Azure Portal:**
   - Go to each Static Web App
   - Deployment > Deployment tokens
   - Click "Generate token"
   - Copy the token

2. **Add to GitHub Secrets:**
   - Go to: https://github.com/XRMindCNTRL/GetGanja/settings/secrets/actions
   - Add these secrets:
     - `AZURE_STATIC_WEB_APPS_API_TOKEN_ORANGE_MUD_083F9AC0F` = (token for GetGanja)
     - `AZURE_STATIC_WEB_APPS_API_TOKEN_GENTLE_GRASS_00BB9010F` = (token for vendor-dashboard)
     - `AZURE_STATIC_WEB_APPS_API_TOKEN_RED_MUD_0B72F350F` = (token for driver-app)
     - `AZURE_STATIC_WEB_APPS_API_TOKEN_KIND_STONE_01C35960F` = (token for admin-app)

## Verify After Deployment

Once deployed, visit these URLs:
- Customer App: https://orange-mud-083f9ac0f.4.azurestaticapps.net
- Vendor Dashboard: https://gentle-grass-00bb9010f.1.azurestaticapps.net
- Driver App: https://red-mud-0b72f350f.2.azurestaticapps.net
- Admin Panel: https://kind-stone-01c35960f.1.azurestaticapps.net

You should see the actual app content (Welcome to Cannabis Delivery Platform, etc.) instead of the React placeholder.
