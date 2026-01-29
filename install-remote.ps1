# Code Review Multi-Agent Remote Installer
# Installs review agents globally to ~/.config/opencode/
# Usage: irm https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.ps1 | iex
# With args: & ([scriptblock]::Create((irm https://...))) -Force

param(
    [switch]$Force,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Write-Host "Code Review Multi-Agent Installer" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: irm https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.ps1 | iex"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Force    Overwrite existing files without prompting"
    Write-Host "  -Help     Show this help message"
    exit 0
}

$RepoUrl = "https://github.com/yldgio/opencode-review"
$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("opencode-review-" + [System.Guid]::NewGuid().ToString("N").Substring(0, 8))

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
    $InstallerPath = Join-Path $TempDir "install.ps1"
    
    if ($Force) {
        & $InstallerPath -Force
    } else {
        & $InstallerPath
    }
}
finally {
    # Cleanup
    if (Test-Path $TempDir) {
        Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
    }
}
