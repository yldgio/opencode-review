#!/bin/bash
set -e

# Code Review Multi-Agent Remote Installer
# Installs review agents globally to ~/.config/opencode/
# Usage: curl -fsSL https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.sh | bash
# With args: curl -fsSL ... | bash -s -- [--force]

REPO_URL="https://github.com/yldgio/opencode-review"
TEMP_DIR=$(mktemp -d)
FORCE_FLAG=""

# Parse arguments
for arg in "$@"; do
  case $arg in
    --force|-f)
      FORCE_FLAG="--force"
      ;;
    --help|-h)
      echo "Code Review Multi-Agent Installer"
      echo ""
      echo "Usage: curl -fsSL https://raw.githubusercontent.com/yldgio/opencode-review/main/install-remote.sh | bash"
      echo "       curl -fsSL ... | bash -s -- [--force]"
      echo ""
      echo "Options:"
      echo "  --force, -f    Overwrite existing files without prompting"
      echo "  --help, -h     Show this help message"
      exit 0
      ;;
  esac
done

# Cleanup on exit
cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

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
bash "$TEMP_DIR/opencode-review/install.sh" $FORCE_FLAG
