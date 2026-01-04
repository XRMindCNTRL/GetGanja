# 🚀 Post-Deployment Setup Guide

## Overview

After running the Azure deployment scripts, your Cannabis Delivery Platform is deployed but needs final configuration to be fully operational.

## ⚡ Quick Start - Essential Next Steps

### 1. Run the Setup Script to Create Azure Infrastructure

**For Windows PowerShell:**
```powershell
# Navigate to your project directory
cd C:\Users\pc\Desktop\cannabis-delivery-platform

# Run the setup script
.\setup-production.ps1
```

**What this script does:**
- Authenticates with Azure CLI
- Creates resource group and deploys infrastructure using Bicep
- Sets up PostgreSQL database, Key Vault, Storage Account
- Generates secure secrets (JWT, database password)
- Stores all secrets securely in Azure Key Vault

**Expected output:**
```
🚀 Setting up Cannabis Delivery Platform for Azure Production
===========================================================
🔐 Step 1: Azure Authentication
📋 Available subscriptions:
...
✅ Azure resources deployed successfully!
   Web App URL: https://your-app-name.azurewebsites.net
   Key Vault: cannabis-kv-prod
   Storage Account: cannabisstorageprod
```

### 2. Run the Deploy Script to Publish Applications

**After setup completes, run:**
```powershell
# Deploy all applications
.\deploy-azure.ps1
```

**What this script does:**
- Builds and deploys backend API to Azure App Service
- Deploys all frontend applications to Azure Static Web Apps
- Configures environment variables and app settings
- Sets up CORS and security policies

**Expected output:**
```
🚀 Azure Deployment Script
==========================
✅ Deployment Complete!
Your applications have been deployed to Azure:
🔗 Backend API: https://your-app-name.azurewebsites.net
🎨 Frontend Applications:
• Customer App: Check Azure Static Web Apps
• Vendor Dashboard: Check Azure Static Web Apps
• Driver App: Check Azure Static Web Apps
• Admin Panel: Check Azure Static Web Apps
```

### 3. Configure Stripe Webhooks for Payment Processing

**Critical Step - Required for payments to work**

#### Step-by-Step Stripe Webhook Setup

1. **Access Stripe Dashboard:**
   - Visit: https://dashboard.stripe.com
   - Log in with your Stripe account
   - Navigate to **Developers** → **Webhooks**
   - Click **"Add endpoint"**

2. **Configure Webhook Endpoint:**
   - **Endpoint URL:** `https://your-app-service-name.azurewebsites.net/payments/webhook`
     - Replace `your-app-service-name` with your actual Azure App Service name
     - Example: `https://cannabis-delivery-api.azurewebsites.net/payments/webhook`
   - **Description:** `Cannabis Delivery Platform - Payment Webhooks`

3. **Select Required Events:**
   - `payment_intent.succeeded` - When payment is successful
   - `payment_intent.payment_failed` - When payment fails
   - `checkout.session.completed` - When checkout session completes
   - `invoice.payment_succeeded` - For subscription payments (if applicable)
   - `invoice.payment_failed` - For failed subscription payments (if applicable)

4. **Create the Webhook:**
   - Click **"Add endpoint"**
   - Copy the **Signing secret** (starts with `whsec_`) immediately
   - This secret is shown only once - save it securely

5. **Store Webhook Secret in Azure Key Vault:**
   ```powershell
   # Replace with your actual values
   $keyVaultName = "cannabis-kv-prod"  # From your setup script output
   $webhookSecret = "whsec_your_actual_webhook_secret_from_stripe"

   # Note: Your deployed Static Web App URL is: https://jolly-forest-020c52a0f.6.azurestaticapps.net
   # Resource Group: CannabisApp
   # Subscription: 2e0757c5-8619-4f8b-a484-4e12fe6ca133


   # Store the webhook secret
   az keyvault secret set `
     --vault-name $keyVaultName `
     --name "stripe-webhook-secret" `
     --value $webhookSecret
   ```

6. **Verify Webhook Configuration:**
   ```powershell
   # Test the webhook endpoint
   $appServiceUrl = "https://your-app-service-name.azurewebsites.net"

   curl -X POST "$appServiceUrl/payments/webhook" `
     -H "Content-Type: application/json" `
     -H "Stripe-Signature: test_signature" `
     -d '{"type": "payment_intent.succeeded", "data": {"object": {"id": "test"}}}'
   ```

