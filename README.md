# 🌿 GetGanja — Cannabis Delivery Platform

> South Africa's full-stack cannabis delivery marketplace — connecting licensed dispensaries with verified customers through real-time order tracking, age verification, and compliance controls.

[![Deploy Backend](https://github.com/XRMindCNTRL/GetGanja/actions/workflows/deploy-backend.yml/badge.svg)](https://github.com/XRMindCNTRL/GetGanja/actions/workflows/deploy-backend.yml)
[![Deploy Infrastructure](https://github.com/XRMindCNTRL/GetGanja/actions/workflows/deploy-infrastructure.yml/badge.svg)](https://github.com/XRMindCNTRL/GetGanja/actions/workflows/deploy-infrastructure.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Node.js](https://img.shields.io/badge/Node.js-20-339933?logo=nodedotjs)](https://nodejs.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?logo=typescript)](https://www.typescriptlang.org)
[![Azure](https://img.shields.io/badge/Azure-Powered-0078D4?logo=microsoftazure)](https://azure.microsoft.com)

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Live Applications](#-live-applications)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Getting Started](#-getting-started)
- [Environment Variables](#-environment-variables)
- [Database Setup](#-database-setup)
- [API Reference](#-api-reference)
- [Available Scripts](#-available-scripts)
- [Deployment](#-deployment)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🌍 Overview

GetGanja is a multi-app cannabis delivery platform built for the South African market. It provides:

- **Age-verified ordering** — customers upload ID for age verification before placing orders
- **Licensed vendor management** — dispensaries apply with cannabis business licences; admins approve/reject
- **Real-time delivery tracking** — drivers share live GPS location via Socket.IO
- **Compliance-first design** — region locking, audit logging, and PII-safe data handling
- **Secure payments** — PayFast (primary) and Stripe (fallback) integrations

The platform consists of four independent React front-end apps sharing a single Express/Node.js back-end API.

---

## 🚀 Live Applications

| Application | URL | Description |
|---|---|---|
| 🛒 **Customer App** | [orange-mud-083f9ac0f.4.azurestaticapps.net](https://orange-mud-083f9ac0f.4.azurestaticapps.net) | Browse products, place orders, live delivery tracking |
| 🏪 **Vendor Dashboard** | [gentle-grass-00bb9010f.1.azurestaticapps.net](https://gentle-grass-00bb9010f.1.azurestaticapps.net) | Manage inventory, process orders, view analytics |
| 🚚 **Driver App** | [red-mud-0b72f350f.2.azurestaticapps.net](https://red-mud-0b72f350f.2.azurestaticapps.net) | Accept deliveries, share real-time location |
| ⚙️ **Admin Panel** | [kind-stone-01c35960f.1.azurestaticapps.net](https://kind-stone-01c35960f.1.azurestaticapps.net) | System oversight, vendor approvals, compliance monitoring |

> **Azure Credits:** $5,000 available, expiring **August 2026**.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Azure Static Web Apps                    │
│  ┌──────────────┐ ┌─────────────────┐ ┌──────────────────┐  │
│  │ Customer App │ │ Vendor Dashboard│ │   Driver App     │  │
│  │  (React/Vite)│ │  (React/Vite)   │ │  (React/Vite)   │  │
│  └──────┬───────┘ └────────┬────────┘ └───────┬──────────┘  │
│         │                  │                  │              │
│  ┌──────┴──────────────────┴──────────────────┘              │
│  │                  Admin Panel (React/Vite)                 │
│  └──────────────────────────────────────────────────────────┘
└─────────────────────────────────────────────────────────────┘
                             │ REST + Socket.IO
┌─────────────────────────────────────────────────────────────┐
│              Azure App Service — Backend API                 │
│        Express + TypeScript + Socket.IO + Prisma ORM        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐   │
│  │   Auth   │ │ Products │ │  Orders  │ │   Payments   │   │
│  └──────────┘ └──────────┘ └──────────┘ └──────────────┘   │
└─────────────────────────────────────────────────────────────┘
                             │
┌────────────┐  ┌────────────┴──────────┐  ┌────────────────┐
│ Azure SQL  │  │  Azure Blob Storage   │  │  Azure Key     │
│  Database  │  │  (Product images,     │  │  Vault         │
│ (Prisma)   │  │   ID documents)       │  │  (Secrets)     │
└────────────┘  └───────────────────────┘  └────────────────┘
```

### Front-end Apps (`apps/`)

Each app is an independent React workspace with its own `package.json`, Tailwind CSS, React Router v6, and Firebase push notifications. They communicate with the shared backend API.

| App | Port (dev) | Directory |
|---|---|---|
| Customer App | 3001 | `apps/customer-app/` |
| Vendor Dashboard | 3002 | `apps/vendor-dashboard/` |
| Driver App | 3003 | `apps/driver-app/` |
| Admin Panel | 3004 | `apps/admin-panel/` |

### Backend (`backend/`)

- **Framework:** Express 4 + TypeScript 5
- **ORM:** Prisma 5 (SQLite for dev, Azure SQL / Cosmos DB for production)
- **Real-time:** Socket.IO 4 (order updates, driver location)
- **Auth:** JWT + bcryptjs; role-based access (`CUSTOMER`, `VENDOR`, `DRIVER`, `ADMIN`)
- **File uploads:** Multer (10 MB limit) → Azure Blob Storage
- **Security:** Helmet, CORS, express-rate-limit (100 req/15 min)

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Frontend** | React 18, TypeScript, Tailwind CSS, React Router v6, Firebase |
| **Backend** | Node.js 20, Express 4, TypeScript 5, Socket.IO 4 |
| **ORM / Database** | Prisma 5, SQLite (dev), Azure SQL Database (prod) |
| **Authentication** | JWT, bcryptjs |
| **Payments** | PayFast (ZAR), Stripe |
| **File Storage** | Azure Blob Storage |
| **Cloud** | Azure App Service, Azure Static Web Apps, Azure Key Vault |
| **CI/CD** | GitHub Actions |
| **Infrastructure** | Azure Bicep (IaC — `infra/`) |

---

## 📦 Prerequisites

- **Node.js** 20 or later — [nodejs.org](https://nodejs.org)
- **npm** 10 or later (included with Node.js 20)
- **Git**
- An **Azure** account (for deployment) or use the included SQLite DB locally

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/XRMindCNTRL/GetGanja.git
cd GetGanja
```

### 2. Install all dependencies

```bash
# Install root + all workspace dependencies
npm install

# Install backend dependencies separately
cd backend && npm install
```

### 3. Configure environment variables

```bash
# Back-end
cp .env.example backend/.env
# Edit backend/.env with your values (see Environment Variables section)

# Each front-end app (repeat for vendor-dashboard, driver-app, admin-panel)
cp apps/customer-app/.env.example apps/customer-app/.env.local 2>/dev/null || true
```

### 4. Set up the database

```bash
cd backend
npx prisma migrate dev --name init
npx prisma generate
```

### 5. Start development servers

**Terminal 1 — Backend**

```bash
cd backend
npm run dev
# API runs on http://localhost:5000
```

**Terminal 2 — Pick a front-end app**

```bash
cd apps/customer-app && npm start    # http://localhost:3001
# or
cd apps/vendor-dashboard && npm start
# or
cd apps/driver-app && npm start
# or
cd apps/admin-panel && npm start
```

---

## 🔐 Environment Variables

Copy `.env.example` to `backend/.env` and fill in the values below.

### Required

| Variable | Description |
|---|---|
| `DATABASE_URL` | Prisma connection string. For local dev use `file:./dev.db` (SQLite) |
| `JWT_SECRET` | Random string ≥ 32 characters used to sign JWTs |
| `FRONTEND_URL` | Customer app URL (for CORS) |

### Payments

| Variable | Description |
|---|---|
| `STRIPE_SECRET_KEY` | Stripe secret key (`sk_test_…` or `sk_live_…`) |
| `STRIPE_PUBLISHABLE_KEY` | Stripe publishable key (`pk_test_…` or `pk_live_…`) |
| `PAYFAST_MERCHANT_ID` | PayFast merchant ID |
| `PAYFAST_MERCHANT_KEY` | PayFast merchant key |

### Azure Services

| Variable | Description |
|---|---|
| `AZURE_STORAGE_CONNECTION_STRING` | Azure Blob Storage connection string |
| `AZURE_STORAGE_CONTAINER_NAME` | Blob container name (e.g. `uploads`) |
| `AZURE_KEYVAULT_URL` | Key Vault URL (optional — for managed secret retrieval) |

### Firebase (Push Notifications)

| Variable | Description |
|---|---|
| `FIREBASE_API_KEY` | Firebase project API key |
| `FIREBASE_PROJECT_ID` | Firebase project ID |
| `FIREBASE_APP_ID` | Firebase app ID |

> **Never commit `.env` files.** They are listed in `.gitignore`.

---

## 🗄️ Database Setup

The schema lives at `backend/prisma/schema.prisma`.

### Key models

| Model | Description |
|---|---|
| `User` | Base user with role (`CUSTOMER`, `VENDOR`, `DRIVER`, `ADMIN`) |
| `CustomerProfile` | Age-verification status and date of birth |
| `VendorProfile` | Business name, licence number, geolocation |
| `DriverProfile` | Driver's licence, vehicle, availability, rating |
| `Product` | Product catalogue with THC/CBD content, stock levels |
| `Order` / `OrderItem` | Order lifecycle with payment & delivery status |
| `Delivery` | Driver assignment and arrival timestamps |
| `Address` | Multiple delivery addresses per customer |

### Common Prisma commands

```bash
# Run migrations (local development)
cd backend && npx prisma migrate dev --name <description>

# Push schema without a migration file (CI/CD)
cd backend && npx prisma db push

# Generate / regenerate Prisma client
cd backend && npx prisma generate

# Open the visual database browser
cd backend && npx prisma studio

# Reset the database (⚠️ deletes all data)
cd backend && npx prisma migrate reset
```

---

## 📡 API Reference

Base URL: `http://localhost:5000` (dev) or your Azure App Service URL.

All protected endpoints require `Authorization: Bearer <token>` header.

### Authentication — `/auth`

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/auth/register` | No | Register a new user |
| `POST` | `/auth/login` | No | Login and receive JWT |
| `GET` | `/auth/profile` | Yes | Get authenticated user profile |

**Register body:**

```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "firstName": "Jane",
  "lastName": "Doe",
  "phone": "+27821234567",
  "role": "CUSTOMER"
}
```

### Products — `/products`

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/products` | No | List all active products |
| `GET` | `/products/:id` | No | Get product by ID |
| `POST` | `/products` | Yes (VENDOR) | Create product (with optional image upload) |
| `PUT` | `/products/:id` | Yes (VENDOR) | Update product |
| `DELETE` | `/products/:id` | Yes (VENDOR/ADMIN) | Deactivate product |

### Orders — `/orders`

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/orders` | Yes | Place a new order |
| `GET` | `/orders` | Yes | List orders for current user |
| `GET` | `/orders/:id` | Yes | Get order details |
| `PATCH` | `/orders/:id/status` | Yes (VENDOR/DRIVER/ADMIN) | Update order status |

### Payments — `/payments`

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/payments/stripe/intent` | Yes | Create Stripe payment intent |
| `POST` | `/payments/payfast/notify` | No | PayFast ITN webhook |

### Health Check

```bash
GET /health
# Response: { "status": "OK", "timestamp": "2026-01-01T00:00:00.000Z" }
```

### Real-time Events (Socket.IO)

| Event (client → server) | Payload | Description |
|---|---|---|
| `join-delivery` | `deliveryId: string` | Subscribe to a delivery room |
| `update-location` | `{ deliveryId, location: { lat, lng } }` | Driver broadcasts GPS position |

| Event (server → client) | Payload | Description |
|---|---|---|
| `location-update` | `{ lat: number, lng: number }` | Live driver location |

---

## 📜 Available Scripts

### Root workspace

```bash
npm install          # Install all workspace + backend dependencies
```

### Backend (`cd backend`)

```bash
npm run dev          # Start dev server with auto-reload (ts-node-dev)
npm run build        # Compile TypeScript → dist/
npm start            # Run compiled dist/server.js
npm test             # Run Jest test suite
npm run lint         # ESLint check
npm run format       # Prettier format
```

### Each front-end app (`cd apps/<app-name>`)

```bash
npm start            # Start Vite/CRA dev server
npm run build        # Production build
npm test             # Run React tests
```

---

## 🚢 Deployment

All deployments are automated via **GitHub Actions** on push to `main`.

### CI/CD Workflows

| Workflow | File | Trigger | Target |
|---|---|---|---|
| Deploy Backend | `deploy-backend.yml` | Push to `main` | Azure App Service |
| Deploy Infrastructure | `deploy-infrastructure.yml` | Push to `main` | Azure Bicep |
| Deploy Customer App | Azure SWA workflow | Push to `main` | Azure Static Web Apps |
| Deploy Vendor Dashboard | Azure SWA workflow | Push to `main` | Azure Static Web Apps |
| Deploy Driver App | Azure SWA workflow | Push to `main` | Azure Static Web Apps |
| Deploy Admin Panel | Azure SWA workflow | Push to `main` | Azure Static Web Apps |

### Required GitHub Secrets

Set these in **Settings → Secrets and variables → Actions**:

| Secret | Description |
|---|---|
| `AZURE_CREDENTIALS` | Azure service principal credentials (JSON) |
| `AZURE_STATIC_WEB_APPS_API_TOKEN_*` | Deployment token for each Static Web App |
| `DATABASE_URL` | Production database connection string |
| `JWT_SECRET` | Production JWT signing secret |
| `STRIPE_SECRET_KEY` | Production Stripe secret key |
| `AZURE_STORAGE_CONNECTION_STRING` | Azure Blob Storage connection string |

See [`GITHUB-SECRETS-SETUP.md`](GITHUB-SECRETS-SETUP.md) for step-by-step instructions.

### Manual Infrastructure Deployment

```bash
# Deploy Azure infrastructure using Bicep
az deployment group create \
  --resource-group <resource-group> \
  --template-file infra/main.bicep \
  --parameters @infra/main.parameters.json
```

---

## 🤝 Contributing

1. **Fork** the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes and write tests where applicable
4. Ensure linting passes: `cd backend && npm run lint`
5. Ensure tests pass: `cd backend && npm test`
6. Commit using [Conventional Commits](https://www.conventionalcommits.org): `git commit -m "feat: add age verification endpoint"`
7. Push and open a **Pull Request** against `main`

### Code Style

- **Backend:** ESLint + Prettier (`npm run lint` / `npm run format`)
- **Frontend:** ESLint via `react-app`
- **TypeScript strict mode** is enabled — avoid `any` where possible
- Follow existing patterns for routes (try/catch, standard HTTP codes, Prisma queries)

---

## ⚖️ Legal & Compliance

This platform is designed for use with **licensed cannabis dispensaries** in South Africa operating under the applicable regulations. All users are subject to:

- Age verification (18+) before placing orders
- Regional delivery restrictions (South Africa only)
- Vendor licence validation before approval

---

## 📄 License

[MIT](LICENSE) © 2024 GetGanja / XRMindCNTRL
