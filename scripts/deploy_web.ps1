# ============================================================
# deploy_web.ps1 — Build Flutter Web and deploy to Hostinger
# ============================================================
# Usage:
#   .\scripts\deploy_web.ps1
#
# What it does:
#   1. flutter build web --release
#   2. Updates the web-production branch with the new build
#   3. Pushes to GitHub (origin/web-production)
#
# To publish to Hostinger after running this script:
#   ssh hostinger-codevault "cd ~/domains/scanhub.sroy.es/public_html && git pull"
# ============================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$WorktreeDir = Join-Path $env:TEMP "codevault-web-deploy-worktree"

Push-Location $RepoRoot

try {
    # --- 1. Build Flutter Web ---
    Write-Host "`n[1/4] Building Flutter web (release)..." -ForegroundColor Cyan
    flutter build web --release
    if ($LASTEXITCODE -ne 0) { throw "flutter build web failed." }

    $BuildSrc = Join-Path $RepoRoot "build\web"
    if (-not (Test-Path $BuildSrc)) { throw "build\web not found after build." }

    # --- 2. Prepare worktree for web-production branch ---
    Write-Host "`n[2/4] Preparing web-production worktree..." -ForegroundColor Cyan

    if (Test-Path $WorktreeDir) {
        git worktree remove --force $WorktreeDir 2>$null
        if (Test-Path $WorktreeDir) { Remove-Item -Recurse -Force $WorktreeDir }
    }

    git fetch origin web-production
    git worktree add $WorktreeDir web-production

    # --- 3. Sync build output into the worktree ---
    Write-Host "`n[3/4] Syncing build files to web-production..." -ForegroundColor Cyan

    Push-Location $WorktreeDir
    try {
        # Remove all tracked files (keep .git)
        git rm -rf . --quiet

        # Copy build/web contents into the worktree root
        Copy-Item -Path "$BuildSrc\*" -Destination $WorktreeDir -Recurse -Force

        # Commit
        $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $CommitMsg = "Deploy web build - $Timestamp"
        git add -A
        git diff --cached --quiet
        if ($LASTEXITCODE -eq 0) {
            Write-Host "No changes detected — already up to date." -ForegroundColor Yellow
        } else {
            git commit -m $CommitMsg
            Write-Host "Committed: $CommitMsg" -ForegroundColor Green
        }
    } finally {
        Pop-Location
    }

    # --- 4. Push to GitHub ---
    Write-Host "`n[4/4] Pushing web-production to GitHub..." -ForegroundColor Cyan
    git push origin web-production
    if ($LASTEXITCODE -ne 0) { throw "git push failed." }

    Write-Host "`n=== Build deployed to GitHub (web-production) ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "To go live on Hostinger, run:" -ForegroundColor Yellow
    Write-Host '  ssh hostinger-codevault "cd ~/domains/scanhub.sroy.es/public_html && git pull"' -ForegroundColor White
    Write-Host ""
    Write-Host "Or to build + deploy + pull in one shot:" -ForegroundColor Yellow
    Write-Host '  .\scripts\deploy_web.ps1 ; ssh hostinger-codevault "cd ~/domains/scanhub.sroy.es/public_html && git pull"' -ForegroundColor White

} catch {
    Write-Host "`n[ERROR] $_" -ForegroundColor Red
    exit 1
} finally {
    # Clean up worktree
    if (Test-Path $WorktreeDir) {
        git worktree remove --force $WorktreeDir 2>$null
        if (Test-Path $WorktreeDir) { Remove-Item -Recurse -Force $WorktreeDir 2>$null }
    }
    Pop-Location
}
