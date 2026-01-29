#!/bin/bash
set -e

# Code Review Multi-Agent Installer
# Installs review agents globally to ~/.config/opencode/
# Usage: ./install.sh [--force]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
FORCE=""

# Detect if running via pipe (stdin is not a terminal)
if [ ! -t 0 ]; then
  FORCE="true"
fi

# Parse arguments
for arg in "$@"; do
  case $arg in
    --force|-f)
      FORCE="true"
      ;;
    --help|-h)
      echo "Code Review Multi-Agent Installer"
      echo ""
      echo "Installs review agents globally to ~/.config/opencode/"
      echo ""
      echo "Usage: ./install.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  -f, --force    Overwrite existing files without prompting"
      echo "  -h, --help     Show this help message"
      echo ""
      echo "After installation, use: opencode run --agent review-setup \"detect the project stack\""
      exit 0
      ;;
  esac
done

echo "Code Review Multi-Agent Installer"
echo "=================================="
echo ""
echo "Installing to: $CONFIG_DIR"
echo ""

# Create config directory structure
mkdir -p "$CONFIG_DIR/agents"
mkdir -p "$CONFIG_DIR/tools"

# Check for existing agents
EXISTING_AGENTS=""
for agent in review-coordinator review-setup review-frontend review-backend review-devops; do
  if [ -f "$CONFIG_DIR/agents/$agent.md" ]; then
    EXISTING_AGENTS="$EXISTING_AGENTS $agent"
  fi
done

if [ -n "$EXISTING_AGENTS" ]; then
  echo "Warning: The following agents already exist:$EXISTING_AGENTS"
  if [ -z "$FORCE" ]; then
    read -p "Overwrite? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
      echo "Aborted."
      exit 1
    fi
  else
    echo "Force mode: overwriting existing files"
  fi
fi

# Copy agents
echo "Installing review agents..."
cp "$SCRIPT_DIR/.opencode/agent/review-coordinator.md" "$CONFIG_DIR/agents/"
cp "$SCRIPT_DIR/.opencode/agent/review-setup.md" "$CONFIG_DIR/agents/"
cp "$SCRIPT_DIR/.opencode/agent/review-frontend.md" "$CONFIG_DIR/agents/"
cp "$SCRIPT_DIR/.opencode/agent/review-backend.md" "$CONFIG_DIR/agents/"
cp "$SCRIPT_DIR/.opencode/agent/review-devops.md" "$CONFIG_DIR/agents/"

echo "  - review-coordinator (main orchestrator)"
echo "  - review-setup (stack detection)"
echo "  - review-frontend (React, Vue, CSS)"
echo "  - review-backend (APIs, databases)"
echo "  - review-devops (Docker, CI/CD, IaC)"

# Copy custom tools
echo ""
echo "Installing custom tools..."
cp "$SCRIPT_DIR/.opencode/tools/install-skill.ts" "$CONFIG_DIR/tools/"
echo "  - install-skill (skill installer)"

# Check for bun/node for tools
if ! command -v bun &> /dev/null && ! command -v node &> /dev/null; then
  echo ""
  echo "Warning: Neither bun nor node found. Custom tools require Node.js or Bun."
  echo "Install Node.js from: https://nodejs.org/"
fi

echo ""
echo "Installation complete!"
echo ""
echo "The review agents are now available globally in all your projects."
echo ""
echo "Next steps:"
echo "  1. Navigate to a project: cd /path/to/your/project"
echo "  2. Run stack detection: opencode run --agent review-setup \"detect the project stack\""
echo "  3. Run a code review: opencode run --agent review-coordinator \"review <file>\""
echo ""
echo "Note: Stack detection will create .opencode/rules/stack-context.md in your project."
echo "      This is the ONLY file added to your project (and it's optional)."
