# TC-US-005: Pre-commit hooks y script de validación

**US**: US-005  
**Épica**: EP-1  
**Fecha**: 2026-06-19

---

## Nivel 1 — Unit Tests

Unit tests para scripts shell/bash.

### TC-U-001: validate-skill.sh detecta frontmatter YAML válido
- Ejecutar: `bash scripts/validate-skill.sh skills/_TEMPLATE`
- Verificar: `[OK] YAML frontmatter found`
- Exit code: 0

### TC-U-002: validate-skill.sh rechaza frontmatter inválido
- Crear skill sin frontmatter
- Ejecutar: `bash scripts/validate-skill.sh skills/test-invalid`
- Verificar: `[ERROR]` en la salida
- Exit code: 1

### TC-U-003: validate-skill.sh detecta todas las secciones
- Ejecutar: `bash scripts/validate-skill.sh skills/_TEMPLATE`
- Verificar: 8 secciones encontradas (Purpose, When to use, When NOT to use, Inputs, Steps, Expected outputs, Validation, Examples)
- Exit code: 0

### TC-U-004: validate-skill.sh detecta Mermaid en overview.md
- Ejecutar: `bash scripts/validate-skill.sh skills/_TEMPLATE`
- Verificar: `[OK] Mermaid diagram found`
- Exit code: 0

### TC-U-005: validate-skill.sh rechaza overview.md sin Mermaid
- Crear skill con overview.md sin Mermaid
- Ejecutar: `bash scripts/validate-skill.sh skills/test-no-mermaid`
- Verificar: `[ERROR] No Mermaid diagram`
- Exit code: 1

### TC-U-006: setup.sh configura git core.hooksPath
- Ejecutar: `bash scripts/setup.sh`
- Verificar: `[OK] Git configured to use hooks`
- Ejecutar: `git config core.hooksPath`
- Verificar: output = `.githooks`
- Exit code: 0

### TC-U-007: pre-commit hook bloquea skills inválidos
- Crear skill inválido
- Ejecutar: `git add skills/test-invalid/...`
- Ejecutar: `git commit -m "test: invalid"`
- Verificar: commit rechazado
- Exit code: 1

### TC-U-008: pre-commit hook permite skills válidos
- Crear skill válido
- Ejecutar: `git add skills/test-valid/...`
- Ejecutar: `git commit -m "test: valid"`
- Verificar: commit creado exitosamente
- Exit code: 0

---

## Nivel 2 — Smoke Tests

### TC-S-001: Validación local del template
```bash
bash scripts/validate-skill.sh skills/_TEMPLATE
```
Expected: Exit code 0, todas las secciones validadas

### TC-S-002: Ejecución de setup.sh
```bash
bash scripts/setup.sh
```
Expected: Exit code 0, hooks configurados

### TC-S-003: Verificación de hook instalado
```bash
git config core.hooksPath
```
Expected: Output = `.githooks`

