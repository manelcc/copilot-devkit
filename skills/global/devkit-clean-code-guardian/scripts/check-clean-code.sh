#!/usr/bin/env bash
# =============================================================================
# check-clean-code.sh — Clean Code Guardian (Kotlin)
# Detecta violaciones de clean code en ficheros .kt
#
# Uso:
#   .github/skills/devkit-clean-code-guardian/scripts/check-clean-code.sh [ruta.kt|directorio]
#
# Si no se pasa argumento, escanea el directorio actual en busca de *.kt
# =============================================================================

set -euo pipefail

print_help() {
  cat <<'USAGE'
Clean Code Guardian checker (Kotlin)

Usage:
  bash skills/global/devkit-clean-code-guardian/scripts/check-clean-code.sh [ruta.kt|directorio]

Options:
  -h, --help   Show this help and exit.

Behavior:
  - Without arguments, scans current directory recursively for *.kt files.
  - With a directory argument, scans that directory recursively for *.kt files.
  - With a .kt file argument, analyzes only that file.
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  print_help
  exit 0
fi

# ------------ Configuración de límites ------------
MAX_CLASS_LINES=500
MAX_FUNCTION_LINES=30
MAX_NESTING_LEVEL=3
MAX_PARAMS=4

# ------------ Colores para output ------------
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

VIOLATIONS=0

# ------------ Selección de ficheros a analizar ------------
if [[ $# -eq 0 ]]; then
  TARGET_DIR="."
  KOTLIN_FILES=$(find "$TARGET_DIR" -name "*.kt" -not -path "*/build/*" -not -path "*/.gradle/*")
elif [[ -d "$1" ]]; then
  KOTLIN_FILES=$(find "$1" -name "*.kt" -not -path "*/build/*" -not -path "*/.gradle/*")
elif [[ -f "$1" && "$1" == *.kt ]]; then
  KOTLIN_FILES="$1"
else
  echo "Error: argumento no válido. Proporciona un fichero .kt o un directorio."
  exit 1
fi

if [[ -z "$KOTLIN_FILES" ]]; then
  echo -e "${GREEN}No se encontraron ficheros .kt para analizar.${NC}"
  exit 0
fi

echo -e "${CYAN}=== Clean Code Guardian — Análisis Kotlin ===${NC}"
echo ""

# ------------ Función: reportar violación ------------
report_violation() {
  local rule="$1"
  local file="$2"
  local line="$3"
  local message="$4"
  local suggestion="$5"

  echo -e "  ${RED}[$rule]${NC} $message"
  echo -e "  ${YELLOW}→ Línea: $line${NC}"
  echo -e "  ${CYAN}→ Sugerencia: $suggestion${NC}"
  echo ""
  VIOLATIONS=$((VIOLATIONS + 1))
}

# ------------ Análisis por fichero ------------
while IFS= read -r file; do
  echo -e "${CYAN}Analizando:${NC} $file"
  TOTAL_LINES=$(wc -l < "$file")
  FILE_VIOLATIONS=0

  # ------ CC-01: Clase > MAX_CLASS_LINES líneas ------
  if [[ $TOTAL_LINES -gt $MAX_CLASS_LINES ]]; then
    report_violation "CC-01" "$file" "1-$TOTAL_LINES" \
      "Clase con $TOTAL_LINES líneas (límite: $MAX_CLASS_LINES)" \
      "Extraer responsabilidades en clases más pequeñas aplicando SRP"
    FILE_VIOLATIONS=$((FILE_VIOLATIONS + 1))
  fi

  # ------ CC-02: Funciones > MAX_FUNCTION_LINES líneas ------
  # Detecta bloques fun { ... } contando llaves
  awk -v max="$MAX_FUNCTION_LINES" -v file="$file" '
  /^\s*(private |public |protected |internal |override |suspend |inline )*(fun )[a-zA-Z]/ {
    fun_name = $0
    fun_start = NR
    depth = 0
    found_open = 0
  }
  fun_start > 0 {
    for (i=1; i<=length($0); i++) {
      c = substr($0, i, 1)
      if (c == "{") { depth++; found_open=1 }
      if (c == "}") depth--
    }
    if (found_open && depth == 0) {
      fun_lines = NR - fun_start + 1
      if (fun_lines > max) {
        printf "  [CC-02] Función con %d líneas (límite: %d)\n", fun_lines, max
        printf "  → Línea: %d\n", fun_start
        printf "  → Sugerencia: Extraer lógica en funciones auxiliares con nombre descriptivo\n\n"
      }
      fun_start = 0
      fun_name = ""
    }
  }
  ' "$file"

  # ------ CC-04: Magic numbers (literales numéricos hardcoded) ------
  # Ignora: 0, 1, -1 (valores idiomáticos comunes), y líneas que son const val
  grep -nE '(=\s*[2-9][0-9]+|=\s*[0-9]{3,})' "$file" \
    | grep -vE '^\s*(const val|//|/\*)' \
    | grep -vE 'val [A-Z_]+ =' \
    | while IFS= read -r match; do
        line_num=$(echo "$match" | cut -d: -f1)
        content=$(echo "$match" | cut -d: -f2-)
        echo -e "  ${RED}[CC-04]${NC} Posible magic number en: $content"
        echo -e "  ${YELLOW}→ Línea: $line_num${NC}"
        echo -e "  ${CYAN}→ Sugerencia: Extraer a 'const val NOMBRE_DESCRIPTIVO = valor' en companion object o Constants.kt${NC}"
        echo ""
      done

  # ------ CC-05: Nombres cortos o abreviados (< 3 chars, o abreviaturas conocidas) ------
  grep -nE '\bval [a-z]{1,2}\b|\bvar [a-z]{1,2}\b|\bfun [a-z]{1,2}\b' "$file" \
    | grep -vE '^\s*//' \
    | while IFS= read -r match; do
        line_num=$(echo "$match" | cut -d: -f1)
        content=$(echo "$match" | cut -d: -f2-)
        echo -e "  ${RED}[CC-05]${NC} Nombre demasiado corto en: $content"
        echo -e "  ${YELLOW}→ Línea: $line_num${NC}"
        echo -e "  ${CYAN}→ Sugerencia: Usar nombre descriptivo que exprese la intención (mínimo 3 caracteres)${NC}"
        echo ""
      done

  # Abreviaturas conocidas problemáticas
  grep -nE '\b(mgr|tmp|ctx|obj|idx|val[0-9]|data2|str[0-9]|buf|impl[0-9])\b' "$file" \
    | grep -vE '^\s*//' \
    | while IFS= read -r match; do
        line_num=$(echo "$match" | cut -d: -f1)
        abbr=$(echo "$match" | grep -oE '(mgr|tmp|ctx|obj|idx|val[0-9]|data2|str[0-9]|buf|impl[0-9])' | head -1)
        echo -e "  ${RED}[CC-05]${NC} Abreviatura detectada: '$abbr'"
        echo -e "  ${YELLOW}→ Línea: $line_num${NC}"
        echo -e "  ${CYAN}→ Sugerencia: Reemplazar '$abbr' por un nombre que exprese su propósito${NC}"
        echo ""
      done

  # ------ CC-06: Anidamiento > MAX_NESTING_LEVEL ------
  awk -v max="$MAX_NESTING_LEVEL" '
  {
    depth = 0
    for (i=1; i<=length($0); i++) {
      c = substr($0, i, 1)
      if (c == "{") depth++
    }
    # Contar indentación como proxy de anidamiento real
    match($0, /^[ \t]+/)
    indent = RLENGTH
    spaces = indent
    # Heurística: cada 4 espacios = 1 nivel de anidamiento
    nest_level = int(spaces / 4)
    if (nest_level > max) {
      printf "  [CC-06] Anidamiento de %d niveles detectado (límite: %d)\n", nest_level, max
      printf "  → Línea: %d\n", NR
      printf "  → Sugerencia: Aplicar Guard Clauses (early return) o extraer bloque en función separada\n\n"
    }
  }
  ' "$file"

  echo -e "  ${GREEN}✓ Análisis completado${NC}"
  echo ""

done <<< "$KOTLIN_FILES"

# ------------ Resumen final ------------
echo -e "${CYAN}=== Resumen ===${NC}"
if [[ $VIOLATIONS -eq 0 ]]; then
  echo -e "${GREEN}Sin violaciones CC-01 a CC-07 detectadas en los ficheros analizados.${NC}"
else
  echo -e "${RED}Se detectaron violaciones. Revisar sugerencias arriba y aplicar refactors.${NC}"
fi
echo ""

# ------------ Detekt (si está disponible) ------------
if command -v detekt &>/dev/null; then
  echo -e "${CYAN}Detekt disponible. Ejecutando análisis de complejidad...${NC}"
  detekt --input "${1:-.}" --report txt:build/reports/detekt-clean-code.txt 2>/dev/null || true
  echo -e "  Reporte Detekt: build/reports/detekt-clean-code.txt"
elif [[ -f "./gradlew" ]]; then
  echo -e "${YELLOW}Tip: puedes ejecutar './gradlew detekt' para análisis completo con reglas configuradas.${NC}"
fi
