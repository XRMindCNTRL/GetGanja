# 🚀 Cannabis Delivery Platform - FINAL Azure Deployment Instructions

## Current Status
- ✅ Backend: Ready for production (TypeScript, Express, Prisma)
- ✅ Frontend Apps: Ready for production (React)
- ✅ Database Schema: Configured with Prisma
- ✅ Azure CLI: Installed and configured
- ✅ Azure Subscription: Active (Microsoft Azure Sponsorship)
- ⏳ Deployment: Ready to begin

## Quick Deployment Commands

Run these commands in PowerShell or Terminal from the project root directory.

### 1. Authenticate with Azure
```powershell
az logout
az login
```
Or use device code if needed:
```powershell
az login --use-device-code
```

### 2. Set Active Subscription
```powershell
az account set --subscription "bb813320-d9cc-4e8e-bf3c-e6d8b6d09772"
```

### 3. Create Resource Group
```powershell
az group create --name cannabis-delivery-rg --location eastus
```

Expected Output:
```json
{
  "id": "/subscriptions/bb813320.../resourceGroups/cannabis-delivery-rg",
  "location": "eastus",
  "name": "cannabis-delivery-rg",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null
}
```

### 4. Deploy Infrastructure (Bicep) - TAKES 10-15 MINUTES
```powershell
$output = az deployment group create `
  --resource-group cannabis-delivery-rg `
  --name cannabis-deployment `
  --template-file infra/main.bicep `
  --parameters environmentName="production" `
  --query "properties.outputs" `
  -o json

# Save outputs to file
$output | Out-File -FilePath azure-outputs.json -Force

# Display outputs
$output | ConvertFrom-Json | Format-Table
```

Expected Resources Created:
- ✅ App Service (Node.js 18 LTS)
- ✅ PostgreSQL Flexible Server (13)
- ✅ Storage Account (Standard_LRS)
- ✅ Key Vault (Standard)
- ✅ Application Insights
- ✅ Log Analytics Workspace
- ✅ Azure AI Services
- ✅ Azure AI Search
- ✅ Azure AI Hub & Project

### 5. Extract Key Values from Output
```powershell
$config = Get-Content azure-outputs.json | ConvertFrom-Json
$webAppUrl = $config.webAppUrl.value
$keyVaultName = $config.keyVaultName.value
$storageAccountName = $config.storageAccountName.value

Write-Host "Web App URL: $webAppUrl"
Write-Host "Key Vault: $keyVaultName"
Write-Host "Storage: $storageAccountName"
```

### 6. Generate and Store Secrets
```powershell
# Generate secure random secrets
$jwtSecret = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
$dbPassword = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})

# Store in Key Vault
az keyvault secret set --vault-name $keyVaultName --name "jwt-secret" --value $jwtSecret --output none
az keyvault secret set --vault-name $keyVaultName --name "db-password" --value $dbPassword --output none

# Store Stripe keys (replace with real values later)
az keyvault secret set --vault-name $keyVaultName --name "stripe-secret-key" --value "sk_test_placeholder" --output none
az keyvault secret set --vault-name $keyVaultName --name "stripe-publishable-key" --value "pk_test_placeholder" --output none

# Store Firebase config
az keyvault secret set --vault-name $keyVaultName --name "firebase-api-key" --value "AIzaSyDOYqmfLOzd7ZcVBtxXqFjPV_ISgfvGbAs" --output none
az keyvault secret set --vault-name $keyVaultName --name "firebase-project-id" --value "holoport-xr" --output none

Write-Host "✅ Secrets stored in Key Vault"
```

### 7. Build Backend Application
```powershell
cd backend
npm install --silent
npm run build
cd ..
```

Expected output: Successful TypeScript compilation

### 8. Deploy Backend to App Service
```powershell
$appName = "cannabis-delivery-api-$(Get-Random -Minimum 1000 -Maximum 9999)"

az webapp up `
  --resource-group cannabis-delivery-rg `
  --name $appName `
  --runtime "NODE:18-lts" `
  --os-type Linux `
  --location eastus
```

**This deploys your backend to: `https://$appName.azurewebsites.net`**

Expected output:
```
{
  "id": "/subscriptions/.../resourceGroups/cannabis-delivery-rg/providers/Microsoft.Web/sites/...",
  "location": "East US",
  "name": "cannabis-delivery-api-xxxx",
  "properties": {
    "defaultHostName": "cannabis-delivery-api-xxxx.azurewebsites.net",
    "enabled": true,
    "kind": "app,linux",
    "state": "Running"
  }
}
```

### 9. Configure App Service Settings
```powershell
az webapp config appsettings set `
  --resource-group cannabis-delivery-rg `
  --name $appName `
  --settings `
    NODE_ENV=production `
    PORT=5000 `
    JWT_SECRET=$jwtSecret `
    STRIPE_SECRET_KEY="sk_test_placeholder" `
    FIREBASE_API_KEY="AIzaSyDOYqmfLOzd7ZcVBtxXqFjPV_ISgfvGbAs"
```

### 10. Test Backend Health Check
```powershell
# Wait 2-3 minutes for app to fully start
Start-Sleep -Seconds 180

# Test health endpoint
$response = Invoke-WebRequest -Uri "https://$appName.azurewebsites.net/health" -Method Get -ErrorAction SilentlyContinue
$response.StatusCode  # Should be 200
$response.Content     # Should show {"status":"ok"}
```

