$ErrorActionPreference = 'Stop'
$laravelPath = 'C:\Users\satab\Downloads\git\CodeVaultLaravel'
$listener = Get-NetTCPConnection -LocalPort 8000 -State Listen -ErrorAction SilentlyContinue

if ($listener) {
    Write-Host "CodeVault Laravel API is already listening on http://127.0.0.1:8000 (PID $($listener.OwningProcess))."
    exit 0
}

$stdout = Join-Path $laravelPath 'storage\logs\local-api.stdout.log'
$stderr = Join-Path $laravelPath 'storage\logs\local-api.stderr.log'
$process = Start-Process -FilePath 'php' `
    -ArgumentList @('artisan', 'serve', '--host=0.0.0.0', '--port=8000') `
    -WorkingDirectory $laravelPath `
    -WindowStyle Hidden `
    -RedirectStandardOutput $stdout `
    -RedirectStandardError $stderr `
    -PassThru

Start-Sleep -Seconds 2
Invoke-RestMethod -Uri 'http://127.0.0.1:8000/up' | Out-Null
Write-Host "CodeVault Laravel API started (launcher PID $($process.Id)) at http://127.0.0.1:8000/api/v1."
