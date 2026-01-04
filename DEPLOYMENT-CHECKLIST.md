# 🎯 DEPLOYMENT CHECKLIST - Cannabis Delivery Platform to Azure

## ✅ What's Ready for Deployment

- ✅ Backend API (Node.js/Express/TypeScript)
- ✅ 4 Frontend Apps (React)
- ✅ Database Schema (Prisma/PostgreSQL)
- ✅ Azure Infrastructure Template (Bicep)
- ✅ Azure CLI Configuration
- ✅ Environment Files
- ✅ Deployment Scripts

---

## 🚀 DEPLOYMENT WALKTHROUGH

### PHASE 1: Azure Infrastructure Setup (10-15 minutes)

**STEP 1: Open Terminal and Navigate**
```powershell
cd c:\Users\pc\Desktop\cannabis-delivery-platform
```

**STEP 2: Verify Azure Login**
```powershell
az account show
```

Expected output shows your subscription details. If error, run:
```powershell
az login
# Follow browser instructions to authenticate
```

**STEP 3: Set Your Subscription**
```powershell
az account set --subscription "bb813320-d9cc-4e8e-bf3c-e6d8b6d09772"
```

**STEP 4: Create Resource Group**
```powershell
az group create --name cannabis-delivery-rg --location eastus
```

✅ **Expected**: Success message with group details

**STEP 5: Deploy Azure Infrastructure (TAKES 10-15 MINUTES)**
```powershell
$bicepOutput = az deployment group create `
  --resource-group cannabis-delivery-rg `
  --name cannabis-deployment `
  --template-file infra/main.bicep `
  --parameters environmentName="production" `
  --query "properties.outputs" `
  -o json

$bicepOutput | Out-File azure-outputs.json -Force
Write-Host "✅ Infrastructure deployed!"
```

✅ **Expected**: JSON file saved with resource URLs

**STEP 6: Extract Resource Names**
```powershell
$outputs = Get-Content azure-outputs.json | ConvertFrom-Json
$webAppUrl = $outputs.webAppUrl.value
$keyVaultName = $outputs.keyVaultName.value

Write-Host "Web App URL: $webAppUrl"
Write-Host "Key Vault: $keyVaultName"
```

---

### PHASE 2: Configure Secrets (2 minutes)

**STEP 7: Generate and Store Secrets**
```powershell
# Create secure random values
$jwtSecret = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
$dbPassword = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})

# Store in Key Vault
az keyvault secret set --vault-name $keyVaultName --name "jwt-secret" --value $jwtSecret --output none
az keyvault secret set --vault-name $keyVaultName --name "db-password" --value $dbPassword --output none
az keyvault secret set --vault-name $keyVaultName --name "stripe-secret-key" --value "sk_test_placeholder" --output none
az keyvault secret set --vault-name $keyVaultName --name "firebase-api-key" --value "AIzaSyDOYqmfLOzd7ZcVBtxXqFjPV_ISgfvGbAs" --output none

Write-Host "✅ Secrets configured in Key Vault"
```

---

### PHASE 3: Deploy Backend API (5 minutes)

**STEP 8: Build Backend**
```powershell
cd backend
npm install --silent
npm run build
cd ..
```

✅ **Expected**: No errors, TypeScript compiles successfully

**STEP 9: Deploy to App Service**
```powershell
$appName = "cannabis-api-$(Get-Random -Minimum 1000 -Maximum 9999)"

az webapp up `
  --resource-group cannabis-delivery-rg `
  --name $appName `
  --runtime "NODE:18-lts" `
  --os-type Linux `
  --location eastus

Write-Host "✅ Backend deployed to: https://$appName.azurewebsites.net"
```

✅ **Expected**: Web app created and code deployed

**STEP 10: Wait for App to Start**
```powershell
Write-Host "Waiting for app to start (3 minutes)..."
Start-Sleep -Seconds 180

