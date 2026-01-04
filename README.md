# Cannabis Delivery Platform

A full-featured cannabis dispensary delivery platform for South Africa, built with Azure resources. This platform includes real-time tracking, compliance controls, and age verification, similar to Uber Eats but tailored for cannabis delivery.

## Project Overview

The platform consists of multiple applications:
- **Customer App**: Web-first, mobile-responsive interface for customers to browse, order, and track deliveries
- **Vendor Dashboard**: Dispensary management interface for vendors to manage inventory, orders, and operations
- **Driver App**: Delivery tracking and navigation interface for drivers
- **Admin Panel**: System oversight, compliance monitoring, and payout management

## Architecture

- **Frontend**: React with Vite, Tailwind CSS
- **Backend**: Azure Functions (API layer), Azure SQL Database or Cosmos DB
- **Authentication**: Azure AD B2C
- **Real-time**: Azure SignalR Service
- **Storage**: Azure Blob Storage for ID uploads
- **Maps**: Azure Maps for geolocation and routing
- **Payments**: PayFast (primary), Stripe (fallback)
- **Infrastructure**: Azure Static Web Apps, Azure Functions, IaC with Bicep

## Azure Sponsorship Benefits

The project leverages Microsoft for Startups benefits, including:

### Azure Credits
- $5,000 in Azure credits (expires January 13, 2026)
- Access to Priority Community Support for Azure through Microsoft Q&A

### GitHub Enterprise
- 1-year subscription for up to 20 users (expires December 29, 2025)

### Dynamics 365
- Customer Service Enterprise: 1-year subscription for up to 10 users
- Sales Enterprise: 1-year subscription for up to 10 users
- Team Member: 1-year subscription for up to 25 users
- All expire January 1, 2026

### Microsoft 365 Business Premium
- 1-year subscription for up to 50 users (expires January 1, 2026)

### Power Platform
- Power Apps: 1-year subscription for up to 10 users (expires March 21, 2026)
- Power Automate: 1-year subscription for up to 10 users (expires April 4, 2026)
- Power BI: 1-year subscription for up to 10 users

### Visual Studio Enterprise
- Subscription for up to 5 users (expires January 13, 2026)

### Other Benefits
- Stripe Atlas: 50% discount on incorporation fee
- Stripe Payments: $500 USD in credits
- LinkedIn Premium Business: 75% off 4-month subscription
- Miro: $1,500 credit for team of up to 9
- MongoDB Atlas: $500 in credits
- Porter: Free for 6 months
- WE.VESTR: Free for startups with less than 30 stakeholders or 70% off first year

## Project Structure

```
cannabis-delivery-platform/
├── apps/
│   ├── customer-app/
│   ├── vendor-dashboard/
│   ├── driver-app/
│   └── admin-panel/
├── api/                    # Azure Functions backend
├── infra/                  # Azure IaC (Bicep/Terraform)
├── shared/                 # Shared UI components and utilities
├── docs/                   # Documentation
├── azure-resources-summary.md  # Detailed Azure benefits summary
└── README.md
```

## Legal & Compliance (South Africa)

- Age verification (18+) via ID upload and validation
- Region-based availability controls
- Secure handling of PII and documents
- Explicit consent and audit logs
- Compliance with South African cannabis regulations

## Setup Instructions

### Prerequisites
- Node.js LTS (24.x recommended)
- Azure CLI (az)
- Azure Developer CLI (azd)
- Git

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd cannabis-delivery-platform
```

2. Install dependencies for all apps:
```bash
# Install shared dependencies
npm install

# Install app-specific dependencies
cd apps/customer-app && npm install
cd ../vendor-dashboard && npm install
cd ../driver-app && npm install
cd ../admin-panel && npm install
```

3. Set up Azure resources:
```bash
# Login to Azure
az login

# Initialize Azure Developer CLI
azd init

# Provision infrastructure
azd up
```

4. Configure environment variables:
Create `.env` files in each app directory with Azure service endpoints, API keys, etc.

### Development

1. Start the backend:
```bash
cd api
func start
```

2. Start individual apps:
```bash
cd apps/customer-app && npm run dev
cd apps/vendor-dashboard && npm run dev
# etc.
```

### Deployment

Deploy to Azure using sponsorship credits:

```bash
azd deploy
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes
4. Submit a pull request

## License

This project is proprietary and confidential. All rights reserved.

## Security Notice

This repository contains sensitive information related to Azure resources and sponsorship benefits. Access is restricted to authorized personnel only.
