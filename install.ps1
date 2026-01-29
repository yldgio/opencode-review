# Code Review Multi-Agent Installer
# Usage: .\install.ps1 [-TargetDir <path>] [-CI]

param(
    [string]$TargetDir = ".",
    [switch]$CI
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDir = Resolve-Path $TargetDir

Write-Host "Installing code review agents to: $TargetDir"

# Check if .opencode already exists
$OpenCodePath = Join-Path $TargetDir ".opencode"
if (Test-Path $OpenCodePath) {
    Write-Host "Warning: .opencode directory already exists in target" -ForegroundColor Yellow
    if (-not $CI) {
        $confirm = Read-Host "Overwrite? (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-Host "Aborted."
            exit 1
        }
    } else {
        Write-Host "CI mode: overwriting existing configuration"
    }
    Remove-Item -Recurse -Force $OpenCodePath
}

# Copy .opencode directory
Write-Host "Copying agent configuration..."
Copy-Item -Recurse (Join-Path $ScriptDir ".opencode") $TargetDir

# Remove development files (they're for this repo only)
$DevFiles = @(
    (Join-Path $OpenCodePath "node_modules"),
    (Join-Path $OpenCodePath "bun.lock"),
    (Join-Path $OpenCodePath "package.json"),
    (Join-Path $OpenCodePath ".gitignore"),
    (Join-Path $OpenCodePath "commands"),
    (Join-Path $OpenCodePath "rules" "implementation-session.md")
)

foreach ($file in $DevFiles) {
    if (Test-Path $file) {
        Remove-Item -Recurse -Force $file
    }
}

# Copy templates to correct locations
Write-Host "Setting up configuration templates..."
$RulesPath = Join-Path $OpenCodePath "rules"
if (-not (Test-Path $RulesPath)) {
    New-Item -ItemType Directory -Path $RulesPath | Out-Null
}

# Copy stack-context template (will be overwritten by review-setup)
Copy-Item (Join-Path $ScriptDir "templates" "stack-context.md") (Join-Path $RulesPath "stack-context.md")

# Copy opencode.json (target project config)
Copy-Item (Join-Path $ScriptDir "templates" "opencode.json") (Join-Path $OpenCodePath "opencode.json") -Force

Write-Host "Configuration copied successfully."

# Run stack detection
Write-Host ""
Write-Host "Running stack detection..."

Set-Location $TargetDir

$OpenCodeExists = Get-Command opencode -ErrorAction SilentlyContinue

if ($OpenCodeExists) {
    if ($CI) {
        opencode run "@review-setup detect this project --ci"
    } else {
        opencode run "@review-setup detect this project"
    }
} else {
    Write-Host "Warning: opencode CLI not found. Skipping stack detection." -ForegroundColor Yellow
    Write-Host "Install opencode and run: opencode run `"@review-setup detect this project`""
}

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Review .opencode\rules\stack-context.md for detected stack"
Write-Host "  2. Run a code review with: opencode run `"@review-coordinator review <file>`""
