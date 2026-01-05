# DEPLOY NOW - NO LOCAL AZURE LOGIN NEEDED

## You DON'T Have To Do Anything Local

Your GitHub Actions workflow is already committed. Follow these 3 steps:

### STEP 1: Get Your Azure Service Principal (run in NEW PowerShell window, NOT the one with failed logins)

```powershell
# OPEN A BRAND NEW POWERSHELL WINDOW
# Paste this entire block and hit Enter:

$sub = "2e0757c5-8619-4f8b-a484-4e12fe6ca133"

# This will open your browser for MFA ONE TIME
az login

# Wait for it to say "You have logged in successfully"
# Then run this:

$sp = az ad sp create-for-rbac `
  --name "cannabis-github-ci-$(Get-Random)" `
  --role Contributor `
  --scopes "/subscriptions/$sub" | ConvertFrom-Json

@{
    clientId       = $sp.appId
    clientSecret   = $sp.password
    subscriptionId = $sp.subscription
    tenantId       = $sp.tenant
} | ConvertTo-Json | Set-Clipboard

Write-Host "✅ Service Principal JSON copied to clipboard!" -ForegroundColor Green
```

### STEP 2: Add GitHub Secret

1. Go to: https://github.com/XRMindCNTRL/GetGanja
2. Click **Settings** → **Secrets and Variables** → **Actions**
3. Click **New repository secret**
4. Name: `AZURE_CREDENTIALS`
5. Paste the JSON from your clipboard
6. Click **Add secret**

### STEP 3: Add Other Secrets (same Settings page)

Click **New repository secret** for each:

- **DB_PASSWORD**: `Cannabis@123456789!Secure!Password!123`
- **JWT_SECRET**: `ThisIsAVeryLongJWTSecretKeyThatIsAtLeast64CharactersLongForSecurity123456789`
- **STRIPE_SECRET_KEY**: `sk_live_51234567890abcdefg` (your actual Stripe key)
- **FIREBASE_ADMIN_KEY**: `{your firebase json}` (your actual Firebase key)

### STEP 4: Run Deployment (GitHub does everything)

1. Go to: https://github.com/XRMindCNTRL/GetGanja/actions
2. Click **Deploy to Azure** workflow
3. Click **Run workflow** → **green button**
4. Wait 10-15 minutes
5. **DONE** - deployed and running

---

## What Gets Deployed Automatically

✅ PostgreSQL database  
✅ Redis cache  
✅ Key Vault with secrets  
✅ Storage account for files  
✅ Backend API (App Service)  
✅ Customer app (Static Web App)  
✅ Vendor dashboard (Static Web App)  
✅ Driver app (Static Web App)  
✅ Admin panel (Static Web App)  

## Your URLs After Deployment

Check GitHub Actions output or Azure Portal for:

- Backend API: `https://cannabis-api-[random].azurewebsites.net`
- Customer app: `https://[hash].azurestaticapps.net`
- Vendor dashboard: `https://[hash].azurestaticapps.net`
- Driver app: `https://[hash].azurestaticapps.net`
- Admin panel: `https://[hash].azurestaticapps.net`

---

## ⚠️ IMPORTANT: Browser MFA Happens ONCE

When you run `az login` in Step 1, it will open a browser. **Complete the MFA one time.** That's it. Then it proceeds automatically. The Service Principal auth doesn't need MFA after that.

---

**You're about 5 minutes away from production deployment. Let's go.**
