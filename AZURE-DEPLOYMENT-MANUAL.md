# Cannabis Delivery Platform - Azure Deployment Instructions

## Prerequisites
- Azure CLI installed: `az --version` should work
- Currently logged into Azure: `az account show`
- Subscription: Microsoft Azure Sponsorship (bb813320-d9cc-4e8e-bf3c-e6d8b6d09772)
- Location: eastus
- Resources to deploy: 
  - App Service (Backend API)
  - Storage Account
  - Key Vault
  - PostgreSQL Database
  - Application Insights

## Manual Step-by-Step Deployment

### Step 1: Create Resource Group
```bash
az group create --name cannabis-delivery-rg --location eastus
```

### Step 2: Deploy Infrastructure with Bicep
```bash
az deployment group create \
  --resource-group cannabis-delivery-rg \
  --name cannabis-deployment \
  --template-file infra/main.bicep \
  --parameters environmentName="production" \
  --query "properties.outputs" \
  -o json > azure-outputs.json
```

This creates:
- App Service Plan (B1 - Basic)
- Web App for Node.js backend
- PostgreSQL Flexible Server
- Storage Account
- Key Vault
- Application Insights

### Step 3: Extract and Save Outputs
```bash
# Linux/macOS/WSL2:
WEB_APP_URL=$(cat azure-outputs.json | jq -r '.webAppUrl.value')
KEY_VAULT=$(cat azure-outputs.json | jq -r '.keyVaultName.value')
```

### Step 4: Configure Key Vault Secrets
```bash
# Generate secure secrets
JWT_SECRET=$(openssl rand -base64 32)
DB_PASSWORD=$(openssl rand -base64 16)

# Store in Key Vault
az keyvault secret set --vault-name $KEY_VAULT --name "jwt-secret" --value "$JWT_SECRET"
az keyvault secret set --vault-name $KEY_VAULT --name "db-password" --value "$DB_PASSWORD"
az keyvault secret set --vault-name $KEY_VAULT --name "stripe-secret-key" --value "sk_test_xxx"
az keyvault secret set --vault-name $KEY_VAULT --name "firebase-api-key" --value "AIzaSyDOYqmfLOzd7ZcVBtxXqFjPV_ISgfvGbAs"
```

### Step 5: Build Backend
```bash
cd backend
npm install
npm run build  # if build script exists
cd ..
```

### Step 6: Deploy Backend to App Service
```bash
az webapp up \
  --resource-group cannabis-delivery-rg \
  --name cannabis-delivery-api \
  --runtime "NODE:18-lts" \
  --os-type Linux
```

### Step 7: Configure App Settings
```bash
# Set environment variables for the App Service
az webapp config appsettings set \
  --resource-group cannabis-delivery-rg \
  --name cannabis-delivery-api \
  --settings \
    NODE_ENV=production \
    PORT=5000 \
    WEBSITE_NODE_DEFAULT_VERSION=18-lts
```

### Step 8: Deploy Frontends (Optional)
For each frontend app:
```bash
cd apps/customer-app
npm install
npm run build

az staticwebapp create \
  --name cannabis-customer-app \
  --resource-group cannabis-delivery-rg \
  --location eastus \
  --sku Free
```

## Verification

### Check Backend Health
```bash
curl https://<WEB_APP_URL>/health
```

Expected response:
```json
{"status": "ok"}
```

### View Logs
```bash
az webapp log tail \
  --resource-group cannabis-delivery-rg \
  --name cannabis-delivery-api
```

### Check App Service Status
```bash
az webapp show \
  --resource-group cannabis-delivery-rg \
  --name cannabis-delivery-api \
  --query "{state:state, defaultHostName:defaultHostName}"
```

## Azure Resources Summary

After successful deployment:

| Resource | Type | Details |
|----------|------|---------|
| Backend API | App Service | https://cannabis-delivery-api-[hash].azurewebsites.net |
| Database | PostgreSQL | cannabis-delivery-server-[hash].postgres.database.azure.com |
| Storage | Storage Account | cannabisdelivery[hash] |
| Secrets | Key Vault | cannabis-delivery-kv-[hash] |
| Monitoring | App Insights | cannabis-delivery-ai |
| Logs | Log Analytics | cannabis-delivery-la |

## Troubleshooting

### Deployment Fails
1. Check Azure CLI: `az --version`
2. Check subscription: `az account show`
3. Check quotas: `az provider list --query "[?namespace=='Microsoft.Web']"`

### App Service Won't Start
```bash
# Check logs
az webapp log tail -g cannabis-delivery-rg -n cannabis-delivery-api

# Restart app
az webapp restart -g cannabis-delivery-rg -n cannabis-delivery-api
```

### Database Connection Issues
1. Verify firewall rules allow connection
2. Check connection string format
3. Ensure database name exists

### Key Vault Access Issues
```bash
# Grant App Service access to Key Vault
APP_SERVICE_PRINCIPAL=$(az webapp identity show \
  -g cannabis-delivery-rg \
  -n cannabis-delivery-api \
  --query principalId -o tsv)

az keyvault set-policy \
  --name $KEY_VAULT \
  --object-id $APP_SERVICE_PRINCIPAL \
  --secret-permissions get list
```

## Next Steps

1. **Test Backend**: Navigate to health endpoint
2. **Configure Stripe**: Add real webhook URLs
3. **Set Firebase**: Update with real credentials
4. **Deploy Frontends**: Deploy React apps to Static Web Apps
5. **Setup CDN**: Add Azure CDN for better performance
6. **Monitor**: Configure alerts in Application Insights

## Cost Estimate

- App Service (B1): ~$12/month
- PostgreSQL (Burstable): ~$30/month
- Storage Account: ~$1/month
- Key Vault: ~$0.60/month
- Application Insights: First 5GB free, then ~$2.00/GB

**Total estimate: ~$50-100/month** (excluding overages)

