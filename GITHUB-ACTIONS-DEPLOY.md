# Azure Deployment via GitHub Actions - IMMEDIATE FIX

## The Problem
- Azure CLI cannot authenticate due to tenant-level MFA enforcement
- Interactive login fails with MSAL token cache errors
- Local deployment is blocked

## The Solution
**Deploy via GitHub Actions** - bypasses local MFA entirely using Azure Service Principal credentials

## Setup (5 minutes)

### Step 1: Create Azure Service Principal for GitHub
```powershell
# Run in PowerShell as your Azure account
$subscriptionId = "2e0757c5-8619-4f8b-a484-4e12fe6ca133"
$sp = az ad sp create-for-rbac `
  --name "cannabis-delivery-github-ci" `
  --role "Contributor" `
  --scopes "/subscriptions/$subscriptionId"

# Copy the entire JSON output - you'll need it next
$sp | ConvertTo-Json
```

### Step 2: Add GitHub Secrets
Go to: **GitHub > Your Repo > Settings > Secrets and Variables > Actions**

Click "New Repository Secret" and add:

1. **AZURE_CREDENTIALS** (paste the entire JSON from Step 1)
   ```json
   {
     "clientId": "...",
     "clientSecret": "...",
     "subscriptionId": "2e0757c5-8619-4f8b-a484-4e12fe6ca133",
     "tenantId": "..."
   }
   ```

2. **DB_PASSWORD** (generate random 32+ char password)
   ```
   MyS3cur3DatabaseP@ssw0rd!
   ```

3. **JWT_SECRET** (generate random 64+ char string)
   ```
   aVeryLongRandomSecretKey...
   ```

4. **STRIPE_SECRET_KEY**
   ```
   sk_live_...
   ```

5. **FIREBASE_ADMIN_KEY**
   ```
   {...firebase json...}
   ```

### Step 3: Trigger Deployment
Go to **Actions > Deploy to Azure > Run Workflow**

Everything deploys automatically. No MFA needed.

## What Gets Deployed
✅ Azure infrastructure (Bicep)
✅ PostgreSQL database
✅ Key Vault with secrets
✅ Backend API to App Service
✅ Customer app to Static Web Apps
✅ Vendor dashboard to Static Web Apps
✅ Driver app to Static Web Apps
✅ Admin panel to Static Web Apps

## After Deployment
1. Check GitHub Actions output for deployed URLs
2. Test backend API: `https://<api>.azurewebsites.net/api/health`
3. Check each frontend URL in output
4. Configure custom domains if needed

## Troubleshooting

**Service Principal Creation Fails**
- Ensure you have Azure Owner/Admin role
- Check subscription ID is correct
- May need to disable security defaults temporarily

**GitHub Actions Fails to Authenticate**
- Verify AZURE_CREDENTIALS JSON is complete and unbroken
- Check all required secrets are set
- Try deleting and recreating the Service Principal

**Deployment Succeeds but No URLs Show**
- Wait 2-3 minutes for App Service startup
- Check Azure Portal > Resource Group for status
- Review GitHub Actions logs for specific errors

## Alternative: Manual CLI (if SP fails)
```powershell
# Clear everything
Remove-Item ~/.azure -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item ~/.msal -Recurse -Force -ErrorAction SilentlyContinue

# Login fresh in new PowerShell window
az login

# Then run deployment
./deploy-all.ps1
```

---
**✅ Recommended: Use GitHub Actions approach - it's faster and doesn't require local MFA**