## Deploy Frontend Applications (Optional - Static Web Apps)

For each frontend app:

```powershell
cd apps/customer-app
npm install --silent
npm run build

# Create Static Web App
az staticwebapp create `
  --name cannabis-customer-app `
  --resource-group cannabis-delivery-rg `
  --location eastus `
  --sku "Free" `
  --source ./build
  
cd ../..
```

Repeat for:
- `vendor-dashboard`
- `driver-app`
- `admin-panel`

## Verify Deployment

### Check Resource Group Status
```powershell
az group show --name cannabis-delivery-rg --query "{name:name, location:location, provisioningState:properties.provisioningState}" -o table
```

### List All Resources
```powershell
az resource list --resource-group cannabis-delivery-rg --query "[][name, type, properties.provisioningState]" -o table
```

### Check App Service Status
```powershell
az webapp show --resource-group cannabis-delivery-rg --name $appName --query "{state:state, defaultHostName:defaultHostName, runtime:siteConfig.linuxFxVersion}"
```

### View Live Logs
```powershell
az webapp log tail `
  --resource-group cannabis-delivery-rg `
  --name $appName
```

## Access Your Applications

After successful deployment:

| Component | URL |
|-----------|-----|
| **Backend API** | `https://$appName.azurewebsites.net` |
| **Health Check** | `https://$appName.azurewebsites.net/health` |
| **API Docs** | `https://$appName.azurewebsites.net/api/docs` |
| **Customer App** | Azure Static Web Apps URL (after deployment) |
| **Vendor Dashboard** | Azure Static Web Apps URL (after deployment) |
| **Driver App** | Azure Static Web Apps URL (after deployment) |
| **Admin Panel** | Azure Static Web Apps URL (after deployment) |

## Key Vault Access

To access secrets from the App Service:

```powershell
# Grant App Service access to Key Vault
$principalId = az webapp identity show -g cannabis-delivery-rg -n $appName --query principalId -o tsv

az keyvault set-policy `
  --name $keyVaultName `
  --object-id $principalId `
  --secret-permissions get list
```

## Monitor Your Applications

### View Application Insights
```powershell
# Get Application Insights connection string
az deployment group show `
  --resource-group cannabis-delivery-rg `
  --name cannabis-deployment `
  --query "properties.outputs.applicationInsightsConnectionString.value"

# Open Azure Portal for detailed monitoring
Start-Process "https://portal.azure.com/#resource/subscriptions/bb813320-d9cc-4e8e-bf3c-e6d8b6d09772/resourceGroups/cannabis-delivery-rg/overview"
```

### Real-time Logs
```powershell
az webapp log tail --resource-group cannabis-delivery-rg --name $appName --follow
```

## Troubleshooting

### Azure CLI Authentication Fails
```powershell
# Clear credential cache
Remove-Item -Path "$env:APPDATA\.azure" -Recurse -Force -ErrorAction SilentlyContinue

# Re-authenticate
az login
```

### Deployment Timeout
```powershell
# Check deployment status
az deployment group show -n cannabis-deployment -g cannabis-delivery-rg
```

### App Service Won't Start
```powershell
# Check logs
az webapp log tail -g cannabis-delivery-rg -n $appName

# Restart app
az webapp restart -g cannabis-delivery-rg -n $appName
```

### Database Connection Issues
```powershell
# Check PostgreSQL firewall rules
az postgres flexible-server firewall-rule list -g cannabis-delivery-rg -n cannabis-delivery-server-*

# Add App Service IP (if needed)
az postgres flexible-server firewall-rule create `
  -g cannabis-delivery-rg `
  -n cannabis-delivery-server-* `
  -r "AllowAzureServices" `
  --start-ip-address 0.0.0.0 `
  --end-ip-address 255.255.255.255
```

## Cost Management

### Estimated Monthly Costs
- **App Service (B1)**: ~$12
- **PostgreSQL (Burstable)**: ~$30
- **Storage Account**: ~$1
- **Key Vault**: ~$0.60
- **Application Insights**: Free (first 5GB)
- **Static Web Apps (Free tier)**: Free

**Total: ~$45-50/month** (excluding data transfer)

### Cost Alerts
```powershell
# Set up budget alert
az costmanagement budget create `
  --scope /subscriptions/bb813320-d9cc-4e8e-bf3c-e6d8b6d09772 `
  --name "Cannabis-Delivery-Budget" `
  --category "Cost" `
  --amount 50 `
  --time-grain Monthly
```

## Next Steps

1. ✅ **Deploy Infrastructure** (run steps 1-8 above)
2. ✅ **Verify Backend** (run step 10)
3. ⏳ **Deploy Frontends** (run frontend deployment commands)
4. ⏳ **Configure Custom Domain** (optional)
5. ⏳ **Set up CI/CD Pipeline** (GitHub Actions)
6. ⏳ **Configure SSL Certificate** (Azure managed)
7. ⏳ **Add Monitoring Alerts** (Application Insights)
8. ⏳ **Update Stripe Webhooks** (with live URLs)

## Support

For issues or questions:
- **Azure Portal**: https://portal.azure.com
- **Azure CLI Docs**: https://learn.microsoft.com/cli/azure
- **App Service Docs**: https://learn.microsoft.com/azure/app-service
- **Bicep Docs**: https://learn.microsoft.com/azure/azure-resource-manager/bicep

---

**Ready to deploy?** Run the commands in order from the "Quick Deployment Commands" section above!

