# 🧪 Cannabis Delivery Platform - App Verification Guide

## Overview
This guide helps verify that all 4 frontend applications are correctly configured and accessible at their Azure Static Web Apps URLs.

## 📱 Application URLs

| App | URL | Resource Name |
|-----|-----|---------------|
| **Customer App** | https://orange-mud-083f9ac0f.4.azurestaticapps.net | orange-mud-083f9ac0f |
| **Vendor Dashboard** | https://gentle-grass-00bb9010f.1.azurestaticapps.net | gentle-grass-00bb9010f |
| **Driver App** | https://red-mud-0b72f350f.2.azurestaticapps.net | red-mud-0b72f350f |
| **Admin Panel** | https://kind-stone-01c35960f.1.azurestaticapps.net | kind-stone-01c35960f |

## 📋 Verification Checklist

### 1. Customer App (orange-mud-083f9ac0f)
- [ ] **URL Accessible**: https://orange-mud-083f9ac0f.4.azurestaticapps.net
  - [ ] Page loads without 404 errors
  - [ ] No console errors (F12 > Console)
  - [ ] Firebase config loads (check Network tab for firebase)
  - [ ] Header displays correctly
  - [ ] Navigation bar visible (Home, Products, Login, Register)

- [ ] **Functionality**:
  - [ ] Home page displays welcome message and hero section
  - [ ] Products page loads and displays product grid
  - [ ] Login form accessible and functional
  - [ ] Register form accessible
  - [ ] Cart functionality works (add to cart button)
  - [ ] Local storage saves user session (logout and refresh - user persists)

- [ ] **Build Configuration**:
  - [ ] Output location: `build/`
  - [ ] API URL configured: `REACT_APP_API_URL` env var set
  - [ ] Firebase env vars set in deployment secrets
  - [ ] Stripe key configured: `REACT_APP_STRIPE_PUBLIC_KEY`

### 2. Vendor Dashboard (gentle-grass-00bb9010f)
- [ ] **URL Accessible**: https://gentle-grass-00bb9010f.1.azurestaticapps.net
  - [ ] Page loads without 404 errors
  - [ ] Header and nav visible
  - [ ] Dashboard layout renders
  - [ ] No console errors (F12 > Console)

- [ ] **Functionality**:
  - [ ] Vendor login form accessible
  - [ ] Inventory management section loads
  - [ ] Order list displays
  - [ ] Product creation/edit forms accessible
  - [ ] Analytics/stats section visible
  - [ ] Settings page accessible

- [ ] **Build Configuration**:
  - [ ] Output location: `build/`
  - [ ] API URL configured correctly
  - [ ] Firebase integration (if used)
  - [ ] Routing works (can navigate between tabs/pages)

### 3. Driver App (red-mud-0b72f350f)
- [ ] **URL Accessible**: https://red-mud-0b72f350f.2.azurestaticapps.net
  - [ ] Page loads without 404 errors
  - [ ] Driver interface displays
  - [ ] Map container visible (if Azure Maps configured)
  - [ ] No console errors

- [ ] **Functionality**:
  - [ ] Driver login form accessible
  - [ ] Available orders list loads
  - [ ] Delivery tracking interface accessible
  - [ ] Accept/decline order buttons present
  - [ ] Real-time location tracking UI present (Socket.IO)
  - [ ] Navigation/routing displays correctly

- [ ] **Build Configuration**:
  - [ ] Output location: `build/`
  - [ ] API URL set to backend service
  - [ ] Azure Maps API key configured
  - [ ] Socket.IO connection configured

### 4. Admin Panel (kind-stone-01c35960f)
- [ ] **URL Accessible**: https://kind-stone-01c35960f.1.azurestaticapps.net
  - [ ] Page loads without 404 errors
  - [ ] Admin interface displays
  - [ ] Dashboard layout visible
  - [ ] No console errors

- [ ] **Functionality**:
  - [ ] Admin login form accessible
  - [ ] User management section accessible
  - [ ] Vendor approval workflow visible
  - [ ] Analytics dashboard displays
  - [ ] Compliance monitoring section loads
  - [ ] Settings/configuration pages accessible

- [ ] **Build Configuration**:
  - [ ] Output location: `build/`
  - [ ] API URL configured
  - [ ] Role-based access controls working

---

## 🔧 Troubleshooting

### If an app shows 404 or blank page:

1. **Check GitHub Actions Workflow**:
   ```bash
   # View recent workflow runs
   gh run list --repo XRMindCNTRL/GetGanja
   
   # Check specific app workflow
   gh run view <run-id> --log
   ```

2. **Verify Static Web App Configuration**:
   ```bash
   # Login to Azure
   az login
   
   # Check SWA resource
   az staticwebapp list --resource-group cannabis-delivery-rg
   ```

3. **Check Build Output**:
   - Ensure `build/` folder exists in each app: `apps/{app}/build/`
   - Verify `package.json` scripts: `npm run build` should create `build/` folder
   - Check `output_location` in workflow matches actual build output

