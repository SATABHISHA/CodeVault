# deploy_web.ps1
# Build Flutter Web and upload directly to Hostinger via SSH/SCP.
# No git branch switching. No web-production branch.
#
# Usage:
#   .\scripts\deploy_web.ps1
#
# Prerequisites:
#   - SSH key added to Hostinger (done once via setup)
#   - ~/.ssh/config entry named hostinger-codevault

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot   = Split-Path -Parent $PSScriptRoot
$BuildSrc   = Join-Path $RepoRoot "build\web"
$TarFile    = Join-Path $env:TEMP "codevault_web.tar.gz"
$RemoteDir  = "~/domains/scanhub.sroy.es/public_html"
$SshAlias   = "hostinger-codevault"
$SwFile     = Join-Path $BuildSrc "flutter_service_worker.js"
$BootstrapFile = Join-Path $BuildSrc "flutter_bootstrap.js"

Push-Location $RepoRoot
try {
    # 1. Build
    Write-Host ""
    Write-Host "[1/3] Building Flutter web (release)..." -ForegroundColor Cyan
    # Disable PWA service worker to prevent stale cached bundles on clients.
    & flutter build web --release --pwa-strategy=none
    if ($LASTEXITCODE -ne 0) { throw "flutter build web failed (exit $LASTEXITCODE)." }
    if (-not (Test-Path $BuildSrc)) { throw "build\web not found after build." }

        # Replace the generated placeholder service worker with a self-removing
        # cleaner so stale clients are forced off old Flutter cache manifests.
        $swScript = @'
self.addEventListener('install', () => self.skipWaiting());

self.addEventListener('activate', (event) => {
    event.waitUntil((async () => {
        try {
            const keys = await caches.keys();
            await Promise.all(keys.map((key) => caches.delete(key)));
        } catch (_) {}

        try {
            await self.registration.unregister();
        } catch (_) {}

        const clients = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
        for (const client of clients) {
            try {
                await client.navigate(client.url);
            } catch (_) {}
        }
    })());
});
'@
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($SwFile, $swScript, $utf8NoBom)

        # Bust CDN caches for the main Dart bundle by versioning the URL loaded
        # from flutter_bootstrap.js on each deploy.
        $buildVersion = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
        $bootstrap = [System.IO.File]::ReadAllText($BootstrapFile)
        $bootstrap = $bootstrap -replace '"mainJsPath":"main\.dart\.js"', ('"mainJsPath":"main.dart.js?v=' + $buildVersion + '"')
        [System.IO.File]::WriteAllText($BootstrapFile, $bootstrap, $utf8NoBom)

    # 2. Package
    Write-Host "[2/3] Packaging build output..." -ForegroundColor Cyan
    if (Test-Path $TarFile) { Remove-Item $TarFile -Force }
    & tar -czf $TarFile -C $BuildSrc .
    if ($LASTEXITCODE -ne 0) { throw "tar packaging failed." }
    $sizeMB = [Math]::Round((Get-Item $TarFile).Length / 1MB, 1)
    Write-Host "  Package size: ${sizeMB} MB" -ForegroundColor DarkGray

    # 3. Upload and extract on server
    Write-Host "[3/3] Uploading to Hostinger..." -ForegroundColor Cyan
    & scp $TarFile "${SshAlias}:~/web_deploy.tar.gz"
    if ($LASTEXITCODE -ne 0) { throw "scp upload failed." }

    $HtaccessSrc = Join-Path $RepoRoot "web\.htaccess"
    & scp $HtaccessSrc "${SshAlias}:~/web_htaccess"
    if ($LASTEXITCODE -ne 0) { throw "scp .htaccess upload failed." }

    & ssh $SshAlias "find $RemoteDir -mindepth 1 -delete 2>/dev/null; tar -xzf ~/web_deploy.tar.gz -C $RemoteDir; mv ~/web_htaccess $RemoteDir/.htaccess; rm -f ~/web_deploy.tar.gz; echo OK"
    if ($LASTEXITCODE -ne 0) { throw "Remote extract failed." }

    Write-Host ""
    Write-Host "=== Live on https://scanhub.sroy.es ===" -ForegroundColor Green
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    if (Test-Path $TarFile) { Remove-Item $TarFile -ErrorAction SilentlyContinue }
    Pop-Location
}