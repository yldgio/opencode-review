# Code Review Multi-Agent Remote Installer
# Usage: irm https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.ps1 | iex
# With args: & ([scriptblock]::Create((irm https://...))) -TargetDir "." -CI

param(
    [string]$TargetDir = ".",
    [switch]$CI
)

$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/yldgio/opencode-review"
$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("opencode-review-" + [System.Guid]::NewGuid().ToString("N").Substring(0, 8))

Write-Host "Code Review Multi-Agent Installer" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check for git
$GitExists = Get-Command git -ErrorAction SilentlyContinue
if (-not $GitExists) {
    Write-Host "Error: git is required but not installed." -ForegroundColor Red
    exit 1
}

try {
    # Clone repository
    Write-Host "Downloading opencode-review..."
    git clone --depth 1 --quiet $RepoUrl $TempDir

    # Run the installer
    Write-Host "Installing to: $TargetDir"
    Write-Host ""

    $InstallerPath = Join-Path $TempDir "install.ps1"
    
    if ($CI) {
        & $InstallerPath -TargetDir $TargetDir -CI
    } else {
        & $InstallerPath -TargetDir $TargetDir
    }
}
finally {
    # Cleanup
    if (Test-Path $TempDir) {
        Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
    }
}