# Test health check
try {
    $health = Invoke-WebRequest -Uri "https://$appName.azurewebsites.net/health" `
        -Method Get -ErrorAction Stop
    Write-Host "✅ Backend is RUNNING!"
    Write-Host $health.Content
} catch {
    Write-Host "⏳ Still starting up, try again in 2 minutes"
    Write-Host "URL: https://$appName.azurewebsites.net/health"
}
```

---

### PHASE 4: Deploy Frontend Applications (Optional)

**STEP 11: Deploy Customer App**
```powershell
cd apps/customer-app
npm install --silent
npm run build

az staticwebapp create `
  --name cannabis-customer-app `
  --resource-group cannabis-delivery-rg `
  --location eastus `
  --sku "Free" `
  --source . `
  --output-location "build"

cd ../..
```

**STEP 12: Repeat for Other Apps**
```powershell
# Vendor Dashboard
cd apps/vendor-dashboard
npm install --silent
npm run build
az staticwebapp create --name cannabis-vendor-dashboard --resource-group cannabis-delivery-rg --location eastus --sku "Free"
cd ../..

# Driver App
cd apps/driver-app
npm install --silent
npm run build
az staticwebapp create --name cannabis-driver-app --resource-group cannabis-delivery-rg --location eastus --sku "Free"
cd ../..

# Admin Panel
cd apps/admin-panel
npm install --silent
npm run build
az staticwebapp create --name cannabis-admin-panel --resource-group cannabis-delivery-rg --location eastus --sku "Free"
cd ../..
```

---

## 🔍 VERIFICATION COMMANDS

### Check All Resources
```powershell
az resource list --resource-group cannabis-delivery-rg `
  --query "[][name, type, properties.provisioningState]" `
  -o table
```

### View Backend Logs
```powershell
az webapp log tail `
  --resource-group cannabis-delivery-rg `
  --name $appName `
  --follow
```

### List All Web Apps
```powershell
az webapp list --resource-group cannabis-delivery-rg `
  --query "[][name, defaultHostName, state]" `
  --output table
```

### Check Database Connection
```powershell
# Get PostgreSQL server name
$dbServer = az resource list -g cannabis-delivery-rg `
  --query "[?type=='Microsoft.DBforPostgreSQL/flexibleServers'].name" `
  --output tsv

Write-Host "Database Server: $dbServer"
```

---

## 📊 YOUR DEPLOYED URLS

After successful deployment:

```
🔗 BACKEND API
https://cannabis-api-[XXXX].azurewebsites.net

Health Check:
https://cannabis-api-[XXXX].azurewebsites.net/health

🎨 FRONTEND APPLICATIONS (after Phase 4)
Customer App: https://cannabis-customer-app.azurestaticapps.net
Vendor Dashboard: https://cannabis-vendor-dashboard.azurestaticapps.net
Driver App: https://cannabis-driver-app.azurestaticapps.net
Admin Panel: https://cannabis-admin-panel.azurestaticapps.net
```

---

## ⚠️ TROUBLESHOOTING

### Issue: "Decryption failed" Azure CLI Error
**Solution:**
```powershell
az logout
Remove-Item -Path "$env:APPDATA\.azure" -Recurse -Force -ErrorAction SilentlyContinue
az login
```

### Issue: App Service Won't Start
**Check logs:**
```powershell
az webapp log tail -g cannabis-delivery-rg -n $appName
```

**Restart:**
```powershell
az webapp restart -g cannabis-delivery-rg -n $appName
```

### Issue: Health Check Returns 404
**Solution:** Wait 5 more minutes - app might still be starting. Check logs above.

### Issue: Key Vault Access Denied
**Solution:** Grant app access:
```powershell
$principalId = az webapp identity show -g cannabis-delivery-rg -n $appName `
  --query principalId -o tsv

az keyvault set-policy `
  --name $keyVaultName `
  --object-id $principalId `
  --secret-permissions get list
```

---

## 💰 COSTS

Monthly estimate:
- **App Service B1**: $12
- **PostgreSQL (Burstable)**: $30
- **Storage**: $1
- **Key Vault**: $0.60
- **Static Web Apps (Free tier)**: Free

**Total: ~$50/month**

---

## 📝 NEXT STEPS

After successful deployment:

1. ✅ Test backend health endpoint
2. ⏳ Deploy all 4 frontend applications
3. ⏳ Update Stripe webhook URLs
4. ⏳ Configure Firebase credentials
5. ⏳ Set up custom domain (optional)
6. ⏳ Enable HTTPS (automatic with Azure)
7. ⏳ Configure monitoring alerts
8. ⏳ Set up CI/CD with GitHub Actions

---

## 📞 SUPPORT

- **Azure Portal**: https://portal.azure.com
- **View Resources**: https://portal.azure.com/#resource/subscriptions/bb813320-d9cc-4e8e-bf3c-e6d8b6d09772/resourceGroups/cannabis-delivery-rg/overview
- **Logs & Monitoring**: Application Insights in Azure Portal
- **Documentation**: See QUICK-DEPLOY.md for detailed commands

---

## ✨ YOU ARE HERE:

```
Phase 1: Infrastructure Setup ✅
├─ ✅ Azure subscription ready
├─ ✅ Resource group created
├─ ✅ Bicep template ready
└─ ⏳ DEPLOY INFRASTRUCTURE (next step)

Phase 2: Configure Secrets ⏳

Phase 3: Deploy Backend ⏳

Phase 4: Deploy Frontends ⏳

Phase 5: Verify & Test ⏳
```

**READY? Follow the steps in "DEPLOYMENT WALKTHROUGH" above! 🚀**

