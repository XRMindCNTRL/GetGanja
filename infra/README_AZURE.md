# Azure App Service deployment (App Service + optional DB/Redis)

This folder contains a Bicep template and workflows to deploy the platform to Azure App Service.

Important: I will deploy both **backend** and **frontend** to Azure App Service as requested.

Pre-reqs
- A GitHub repository secret named `AZURE_CREDENTIALS` containing the JSON output of `az ad sp create-for-rbac ... --sdk-auth`.
- Secrets used in workflows:
  - `AZURE_CREDENTIALS` (required)
  - `AZURE_SUBSCRIPTION_ID` (recommended)
  - `POSTGRES_PASSWORD` (required if deploying PostgreSQL)

How to deploy
1. Ensure `AZURE_CREDENTIALS` is added to GitHub repository secrets.
2. (Optional) Set `POSTGRES_PASSWORD` secret in your repo if you want the Bicep template to create PostgreSQL.
3. Run the `Deploy infrastructure` workflow from Actions -> Deploy infrastructure (or trigger via workflow_dispatch). Provide the resource group `cannabis-delivery-rg` and location (`eastus` by default).
4. After infrastructure deployment finishes, use the `Deploy Backend` and `Deploy Frontend` workflows (they run on push to `main` by default).

Notes
- The Bicep template will create App Service Plan (Linux Node 20), two Web Apps, Application Insights and Key Vault. PostgreSQL Flexible and Redis are optional and created when enabled in the workflow input or parameters.
- App Service will be configured to use Node 20 and to run builds during deployment.
- Do not store secrets in this repo. Use Key Vault and GitHub Secrets.
