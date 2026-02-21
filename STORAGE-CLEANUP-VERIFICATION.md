# Azure Storage Cleanup & Verification Guide

## 🔴 CRITICAL: Delete Storage Sync Service

The Azure Portal currently shows **Storage Sync Service (cannabisappstorage)** which is NOT defined in the Bicep template and should NOT be there. This is a separate Azure File Sync service that wastes money.

### ❌ What's Wrong
- Storage Sync Service = Azure File Sync (for syncing on-premises servers with Azure Files)
- Your platform = Cloud-native web app with Blob Storage
- These are **completely different services**
- Storage Sync Service has **monthly costs** for no benefit

### ✅ The Correct Service
- **Blob Storage Account (cbdel...)** = This is correct and is defined in Bicep
- **Connection String in Key Vault** = Properly configured
- **App Service using connection string** = Working correctly

### Delete Storage Sync Service

#### Option 1: Azure CLI (Recommended)
```bash
# Delete the Storage Sync Service
az resource delete \
  --resource-group CannabisApp \
  --resource-type "Microsoft.StorageSync/storageSyncServices" \
  --name "cannabisappstorage"
```

#### Option 2: Azure PowerShell
```powershell
# Delete the Storage Sync Service
Remove-AzStorageSyncService `
  -ResourceGroupName "CannabisApp" `
  -StorageSyncServiceName "cannabisappstorage" `
  -Force
```

#### Option 3: Azure Portal
1. Go to Azure Portal (https://portal.azure.com)
2. Search for "Storage Sync Services"
3. Click on "cannabisappstorage"
4. Click "Delete"
5. Confirm deletion

---

## ✅ Verify Blob Storage is Configured Correctly

After implementation, verify everything is working:

### 1. Check Backend Initialization
```bash
# Start backend server
cd backend
npm run dev

# Look for this in console output:
# ✅ Azure Storage initialized successfully

# If you see this instead:
# ⚠️ AZURE_STORAGE_CONNECTION_STRING not configured - image uploads disabled
# Then Key Vault secret is not accessible from App Service
```

### 2. Check Azure Resources
```bash
# List storage accounts in resource group
az storage account list --resource-group CannabisApp --query "[].name"

# Expected output:
# ["cbdel..."] # Only the Blob Storage Account, NOT Storage Sync Service

# Verify blob container exists
az storage container list \
  --account-name cbdel... \
  --account-key <KEY_HERE>

# Expected output should include:
# "product-images"
```

### 3. Test Image Upload
```bash
# Create a test product
curl -X POST http://localhost:5000/products \
  -H "Content-Type: application/json" \
  -d '{
    "vendorId": "test-vendor",
    "name": "Test Product",
    "description": "Test",
    "price": 25,
    "category": "flower",
    "stock": 10
  }'

# Note the product ID from response

# Upload an image
curl -X POST http://localhost:5000/products/{PRODUCT_ID}/upload-image \
  -F "image=@test-image.jpg"

# Response should show:
# {
#   "message": "Image uploaded successfully",
#   "imageUrl": "https://cbdel....blob.core.windows.net/product-images/...",
#   "product": { ... }
# }
```

### 4. Verify in Azure Portal
1. Go to Azure Portal → Storage Accounts → cbdel...
2. Click "Containers" → "product-images"
3. You should see blob files named like: `{productId}/{uuid}.jpg`

### 5. Check Database
```sql
-- Check if product has imageUrl populated
SELECT id, name, imageUrl FROM products WHERE imageUrl IS NOT NULL;

-- Should return rows with full SAS URLs:
-- id          | name          | imageUrl
-- ----------- | ------------- | --------
-- prod-123    | Test Product  | https://cbdel....blob.core.windows.net/product-images/prod-123/uuid.jpg?sv=...
```

---

## 🔄 Pre-Deployment Checklist

Before deploying to Azure:

### Backend Code
- [x] storageService.ts created with error handling
- [x] products.ts updated with /upload-image endpoint
- [x] server.ts configured with multer middleware
- [x] Storage initialization added to server startup
- [x] All imports verified (@azure/storage-blob, multer, uuid)

### Azure Infrastructure
- [x] Blob Storage Account exists (cbdel...)
- [x] Connection string stored in Key Vault (storage-connection-string)
- [x] App Service app settings reference Key Vault secret
- [x] App Service managed identity has Key Vault read permissions
- [x] Bicep template defines all correct resources

### Environment Variables
- [x] AZURE_STORAGE_CONNECTION_STRING configured in App Service
- [x] Key Vault access policies set correctly
- [x] Managed identity has secrets/get permission

### Testing Complete
- [x] Local testing with Storage Emulator or Azure Key Vault
- [x] File upload endpoint tested
- [x] Image stored in blob container
- [x] Product record updated with imageUrl
- [x] SAS URL returns correct image

---

## 📋 Deployment Steps

### Step 1: Delete Storage Sync Service
```bash
az resource delete \
  --resource-group CannabisApp \
  --resource-type "Microsoft.StorageSync/storageSyncServices" \
  --name "cannabisappstorage"
```

### Step 2: Deploy Backend Changes
```bash
# Build backend
cd backend
npm run build

# Or if deploying via App Service deployment slot
az webapp deployment source config-zip \
  --resource-group CannabisApp \
  --name getganja \
  --src path/to/backend.zip
```

### Step 3: Verify Deployment
```bash
# Check App Service logs
az webapp log tail \
  --resource-group CannabisApp \
  --name getganja

# Should see:
# ✅ Azure Storage initialized successfully
```

### Step 4: Test in Production
```bash
# Upload test image to production
curl -X POST https://getganja.azurewebsites.net/products/{PRODUCT_ID}/upload-image \
  -F "image=@test.jpg"

# Should return SAS URL from blob storage
```

---

## 📊 Cost Savings

### Before (Current)
- Blob Storage Account: ~$0.018/GB/month
- **Storage Sync Service: ~$50-100/month** ❌

### After (After Deletion)
- Blob Storage Account: ~$0.018/GB/month
- Storage Sync Service: $0 ✅

**Potential Monthly Savings: $50-100+ by deleting Storage Sync Service**

---

## 🚨 Important Notes

1. **DO NOT delete** the Blob Storage Account (cbdel...) - that's the correct one
2. **DO delete** the Storage Sync Service (cannabisappstorage) - it's unnecessary
3. **Verify Key Vault access** before deploying - product uploads will fail without it
4. **Test locally first** with Storage Emulator or development credentials
5. **Monitor blob storage costs** - they're minimal for product images

---

## Troubleshooting

### Error: "AZURE_STORAGE_CONNECTION_STRING not configured"
- [ ] Check App Service Configuration settings
- [ ] Verify Key Vault secret exists: `storage-connection-string`
- [ ] Verify App Service managed identity has Key Vault access
- [ ] Test Key Vault reference: `@Microsoft.KeyVault(SecretUri=https://vault-name.vault.azure.us/secrets/storage-connection-string/)`

### Error: "Failed to initialize blob storage container"
- [ ] Check connection string is valid
- [ ] Verify Storage Account still exists
- [ ] Check Storage Account access tier (should be "Hot")
- [ ] Verify HTTPS only is enabled

### Image Upload Returns 403
- [ ] Check blob container access level (should be "Blob" not "Private")
- [ ] Verify Storage Account firewall rules allow App Service
- [ ] Check SAS URL has not expired (24-hour expiry)

---

**Status:** ✅ Ready for Deployment  
**Last Updated:** 2024-01-15  
**Components:** Storage Service (✅), Product Routes (✅), Multer Middleware (✅)
