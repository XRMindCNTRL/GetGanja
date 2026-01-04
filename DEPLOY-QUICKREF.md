# 🎯 QUICK REFERENCE - Cannabis Delivery Platform Azure Deployment

## 📋 All Deployment Guides

| Document | Purpose | Best For |
|----------|---------|----------|
| **DEPLOYMENT-READY.md** | Overview & summary | Understanding what's ready |
| **DEPLOYMENT-CHECKLIST.md** | Step-by-step guide | Following along visually |
| **QUICK-DEPLOY.md** | Command reference | Copy-paste deployment |
| **AZURE-DEPLOYMENT-MANUAL.md** | Technical details | Understanding architecture |

---

## ⚡ FASTEST DEPLOYMENT (5 minutes to get started)

### 1. Open PowerShell Terminal
```powershell
cd c:\Users\pc\Desktop\cannabis-delivery-platform
```

### 2. Verify Azure Login
```powershell
az account show
```

### 3. Run Automated Deployment
```powershell
powershell -ExecutionPolicy Bypass -File azure-deploy-auto.ps1 -Phase all
```

**That's it!** Script handles everything automatically.

---

## 🔑 Key Commands (Copy-Paste Ready)

### Authenticate
```powershell
az login
az account set --subscription "bb813320-d9cc-4e8e-bf3c-e6d8b6d09772"
```

### Create Infrastructure
```powershell
az group create --name cannabis-delivery-rg --location eastus

$output = az deployment group create `
  --resource-group cannabis-delivery-rg `
  --name cannabis-deployment `
  --template-file infra/main.bicep `
  --parameters environmentName="production" `
  --query "properties.outputs" `
  -o json

$output | Out-File azure-outputs.json -Force
$config = $output | ConvertFrom-Json
$webAppUrl = $config.webAppUrl.value
$keyVaultName = $config.keyVaultName.value
```

### Configure Secrets
```powershell
$jwtSecret = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
$dbPassword = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})

az keyvault secret set --vault-name $keyVaultName --name "jwt-secret" --value $jwtSecret --output none
az keyvault secret set --vault-name $keyVaultName --name "db-password" --value $dbPassword --output none
az keyvault secret set --vault-name $keyVaultName --name "stripe-secret-key" --value "sk_test_placeholder" --output none
az keyvault secret set --vault-name $keyVaultName --name "firebase-api-key" --value "AIzaSyDOYqmfLOzd7ZcVBtxXqFjPV_ISgfvGbAs" --output none
```

### Deploy Backend
```powershell
cd backend
npm install
npm run build
cd ..

az webapp up `
  --resource-group cannabis-delivery-rg `
  --name cannabis-api-$(Get-Random -Minimum 1000 -Maximum 9999) `
  --runtime "NODE:18-lts" `
  --os-type Linux `
  --location eastus
```

### Test
```powershell
# Wait 3 minutes then test
Start-Sleep -Seconds 180
Invoke-WebRequest -Uri "https://cannabis-api-XXXX.azurewebsites.net/health"
```

---

## 🔍 Verification Commands

```powershell
# Check current account
az account show

# List resource groups
az group list --query "[].name" -o table

# Check deployment status
az deployment group show -n cannabis-deployment -g cannabis-delivery-rg --query "properties.provisioningState"

# View backend logs
az webapp log tail -g cannabis-delivery-rg -n cannabis-api-XXXX

# List all resources
az resource list -g cannabis-delivery-rg --query "[][name,type]" -o table

# Check Key Vault
az keyvault secret list --vault-name cannabis-delivery-kv-XXXX --query "[].name" -o table
```

---

## 📍 Expected URLs After Deployment

```
Backend API:
https://cannabis-api-[RANDOM].azurewebsites.net

Health Check:
https://cannabis-api-[RANDOM].azurewebsites.net/health

