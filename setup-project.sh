#!/bin/bash

# setup-project.sh
# Enlaza skills/agentes/prompts/instructions específicos de tecnología en el proyecto actual.
# Los artefactos globales ya están en ~/.copilot/ (instalados con setup.sh).
# Ejecutar desde el ROOT del proyecto consumidor.
#
# Uso:
#   bash $COPILOT_DEVKIT_HOME/setup-project.sh --android
#   bash $COPILOT_DEVKIT_HOME/setup-project.sh --ios
#   bash $COPILOT_DEVKIT_HOME/setup-project.sh --cmp
#   bash $COPILOT_DEVKIT_HOME/setup-project.sh --kmp
#   bash $COPILOT_DEVKIT_HOME/setup-project.sh --python
#   bash $COPILOT_DEVKIT_HOME/setup-project.sh --skill <nombre>
#   bash $COPILOT_DEVKIT_HOME/setup-project.sh --list

set -euo pipefail

REPO_DIR="${COPILOT_DEVKIT_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
SKILLS_DIR="$REPO_DIR/skills"
AGENTS_DIR="$REPO_DIR/agents"
PROMPTS_DIR="$REPO_DIR/prompts"
INSTRUCTIONS_DIR="$REPO_DIR/instructions"
PROJECT_DIR="$PWD"
TARGET_SKILLS_DIR="$PROJECT_DIR/.github/skills"
TARGET_AGENTS_DIR="$PROJECT_DIR/.github/agents"
TARGET_PROMPTS_DIR="$PROJECT_DIR/.github/prompts"
TARGET_INSTRUCTIONS_DIR="$PROJECT_DIR/.github/instructions"

# ─── Parse arguments ──────────────────────────────────────────────────────────
ANDROID=false
IOS=false
CMP=false
KMP=false
PYTHON=false
SPECIFIC_SKILLS=()
DO_LIST=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --android)   ANDROID=true;  shift ;;
        --ios)       IOS=true;      shift ;;
        --cmp)       CMP=true;      shift ;;
        --kmp)       KMP=true;      shift ;;
        --python)    PYTHON=true;   shift ;;
        --skill)     SPECIFIC_SKILLS+=("$2"); shift 2 ;;
        --list)      DO_LIST=true;  shift ;;
        *)
            echo "❌ Opción desconocida: $1"
            echo "   Uso: setup-project.sh [--android] [--ios] [--cmp] [--kmp] [--python] [--skill <nombre>] [--list]"
            exit 1
            ;;
    esac
done

# ─── Helper: enlazar un elemento ──────────────────────────────────────────────
link_item() {
    local source_path="$1"
    local target_dir="$2"
    local label="$3"
    local item_name
    item_name="$(basename "$source_path")"
    local target="$target_dir/$item_name"

    if [[ ! -e "$source_path" ]]; then
        echo "  ⚠️  No existe: $source_path"
        return
    fi

    mkdir -p "$target_dir"

    if [[ -L "$target" ]]; then
        echo "  ↩️  Ya enlazado ($label): $item_name"
    elif [[ -e "$target" ]]; then
        echo "  ⚠️  Existe (no es symlink) ($label): $item_name — omitido."
    else
        ln -s "$source_path" "$target"
        echo "  🔗 Enlazado ($label): $item_name"
    fi
}

