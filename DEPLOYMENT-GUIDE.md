# 🚀 Cannabis Delivery Platform - Azure Production Deployment Guide

## 📋 Prerequisites

- Azure account with active subscription
- Azure CLI installed (`az` command)
- jq installed for JSON processing
- Stripe account for payments
- Firebase project for notifications
- Custom domain (optional)

## ☁️ Step 1: Azure Infrastructure Setup

### Automated Setup (Recommended)

1. **Run the Production Setup Script:**
   ```powershell
   # On Windows PowerShell
   .\setup-production.ps1
   ```

   ```bash
   # On Linux/macOS
   chmod +x setup-production.sh
   ./setup-production.sh
   ```

   This script will:
   - Authenticate with Azure CLI
   - Create resource group and deploy infrastructure using Bicep
   - Set up PostgreSQL database, Key Vault, Storage Account
   - Configure Application Insights and AI services
   - Generate and store secrets securely

2. **Deploy Applications:**
   ```powershell
   # On Windows PowerShell
   .\deploy-azure.ps1
   ```

   ```bash
   # On Linux/macOS
   chmod +x deploy-azure.sh
   ./deploy-azure.sh
   ```

### Manual Setup

1. **Install Azure CLI:**
   ```bash
   # Windows (PowerShell)
   winget install -e --id Microsoft.AzureCLI

   # macOS
   brew install azure-cli

   # Linux
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```

2. **Login to Azure:**
   ```bash
   az login --use-device-code
   ```

3. **Set Subscription:**
   ```bash
   az account set --subscription 2e0757c5-8619-4f8b-a484-4e12fe6ca133
   ```

4. **Deploy Infrastructure:**
   ```bash
   # Create resource group
   az group create --name CannabisApp --location southafricanorth

   # Deploy using Bicep template
   az deployment group create \
     --resource-group CannabisApp \
     --template-file infra/main.bicep \
     --parameters environmentName="production"
   ```


## 🗄️ Step 2: Database Setup

The Azure setup automatically creates a PostgreSQL Flexible Server and configures it with your application.

### Database Migration:

```bash
cd backend
npx prisma generate
npx prisma db push
```

## 🔧 Step 3: Environment Variables Setup

### Azure Key Vault Secrets (Automated)

The setup script automatically stores all secrets in Azure Key Vault:

- **JWT Secret**: Auto-generated secure token
- **Database Password**: Auto-generated secure password
- **Stripe Keys**: Your provided Stripe credentials
- **Firebase Config**: Your Firebase project settings
- **Storage Connection**: Azure Storage account connection string

### Frontend Environment Variables

Frontend applications automatically receive:

```env
REACT_APP_API_URL=https://your-app-service-url.azurewebsites.net
REACT_APP_STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key
REACT_APP_FIREBASE_API_KEY=your_firebase_api_key
REACT_APP_FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
REACT_APP_FIREBASE_PROJECT_ID=your-project-id
REACT_APP_FIREBASE_STORAGE_BUCKET=your-project.appspot.com
REACT_APP_FIREBASE_MESSAGING_SENDER_ID=123456789
REACT_APP_FIREBASE_APP_ID=1:123456789:web:abcdef123456
REACT_APP_FIREBASE_VAPID_KEY=your_vapid_key
```

## 🚀 Step 4: Application Deployment

### Automated Deployment

1. **Deploy Backend to Azure App Service:**
   ```bash
   ./deploy-azure.sh
   ```

2. **Deploy Frontend to Azure Static Web Apps:**
   The script automatically creates Static Web Apps for:
   - Customer App
   - Vendor Dashboard
   - Driver App
   - Admin Panel

### Manual Deployment

1. **Backend Deployment:**
   ```bash
   cd backend
   npm install
   npm run build
   az webapp up --resource-group your-resource-group --name your-app-name --runtime "NODE:18-lts"
   ```

2. **Frontend Deployment:**
   ```bash
   # Customer App
   cd apps/customer-app
   npm install && npm run build
   az staticwebapp create --name cannabis-customer-app --resource-group your-resource-group --source . --output-location build --sku Free

   # Repeat for other apps...
   ```

## 🔒 Step 5: Security Configuration

### Azure App Service Security

1. **Enable HTTPS Only:**
   ```bash
   az webapp update --resource-group your-resource-group --name your-app-name --set httpsOnly=true
   ```

2. **Configure CORS:**
   - Backend automatically configured for frontend URLs
   - Add additional origins if needed in Azure Portal

3. **Key Vault Integration:**
   - Secrets are automatically referenced from Key Vault
   - No sensitive data stored in application settings

## 📊 Step 6: Monitoring Setup