#### Testing Stripe Webhooks

1. **Use Stripe CLI for Local Testing (Optional):**
   ```powershell
   # Install Stripe CLI
   # Download from: https://stripe.com/docs/stripe-cli

   # Login to Stripe
   stripe login

   # Forward webhooks to your local development server
   stripe listen --forward-to localhost:5000/payments/webhook
   ```

2. **Test with Stripe Dashboard:**
   - Go to **Payments** in Stripe Dashboard
   - Create a test payment
   - Check webhook delivery attempts in **Developers** → **Webhooks**

3. **Monitor Webhook Logs:**
   ```powershell
   # Check Azure App Service logs for webhook processing
   az webapp log tail `
     --resource-group cannabis-delivery-rg `
     --name your-app-service-name
   ```

#### Troubleshooting Webhook Issues

**Common Problems:**

1. **Webhook Not Receiving Events:**
   - Verify endpoint URL is correct and accessible
   - Check that events are selected in Stripe Dashboard
   - Ensure webhook secret is stored in Key Vault

2. **Signature Verification Fails:**
   - Confirm webhook secret is correctly stored
   - Check timestamp tolerance (default 5 minutes)
   - Verify webhook endpoint code handles signatures properly

3. **Events Not Processing:**
   - Check application logs for errors
   - Verify database connectivity
   - Ensure order status updates are working

**Webhook Event Handling:**
Your application should handle these events:
- `payment_intent.succeeded`: Update order status to paid
- `payment_intent.payment_failed`: Update order status to failed
- `checkout.session.completed`: Process completed checkout sessions

#### Security Best Practices

1. **Always verify webhook signatures** using the webhook secret
2. **Use HTTPS endpoints only** (Azure provides this automatically)
3. **Store webhook secrets securely** in Azure Key Vault
4. **Implement idempotency** to handle duplicate events
5. **Monitor webhook delivery** and handle failures gracefully

#### Webhook Retry Policy

Stripe automatically retries failed webhooks:
- Immediate retry on failure
- Exponential backoff for up to 3 days
- Manual retry available in Stripe Dashboard

**Your Stripe webhooks are now configured and ready to process payments securely!** 🎉

### 4. Set Up Custom Domain (Optional)

**If you want a custom domain instead of Azure URLs:**

1. **Purchase Domain:**
   - Go to GoDaddy, Namecheap, or your preferred registrar
   - Buy your domain (e.g., `mycannabisapp.com`)

2. **Configure in Azure:**
   ```powershell
   # Add custom domain to App Service
   az webapp config hostname set `
     --resource-group cannabis-delivery-rg `
     --name your-app-name `
     --hostname www.mycannabisapp.com

   # Azure will provide free SSL certificate
   az webapp config ssl create `
     --resource-group cannabis-delivery-rg `
     --name your-app-name `
     --hostname www.mycannabisapp.com
   ```

3. **Update DNS Records:**
   - **Type:** CNAME
   - **Name:** www
   - **Value:** your-app-name.azurewebsites.net

### 5. Test Your Live Applications

**Comprehensive Testing Checklist:**

#### Backend API Tests:
```powershell
# Health check
curl https://your-app-name.azurewebsites.net/health

# Test authentication endpoint
curl -X POST https://your-app-name.azurewebsites.net/auth/login `
  -H "Content-Type: application/json" `
  -d '{"email":"test@example.com","password":"testpass"}'

# Test products endpoint
curl https://your-app-name.azurewebsites.net/products
```

