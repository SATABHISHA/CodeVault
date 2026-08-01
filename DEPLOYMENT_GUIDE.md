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
   - Once the build is finished, GitHub will push the compiled files to the `web-production` branch automatically.
4. **Deploy via SSH:**
   - SSH into your Hostinger server: `ssh -p 65002 u473577775@82.25.106.143`
   - Run the following commands:
     ```bash
     cd ~/domains/scanhub.sroy.es/public_html
     git pull origin web-production
     ```
5. **Done!** Visit `https://scanhub.sroy.es` in your browser and your changes will be live.

---

## Current Hostinger Workflow (Manual Git-Based Deploy)

This repository also supports a direct deployment flow for the Hostinger server using the `web-production` branch.

### One-time server setup
- Create the SSH key pair locally and add the public key to the Hostinger account.
- Add an SSH config alias named `hostinger-codevault` for the server.
- Clone the `web-production` branch into the public HTML folder:

```bash
ssh hostinger-codevault "cd ~/domains/scanhub.sroy.es/public_html && git clone --single-branch --branch web-production https://github.com/SATABHISHA/CodeVault.git ."
```

### Local deployment commands
From the repository root on your machine, run:

```powershell
./scripts/deploy_web.ps1
```

That script will:
- build the Flutter web app in release mode,
- update the `web-production` branch with the generated files,
- push the latest build to GitHub.

Then publish the update on the Hostinger server:

```powershell
ssh hostinger-codevault "cd ~/domains/scanhub.sroy.es/public_html && git pull"
```

You can run both steps in one command:

```powershell
./scripts/deploy_web.ps1; ssh hostinger-codevault "cd ~/domains/scanhub.sroy.es/public_html && git pull"
```

---

## Troubleshooting

### What if the deployment fails?
1. Go to your GitHub repository in your web browser.
2. Click on the **Actions** tab.
3. Click on the latest workflow run to see exactly which step failed (e.g., if a dependency failed to download or if there was a syntax error in your code).

### Manual Backup Method (Not Recommended)
If GitHub Actions is completely broken and you need to deploy immediately in an emergency, you can deploy manually:
1. Run `flutter build web --release --base-href /` locally.
2. Log into your Hostinger server via SSH.
3. Use `scp` or an FTP client to upload all the contents of the `build/web/` directory directly into your Hostinger `domains/scanhub.sroy.es/public_html` folder, overwriting the old files.
