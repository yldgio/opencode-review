# Issue 5 - Minimal Installer Script

**Status:** DONE

## Overview

Create a simple installation script that copies the code review configuration into a target project and runs the setup agent to detect the stack.

---

## Subtasks

### 5.1 Create Install Script (MVP)

**Status:** DONE

**Requirement:**
Provide scripts to install the code review agents into any project and run stack detection.

**Implementation Details:**

#### Bash Script (Linux/macOS/Git Bash)

Create `install.sh` at repository root:

```bash
#!/bin/bash
set -e

# Code Review Multi-Agent Installer
# Usage: ./install.sh [target-directory] [--ci]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-.}"
CI_MODE=""

# Parse arguments
for arg in "$@"; do
  case $arg in
    --ci)
      CI_MODE="--ci"
      shift
      ;;
    *)
      if [ -d "$arg" ]; then
        TARGET_DIR="$arg"
      fi
      ;;
  esac
done

# Resolve target directory
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo "Installing code review agents to: $TARGET_DIR"

# Check if .opencode already exists
if [ -d "$TARGET_DIR/.opencode" ]; then
  echo "Warning: .opencode directory already exists in target"
  read -p "Overwrite? (y/N): " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Aborted."
    exit 1
  fi
fi

# Copy .opencode directory
echo "Copying agent configuration..."
cp -r "$SCRIPT_DIR/.opencode" "$TARGET_DIR/"

# Remove node_modules if present (they're for development only)
rm -rf "$TARGET_DIR/.opencode/node_modules" 2>/dev/null || true
rm -f "$TARGET_DIR/.opencode/bun.lock" 2>/dev/null || true
rm -f "$TARGET_DIR/.opencode/package.json" 2>/dev/null || true

echo "Configuration copied successfully."

# Run stack detection
echo ""
echo "Running stack detection..."

cd "$TARGET_DIR"

if command -v opencode &> /dev/null; then
  if [ -n "$CI_MODE" ]; then
    opencode run "@review-setup detect this project --ci"
  else
    opencode run "@review-setup detect this project"
  fi
else
  echo "Warning: opencode CLI not found. Skipping stack detection."
  echo "Install opencode and run: opencode run \"@review-setup detect this project\""
fi

echo ""
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Review .opencode/rules/stack-context.md for detected stack"
echo "  2. Run a code review with: opencode run \"@review-coordinator review <file>\""
```

#### PowerShell Script (Windows)

Create `install.ps1` at repository root:

```powershell
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
    $confirm = Read-Host "Overwrite? (y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "Aborted."
        exit 1
    }
    Remove-Item -Recurse -Force $OpenCodePath
}

# Copy .opencode directory
Write-Host "Copying agent configuration..."
Copy-Item -Recurse (Join-Path $ScriptDir ".opencode") $TargetDir

# Remove development files
$NodeModules = Join-Path $OpenCodePath "node_modules"
$BunLock = Join-Path $OpenCodePath "bun.lock"
$PackageJson = Join-Path $OpenCodePath "package.json"

if (Test-Path $NodeModules) { Remove-Item -Recurse -Force $NodeModules }
if (Test-Path $BunLock) { Remove-Item -Force $BunLock }
if (Test-Path $PackageJson) { Remove-Item -Force $PackageJson }

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
Write-Host "  1. Review .opencode/rules/stack-context.md for detected stack"
Write-Host "  2. Run a code review with: opencode run `"@review-coordinator review <file>`""
```

#### Script Features

| Feature | Description |
|---------|-------------|
| Target directory | Can specify where to install (default: current directory) |
| `--ci` flag | Non-interactive mode for CI/CD pipelines |
| Overwrite protection | Prompts before overwriting existing `.opencode` |
| Auto-detection | Runs `review-setup` after copying files |
| Cleanup | Removes development files (node_modules, lock files) |
| Graceful fallback | Works even if opencode CLI is not installed |

**Acceptance Criteria:**
- [x] `install.sh` exists at repository root
- [x] `install.ps1` exists at repository root
- [x] Both scripts accept target directory argument
- [x] Both scripts support `--ci` flag for non-interactive mode
- [x] Scripts copy `.opencode/` to target (excluding dev files)
- [x] Scripts run `review-setup` agent after copying
- [x] Scripts handle missing opencode CLI gracefully
- [x] Scripts print next steps on completion

---

## Files to Create

| File | Action |
|------|--------|
| `install.sh` | CREATE |
| `install.ps1` | CREATE |

---

## Dependencies

- Issue 1: `review-setup` agent must exist
- Issue 4: Directory structure must be correct

---

## Testing

### Bash Script
```bash
# Test on a sample project
cd /path/to/sample-project
/path/to/code-review-oc/install.sh . --ci

# Verify installation
ls -la .opencode/
cat .opencode/rules/stack-context.md
```

### PowerShell Script
```powershell
# Test on a sample project
cd C:\path\to\sample-project
C:\path\to\code-review-oc\install.ps1 -TargetDir . -CI

# Verify installation
Get-ChildItem .opencode\
Get-Content .opencode\rules\stack-context.md
```

### CI/CD Integration Test
```yaml
# Example GitHub Actions usage
- name: Install code review agents
  run: |
    git clone https://github.com/your-org/code-review-oc /tmp/code-review
    /tmp/code-review/install.sh . --ci
```
