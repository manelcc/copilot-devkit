#!/bin/bash

# validate-skill.sh
# Validates SKILL.md files for proper structure, frontmatter, and required sections

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Validation state
ERRORS=()
WARNINGS=()
VALIDATED_SKILLS=()

log_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
  ERRORS+=("$1")
}

log_success() {
  echo -e "${GREEN}[OK]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARN]${NC} $1"
  WARNINGS+=("$1")
}

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

if [ -z "$1" ]; then
  echo "Usage: $0 <skill-path> [<skill-path2> ...]"
  exit 1
fi

validate_skill() {
  local skill_path="$1"
  local skill_file="${skill_path}/SKILL.md"
  local overview_file="${skill_path}/references/overview.md"

  echo ""
  echo "=================================================="
  log_info "Validating: ${skill_path}"
  echo "=================================================="

  if [ ! -d "$skill_path" ]; then
    log_error "Path not found: ${skill_path}"
    return 1
  fi

  if [ ! -f "$skill_file" ]; then
    log_error "SKILL.md not found in ${skill_path}"
    return 1
  fi

  log_success "SKILL.md exists"

  # Check YAML frontmatter
  if ! head -1 "$skill_file" | grep -q "^---$"; then
    log_error "Missing YAML frontmatter start (---)"
    return 1
  fi

  log_success "YAML frontmatter found"

  # Extract and validate frontmatter
  local frontmatter
  frontmatter=$(sed -n '/^---$/,/^---$/p' "$skill_file" | sed '1d;$d')

  for field in "name" "description" "triggers" "non_triggers"; do
    if ! echo "$frontmatter" | grep -q "^$field:"; then
      log_error "Missing frontmatter field: $field"
      return 1
    fi
  done

  log_success "All frontmatter fields present"

  # Check required sections
  local sections=("Purpose" "When to use" "When NOT to use" "Inputs" "Steps" "Expected outputs" "Validation" "Examples")
  
  for section in "${sections[@]}"; do
    if grep -q "^## $section" "$skill_file"; then
      log_success "Found section: ## $section"
    else
      log_error "Missing section: ## $section"
      return 1
    fi
  done

  # Check overview.md
  if [ ! -f "$overview_file" ]; then
    log_error "references/overview.md not found"
    return 1
  fi

  log_success "references/overview.md exists"

  if ! grep -q '```mermaid' "$overview_file"; then
    log_error "No Mermaid diagram in overview.md"
    return 1
  fi

  log_success "Mermaid diagram found"

  VALIDATED_SKILLS+=("$skill_path")
  log_success "VALIDATION PASSED: ${skill_path}"
  return 0
}

FAILED=0

for skill_path in "$@"; do
  if ! validate_skill "$skill_path"; then
    FAILED=1
  fi
done

echo ""
echo "=================================================="
echo "SUMMARY"
echo "=================================================="
echo "Validated: ${#VALIDATED_SKILLS[@]}"
echo "Errors: ${#ERRORS[@]}"
echo "Warnings: ${#WARNINGS[@]}"
echo "=================================================="

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}All skills passed validation${NC}"
  exit 0
else
  echo -e "${RED}Validation FAILED${NC}"
  exit 1
fi
