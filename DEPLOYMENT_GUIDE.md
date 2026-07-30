# CodeVault Deployment Guide

This guide explains how the CodeVault Flutter Web application is deployed to the Hostinger production server.

## The Deployment Process (Fully Automated!)

You do **NOT** need to manually build the app, you do **NOT** need to push to a `web-production` branch, and you do **NOT** need to log into SSH to pull changes. 

The entire process is automated via **GitHub Actions**.

### Step-by-Step Instructions for Future Updates:

1. **Write your code:** Make whatever changes you need in your local `main` branch.
2. **Commit and Push:**
   ```bash
   git add .
   git commit -m "Your update message"
   git push origin main
   ```
3. **Wait 2 Minutes:**
   - As soon as you push to `main`, GitHub Actions detects the change.
   - GitHub will spin up a cloud server, install Flutter `3.38.7`, and automatically run `flutter build web --release`.
   - Once the build is finished, GitHub will securely log into your Hostinger server (using the `HOSTINGER_PASSWORD` secret you provided) and copy the new compiled files directly into the `public_html` folder.
4. **Done!** Visit `https://scanhub.sroy.es` in your browser and your changes will be live.

---

## Troubleshooting

### What if the deployment fails?
1. Go to your GitHub repository in your web browser.
2. Click on the **Actions** tab.
3. Click on the latest workflow run to see exactly which step failed (e.g., if a dependency failed to download or if there was a syntax error in your code).

### Manual Backup Method (Not Recommended)
If GitHub Actions is completely broken and you need to deploy immediately in an emergency, you can deploy manually:
1. Run `flutter build web --release --base-href /` locally.
2. Log into your Hostinger control panel or use an FTP client (like FileZilla).
3. Upload all the contents of the `build/web/` directory directly into your Hostinger `domains/scanhub.sroy.es/public_html` folder, overwriting the old files.
