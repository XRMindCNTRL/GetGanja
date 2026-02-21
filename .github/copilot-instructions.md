# Cannabis Delivery Platform - AI Coding Agent Instructions

## Project Overview
Cannabis Delivery Platform is a full-stack marketplace for cannabis dispensaries in South Africa. It uses React/Vite for 4 customer-facing apps, Express/Node.js backend with Prisma ORM, and Azure services for infrastructure, payments (PayFast/Stripe), and real-time features (SignalR).

## Architecture

### Frontend Layer (React + Vite)
- **Apps**: `apps/{customer-app, vendor-dashboard, driver-app, admin-panel}` - independent monorepo workspaces
- **Build**: `npm start` (dev) / `npm run build` (production)
- **Styling**: Tailwind CSS with PostCSS
- **Routing**: React Router v6
- **State**: Component-based, Firebase for auth/notifications
- **Key patterns**: 
  - Each app is self-contained with own `tsconfig.json`, package.json, build
  - Shared utilities through root `shared/` directory (if needed)
  - Environment config via `.env.local` (never commit credentials)

### Backend Layer (Express + TypeScript)
- **Entry**: `backend/src/server.ts` - Express app with Socket.IO for real-time
- **Routes**: `backend/src/routes/` - auth, products, orders, payments (modular)
- **Database**: Prisma ORM with schema at `backend/prisma/schema.prisma`
- **Key middleware**: helmet (security), CORS, rate-limiting, multer (file uploads)
- **Auth**: JWT tokens (bcryptjs hashing), role-based (CUSTOMER, VENDOR, DRIVER, ADMIN)
- **File handling**: Multer limits 10MB images → Azure Blob Storage via `storageService.ts`
- **Build**: `npm run build` → `dist/server.js`, start with `npm start` or dev watch with `npm run dev`

### Data Layer (Prisma)
- **Models**: User (base), CustomerProfile, VendorProfile, DriverProfile, Product, Order, Delivery, Payment, Address
- **Patterns**: 
  - User is central, with role-specific profile relations (onDelete: Cascade)
  - Compliance fields: `verified` (age), `isApproved` (vendor licenses), `isActive` (user status)
  - Location: latitude/longitude for geolocation, Address model for multiple per user
- **Dev DB**: SQLite (`prisma/dev.db`), production uses SQL Database or Cosmos DB
- **Prisma workflow**: `npx prisma migrate dev` (local), `npx prisma generate` (client), `npx prisma studio` (UI)

### External Services
- **Azure**: Static Web Apps (frontend), Functions/App Service (backend), Key Vault (secrets), Blob Storage (uploads), SQL/Cosmos DB
- **Payments**: PayFast (primary South Africa), Stripe (fallback)
- **Real-time**: Socket.IO for order updates, delivery tracking
- **Maps**: Azure Maps API (routing, geolocation)
- **Auth**: Email/password with JWT, Azure AD B2C for SSO (future)
- **Compliance**: ID upload → Blob Storage, age verification workflow

## Developer Workflows

### Setup & Installation
```bash
# Install root and app dependencies
npm install
# Sets up monorepo workspaces (apps/*) + backend

# Environment setup (copy .env.example or create .env.local in each app + backend)
# Required: DATABASE_URL, STRIPE_KEY, PAYFAST_KEY, AZURE_STORAGE_*, JWT_SECRET
```

### Local Development
```bash
# Terminal 1: Backend server
cd backend && npm run dev
# Runs on http://localhost:3000 with ts-node-dev (auto-reload)

# Terminal 2: Pick one app to run
cd apps/customer-app && npm start
# Or: cd apps/vendor-dashboard && npm start
# Runs on http://localhost:3001 or assigned port
```

### Database Migrations
```bash
# Create migration after schema changes
cd backend && npx prisma migrate dev --name <feature_name>

# Push schema without creating migration (CI/CD)
npx prisma db push

# Reset DB (WARNING: deletes all data)
npx prisma migrate reset
```

### Testing
```bash
cd backend && npm test
# Runs Jest, reads setup.ts for DB config
# Test files: __tests__/ or *.test.ts pattern
# Integration tests mock Prisma or use test DB
```

### Deployment
- **Frontend**: `npm run build` → Azure Static Web Apps (auto-deploy on main via GitHub Actions)
- **Backend**: `npm run build` → Azure App Service or Functions (push triggering CI/CD)
- **IaC**: Bicep templates in `infra/` (apply via `az deployment group create`)
- **Secrets**: Store in Key Vault, inject at runtime via `@azure/keyvault-secrets`

## Code Patterns & Conventions

### Routing (Express)
- Export default Router from each file: `export default router;`
- Import in server.ts: `import authRoutes from './routes/auth'; app.use('/auth', authRoutes);`
- Endpoint naming: `/auth/register`, `/orders/{id}`, `/products`
- Async handlers with try-catch, return `res.status(code).json(data)` or `res.status(500).json({ error })`

