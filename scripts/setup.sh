#!/bin/bash

# setup.sh
# Sets up the development environment and installs pre-commit hooks

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper functions
log_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

log_error() {
  echo -e "${RED}✗ ERROR:${NC} $1" >&2
}

log_success() {
  echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

# Get repository root
REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

echo ""
echo "════════════════════════════════════════════════════════"
log_info "Setting up development environment"
echo "════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────
# 1. VERIFY GIT REPOSITORY
# ─────────────────────────────────────────────────────────

if [ ! -d "$REPO_ROOT/.git" ]; then
  log_error "Not a git repository: $REPO_ROOT"
  exit 1
fi

log_success "Git repository detected: $REPO_ROOT"

# ─────────────────────────────────────────────────────────
# 2. INSTALL PRE-COMMIT HOOKS
# ─────────────────────────────────────────────────────────

HOOKS_PATH=".githooks"

if [ ! -d "$REPO_ROOT/$HOOKS_PATH" ]; then
  log_error "Hooks directory not found: $REPO_ROOT/$HOOKS_PATH"
  exit 1
fi

log_info "Configuring git hooks path to: $HOOKS_PATH"

# Configure git to use .githooks directory for hooks
git config core.hooksPath "$HOOKS_PATH"

if git config core.hooksPath | grep -q "$HOOKS_PATH"; then
  log_success "Git configured to use hooks from $HOOKS_PATH"
else
  log_error "Failed to configure git hooks path"
  exit 1
fi

# ─────────────────────────────────────────────────────────
# 3. VERIFY HOOK FILES EXIST AND ARE EXECUTABLE
# ─────────────────────────────────────────────────────────

HOOKS_TO_CHECK=(
  "pre-commit"
)

for hook_name in "${HOOKS_TO_CHECK[@]}"; do
  hook_file="$REPO_ROOT/$HOOKS_PATH/$hook_name"
  
  if [ ! -f "$hook_file" ]; then
    log_warning "Hook file not found: $hook_file"
  elif [ ! -x "$hook_file" ]; then
    log_warning "Hook is not executable, making it executable: $hook_file"
    chmod +x "$hook_file"
    log_success "Hook made executable: $hook_name"
  else
    log_success "Hook is executable: $hook_name"
  fi
done

# ─────────────────────────────────────────────────────────
# 4. VERIFY VALIDATE SCRIPT EXISTS
# ─────────────────────────────────────────────────────────

VALIDATE_SCRIPT="$REPO_ROOT/scripts/validate-skill.sh"

if [ ! -f "$VALIDATE_SCRIPT" ]; then
  log_error "Validation script not found: $VALIDATE_SCRIPT"
  exit 1
fi

if [ ! -x "$VALIDATE_SCRIPT" ]; then
  log_info "Making validation script executable"
  chmod +x "$VALIDATE_SCRIPT"
fi

log_success "Validation script exists and is executable"

# ─────────────────────────────────────────────────────────
# 5. FINAL VERIFICATION
# ─────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════════════════════"
log_success "Setup complete!"
echo "════════════════════════════════════════════════════════"
echo ""

log_info "Environment details:"
echo "   Repository root: $REPO_ROOT"
echo "   Hooks path: $REPO_ROOT/$HOOKS_PATH"
echo "   Configured hooks path: $(git config core.hooksPath)"
echo ""

log_info "To test the hooks, try:"
echo "   cd $REPO_ROOT"
echo "   ./scripts/validate-skill.sh skills/_TEMPLATE"
echo ""

log_success "Ready to develop!"
echo ""
