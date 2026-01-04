# Azure Static Web Apps - Deployment Token Rotation & Security Guide

## ⚠️ CRITICAL: Token Exposure Detected

**Issue:** The deployment token was posted publicly in chat/communication.  
**Action Required:** Rotate the token immediately to prevent unauthorized deployments.

---

## How to Rotate the Deployment Token

### Option 1: Via Azure Portal (Recommended for non-technical users)

1. Go to **Azure Portal** → search for **"GetGanja"** (or navigate to your Static Web App)
2. In the left menu, click **Deployment center** or **Settings** → **Deployment tokens**
3. Click **Regenerate** next to the existing token
4. Copy the new token (you'll only see it once)
5. **Save the new token securely** (see "Secure Storage" section below)
6. Update your CI/CD systems (GitHub Actions, etc.) with the new token

### Option 2: Via Azure CLI

```bash
# Authenticate
az login

# Get the current deployment token (shows last few chars only)
az staticwebapp show -n GetGanja -g CannabisApp --query "repositoryToken" --output tsv

# Regenerate the token (creates a new one, old one becomes invalid)
az staticwebapp update -n GetGanja -g CannabisApp --repository-token
```

**Note:** After regenerating, retrieve the new token and update your secrets.

---

## Secure Storage: GitHub Actions Secrets

### How to Store the New Token in GitHub Secrets

1. Navigate to your GitHub repository
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `AZURE_STATIC_WEB_APPS_DEPLOYMENT_TOKEN`
5. Value: Paste the new deployment token from Azure
6. Click **Add secret**

### Using the Secret in GitHub Actions Workflow

The workflow file `.github/workflows/deploy-static-web-app.yml` already uses this secret:

```yaml
azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_DEPLOYMENT_TOKEN }}
```

---

## Token Lifecycle Best Practices

| Practice | Description |
|----------|-------------|
| **Never commit tokens to git** | Store in environment variables, secrets managers, or CI/CD systems |
| **Rotate regularly** | Every 90 days (or immediately if exposed) |
| **Use environment-specific tokens** | Separate tokens for staging/production if possible |
| **Monitor usage** | Check deployment history in Azure Portal regularly |
| **Revoke immediately if compromised** | Do not wait; regenerate immediately |
| **Use GitHub Secrets for CI/CD** | GitHub encrypts and masks secret values in logs |

---

## Verification After Rotation

1. Update the GitHub secret with the new token
2. Push a test commit to `main` (e.g., update README or minor file change)
3. Check **GitHub Actions** → **Workflows** → **Deploy to Azure Static Web Apps** to verify deployment succeeds
4. Confirm the site deployed correctly: https://jolly-forest-020c52a0f.6.azurestaticapps.net

---

## Revoking a Token (vs. Rotating)

If you want to **revoke access entirely** without rotating:

- **Azure Portal:** Go to **Deployment center** → **Manage access** → Remove/revoke the token
- **Azure CLI:** `az staticwebapp identity remove --name GetGanja --resource-group CannabisApp`

---

## Additional Security Recommendations

- ✅ Enable **Managed Identity** in Azure for better secret management
- ✅ Use **Azure Key Vault** to store and rotate tokens
- ✅ Enable **GitHub branch protection** to require approval before deploying to production
- ✅ Monitor **Azure Activity Log** for unauthorized deployment attempts
- ✅ Use separate deployment tokens for staging and production environments

---

## Resources

- [Azure Static Web Apps - Manage deployment tokens](https://learn.microsoft.com/en-us/azure/static-web-apps/deployment-token-management)
- [GitHub Actions - Using secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)
- [Microsoft - Best practices for managing secrets](https://learn.microsoft.com/en-us/azure/security/fundamentals/secrets-management)