#### Frontend Application Tests:
1. **Customer App:**
   - Visit the Static Web App URL
   - Try user registration
   - Browse products
   - Test checkout flow (without real payment)

2. **Vendor Dashboard:**
   - Login as vendor
   - Check product management
   - Verify order management

3. **Driver App:**
   - Login as driver
   - Check order assignments
   - Test location updates

4. **Admin Panel:**
   - Login as admin
   - Check user management
   - Verify analytics

#### Database Tests:
```powershell
# Test database connection
az postgres flexible-server connect `
  --name cannabis-db-prod `
  --admin-user cannabisadmin `
  --interactive
```

#### Load Testing:
```powershell
# Install Artillery for load testing
npm install -g artillery

# Create and run load test
artillery quick --count 10 --num 5 https://your-app-name.azurewebsites.net/health
```

---

## 📋 Complete Deployment Checklist

- [ ] ✅ Run `.\setup-production.ps1` (infrastructure setup)
- [ ] ✅ Run `.\deploy-azure.ps1` (application deployment)
- [ ] 🔴 Configure Stripe webhooks (critical for payments)
- [ ] 🟡 Set up custom domain (optional)
- [ ] 🟡 Test all applications thoroughly
- [ ] 🟡 Configure monitoring alerts
- [ ] 🟡 Set up backup strategy
- [ ] 🟡 Performance optimization

**🔴 = Required | 🟡 = Recommended | ✅ = Completed**

---

## 🆘 Need Help?

If you encounter issues:

1. **Check Azure Resources:**
   ```powershell
   # List all resources in your resource group
   az resource list --resource-group cannabis-delivery-rg --output table
   ```

2. **View Application Logs:**
   ```powershell
   # Real-time backend logs
   az webapp log tail --resource-group cannabis-delivery-rg --name your-app-name
   ```

3. **Check Deployment Status:**
   ```powershell
   # Check App Service status
   az webapp show --resource-group cannabis-delivery-rg --name your-app-name --output table
   ```

4. **Common Issues:**
   - **"Resource group not found"**: Run setup script first
   - **"Webhook failures"**: Verify Stripe webhook secret in Key Vault
   - **"Domain not working"**: Wait 24-48 hours for DNS propagation

---

## 🎉 Success!

After completing these steps, your Cannabis Delivery Platform will be:
- ✅ **Live on Azure** with scalable infrastructure
- ✅ **Processing payments** securely via Stripe
- ✅ **Monitored** with Application Insights
- ✅ **Secure** with HTTPS and Key Vault
- ✅ **Production-ready** with custom domain (optional)

**Your applications will be accessible at:**
- **Backend API:** `https://your-app-name.azurewebsites.net`
- **Customer App:** Azure Static Web App URL
- **Vendor Dashboard:** Azure Static Web App URL
- **Driver App:** Azure Static Web App URL
- **Admin Panel:** Azure Static Web App URL

## 📋 Prerequisites

- Azure deployment completed successfully
- Access to Stripe Dashboard
- Access to Firebase Console
- Domain registrar access (optional)

---

## 1. 🔐 Configure Stripe Webhooks (REQUIRED)

### Step-by-Step Setup

1. **Go to Stripe Dashboard:**
   - Visit: https://dashboard.stripe.com
   - Navigate to **Developers** → **Webhooks**

2. **Add Webhook Endpoint:**
   - Click **"Add endpoint"**
   - **Endpoint URL:** `https://your-app-service-name.azurewebsites.net/payments/webhook`
     - Replace `your-app-service-name` with your actual Azure App Service name
   - **Events to listen for:**
     - `payment_intent.succeeded`
     - `payment_intent.payment_failed`
     - `checkout.session.completed`

3. **Copy Webhook Secret:**
   - After creating the webhook, copy the **Signing secret** (starts with `whsec_`)
   - Store it in Azure Key Vault:
   ```powershell
   az keyvault secret set --vault-name cannabis-kv-prod --name "stripe-webhook-secret" --value "whsec_your_webhook_secret"

   ```

