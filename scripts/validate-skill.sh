#!/bin/bash
# validate-skill.sh — alias canónico para devkit-validate-skill.sh
# US-004: los CA referencian este nombre; delega al validador real.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/devkit-validate-skill.sh" "$@"