link_folder() {
    local source_dir="$1"
    local target_dir="$2"
    local category="$3"
    local label="$4"

    [[ -d "$source_dir" ]] || return

    echo "  [$label/$category]"
    for item in "$source_dir"/*; do
        [[ -e "$item" ]] || continue
        link_item "$item" "$target_dir" "$label"
    done
}

# ─── --list ───────────────────────────────────────────────────────────────────
if [[ "$DO_LIST" == true ]]; then
    echo ""
    echo "Contenido disponible en copilot-devkit:"
    echo ""

    for section in skills agents prompts instructions; do
        case "$section" in
            skills) section_dir="$SKILLS_DIR" ;;
            agents) section_dir="$AGENTS_DIR" ;;
            prompts) section_dir="$PROMPTS_DIR" ;;
            instructions) section_dir="$INSTRUCTIONS_DIR" ;;
        esac

        echo "[$section]"
        for category in android ios multiplatform/cmp multiplatform/kmp backend/python; do
            dir="$section_dir/$category"
            [[ -d "$dir" ]] || continue
            entries=("$dir"/*)
            [[ -e "${entries[0]}" ]] || continue
            echo "  [$category]"
            for entry in "${entries[@]}"; do
                [[ -e "$entry" ]] && echo "    - $(basename "$entry")"
            done
        done
        echo ""
    done

    echo "💡 Las skills/agentes globales están en ~/.copilot/ (instaladas con setup.sh)"
    echo ""

    exit 0
fi

# ─── --skill (skills concretas) ───────────────────────────────────────────────
if [[ ${#SPECIFIC_SKILLS[@]} -gt 0 ]]; then
    mkdir -p "$TARGET_SKILLS_DIR"
    echo "📦 Proyecto: $(basename "$PROJECT_DIR")"
    echo ""
    for skill_name in "${SPECIFIC_SKILLS[@]}"; do
        found=false
        for dir in "$SKILLS_DIR"/android "$SKILLS_DIR"/ios "$SKILLS_DIR"/multiplatform/cmp "$SKILLS_DIR"/multiplatform/kmp "$SKILLS_DIR"/backend/python; do
            skill_path="$dir/$skill_name"
            if [[ -e "$skill_path" ]]; then
                link_item "$skill_path" "$TARGET_SKILLS_DIR" "skills"
                found=true
                break
            fi
        done
        if [[ "$found" == false ]]; then
            echo "  ❌ Skill no encontrada: $skill_name"
            echo "     Usa --list para ver las disponibles."
        fi
    done
    echo ""
    echo "✅ Hecho. Reabre VS Code en este proyecto para activar las skills."
    exit 0
fi

# ─── Validate at least one tech flag ─────────────────────────────────────────
if [[ "$ANDROID" == false && "$IOS" == false && "$CMP" == false && "$KMP" == false && "$PYTHON" == false ]]; then
    echo "❌ Debes indicar al menos una tecnología: --android --ios --cmp --kmp --python"
    echo "   O usa --skill <nombre> para enlazar skills específicas."
    echo "   Usa --list para ver el contenido disponible."
    exit 1
fi

# ─── Install tech-specific content (global already in ~/.copilot/) ────────────
mkdir -p "$TARGET_SKILLS_DIR" "$TARGET_AGENTS_DIR" "$TARGET_PROMPTS_DIR" "$TARGET_INSTRUCTIONS_DIR"
echo "📦 Proyecto: $(basename "$PROJECT_DIR")"
echo ""

TECHS_ENABLED=()
[[ "$ANDROID" == true ]] && TECHS_ENABLED+=("android")
[[ "$IOS" == true ]] && TECHS_ENABLED+=("ios")
[[ "$CMP" == true ]] && TECHS_ENABLED+=("cmp")
[[ "$KMP" == true ]] && TECHS_ENABLED+=("kmp")
[[ "$PYTHON" == true ]] && TECHS_ENABLED+=("python")

echo "🏷️  Tecnologías: ${TECHS_ENABLED[*]}"
echo ""

# Link technology-specific content only (global already in ~/.copilot/)

# 1. Link Android
if [[ "$ANDROID" == true ]]; then
    link_folder "$SKILLS_DIR/android" "$TARGET_SKILLS_DIR" "android" "skills"
    link_folder "$AGENTS_DIR/android" "$TARGET_AGENTS_DIR" "android" "agents"
    link_folder "$PROMPTS_DIR/android" "$TARGET_PROMPTS_DIR" "android" "prompts"
    link_item "$INSTRUCTIONS_DIR/devkit-android-compose.instructions.md" "$TARGET_INSTRUCTIONS_DIR" "instructions"
    link_item "$INSTRUCTIONS_DIR/devkit-android-legacy.instructions.md" "$TARGET_INSTRUCTIONS_DIR" "instructions"
fi

# 2. Link iOS
if [[ "$IOS" == true ]]; then
    link_folder "$SKILLS_DIR/ios" "$TARGET_SKILLS_DIR" "ios" "skills"
    link_folder "$AGENTS_DIR/ios" "$TARGET_AGENTS_DIR" "ios" "agents"
    link_folder "$PROMPTS_DIR/ios" "$TARGET_PROMPTS_DIR" "ios" "prompts"
    link_item "$INSTRUCTIONS_DIR/devkit-ios-swiftui.instructions.md" "$TARGET_INSTRUCTIONS_DIR" "instructions"
    link_item "$INSTRUCTIONS_DIR/devkit-ios-uikit.instructions.md" "$TARGET_INSTRUCTIONS_DIR" "instructions"
fi

# 3. Link CMP
if [[ "$CMP" == true ]]; then
    link_folder "$SKILLS_DIR/multiplatform/cmp" "$TARGET_SKILLS_DIR" "cmp" "skills"
    link_folder "$AGENTS_DIR/multiplatform/cmp" "$TARGET_AGENTS_DIR" "cmp" "agents"
    link_folder "$PROMPTS_DIR/multiplatform/cmp" "$TARGET_PROMPTS_DIR" "cmp" "prompts"
    link_item "$INSTRUCTIONS_DIR/devkit-cmp.instructions.md" "$TARGET_INSTRUCTIONS_DIR" "instructions"
fi

# 4. Link KMP
if [[ "$KMP" == true ]]; then
    link_folder "$SKILLS_DIR/multiplatform/kmp" "$TARGET_SKILLS_DIR" "kmp" "skills"
    link_folder "$AGENTS_DIR/multiplatform/kmp" "$TARGET_AGENTS_DIR" "kmp" "agents"
    link_folder "$PROMPTS_DIR/multiplatform/kmp" "$TARGET_PROMPTS_DIR" "kmp" "prompts"
    link_item "$INSTRUCTIONS_DIR/devkit-kmp.instructions.md" "$TARGET_INSTRUCTIONS_DIR" "instructions"
fi

# 5. Link Python backend
if [[ "$PYTHON" == true ]]; then
    link_folder "$SKILLS_DIR/backend/python" "$TARGET_SKILLS_DIR" "python" "skills"
    link_folder "$AGENTS_DIR/backend/python" "$TARGET_AGENTS_DIR" "python" "agents"
    link_folder "$PROMPTS_DIR/backend/python" "$TARGET_PROMPTS_DIR" "python" "prompts"
    # No extra instructions for Python
fi

echo ""
echo "✅ Hecho. Reabre VS Code en este proyecto para activar las skills/agentes/prompts/instructions."
echo ""
echo "💡 Las skills/agentes globales ya están en ~/.copilot/ (instaladas con setup.sh)"