### Verification

Test the webhook:
```bash
# Test webhook endpoint
curl -X POST https://your-app-service-name.azurewebsites.net/payments/webhook \
  -H "Content-Type: application/json" \
  -d '{"test": "webhook"}'
```

---

## 2. 📧 Configure Email Notifications (Optional)

### SMTP Setup

1. **Gmail Setup:**
   - Enable 2-factor authentication
   - Generate App Password: https://myaccount.google.com/apppasswords
   - Store credentials in Key Vault

2. **Azure Key Vault Secrets:**
   ```powershell
   az keyvault secret set --vault-name your-keyvault-name --name "smtp-host" --value "smtp.gmail.com"
   az keyvault secret set --vault-name your-keyvault-name --name "smtp-port" --value "587"
   az keyvault secret set --vault-name your-keyvault-name --name "smtp-user" --value "your-email@gmail.com"
   az keyvault secret set --vault-name your-keyvault-name --name "smtp-pass" --value "your-app-password"
   ```

---

## 3. 🌐 Custom Domain Setup (Optional)

### Azure App Service Domain

1. **Purchase Domain:**
   - Go to your domain registrar (GoDaddy, Namecheap, etc.)
   - Purchase your desired domain

2. **Configure in Azure:**
   ```powershell
   # Add custom domain
   az webapp config hostname set \
     --resource-group your-resource-group \
     --name your-app-service-name \
     --hostname www.yourdomain.com

   # Add SSL certificate (free)
   az webapp config ssl create \
     --resource-group your-resource-group \
     --name your-app-service-name \
     --hostname www.yourdomain.com
   ```

3. **Update DNS Records:**
   - **Type:** CNAME
   - **Name:** www (or @ for root domain)
   - **Value:** your-app-service-name.azurewebsites.net

### Static Web Apps Domain

For each frontend app:
```powershell
# Check your static web app names
az staticwebapp list --resource-group your-resource-group --query "[].{name:name, url:defaultHostname}" -o table

# Add custom domain to static web app
az staticwebapp hostname set \
  --resource-group your-resource-group \
  --name your-static-app-name \
  --domain yourdomain.com
```

---

## 4. 🧪 Testing & Validation

### Health Checks

1. **API Health Check:**
   ```powershell
   # Test backend API
   curl https://your-app-service-name.azurewebsites.net/health
   ```

2. **Database Connection:**
   ```powershell
   # Test database connectivity
   az postgres flexible-server connect \
     --name your-db-server \
     --admin-user cannabisadmin \
     --interactive
   ```

3. **Frontend Applications:**
   - Visit each Static Web App URL
   - Test user registration and login
   - Verify payment processing flow

### Load Testing

```powershell
# Install Artillery (if not installed)
npm install -g artillery

# Create load test configuration
# load-test.yml
config:
  target: 'https://your-app-service-name.azurewebsites.net'
  phases:
    - duration: 60
      arrivalRate: 5
  defaults:
    headers:
      Content-Type: 'application/json'

scenarios:
  - name: 'Health check'
    requests:
      - get:
          url: '/health'
```

---

## 5. 📊 Monitoring Setup

### Application Insights

1. **Verify Configuration:**
   ```powershell
   # Check Application Insights
   az monitor app-insights component show \
     --resource-group your-resource-group \
     --app your-app-insights-name
   ```

2. **View Logs:**
   ```powershell
   # Real-time logs
   az webapp log tail \
     --resource-group your-resource-group \
     --name your-app-service-name
   ```

3. **Set up Alerts:**
   - Go to Azure Portal → Application Insights
   - Configure alerts for:
     - Response time > 5 seconds
     - Error rate > 5%
     - CPU usage > 80%

### Log Analytics