Frontend Apps (After Phase 4):
https://cannabis-customer-app.azurestaticapps.net
https://cannabis-vendor-dashboard.azurestaticapps.net
https://cannabis-driver-app.azurestaticapps.net
https://cannabis-admin-panel.azurestaticapps.net
```

---

## ⏱️ Timeline

| Phase | Time | Status |
|-------|------|--------|
| Authenticate | 1 min | ⚡ Quick |
| Create Resources | 15 min | ⏳ Wait |
| Secrets | 1 min | ⚡ Quick |
| Build Backend | 3 min | ⚡ Quick |
| Deploy Backend | 2 min | ⚡ Quick |
| App Startup | 3 min | ⏳ Wait |
| Test | 2 min | ⚡ Quick |
| Deploy Frontends | 5 min | ⚡ Quick |
| **TOTAL** | **~32 min** | 📊 |

---

## 🚨 Troubleshooting Quick Fixes

### "Decryption failed" error
```powershell
az logout
Remove-Item "$env:APPDATA\.azure" -Recurse -Force -ErrorAction SilentlyContinue
az login
```

### App won't start
```powershell
# Check logs
az webapp log tail -g cannabis-delivery-rg -n cannabis-api-XXXX

# Restart
az webapp restart -g cannabis-delivery-rg -n cannabis-api-XXXX
```

### Key Vault access denied
```powershell
$principalId = az webapp identity show -g cannabis-delivery-rg -n cannabis-api-XXXX --query principalId -o tsv
az keyvault set-policy --name cannabis-delivery-kv-XXXX --object-id $principalId --secret-permissions get list
```

### Deployment timeout
```powershell
az deployment group show -n cannabis-deployment -g cannabis-delivery-rg --query "properties.provisioningState"
```

---

## 📞 Support Resources

| Item | Link |
|------|------|
| Azure Portal | https://portal.azure.com |
| Azure CLI Docs | https://learn.microsoft.com/cli/azure |
| App Service | https://learn.microsoft.com/azure/app-service |
| PostgreSQL | https://learn.microsoft.com/azure/postgresql |
| Key Vault | https://learn.microsoft.com/azure/key-vault |

---

## 💰 Cost Estimate

| Service | Tier | Monthly Cost |
|---------|------|--------------|
| App Service | B1 | $12 |
| PostgreSQL | Burstable | $30 |
| Storage | Standard | $1 |
| Key Vault | Standard | $0.60 |
| App Insights | Free | $0 |
| Static Web Apps | Free | $0 |
| **Total** | | **~$50** |

---

## ✅ Pre-Deployment Checklist

- [ ] Azure subscription is active
- [ ] `az account show` works
- [ ] `az --version` shows Azure CLI installed
- [ ] In correct project directory
- [ ] Terminal/PowerShell open
- [ ] Stable internet connection
- [ ] ~30 minutes available

---

## 🎯 Three Deployment Options

### Option 1: Fully Automated (EASIEST)
```powershell
powershell -ExecutionPolicy Bypass -File azure-deploy-auto.ps1
```

### Option 2: Guided Checklist (SAFEST)
Follow steps in: **DEPLOYMENT-CHECKLIST.md**

### Option 3: Manual Commands (FASTEST for experts)
Copy commands from: **QUICK-DEPLOY.md**

---

## 📊 Azure Resources Summary

```
Resource Group: cannabis-delivery-rg
├─ App Service Plan (B1)
│  └─ Web App (cannabis-api-XXXX)
├─ PostgreSQL Flexible Server
│  └─ Database (cannabis-delivery-db)
├─ Storage Account
│  └─ Blob Containers
├─ Key Vault
│  └─ Secrets (jwt, db password, etc.)
├─ Application Insights
├─ Log Analytics Workspace
├─ Azure AI Services
├─ Azure AI Search
├─ Azure AI Hub
└─ Azure AI Project
```

---

## 🎓 Next Steps

1. **Choose Option** (Automated, Guided, or Manual)
2. **Run Deployment** (~30 minutes)
3. **Verify** (Test health endpoint)
4. **Configure** (Stripe, Firebase, etc.)
5. **Deploy Frontends** (4 React apps)
6. **Monitor** (Application Insights)
7. **Optimize** (CDN, caching, etc.)

---

## 🚀 READY?

1. Open terminal
2. `cd c:\Users\pc\Desktop\cannabis-delivery-platform`
3. Choose your option:
   - **Easiest**: `powershell -ExecutionPolicy Bypass -File azure-deploy-auto.ps1`
   - **Guided**: Open `DEPLOYMENT-CHECKLIST.md`
   - **Manual**: Open `QUICK-DEPLOY.md`

**You got this! 🎉**