### Application Insights

Azure Application Insights is automatically configured:

- **Real-time metrics**: CPU, memory, requests
- **Error tracking**: Automatic exception logging
- **Performance monitoring**: Response times, throughput
- **Custom telemetry**: Business metrics and events

### Log Analytics

```bash
# View application logs
az webapp log tail --resource-group your-resource-group --name your-app-name

# Download logs
az webapp log download --resource-group your-resource-group --name your-app-name
```

## 🌐 Step 7: Custom Domain Setup (Optional)

1. **Purchase Domain:**
   - Go to your domain registrar
   - Purchase your desired domain name

2. **Configure in Azure:**
   ```bash
   # Add custom domain to App Service
   az webapp config hostname set --resource-group your-resource-group --name your-app-name --hostname www.yourdomain.com

   # Add SSL certificate (Azure provides free certificates)
   az webapp config ssl create --resource-group your-resource-group --name your-app-name --hostname www.yourdomain.com
   ```

3. **Update DNS Records:**
   - Add CNAME record pointing to your Azure App Service URL
   - Azure will provide the exact DNS configuration

## 💳 Step 8: Stripe Webhook Setup

1. **Configure Webhook Endpoint:**
   - Go to [Stripe Dashboard](https://dashboard.stripe.com) → Webhooks
   - Add endpoint: `https://your-app-service-url.azurewebsites.net/payments/webhook`
   - Select events: `payment_intent.succeeded`, `payment_intent.payment_failed`

2. **Store Webhook Secret:**
   ```bash
   az keyvault secret set --vault-name your-keyvault-name --name "stripe-webhook-secret" --value "whsec_your_webhook_secret"
   ```

## 🧪 Step 9: Testing and Validation

### Health Checks

1. **API Health Check:**
   ```bash
   curl https://your-app-service-url.azurewebsites.net/health
   ```

2. **Database Connection:**
   ```bash
   # Test database connectivity
   az postgres flexible-server connect --name your-db-server --admin-user cannabisadmin --interactive
   ```

3. **Frontend Accessibility:**
   - Visit each Static Web App URL
   - Test user registration and login
   - Verify payment processing

### Load Testing

```bash
# Install Artillery for load testing
npm install -g artillery

# Run load tests
artillery run load-test.yml
```

## 📋 Production Checklist

- [ ] Azure resources deployed successfully
- [ ] Database schema migrated
- [ ] Secrets stored in Key Vault
- [ ] Applications deployed and accessible
- [ ] HTTPS enabled
- [ ] Custom domain configured (optional)
- [ ] Stripe webhooks configured
- [ ] Monitoring and logging enabled
- [ ] Load testing completed
- [ ] Backup strategy implemented

## 🔧 Useful Azure Commands

```bash
# Check app status
az webapp show --resource-group your-resource-group --name your-app-name

# Restart app
az webapp restart --resource-group your-resource-group --name your-app-name

# View logs
az webapp log tail --resource-group your-resource-group --name your-app-name

# Scale up/down
az appservice plan update --name your-plan --resource-group your-resource-group --sku B2

# List all resources
az resource list --resource-group your-resource-group --output table
```

## 🎉 Deployment Complete!

Your Cannabis Delivery Platform is now live on Azure:

- **Backend API**: `https://cannabis-delivery-api.azurewebsites.net`
- **Customer App**: `https://jolly-forest-020c52a0f.6.azurestaticapps.net` (GetGanja)
- **Vendor Dashboard**: Check Azure Static Web Apps
- **Driver App**: Check Azure Static Web Apps
- **Admin Panel**: Check Azure Static Web Apps


## 🆘 Troubleshooting

### Common Issues

1. **Deployment Failures:**
   - Check Azure CLI authentication: `az account show`
   - Verify resource group exists: `az group list`
   - Verify subscription: `az account set --subscription 2e0757c5-8619-4f8b-a484-4e12fe6ca133`
   - Check deployment logs: `az deployment group list --resource-group CannabisApp`

2. **Database Connection Issues:**
   - Verify Key Vault secrets: `az keyvault secret list --vault-name cannabis-kv-prod`
   - Check PostgreSQL server: `az postgres flexible-server list`

3. **Application Errors:**
   - View application logs: `az webapp log tail --resource-group CannabisApp --name cannabis-delivery-api`
   - Check Application Insights for errors


### Support Resources

- **Azure Documentation**: https://docs.microsoft.com/azure
- **Azure Support**: https://azure.microsoft.com/support
- **Stack Overflow**: Tag questions with `azure-app-service`

---

**Need Help?** Check the troubleshooting section or create an issue in the project repository.
