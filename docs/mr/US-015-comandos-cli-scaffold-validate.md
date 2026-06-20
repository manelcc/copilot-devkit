# US-015 — Comandos CLI `scaffold` y `validate` para skills

## Resumen

Esta PR implementa los subcomandos reales de CLI para automatizar la creación y validación de skills:

- `devtools scaffold skill <name> <namespace>`
- `devtools validate skill <path> [--fix]`

Con esto se elimina el flujo manual de copiar templates y ejecutar scripts bash a mano para cada skill.

## Alcance

### 1. Scaffold real de skills

Se implementa en `cli-tools/devtools/commands/scaffold.py`:

- Grupo `scaffold` con subcomando `skill`
- Resolución de raíz del repo (`skills/` + `scripts/`)
- Validación de namespace existente
- Prevención de sobreescritura si la skill ya existe
- Copia desde `skills/_TEMPLATE/`
- Reemplazo de placeholders:
  - `[Name]` -> `<name>`
  - `[namespace]` -> `<namespace>`
- Normalización de `name:` en frontmatter
- Mensaje final con path creado

### 2. Validate real de skills

Se implementa en `cli-tools/devtools/commands/validate.py`:

- Grupo `validate` con subcomando `skill`
- Resolución del script oficial de validación:
  - `scripts/validate-skill.sh` (si existe)
  - fallback a `scripts/devkit-validate-skill.sh`
- Ejecución del script y parseo de checks
- Salida en tabla con estados `✓` / `✗` / `⚠`
- Códigos de salida:
  - `0` skill válida
  - `1` skill inválida

### 3. Autofix básico (`--fix`)

En `devtools validate skill <path> --fix` se añade:

- Generación de frontmatter stub si falta en `SKILL.md`
- Creación de `references/overview.md` con Mermaid básico si falta
- Mensajes explícitos:
  - `✓ Generado frontmatter stub`
  - `✓ Creado references/overview.md`

## Criterios de aceptación (US-015)

- [x] `scaffold skill` crea `skills/<namespace>/<name>/` desde template
- [x] Reemplaza placeholders en `SKILL.md`
- [x] Error descriptivo si la skill ya existe
- [x] `validate skill <path>` invoca script interno y muestra tabla de checks
- [x] Exit code `0` en válido y `1` en inválido
- [x] `validate --fix` crea frontmatter stub si falta
- [x] `validate --fix` crea `references/overview.md` si falta
- [x] Ayuda disponible en `devtools scaffold --help` y `devtools validate --help`

## Validación manual ejecutada

Se validó en local con `.venv`:

1. `devtools scaffold --help` y `devtools validate --help`
2. `devtools scaffold skill us015-skill-e2e global`
3. `devtools validate skill skills/global/us015-skill-e2e` (tabla + exit code 0)
4. Eliminación de frontmatter y `overview.md`
5. `devtools validate skill skills/global/us015-skill-e2e --fix` (genera ambos)
6. `devtools validate skill` sobre skill inválida (exit code 1)
7. Verificación de errores por namespace inexistente y skill duplicada

## Riesgos / compatibilidad

- No se introducen breaking changes en comandos existentes.
- Se mantiene compatibilidad con ambos nombres de script de validación (`validate-skill.sh` y `devkit-validate-skill.sh`).

## Archivos modificados

- `cli-tools/devtools/commands/scaffold.py`
- `cli-tools/devtools/commands/validate.py`

## Commit

- `5bd3272 feat(cli): implement scaffold and validate commands for US-015`
