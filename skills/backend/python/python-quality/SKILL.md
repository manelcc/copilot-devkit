---
name: python-quality
description: >
  Skill de auditoría de calidad Python con hallazgos basados en evidencia,
  priorizados por severidad CRITICAL/HIGH/MEDIUM/LOW y plan de remediación accionable.
triggers:
  - "audita calidad python"
  - "revisa codigo python"
  - "quality review python"
  - "encuentra problemas en este modulo python"
non_triggers:
  - "android quality"
  - "ios quality"
  - "patrones de diseño python"
---

# Python Quality

## Purpose
Auditar código Python produciendo hallazgos verificables, priorizados por severidad con plan de remediación concreto.

## When to use
- Auditar repositorio Python antes de merge o release.
- Revisar módulo por deuda técnica o regresión de calidad.
- Diagnosticar problemas de arquitectura, tipado, seguridad o testing.

## When NOT to use
- Selección de patrón de diseño (usar `python-patterns`).
- Código no Python.
- Revisión puramente de formato.

## Inputs
- Scope: repositorio completo o paths específicos (`src/`, `app/`, `services/`).
- Focus opcional: arquitectura, typing, testing, seguridad, performance.
- Constraints: ignorar carpetas, solo código runtime, incluir/excluir tests.

## Required rules
Usar solo estos ficheros de reglas (no inferir baseline):
- `references/python-rules-critical.md`
- `references/python-rules-high.md`
- `references/python-rules-medium.md`
- `references/python-rules-low.md`

Si algún fichero falta, detener la auditoría e indicar qué regla falta.

## Steps
1. Definir scope de análisis.
2. Validar ficheros de reglas en `references/`.
3. Cargar solo esos ficheros.
4. Inspeccionar código: arquitectura, typing, tests, seguridad, calidad.
5. Registrar solo hallazgos verificables con path, símbolo, comportamiento, regla violada.
6. Clasificar severidad (CRITICAL/HIGH/MEDIUM/LOW).
7. Priorizar por impacto y esfuerzo.
8. Proponer plan incremental 7/30 días.

## Expected outputs
- Resumen ejecutivo.
- Estado de validación de reglas.
- Tabla priorizada de hallazgos.
- Quick wins.
- Riesgos sistémicos.
- Plan de remediación.

## Validation
- [ ] Todos los ficheros de reglas presentes.
- [ ] Cada hallazgo con evidencia trazable.
- [ ] Severidad e impacto priorizados.
- [ ] Informe accionable para equipo Python.
- [ ] `references/overview.md` con diagrama Mermaid.

## Examples

### Example - Hallazgo CRITICAL

```python
SECRET_KEY = "my-super-secret-hardcoded"
DATABASE_URL = "postgresql://user:password@localhost/prod"
```

```text
ID: Q-001
Severity: CRITICAL
Rule: Secretos hardcodeados en código fuente
Evidence: config.py - SECRET_KEY y DATABASE_URL con valores literales
Impact: Exposición de credenciales en repositorio
Recommendation: Usar variables de entorno + python-dotenv; nunca commitear secretos
```

## Sources
- Source origin: /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/skills/python-quality-skill/
- Quality rules origin: /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/python-quality-rules/
