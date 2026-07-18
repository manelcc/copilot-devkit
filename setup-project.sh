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
#   bash $COPILOT_DEVKIT_HOME/setup-project.sh --kotlin
#   bash $COPILOT_DEVKIT_HOME/setup-project.sh --skill <nombre>
#   bash $COPILOT_DEVKIT_HOME/setup-project.sh --list
#
# Gemini (Android Studio):
#   bash $COPILOT_DEVKIT_HOME/setup-project.sh --android --gemini
#   bash $COPILOT_DEVKIT_HOME/setup-project.sh --android --kmp --gemini
#   Crea .agents/skills/ (skills), genera AGENTS.md (instrucciones/agentes).
#   Prompts: gestionados desde la Prompt Library de Android Studio (UI).

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
# Gemini (Android Studio Quail 1+)
TARGET_GEMINI_SKILLS_DIR="$PROJECT_DIR/.agents/skills"

# ─── Parse arguments ──────────────────────────────────────────────────────────
ANDROID=false
IOS=false
CMP=false
KMP=false
PYTHON=false
KOTLIN=false
GEMINI=false
SPECIFIC_SKILLS=()
DO_LIST=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --android)   ANDROID=true;  shift ;;
        --ios)       IOS=true;      shift ;;
        --cmp)       CMP=true;      shift ;;
        --kmp)       KMP=true;      shift ;;
        --python)    PYTHON=true;   shift ;;
        --kotlin)    KOTLIN=true;   shift ;;
        --gemini)    GEMINI=true;   shift ;;
        --skill)     SPECIFIC_SKILLS+=("$2"); shift 2 ;;
        --list)      DO_LIST=true;  shift ;;
        *)
            echo "❌ Opción desconocida: $1"
            echo "   Uso: setup-project.sh [--android] [--ios] [--cmp] [--kmp] [--python] [--kotlin] [--gemini] [--skill <nombre>] [--list]"
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

