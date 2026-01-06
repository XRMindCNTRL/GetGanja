# Cannabis Delivery Platform - Production URLs

## 🌐 Live Application URLs

### Frontend Applications
- **Customer App**: https://orange-mud-083f9ac0f.4.azurestaticapps.net
  - Browse products, place orders, user registration/login

- **Vendor Dashboard**: https://gentle-grass-00bb9010f.1.azurestaticapps.net
  - Vendor inventory management, order handling
- **Driver App**: https://red-mud-0b72f350f.2.azurestaticapps.net
  - Driver order tracking, navigation
- **Admin Panel**: https://kind-stone-01c35960f.1.azurestaticapps.net
  - System administration, user management, analytics

### Backend API
- **Base URL**: https://getganja.azurewebsites.net
- **Health Check**: https://getganja.azurewebsites.net/health

## 🔗 API Endpoints

### Authentication
- **POST** `/auth/register` - User registration
- **POST** `/auth/login` - User login

### Products
- **GET** `/products` - List all products
- **GET** `/products/:id` - Get product details
- **POST** `/products` - Create product (vendor/admin)
- **PUT** `/products/:id` - Update product (vendor/admin)
- **DELETE** `/products/:id` - Delete product (admin)

### Orders
- **GET** `/orders` - List user orders
- **GET** `/orders/:id` - Get order details
- **POST** `/orders` - Create new order
- **PUT** `/orders/:id` - Update order status
- **DELETE** `/orders/:id` - Cancel order

### Payments
- **POST** `/payments` - Process payment
- **GET** `/payments/:id` - Get payment status

## 📊 Monitoring & Analytics
- **Application Insights**: Configured for performance monitoring
- **Azure Portal**: https://portal.azure.com (Resource Group: cannabis-delivery-rg)

## 🔒 Security
- **Azure Key Vault**: Secrets management
- **Azure AD B2C**: Authentication (when configured)
- **SSL/TLS**: Enabled on all endpoints

## 📱 Mobile & PWA
- All frontend apps support PWA installation
- Service workers configured for offline functionality
- Responsive design for mobile devices

## 🚀 Deployment Status
- **Infrastructure**: Azure App Service, Static Web Apps, PostgreSQL
- **CI/CD**: GitHub Actions workflows configured
- **Auto-deployment**: Enabled on main branch pushes
- **Environment**: Production (East US region)

## 📞 Support
- **GitHub Repository**: https://github.com/XRMindCNTRL/GetGanja
- **Documentation**: See README.md and docs/ folder
- **Issues**: Report via GitHub Issues

---
*Last updated: $(date)*
*Platform Status: ✅ Production Ready*
