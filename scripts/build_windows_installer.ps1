# Build and package the CodeVault Windows x64 release as one installer EXE.

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$PubspecPath = Join-Path $RepoRoot "pubspec.yaml"
$InstallerScript = Join-Path $RepoRoot "windows\installer\codevault.iss"
$ReleaseDirectory = Join-Path $RepoRoot "build\windows\x64\runner\Release"
$ReleaseExecutable = Join-Path $ReleaseDirectory "codevault.exe"
$OutputDirectory = Join-Path $RepoRoot "dist\windows"

function Find-InnoSetupCompiler {
    $command = Get-Command "ISCC.exe" -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        return $command.Source
    }

    $candidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Inno Setup 6\ISCC.exe"),
        (Join-Path ${env:ProgramFiles(x86)} "Inno Setup 6\ISCC.exe"),
        (Join-Path $env:ProgramFiles "Inno Setup 6\ISCC.exe")
    )

    return $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string[]]$ArgumentList,

        [Parameter(Mandatory = $true)]
        [string]$FailureMessage
    )

    & $FilePath @ArgumentList
    if ($LASTEXITCODE -ne 0) {
        throw "$FailureMessage (exit $LASTEXITCODE)."
    }
}

Push-Location $RepoRoot
try {
    $flutter = Get-Command "flutter" -ErrorAction SilentlyContinue
    if ($null -eq $flutter) {
        throw "Flutter was not found on PATH. Install Flutter and enable Windows desktop support."
    }

    $iscc = Find-InnoSetupCompiler
    if ([string]::IsNullOrWhiteSpace($iscc)) {
        throw "Inno Setup 6 was not found. Install it with: winget install --id JRSoftware.InnoSetup --exact --scope user"
    }

    $pubspec = [System.IO.File]::ReadAllText($PubspecPath)
    $versionMatch = [regex]::Match(
        $pubspec,
        '(?m)^\s*version:\s*([0-9]+\.[0-9]+\.[0-9]+)(?:\+([0-9]+))?\s*$'
    )
    if (-not $versionMatch.Success) {
        throw "Could not read a numeric version such as 1.0.0+1 from pubspec.yaml."
    }

    $appVersion = $versionMatch.Groups[1].Value
    $buildNumber = if ($versionMatch.Groups[2].Success) {
        $versionMatch.Groups[2].Value
    } else {
        "0"
    }
    $installerName = "CodeVault-$appVersion-Windows-x64.exe"
    $installerPath = Join-Path $OutputDirectory $installerName

    Write-Host ""
    Write-Host "CodeVault Windows installer build" -ForegroundColor White
    Write-Host "Version: $appVersion+$buildNumber" -ForegroundColor DarkGray
    Write-Host "Target:  Windows x64" -ForegroundColor DarkGray

    Write-Host ""
    Write-Host "[1/2] Building Flutter Windows release..." -ForegroundColor Cyan
    $flutterArguments = @(
        "build",
        "windows",
        "--release",
        "--build-name=$appVersion",
        "--build-number=$buildNumber"
    )
    Invoke-CheckedCommand -FilePath $flutter.Source -ArgumentList $flutterArguments -FailureMessage "Flutter Windows build failed"

    if (-not (Test-Path $ReleaseExecutable)) {
        throw "Expected release executable was not created: $ReleaseExecutable"
    }

    Write-Host "[2/2] Creating single-file installer..." -ForegroundColor Cyan
    if (Test-Path $installerPath) {
        Remove-Item $installerPath -Force
    }

    $isccArguments = @(
        "/Qp",
        "/DAppVersion=$appVersion",
        "/DAppBuild=$buildNumber",
        $InstallerScript
    )
    Invoke-CheckedCommand -FilePath $iscc -ArgumentList $isccArguments -FailureMessage "Inno Setup compilation failed"

    if (-not (Test-Path $installerPath)) {
        throw "Expected installer was not created: $installerPath"
    }

    $installer = Get-Item $installerPath
    $sizeMb = [Math]::Round($installer.Length / 1MB, 2)
    $sha256 = (Get-FileHash $installerPath -Algorithm SHA256).Hash

    Write-Host ""
    Write-Host "Windows installer created successfully." -ForegroundColor Green
    Write-Host "File:    $installerPath"
    Write-Host "Size:    $sizeMb MB"
    Write-Host "SHA-256: $sha256"
    Write-Host ""
} catch {
    Write-Host ""
    Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
}