# ─── Gemini helpers ───────────────────────────────────────────────────────────
# Enlaza skills de un directorio fuente en .agents/skills/ (estructura plana requerida por Gemini)
link_gemini_skills_from() {
    local source_dir="$1"
    local category="$2"

    [[ -d "$source_dir" ]] || return

    mkdir -p "$TARGET_GEMINI_SKILLS_DIR"
    echo "  [gemini/skills/$category]"
    for item in "$source_dir"/*; do
        [[ -e "$item" ]] || continue
        local item_name
        item_name="$(basename "$item")"
        local target="$TARGET_GEMINI_SKILLS_DIR/$item_name"

        if [[ -L "$target" ]]; then
            echo "  ↩️  Ya enlazado (gemini): $item_name"
        elif [[ -e "$target" ]]; then
            echo "  ⚠️  Existe (no es symlink) (gemini): $item_name — omitido."
        else
            ln -s "$item" "$target"
            echo "  🔗 Enlazado (gemini): $item_name"
        fi
    done
}

# Genera/actualiza AGENTS.md:
# Helper: extrae el cuerpo markdown de un .agent.md eliminando el bloque YAML frontmatter
strip_agent_body() {
    local file="$1"
    awk '
        BEGIN { in_fm=0; past_fm=0 }
        /^---$/ {
            if (!past_fm) {
                if (!in_fm) { in_fm=1; next }
                else        { in_fm=0; past_fm=1; next }
            }
        }
        past_fm { print }
    ' "$file"
}

# Genera/actualiza AGENTS.md con estructura:
#   1. Instructions  → @-import desde .github/instructions/
#   2. Orchestrators → top-level .github/agents/*.agent.md  +  agentes globales del devkit
#   3. Sub-agents    → .github/agents/**/*.agent.md (profundidad ≥ 2)
# El YAML frontmatter Copilot-específico (model:, tools:, etc.) se elimina de todos los .agent.md
generate_agents_md() {
    local agents_md="$PROJECT_DIR/AGENTS.md"
    local tmpfile
    tmpfile=$(mktemp)

    cat > "$tmpfile" << 'HEREDOC'
# DevKit — Agent Instructions
<!-- Generated by setup-project.sh --gemini. Re-run to regenerate. -->

You are an expert developer assistant. When the user asks you to perform a task,
follow the routing logic of the Orchestrator section to apply the correct expertise.
Address sub-agents directly when the user's request matches their domain.

HEREDOC

    # ── 1. Instructions ───────────────────────────────────────────────────────
    local found_instructions=false
    for f in "$TARGET_INSTRUCTIONS_DIR"/*.instructions.md; do
        [[ -e "$f" ]] || continue
        echo "@./.github/instructions/$(basename "$f")" >> "$tmpfile"
        echo "" >> "$tmpfile"
        found_instructions=true
    done
    if [[ "$found_instructions" == false ]]; then
        echo "> ⚠️ No instruction files found. Run \`setup-project.sh --android\` first." >> "$tmpfile"
        echo "" >> "$tmpfile"
    fi

    # ── 2. Orchestrators ──────────────────────────────────────────────────────
    {
        echo ""
        echo "---"
        echo ""
        echo "## Orchestrators"
        echo ""
        echo "> Entry points. The orchestrator routes each request to the correct sub-agent or skill."
        echo ""
    } >> "$tmpfile"

    # 2a. Stack orchestrator (root of .github/agents/)
    for agent_file in "$TARGET_AGENTS_DIR"/*.agent.md; do
        [[ -e "$agent_file" ]] || continue
        local body
        body=$(strip_agent_body "$agent_file")
        [[ -z "${body// }" ]] && continue
        printf '%s\n\n' "$body" >> "$tmpfile"
    done

    # 2b. Global orchestrators from devkit source (lifecycle, qa — always needed)
    for agent_file in "$AGENTS_DIR/global"/*.agent.md; do
        [[ -e "$agent_file" ]] || continue
        [[ "$(basename "$agent_file")" == "_TEMPLATE"* ]] && continue
        local body
        body=$(strip_agent_body "$agent_file")
        [[ -z "${body// }" ]] && continue
        printf '%s\n\n' "$body" >> "$tmpfile"
    done

    # ── 3. Sub-agents ─────────────────────────────────────────────────────────
    {
        echo "---"
        echo ""
        echo "## Sub-agents"
        echo ""
        echo "> Invoked by the orchestrator. You can also address them directly by name."
        echo ""
    } >> "$tmpfile"

    local current_category=""
    while IFS= read -r -d '' agent_file; do
        # Derive category from path: .github/agents/<category>/...
        local rel_path="${agent_file#"$TARGET_AGENTS_DIR/"}"
        local category
        category=$(dirname "$rel_path")

        if [[ "$category" != "$current_category" ]]; then
            echo "### $category" >> "$tmpfile"
            echo "" >> "$tmpfile"
            current_category="$category"
        fi

        local body
        body=$(strip_agent_body "$agent_file")
        [[ -z "${body// }" ]] && continue
        printf '%s\n\n' "$body" >> "$tmpfile"
        echo "---" >> "$tmpfile"
        echo "" >> "$tmpfile"
    done < <(find -L "$TARGET_AGENTS_DIR" -mindepth 2 -name "*.agent.md" -print0 2>/dev/null | sort -z)

    # ── 4. Skills footer ──────────────────────────────────────────────────────
    cat >> "$tmpfile" << 'HEREDOC'

## Skills disponibles
Skills on-demand en `.agents/skills/`. Usa `@skill-name` en el chat o describe la tarea
y Gemini activa la skill automáticamente.
HEREDOC

    if [[ -f "$agents_md" ]]; then
        echo "  ↩️  AGENTS.md actualizado"
    else
        echo "  🔗 AGENTS.md generado"
    fi
    mv "$tmpfile" "$agents_md"
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
        for category in android ios multiplatform/cmp multiplatform/kmp backend/python backend/kotlin-ktor; do
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
        for dir in "$SKILLS_DIR"/android "$SKILLS_DIR"/ios "$SKILLS_DIR"/multiplatform/cmp "$SKILLS_DIR"/multiplatform/kmp "$SKILLS_DIR"/backend/python "$SKILLS_DIR"/backend/kotlin-ktor; do
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
if [[ "$ANDROID" == false && "$IOS" == false && "$CMP" == false && "$KMP" == false && "$PYTHON" == false && "$KOTLIN" == false ]]; then
    echo "❌ Debes indicar al menos una tecnología: --android --ios --cmp --kmp --python --kotlin"
    echo "   Combina con --gemini para soporte de Gemini en Android Studio."
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
[[ "$KOTLIN" == true ]] && TECHS_ENABLED+=("kotlin")

echo "🏷️  Tecnologías: ${TECHS_ENABLED[*]}"
echo ""

# Link technology-specific content only (global already in ~/.copilot/)

# 1. Link Android (compose + legacy only; KMP requiere --kmp explícito)
if [[ "$ANDROID" == true ]]; then
    link_folder "$SKILLS_DIR/android/compose" "$TARGET_SKILLS_DIR/android/compose" "android/compose" "skills"
    link_folder "$SKILLS_DIR/android/legacy"  "$TARGET_SKILLS_DIR/android/legacy"  "android/legacy"  "skills"
    link_folder "$AGENTS_DIR/android/compose" "$TARGET_AGENTS_DIR/android/compose" "android/compose" "agents"
    link_folder "$AGENTS_DIR/android/legacy"  "$TARGET_AGENTS_DIR/android/legacy"  "android/legacy"  "agents"
    link_item   "$AGENTS_DIR/android/devkit-android-project-orchestrator.agent.md" "$TARGET_AGENTS_DIR" "agents"
    link_folder "$PROMPTS_DIR/android/compose" "$TARGET_PROMPTS_DIR/android/compose" "android/compose" "prompts"
    link_folder "$PROMPTS_DIR/android/legacy"  "$TARGET_PROMPTS_DIR/android/legacy"  "android/legacy"  "prompts"
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

# 6. Link Kotlin/Ktor backend
if [[ "$KOTLIN" == true ]]; then
    link_folder "$SKILLS_DIR/backend/kotlin-ktor" "$TARGET_SKILLS_DIR" "kotlin-ktor" "skills"
    link_folder "$AGENTS_DIR/backend/kotlin-ktor" "$TARGET_AGENTS_DIR" "kotlin-ktor" "agents"
    link_folder "$PROMPTS_DIR/backend/kotlin-ktor" "$TARGET_PROMPTS_DIR" "kotlin-ktor" "prompts"
    link_item "$INSTRUCTIONS_DIR/devkit-backend-kotlin.instructions.md" "$TARGET_INSTRUCTIONS_DIR" "instructions"
fi

# ─── Official Android skills (via android CLI) ───────────────────────────────
if [[ "$ANDROID" == true ]]; then
    if command -v android >/dev/null 2>&1; then
        echo ""
        echo "📱 Instalando official Android skills (android/skills)..."
        android skills add --all --project="$PROJECT_DIR" 2>&1 | sed 's/^/  /'
        echo "  ✓ Official Android skills instaladas"
    else
        echo ""
        echo "  ⚠️  'android' CLI no encontrado — omitiendo official Android skills."
        echo "     Instálalo con: curl -fsSL https://d.android.com/dl/android-cli/install.sh | bash"
        echo "     Luego ejecuta: android skills add --all --project=."
    fi
fi

# ─── Gemini (Android Studio) ──────────────────────────────────────────────────
if [[ "$GEMINI" == true ]]; then
    echo ""
    echo "🤖 Configurando Gemini (Android Studio)..."
    echo ""

    # Skills → .agents/skills/ (plano, estándar Quail 1+)
    if [[ "$ANDROID" == true ]]; then
        link_gemini_skills_from "$SKILLS_DIR/android/compose" "android/compose"
        link_gemini_skills_from "$SKILLS_DIR/android/legacy"  "android/legacy"
    fi
    if [[ "$IOS" == true ]]; then
        link_gemini_skills_from "$SKILLS_DIR/ios/swiftui" "ios/swiftui"
        link_gemini_skills_from "$SKILLS_DIR/ios/uikit"   "ios/uikit"
    fi
    if [[ "$CMP" == true ]]; then
        link_gemini_skills_from "$SKILLS_DIR/multiplatform/cmp" "cmp"
    fi
    if [[ "$KMP" == true ]]; then
        link_gemini_skills_from "$SKILLS_DIR/multiplatform/kmp" "kmp"
    fi
    if [[ "$PYTHON" == true ]]; then
        link_gemini_skills_from "$SKILLS_DIR/backend/python" "python"
    fi
    if [[ "$KOTLIN" == true ]]; then
        link_gemini_skills_from "$SKILLS_DIR/backend/kotlin-ktor" "kotlin-ktor"
    fi

    # Global skills → .agents/skills/
    if [[ -d "$SKILLS_DIR/global" ]]; then
        link_gemini_skills_from "$SKILLS_DIR/global" "global"
    fi

    echo ""
    # AGENTS.md (instrucciones + agentes) → project root
    generate_agents_md

    echo ""
    echo "  📁 Estructura Gemini creada:"
    echo "     .agents/skills/   ← skills (usa @skill-name en el chat)"
    echo "     AGENTS.md         ← instrucciones cargadas en cada prompt"
    echo "  ℹ️  Prompts: gestiónalos en la Prompt Library de Android Studio (UI)."
fi

echo ""
if [[ "$GEMINI" == true ]]; then
    echo "✅ Hecho. Reabre Android Studio para activar las skills/instrucciones de Gemini."
else
    echo "✅ Hecho. Reabre VS Code en este proyecto para activar las skills/agentes/prompts/instructions."
fi
echo ""
echo "💡 Las skills/agentes globales ya están en ~/.copilot/ (instaladas con setup.sh)"