### Database Queries (Prisma)
- Always declare `const prisma = new PrismaClient();` at top of file (or inject as service)
- Use type-safe queries: `prisma.user.findUnique({ where: { id } })`, `create()`, `update()`, `delete()`
- Include relations: `{ include: { vendorProfile: true, orders: true } }`
- Handle not-found: check null return, throw error if required
- Example: `const user = await prisma.user.findUnique({ where: { email }, include: { orders: true } });`

### Authentication
- JWT payload: `{ userId, role, email }` signed with JWT_SECRET
- Middleware pattern: extract token from `Authorization: Bearer <token>` header, verify, attach to req.user
- Role checks: gate endpoints with `if (req.user.role !== 'VENDOR') return res.status(403).json(...)`
- Password: always hash with bcryptjs before storing, never log

### File Uploads (Multer + Azure Blob)
- Multer middleware filters by MIME type, enforces 10MB limit (id upload use case)
- storageService.ts handles upload to Azure: `uploadToBlob(container, blobName, buffer)`
- Return blob URL in response for UI to display
- Cleanup: implement blob deletion for removed files (id verification, product images)

### Real-time (Socket.IO)
- Server: initialize in server.ts with CORS, listen on `io.on('connection', (socket) => {})`
- Events: order status, driver location, delivery updates (emit to specific user rooms)
- Namespaces optional but consider `/orders`, `/deliveries` for org
- Frontend: import `useSocket` or init `io(BACKEND_URL)`, emit and on handlers

### Error Handling
- Use specific HTTP codes: 400 (bad request), 401 (auth), 403 (forbidden), 404 (not found), 500 (server error)
- Validation: check required fields early, return 400 with error message
- DB errors: catch Prisma errors (unique constraint, etc.), log, return 500
- Rate limiting applied at app level (100 req/15min per IP)

### Compliance & Security
- Age verification: user must upload ID, backend validates, sets `verified: true`
- Region check: orders only allowed in approved regions (South Africa)
- Data sensitivity: ID images, payment details, user location in Blob + encrypted at rest
- PII handling: never log passwords, credit cards, or full ID numbers
- Audit trail: log user actions (logins, orders, compliance checks) for compliance

## Key File References
- **Backend entry**: [backend/src/server.ts](backend/src/server.ts) - Express app setup
- **Database schema**: [backend/prisma/schema.prisma](backend/prisma/schema.prisma) - all models
- **Route examples**: [backend/src/routes/auth.ts](backend/src/routes/auth.ts), orders.ts, payments.ts
- **Utilities**: [backend/src/utils/storageService.ts](backend/src/utils/storageService.ts) - Azure Blob
- **App entry**: [apps/customer-app/src/](apps/customer-app/src/) - React components
- **TypeScript config**: [backend/tsconfig.json](backend/tsconfig.json) - paths mapping (@/* aliases)

## Environment Variables Template
```
# Backend (.env in backend/)
DATABASE_URL=postgresql://user:pass@localhost/cannabis_db
JWT_SECRET=your-secret-key-min-32-chars
FRONTEND_URL=http://localhost:3000
AZURE_STORAGE_CONNECTION_STRING=DefaultEndpointsProtocol=https;...
STRIPE_SECRET_KEY=sk_test_...
PAYFAST_MERCHANT_ID=...
PAYFAST_MERCHANT_KEY=...

# Frontend (.env.local in each app/)
REACT_APP_API_URL=http://localhost:3000
REACT_APP_STRIPE_PUBLIC_KEY=pk_test_...
REACT_APP_FIREBASE_CONFIG=...
```

## Common Commands Cheat Sheet
| Task | Command |
|------|---------|
| Lint backend | `cd backend && npm run lint` |
| Format code | `cd backend && npm run format` |
| Build backend | `cd backend && npm run build` |
| Build customer app | `cd apps/customer-app && npm run build` |
| Run all tests | `cd backend && npm test` |
| Prisma Studio | `cd backend && npx prisma studio` |
| Start dev env | `npm run dev` (if root script set up) or Terminal > Run Task |

## When Adding Features

1. **New endpoint?** Create route file in `backend/src/routes/`, add to server.ts
2. **New data model?** Add to `backend/prisma/schema.prisma`, run migrate, update types
3. **New app page?** Create Component in `apps/{app}/src/`, add Route in Router config
4. **External API?** Create service in `backend/src/services/`, inject in routes
5. **Database query?** Use Prisma patterns, include relations, handle errors
6. **Real-time feature?** Add Socket.IO event in server.ts, emit from handler, listen in React
7. **File upload?** Use multer middleware + storageService.uploadToBlob()
8. **Compliance check?** Add audit log, role check, region validation as needed

## Testing & Quality
- Jest for backend unit/integration tests
- React Testing Library for component tests (if configured)
- Linting: ESLint via npm run lint
- Type safety: strict tsconfig.json enforces TS checks
- Code formatting: Prettier on save (recommended in VS Code)
