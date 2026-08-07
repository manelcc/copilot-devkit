#!/bin/bash

# setup.sh
# Configura copilot-devkit en una máquina nueva — instala globales en ~/.copilot/ y CLI en PATH.
# Ejecutar UNA SOLA VEZ desde el root del repo.

set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

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

echo ""
echo "════════════════════════════════════════════════════════"
log_info "Setting up copilot-devkit globally"
echo "════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────
# 1. DETECT SHELL CONFIG
# ─────────────────────────────────────────────────────────

if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_RC="$HOME/.bashrc"
elif [[ -f "$HOME/.bash_profile" ]]; then
    SHELL_RC="$HOME/.bash_profile"
else
    log_error "No se encontró ~/.zshrc ni ~/.bashrc"
    echo "   Añade manualmente a tu shell rc:"
    echo "   export COPILOT_DEVKIT_HOME=\"$REPO_ROOT\""
    echo "   export PATH=\"\$COPILOT_DEVKIT_HOME/cli-tools:\$PATH\""
    exit 1
fi

# ─────────────────────────────────────────────────────────
# 2. ADD CLI TO PATH AND EXPORT COPILOT_DEVKIT_HOME
# ─────────────────────────────────────────────────────────

if grep -q "COPILOT_DEVKIT_HOME" "$SHELL_RC" 2>/dev/null; then
    log_success "COPILOT_DEVKIT_HOME ya está en $SHELL_RC"
else
    echo "" >> "$SHELL_RC"
    echo "# Copilot DevKit" >> "$SHELL_RC"
    echo "export COPILOT_DEVKIT_HOME=\"$REPO_ROOT\"" >> "$SHELL_RC"
    log_success "COPILOT_DEVKIT_HOME añadido a $SHELL_RC"
fi

# ─────────────────────────────────────────────────────────
# 3. INSTALL PYTHON >= 3.11 VERIFICATION
# ─────────────────────────────────────────────────────────

if ! command -v python3 >/dev/null 2>&1; then
  log_error "python3 no está disponible en PATH"
  exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
PYTHON_OK=$(python3 -c 'import sys; print(int((sys.version_info.major, sys.version_info.minor) >= (3, 11)))')

if [ "$PYTHON_OK" != "1" ]; then
  log_error "Se requiere Python >= 3.11. Detectado: $PYTHON_VERSION"
  exit 1
fi

log_info "Instalando CLI devtools (editable)"
set +e
python3 -m pip install -q -e "$REPO_ROOT/cli-tools"
pip_exit_code=$?
set -e

if [ "$pip_exit_code" -ne 0 ]; then
  log_warning "Fallo en pip editable install. Reintentando con compatibilidad PEP 668 (--break-system-packages)."
  python3 -m pip install -q --break-system-packages -e "$REPO_ROOT/cli-tools"
fi

if command -v devtools >/dev/null 2>&1; then
  log_success "CLI devtools instalada"
else
  log_warning "No se encontró 'devtools' en PATH tras la instalación"
fi

if command -v setup-project >/dev/null 2>&1; then
  log_success "Comando setup-project disponible"
else
  log_warning "No se encontró 'setup-project' en PATH tras la instalación"
fi

# ─────────────────────────────────────────────────────────
# 4. LINK GLOBAL SKILLS TO ~/.copilot/skills/
# ─────────────────────────────────────────────────────────

GLOBAL_SKILLS_DIR="$REPO_ROOT/skills/global"
COPILOT_SKILLS_DIR="$HOME/.copilot/skills"
mkdir -p "$COPILOT_SKILLS_DIR"

linked=0
while IFS= read -r skill_md; do
  skill_dir="$(dirname "$skill_md")"
  skill_name="$(basename "$skill_dir")"
  target="$COPILOT_SKILLS_DIR/$skill_name"

  if [[ -L "$target" ]]; then
    current_target="$(readlink "$target")"
    if [[ "$current_target" == "$skill_dir" ]]; then
      log_info "Ya enlazada: $skill_name"
    else
      rm "$target"
      ln -s "$skill_dir" "$target"
      log_success "Actualizada: $skill_name"
      ((linked++)) || true
    fi
  elif [[ -e "$target" ]]; then
    log_warning "Existe (no es symlink): $skill_name — omitida"
  else
    ln -s "$skill_dir" "$target"
    log_success "Enlazada: $skill_name"
    ((linked++)) || true
  fi
done < <(find "$GLOBAL_SKILLS_DIR" -type f -name "SKILL.md" | sort)

# ─────────────────────────────────────────────────────────
# 5. LINK GLOBAL AGENTS TO ~/.copilot/agents/
# ─────────────────────────────────────────────────────────

GLOBAL_AGENTS_DIR="$REPO_ROOT/agents/global"
COPILOT_AGENTS_DIR="$HOME/.copilot/agents"
mkdir -p "$COPILOT_AGENTS_DIR"

agents_linked=0
for agent_file in "$GLOBAL_AGENTS_DIR"/*.agent.md; do
    [[ -f "$agent_file" ]] || continue
    agent_name="$(basename "$agent_file")"
    target="$COPILOT_AGENTS_DIR/$agent_name"

    if [[ -L "$target" ]]; then
        current_target="$(readlink "$target")"
        if [[ "$current_target" == "$agent_file" ]]; then
            log_info "Agente ya enlazado: $agent_name"
        else
            rm "$target"
            ln -s "$agent_file" "$target"
            log_success "Agente actualizado: $agent_name"
            ((agents_linked++)) || true
        fi
    elif [[ -e "$target" ]]; then
        log_warning "Agente existe (no es symlink): $agent_name — omitido"
    else
        ln -s "$agent_file" "$target"
        log_success "Agente enlazado: $agent_name"
        ((agents_linked++)) || true
    fi
done

# ─────────────────────────────────────────────────────────
# 6. INSTALL PRE-COMMIT HOOKS
# ─────────────────────────────────────────────────────────

HOOKS_PATH=".githooks"

if [ ! -d "$REPO_ROOT/$HOOKS_PATH" ]; then
  log_error "Hooks directory not found: $REPO_ROOT/$HOOKS_PATH"
  exit 1
fi

log_info "Configuring git hooks path to: $HOOKS_PATH"
git config core.hooksPath "$HOOKS_PATH"

if git config core.hooksPath | grep -q "$HOOKS_PATH"; then
  log_success "Git configured to use hooks from $HOOKS_PATH"
else
  log_error "Failed to configure git hooks path"
  exit 1
fi

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
# 7. VERIFY VALIDATE SCRIPT EXISTS
# ─────────────────────────────────────────────────────────

VALIDATE_SCRIPT="$REPO_ROOT/scripts/devkit-validate-skill.sh"

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
# 8. FINAL SUMMARY
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
echo "   Skills globales enlazadas: $linked"
echo "   Agentes globales enlazados: $agents_linked"
echo ""

log_info "Reload your shell:"
echo "   source $SHELL_RC"
echo ""

log_info "To bootstrap a consumer project by technology (symlink mode), run:"
echo "   cd /path/to/your/project"
echo "   setup-project --android"
echo "   setup-project --ios"
echo "   setup-project --cmp"
echo "   setup-project --kmp"
echo "   setup-project --python"
echo ""

log_success "Ready to develop!"
echo ""
