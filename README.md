# CodeVault

## Deployment workflow

The web app can be deployed to Hostinger using the Git-based workflow below.

### One-time setup
- Add the SSH key for the Hostinger server and configure the alias `hostinger-codevault`.
- Clone the `web-production` branch into the public HTML folder on the server.

### Deploy from local machine
Run the PowerShell script from the repository root:

```powershell
./scripts/deploy_web.ps1
```

This builds the Flutter web app, commits the generated files into the `web-production` branch, and pushes them to GitHub.

To publish the latest build on the Hostinger server, run:

```powershell
ssh hostinger-codevault "cd ~/domains/scanhub.sroy.es/public_html && git pull"
```

You can also run both steps in one command:

```powershell
./scripts/deploy_web.ps1; ssh hostinger-codevault "cd ~/domains/scanhub.sroy.es/public_html && git pull"
```