4. **Environment Variables**:
   - Check that all required env vars are set in Azure Static Web Apps:
     - `REACT_APP_API_URL`
     - `REACT_APP_STRIPE_PUBLIC_KEY`
     - `REACT_APP_FIREBASE_*` (all Firebase config vars)
     - `REACT_APP_AZURE_MAPS_KEY`
   
   ```bash
   # Check app settings via portal:
   az staticwebapp appsettings list \
     --resource-group cannabis-delivery-rg \
     --name <resource-name>
   ```

5. **Clear Browser Cache**:
   - Hard refresh: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
   - Clear cookies: Inspect > Application > Clear Site Data

### If an app has console errors:

1. **Missing API Connection**:
   - Check `REACT_APP_API_URL` points to backend: `https://getganja.azurewebsites.net`
   - Verify backend API is running and accessible
   - Check CORS configuration on backend

2. **Firebase Issues**:
   - Verify all Firebase env vars are set in SWA:
     - `REACT_APP_FIREBASE_API_KEY`
     - `REACT_APP_FIREBASE_AUTH_DOMAIN`
     - `REACT_APP_FIREBASE_PROJECT_ID`
     - `REACT_APP_FIREBASE_STORAGE_BUCKET`
     - `REACT_APP_FIREBASE_MESSAGING_SENDER_ID`
     - `REACT_APP_FIREBASE_APP_ID`
   - Check Firebase project is active and accessible

3. **Stripe Integration**:
   - Verify `REACT_APP_STRIPE_PUBLIC_KEY` is set
   - Check Stripe account is active and publishable key is correct

---

## ✅ Full Verification Script

Run this PowerShell script to verify all apps:

```powershell
$apps = @(
    @{name="Customer App"; url="https://orange-mud-083f9ac0f.4.azurestaticapps.net"},
    @{name="Vendor Dashboard"; url="https://gentle-grass-00bb9010f.1.azurestaticapps.net"},
    @{name="Driver App"; url="https://red-mud-0b72f350f.2.azurestaticapps.net"},
    @{name="Admin Panel"; url="https://kind-stone-01c35960f.1.azurestaticapps.net"}
)

Write-Host "====== Cannabis Delivery Platform - App Verification ======" -ForegroundColor Cyan

foreach ($app in $apps) {
    Write-Host "`nChecking: $($app.name)" -ForegroundColor Yellow
    Write-Host "URL: $($app.url)"
    
    try {
        $response = Invoke-WebRequest -Uri $app.url -UseBasicParsing -TimeoutSec 10
        Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
        
        if ($response.Content -like "*root*" -or $response.Content -like "*app*") {
            Write-Host "Content: HTML page loaded ✓" -ForegroundColor Green
        } else {
            Write-Host "Content: May be blank or misconfigured ⚠️" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Status: ❌ ERROR - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n====== API Health Check ======" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "https://getganja.azurewebsites.net/health" -UseBasicParsing -TimeoutSec 10
    Write-Host "Backend API: ✓ Accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "Backend API: ❌ Not accessible - $($_.Exception.Message)" -ForegroundColor Red
}
```

---

## 🚀 Local Testing (Before Deployment)

Test each app locally before checking production URLs:

```bash
# Terminal 1: Start backend
cd backend && npm run dev

# Terminal 2: Test each app
cd apps/customer-app && npm start
# Access at http://localhost:3001

# Then separately test:
cd apps/vendor-dashboard && npm start
# Access at http://localhost:3002

cd apps/driver-app && npm start
# Access at http://localhost:3003

cd apps/admin-panel && npm start
# Access at http://localhost:3004
```

---

## 📊 Deployment Status Check

```bash
# View recent deployments
az staticwebapp list --resource-group cannabis-delivery-rg

# Check specific app deployment
az staticwebapp show \
  --resource-group cannabis-delivery-rg \
  --name orange-mud-083f9ac0f
```

---

## 🔐 Environment Variables Needed

Ensure these are set in each Static Web App configuration:

**All Apps**:
- `REACT_APP_API_URL=https://getganja.azurewebsites.net`
- `REACT_APP_STRIPE_PUBLIC_KEY=pk_test_...`

**Apps Using Firebase** (Customer, Vendor, Driver, Admin):
- `REACT_APP_FIREBASE_API_KEY=...`
- `REACT_APP_FIREBASE_AUTH_DOMAIN=...`
- `REACT_APP_FIREBASE_PROJECT_ID=...`
- `REACT_APP_FIREBASE_STORAGE_BUCKET=...`
- `REACT_APP_FIREBASE_MESSAGING_SENDER_ID=...`
- `REACT_APP_FIREBASE_APP_ID=...`

**Driver App (if using Azure Maps)**:
- `REACT_APP_AZURE_MAPS_KEY=...`

---

## 📝 Next Steps

Once all apps are verified and displaying correctly:

1. ✅ Test user registration and login flow across all apps
2. ✅ Verify backend API connectivity from each app
3. ✅ Test real-time features (Socket.IO for order updates)
4. ✅ Verify Firebase notifications
5. ✅ Test payment flow (Stripe integration)
6. ✅ Verify geolocation and maps functionality
7. ✅ Monitor Azure Application Insights for errors

---

**Last Updated**: January 6, 2026
**Status**: Ready for Verification
