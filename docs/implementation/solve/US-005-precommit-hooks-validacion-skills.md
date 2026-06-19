# US-005 — Pre-commit hooks y validación de skills

**Status**: ✅ **DONE**  
**Sprint**: 0 | **Epic**: EP-1 | **Priority**: P1 | **SP**: 5  
**Merged**: PR #3 to develop

---

## Funcionalidad entregada

### 1. Script de validación (`scripts/validate-skill.sh`)
- Valida **frontmatter YAML** (obligatorios: `name`, `description`, `triggers`, `non_triggers`)
- Valida **8 secciones obligatorias**:
  - Purpose, When to use, When NOT to use, Inputs, Steps, Expected outputs, Validation, Examples
- Valida **overview.md con diagrama Mermaid** (obligatorio)
- Soporta validación de directorios (busca todos los `SKILL.md`) o archivos individuales
- Sale con código 0 (éxito) o 1 (error)
- Salida coloreada con [OK], [ERROR], [WARN], [INFO]

### 2. Pre-commit hook (`.githooks/pre-commit`)
- Detecta automáticamente skills modificados en el stage area
- Ejecuta validación solo sobre archivos staged (no hace commit si algo falla)
- Mensajes descriptivos de error
- Permite bypass con `git commit --no-verify` (no recomendado)
- Bloquea commits con skills mal formados

### 3. Setup script (`scripts/setup.sh`)
- Instala el hook automáticamente: `git config core.hooksPath .githooks`
- Verifica que todos los scripts sean ejecutables
- Valida integridad del entorno (existe `validate-skill.sh`, existe `.githooks/pre-commit`)
- Salida coloreada con resumen de instalación
- Proporciona instrucciones de testing
- **Idempotente**: ejecutarlo 2+ veces es seguro

---

## Cobertura funcional

| Requisito | Implementado | Notas |
|-----------|--------------|-------|
| Validar frontmatter YAML | ✅ | Campos: name, description, triggers, non_triggers |
| Validar secciones obligatorias | ✅ | 8 secciones |
| Validar overview.md + Mermaid | ✅ | Detecta ```mermaid block |
| Pre-commit hook | ✅ | Ejecutado por git automáticamente |
| Setup automático | ✅ | `git config core.hooksPath .githooks` |
| Idempotencia | ✅ | Seguro ejecutar N veces |
| Mensajes descriptivos | ✅ | Coloreados con [OK], [ERROR] |

---

## Checklist de calidad

- [x] Código limpio (funciones ≤50 líneas bash)
- [x] Sin hardcodes (REPO_ROOT detectado dinámicamente)
- [x] Manejo de errores (set -e, exit codes)
- [x] Documentación inline (comentarios en secc clave)
- [x] Tests manuales pasaron:
  - [x] `./scripts/validate-skill.sh skills/_TEMPLATE` → PASS
  - [x] Pre-commit bloquea skills mal formados
  - [x] `./scripts/setup.sh` instala hooks exitosamente
- [x] No rompe nada existente (compatibilidad con _TEMPLATE)
- [x] Commits atómicos con trailer Copilot

---

## Criterios de aceptación

| Criterio | Status |
|----------|--------|
| `scripts/validate-skill.sh <path>` valida frontmatter YAML | ✅ |
| `scripts/validate-skill.sh` valida secciones obligatorias | ✅ |
| `scripts/validate-skill.sh` valida overview.md con Mermaid | ✅ |
| `.githooks/pre-commit` llama al script para skills/ modificados | ✅ |
| `.githooks/pre-commit` bloquea commit si hay errores | ✅ |
| `setup.sh` instala hook automáticamente | ✅ |
| Script sale con código 1 (error) si falla | ✅ |
| Script sale con código 0 (éxito) si todo ok | ✅ |

---

## Archivos modificados

```
.githooks/pre-commit                    [NEW] 67 líneas
scripts/validate-skill.sh               [MODIFIED] +140 líneas
scripts/setup.sh                        [MODIFIED] +139 líneas
```

**PR**: #3 (merged to develop)  
**Commits**: 1 atomic commit with Co-authored-by trailer

---

## Cómo probar localmente

### Prerequisites
- Git ≥ 2.9 (para `.githooks`)
- Bash ≥ 4.0
- Skill template existe: `skills/_TEMPLATE/SKILL.md`

### Test 1: Validar skill existente
```bash
cd /repo
./scripts/validate-skill.sh skills/_TEMPLATE
# Expected: ✓ VALIDATION PASSED
```

### Test 2: Setup hooks
```bash
./scripts/setup.sh
# Expected: ✓ Setup complete!
# Verificar: git config core.hooksPath → .githooks
```

### Test 3: Pre-commit bloquea error
```bash
cd skills/_TEMPLATE
echo "error" >> SKILL.md
git add SKILL.md
git commit -m "test"
# Expected: ✗ Skill validation FAILED
# Commit bloqueado
git restore SKILL.md
```

### Test 4: Pre-commit permite válido
```bash
cd skills/_TEMPLATE/references
echo "" >> overview.md
git add overview.md
git commit -m "test: add blank line"
# Expected: ✓ All skills passed validation
# Commit exitoso
```

---

## Próximos pasos

- **US-006**: Setup local del desarrollador (integrar `setup.sh` en README)
- **US-010**: Extender `validate-skill.sh` para validar agents (`validate-agent.sh`)

---

## Referencias

- `skills/_TEMPLATE/SKILL.md` — template validado
- `scripts/validate-skill.sh` — fuente de validación
- `.githooks/pre-commit` — hook ejecutable
- `scripts/setup.sh` — instalador idempotente
