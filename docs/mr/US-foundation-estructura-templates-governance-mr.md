# MR: US-foundation — Cierre deuda Sprint 0 (US-001, US-002, US-003, US-004, US-009)

| Campo | Valor |
|---|---|
| **Rama** | `feature/US-foundation-estructura-templates-governance` |
| **Target** | `develop` |
| **Fecha** | 2026-06-25 |
| **Tipo** | `feat` |
| **US cerradas** | US-001 · US-002 · US-003 · US-004 · US-009 |

---

## 🎯 Qué se ha implementado

Cierre de la deuda técnica del **Sprint 0**: las US de fundamentos que se habían saltado mientras se avanzaba en contenido (US-007 a US-016). Esta MR completa los artefactos de gobernanza, templates y validación que dan soporte a todo el catálogo.

Se ha optado por agrupar las 5 US en una sola rama al ser cambios de infraestructura pequeños y cohesionados, sin riesgo de contaminación entre ellos.

---

## 📦 Commits incluidos

### feat
- `feat(US-001)`: add `.github/copilot-instructions.md` as global entry point
- `feat(US-002)`: rewrite README with 9-stack table, quick-start and governance links
- `feat(US-003)`: update `SKILL.md` template with `[UpperCase]` placeholders and required sections
- `feat(US-004)`: add `scripts/validate-skill.sh` as canonical alias for `devkit-validate-skill.sh`

### chore
- `chore(US-001..009)`: mark US-001/002/003/004/009 as DONE in backlog-index

---

## 📂 Archivos modificados

| Archivo | US | Tipo |
|---|---|---|
| `.github/copilot-instructions.md` | US-001/002 | Creado |
| `README.md` | US-002 | Modificado |
| `skills/_TEMPLATE/SKILL.md` | US-003 | Modificado |
| `scripts/validate-skill.sh` | US-004 | Creado |
| `docs/implementation/user-stories/backlog-index.md` | todas | Modificado |

---

## ✅ Criterios de aceptación cubiertos

### US-001 — Estructura de directorios
- [x] Directorios `agents/`, `skills/`, `prompts/`, `instructions/` con jerarquía por stack
- [x] Simetría 1:1 entre los tres namespaces principales
- [x] `.gitkeep` en directorios hoja vacíos
- [x] `.github/copilot-instructions.md` como entry point global

### US-002 — README y governance
- [x] README con tabla de 9 stacks (Stack | Lenguaje | Frameworks clave)
- [x] Árbol de estructura hasta nivel 2
- [x] Quick-start para consumidores (`pip install -e cli-tools/ && devtools sync`)
- [x] Quick-start para contributors (`./scripts/setup.sh && devtools scaffold skill`)
- [x] Links a `constitution.md`, `epics.md`, `backlog-index.md`, `sync-strategy.md`
- [x] README < 200 líneas
- [x] `.github/copilot-instructions.md` referencia `skills/_TEMPLATE/SKILL.md` y `agents/_TEMPLATE.agent.md`

### US-003 — Templates base
- [x] `skills/_TEMPLATE/SKILL.md` con frontmatter `name`/`description`
- [x] Todas las secciones obligatorias presentes (Purpose, When to use, When NOT to use, Inputs, Steps, Expected outputs, Validation, Examples)
- [x] `references/overview.md` con bloque Mermaid
- [x] Placeholders con notación `[UpperCase]`
- [x] Template pasa `devkit-validate-skill.sh` con exit 0
- [x] `agents/_TEMPLATE.agent.md` con `description`, `tools`, `model` y `handoffs`

### US-004 — Validación y setup
- [x] `scripts/validate-skill.sh` funcional (alias canónico de `devkit-validate-skill.sh`)
- [x] `.githooks/pre-commit` valida solo skills del diff actual
- [x] `scripts/setup.sh` configura `git config core.hooksPath .githooks`
- [x] 25/25 skills del repo pasan validación

### US-009 — Skills globales
- [x] `skills/global/devkit-clean-code-guardian/` ✅
- [x] `skills/global/devkit-git-workflow/` ✅
- [x] `skills/global/devkit-mr-description-generator/` ✅
- [x] `skills/global/devkit-feature-lifecycle/` ✅
- [x] Sin referencias a mycardiochef en skills globales
- [x] Las 4 skills pasan `devkit-validate-skill.sh` con exit 0

---

## 🔍 Cómo probar

```bash
# 1. Clonar rama y verificar estructura
git checkout feature/US-foundation-estructura-templates-governance

# 2. Validar template
bash scripts/validate-skill.sh skills/_TEMPLATE/

# 3. Validar todas las skills
for d in skills/*/*/ skills/*/*/*/; do
  [ -f "$d/SKILL.md" ] && bash scripts/validate-skill.sh "$d"
done

# 4. Verificar README < 200 líneas
wc -l README.md

# 5. Verificar .github/copilot-instructions.md existe
cat .github/copilot-instructions.md
```

---

## 📋 Checklist pre-merge

- [x] Rama parte de `develop` actualizado
- [x] 5 commits atómicos semánticos (uno por US)
- [x] Pre-commit ejecutado sin errores en commit US-003
- [x] Backlog-index actualizado: US-001/002/003/004/009 marcadas ✅ DONE
- [x] Sin referencias a proyectos de origen (mycardiochef, bankinter) en archivos nuevos
- [x] 25/25 skills del repo pasan validación
