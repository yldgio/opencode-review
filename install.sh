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
  if [ -z "$CI_MODE" ]; then
    read -p "Overwrite? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
      echo "Aborted."
      exit 1
    fi
  else
    echo "CI mode: overwriting existing configuration"
  fi
fi

# Copy .opencode directory
echo "Copying agent configuration..."
cp -r "$SCRIPT_DIR/.opencode" "$TARGET_DIR/"

# Remove development files (they're for this repo only)
rm -rf "$TARGET_DIR/.opencode/node_modules" 2>/dev/null || true
rm -f "$TARGET_DIR/.opencode/bun.lock" 2>/dev/null || true
rm -f "$TARGET_DIR/.opencode/package.json" 2>/dev/null || true
rm -f "$TARGET_DIR/.opencode/.gitignore" 2>/dev/null || true
rm -rf "$TARGET_DIR/.opencode/commands" 2>/dev/null || true
rm -f "$TARGET_DIR/.opencode/rules/implementation-session.md" 2>/dev/null || true

# Copy templates to correct locations
echo "Setting up configuration templates..."
mkdir -p "$TARGET_DIR/.opencode/rules"

# Copy stack-context template (will be overwritten by review-setup)
cp "$SCRIPT_DIR/templates/stack-context.md" "$TARGET_DIR/.opencode/rules/stack-context.md"

# Copy opencode.json (target project config)
cp "$SCRIPT_DIR/templates/opencode.json" "$TARGET_DIR/.opencode/opencode.json"

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