```powershell
# Query application logs
az monitor query \
  --resource /subscriptions/your-subscription/resourceGroups/your-resource-group/providers/microsoft.insights/components/your-app-insights \
  --analytics-query "requests | where timestamp > ago(1h) | summarize count() by bin(timestamp, 5m)" \
  --output table
```

---

## 6. 🔒 Security Configuration

### HTTPS Enforcement

```powershell
# Enable HTTPS only
az webapp update \
  --resource-group your-resource-group \
  --name your-app-service-name \
  --set httpsOnly=true
```

### CORS Configuration

```powershell
# Update CORS settings
az webapp cors add \
  --resource-group your-resource-group \
  --name your-app-service-name \
  --allowed-origins "https://your-static-web-app-url.azurestaticapps.net"
```

### Key Vault Access

```powershell
# Grant App Service access to Key Vault
az keyvault set-policy \
  --name your-keyvault-name \
  --object-id $(az webapp identity show --resource-group your-resource-group --name your-app-service-name --query principalId -o tsv) \
  --secret-permissions get list
```

---

## 7. 🚀 Performance Optimization

### Scaling

```powershell
# Scale up App Service Plan
az appservice plan update \
  --name your-app-service-plan \
  --resource-group your-resource-group \
  --sku B2

# Enable auto-scaling
az monitor autoscale create \
  --resource /subscriptions/your-subscription/resourceGroups/your-resource-group/providers/Microsoft.Web/serverfarms/your-app-service-plan \
  --resource-group your-resource-group \
  --name "autoscaling" \
  --min-count 1 \
  --max-count 10 \
  --count 1
```

### CDN Setup (Optional)

```powershell
# Create CDN profile
az cdn profile create \
  --resource-group your-resource-group \
  --name your-cdn-profile \
  --sku Standard_Microsoft

# Create CDN endpoint
az cdn endpoint create \
  --resource-group your-resource-group \
  --profile-name your-cdn-profile \
  --name your-cdn-endpoint \
  --origin your-app-service-name.azurewebsites.net \
  --origin-host-header your-app-service-name.azurewebsites.net
```

---

## 8. 📋 Production Checklist

- [ ] Azure resources deployed successfully
- [ ] Database schema migrated
- [ ] Secrets stored in Key Vault
- [ ] Applications deployed and accessible
- [ ] HTTPS enabled
- [ ] Custom domain configured (optional)
- [ ] Stripe webhooks configured
- [ ] Email notifications configured (optional)
- [ ] Monitoring and logging enabled
- [ ] Load testing completed
- [ ] Backup strategy implemented
- [ ] Security policies configured
- [ ] Performance optimization applied

---

## 9. 🆘 Troubleshooting

### Common Issues

1. **Webhook Failures:**
   - Verify endpoint URL is correct
   - Check webhook secret in Key Vault
   - Review application logs

2. **Domain Issues:**
   - Wait for DNS propagation (can take 24-48 hours)
   - Verify DNS records are correct
   - Check SSL certificate status

3. **Performance Issues:**
   - Monitor Application Insights
   - Check database connection pool
   - Review App Service Plan scaling

### Support Resources

- **Azure Documentation:** https://docs.microsoft.com/azure
- **Stripe Webhooks:** https://stripe.com/docs/webhooks
- **Firebase Console:** https://console.firebase.google.com

---

## 🎉 Deployment Complete!

Your Cannabis Delivery Platform is now fully operational on Azure with:

- ✅ **Backend API:** `https://your-app-service.azurewebsites.net`
- ✅ **Customer App:** Azure Static Web App
- ✅ **Vendor Dashboard:** Azure Static Web App
- ✅ **Driver App:** Azure Static Web App
- ✅ **Admin Panel:** Azure Static Web App
- ✅ **Secure Payments:** Stripe integration
- ✅ **Real-time Monitoring:** Application Insights
- ✅ **Scalable Infrastructure:** Auto-scaling enabled

**Need Help?** Check the troubleshooting section or create an issue in the project repository.
