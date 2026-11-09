# Treg Deployment & Webhook Guide

## VPS & Dokploy Infrastructure

- **VPS Host / IP**: `69.62.106.189`
- **SSH User**: `root`
- **SSH Password**: `Kissinger2026@`
- **Dokploy Dashboard**: `http://69.62.106.189:3000`
- **Dokploy Project**: `Treg`
- **Dokploy Environment**: `production`
- **Application Name**: `treg` (`treg-app-2026`)
- **GitHub Repository**: `https://github.com/denneltechnologies-tech/treg.git` (branch: `main`)
- **Live HTTPS URL**: `https://treg-69-62-106-189.sslip.io`
- **Healthcheck Endpoint**: `https://treg-69-62-106-189.sslip.io/meta`
- **Web Dashboard**: `https://treg-69-62-106-189.sslip.io/app`

---

## Automatic Deployment Webhook

To have your project automatically deploy every time you push code to GitHub:

1. Open your GitHub repository: [https://github.com/denneltechnologies-tech/treg](https://github.com/denneltechnologies-tech/treg)
2. Go to **Settings** > **Webhooks** > Click **Add webhook**
3. Configure the following fields:
   - **Payload URL**: `http://69.62.106.189:3000/api/deploy/treg_deploy_webhook_2026_auto`
   - **Content type**: `application/json`
   - **Secret**: *(leave empty)*
   - **Which events would you like to trigger this webhook?**: Select **Just the `push` event**.
   - **Active**: Check the box.
4. Click **Add webhook**.

Every time you push commits to the `main` branch, GitHub sends a payload to Dokploy, and Dokploy will pull, build the Docker image, run migrations (`python -m treg upgrade`), and reload the service with zero downtime!

---

## Manual Webhook Trigger via cURL

You can also trigger a deployment from any terminal:

```bash
curl -i -X POST \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -d '{"ref": "refs/heads/main"}' \
  http://69.62.106.189:3000/api/deploy/treg_deploy_webhook_2026_auto
```

---

## Admin Sign-in & Authentication

- **Login URL**: `https://treg-69-62-106-189.sslip.io/login`
- **Admin Email**: `otooaggreydennis@gmail.com`
- **Sign-in Method**: Email PIN
- **Fixed PIN**: `202600`
- **Role**: Superadmin & Owner of `Otooaggreydennis's team`

### How to Sign In:
1. Go to `https://treg-69-62-106-189.sslip.io/login` (or `/app`).
2. In the Sign In modal, enter `otooaggreydennis@gmail.com` into the **Email** field.
3. Click **"Email me a sign-in code"**.
4. When prompted for the 6-digit code, enter `202600`.
5. Click **"Sign in"**. The dashboard will load with full Superadmin privileges!

### Enabling Google One-Click Login (Optional):
To use the "Continue with Google" button:
1. Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials).
2. Create an **OAuth 2.0 Client ID** (Web application).
3. Set Authorized Redirect URI: `https://treg-69-62-106-189.sslip.io/auth/google/callback`.
4. Add the following environment variables in Dokploy (`Treg` -> `treg` -> Environment):
   ```
   TREG_GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
   TREG_GOOGLE_CLIENT_SECRET=your-google-client-secret
   ```

