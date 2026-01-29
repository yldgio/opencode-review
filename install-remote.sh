#!/bin/bash
set -e

# Code Review Multi-Agent Remote Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.sh | bash
# With args: curl -fsSL ... | bash -s -- [target-dir] [--ci]

REPO_URL="https://github.com/yldgio/opencode-review"
TEMP_DIR=$(mktemp -d)
TARGET_DIR="${1:-.}"
CI_FLAG=""

# Parse arguments
for arg in "$@"; do
  case $arg in
    --ci)
      CI_FLAG="--ci"
      ;;
    *)
      if [ "$arg" != "" ]; then
        TARGET_DIR="$arg"
      fi
      ;;
  esac
done

# Cleanup on exit
cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "Code Review Multi-Agent Installer"
echo "=================================="
echo ""

# Check for git
if ! command -v git &> /dev/null; then
  echo "Error: git is required but not installed."
  exit 1
fi

# Clone repository
echo "Downloading opencode-review..."
git clone --depth 1 --quiet "$REPO_URL" "$TEMP_DIR/opencode-review"

# Run the installer
echo "Installing to: $TARGET_DIR"
echo ""

if [ -n "$CI_FLAG" ]; then
  bash "$TEMP_DIR/opencode-review/install.sh" "$TARGET_DIR" --ci
else
  bash "$TEMP_DIR/opencode-review/install.sh" "$TARGET_DIR"
fi
