# Code Review Multi-Agent Installer
# Installs review agents globally to ~/.config/opencode/
# Usage: .\install.ps1 [-Force]

param(
    [switch]$Force,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Write-Host "Code Review Multi-Agent Installer" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Installs review agents globally to ~/.config/opencode/"
    Write-Host ""
    Write-Host "Usage: .\install.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Force    Overwrite existing files without prompting"
    Write-Host "  -Help     Show this help message"
    Write-Host ""
    Write-Host "After installation, use: opencode run --agent review-setup `"detect the project stack`""
    exit 0
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Determine config directory (respect OPENCODE_CONFIG_DIR if set)
if ($env:OPENCODE_CONFIG_DIR) {
    $ConfigDir = $env:OPENCODE_CONFIG_DIR
} else {
    $ConfigDir = Join-Path $env:USERPROFILE ".config\opencode"
}

Write-Host "Code Review Multi-Agent Installer" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installing to: $ConfigDir"
Write-Host ""

# Create config directory structure
$AgentsDir = Join-Path $ConfigDir "agents"
$ToolsDir = Join-Path $ConfigDir "tools"

New-Item -ItemType Directory -Path $AgentsDir -Force | Out-Null
New-Item -ItemType Directory -Path $ToolsDir -Force | Out-Null

# Check for existing agents
$Agents = @("review-coordinator", "review-setup", "review-frontend", "review-backend", "review-devops")
$ExistingAgents = @()

foreach ($agent in $Agents) {
    $AgentPath = Join-Path $AgentsDir "$agent.md"
    if (Test-Path $AgentPath) {
        $ExistingAgents += $agent
    }
}

if ($ExistingAgents.Count -gt 0) {
    Write-Host "Warning: The following agents already exist: $($ExistingAgents -join ', ')" -ForegroundColor Yellow
    if (-not $Force) {
        $confirm = Read-Host "Overwrite? (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-Host "Aborted."
            exit 1
        }
    } else {
        Write-Host "Force mode: overwriting existing files"
    }
}

# Copy agents
Write-Host "Installing review agents..."
$SourceAgentDir = Join-Path $ScriptDir ".opencode\agent"

Copy-Item (Join-Path $SourceAgentDir "review-coordinator.md") $AgentsDir -Force
Copy-Item (Join-Path $SourceAgentDir "review-setup.md") $AgentsDir -Force
Copy-Item (Join-Path $SourceAgentDir "review-frontend.md") $AgentsDir -Force
Copy-Item (Join-Path $SourceAgentDir "review-backend.md") $AgentsDir -Force
Copy-Item (Join-Path $SourceAgentDir "review-devops.md") $AgentsDir -Force

Write-Host "  - review-coordinator (main orchestrator)"
Write-Host "  - review-setup (stack detection)"
Write-Host "  - review-frontend (React, Vue, CSS)"
Write-Host "  - review-backend (APIs, databases)"
Write-Host "  - review-devops (Docker, CI/CD, IaC)"

# Copy custom tools
Write-Host ""
Write-Host "Installing custom tools..."
$SourceToolsDir = Join-Path $ScriptDir ".opencode\tools"

Copy-Item (Join-Path $SourceToolsDir "install-skill.ts") $ToolsDir -Force
Write-Host "  - install-skill (skill installer)"

# Check for node
$NodeExists = Get-Command node -ErrorAction SilentlyContinue
$BunExists = Get-Command bun -ErrorAction SilentlyContinue

if (-not $NodeExists -and -not $BunExists) {
    Write-Host ""
    Write-Host "Warning: Neither bun nor node found. Custom tools require Node.js or Bun." -ForegroundColor Yellow
    Write-Host "Install Node.js from: https://nodejs.org/"
}

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "The review agents are now available globally in all your projects."
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Navigate to a project: cd C:\path\to\your\project"
Write-Host "  2. Run stack detection: opencode run --agent review-setup `"detect the project stack`""
Write-Host "  3. Run a code review: opencode run --agent review-coordinator `"review <file>`""
Write-Host ""
Write-Host "Note: Stack detection will create .opencode\rules\stack-context.md in your project."
Write-Host "      This is the ONLY file added to your project (and it's optional)."
