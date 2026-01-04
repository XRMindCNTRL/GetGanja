# GitHub Secrets Setup - Azure Static Web Apps Deployment

## Quick Setup (5 minutes)

### Step 1: Prepare the New Deployment Token

Before setting up GitHub Secrets, you need the new deployment token from Azure:

1. Go to **Azure Portal**
2. Navigate to your **Static Web App (GetGanja)**
3. Click **Deployment center** or **Settings** → **Deployment tokens**
4. Click **Regenerate** and copy the new token

### Step 2: Add Secret to GitHub

1. Open your GitHub repository in a browser
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Fill in:
   - **Name:** `AZURE_STATIC_WEB_APPS_DEPLOYMENT_TOKEN`
   - **Value:** Paste the token you copied from Azure
5. Click **Add secret**

### Step 3: Test the Workflow

1. Make a small commit to the `main` branch (e.g., update README)
2. Go to **Actions** → **Deploy to Azure Static Web Apps** workflow
3. Confirm the deployment runs successfully
4. Verify the site updates at https://jolly-forest-020c52a0f.6.azurestaticapps.net

---

## What the Workflow Does

The GitHub Actions workflow (`.github/workflows/deploy-static-web-app.yml`) automatically:

1. **Builds** the React app (`npm run build`)
2. **Deploys** the build to Azure Static Web Apps
3. **Uses the secret** to authenticate with Azure (the secret is never logged or exposed)

---

## Troubleshooting

### Workflow fails with authentication error
- ✅ Verify the secret name is exactly: `AZURE_STATIC_WEB_APPS_DEPLOYMENT_TOKEN`
- ✅ Verify the token is correct and not expired
- ✅ Check GitHub Actions logs (not your build output) for the actual error

### Site not updating after push
- ✅ Confirm the workflow completed (green checkmark in **Actions**)
- ✅ Hard-refresh the site (Ctrl+Shift+R or Cmd+Shift+R)
- ✅ Check Azure deployment history for errors

### Can't access Secrets page
- ✅ You need **Admin** or **Maintain** permissions on the repository
- ✅ Ask your repo owner if you don't have access

---

## Secret Best Practices

- ✅ **Never share or display the secret value**
- ✅ **Never commit it to code**
- ✅ **Rotate it every 90 days** (or immediately if exposed)
- ✅ **Use for GitHub Actions only** (don't share to external services)
- ✅ **Delete old secrets** after rotation

---

## Next: Enable Branch Protection (Optional but Recommended)

Prevent accidental deployments to production:

1. Go to **Settings** → **Branches**
2. Click **Add rule** under "Branch protection rules"
3. Set up:
   - Branch name pattern: `main`
   - Require pull request reviews before merging
   - Require status checks to pass (select your workflow)
4. Save

This ensures only approved, tested code deploys to production.

---

## Resources

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)
- [Azure Static Web Apps Deploy Action](https://github.com/Azure/static-web-apps-deploy)
- [Cannabis Delivery Platform - Deployment Guide](./)
