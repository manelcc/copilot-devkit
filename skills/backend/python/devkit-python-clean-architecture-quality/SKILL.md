---
name: devkit-python-clean-architecture-quality
description: >
  Auditoria de clean-architecture-quality para backend Python basada en evidencia,
  con severidad CRITICAL/HIGH/MEDIUM/LOW y plan de remediacion accionable.
triggers:
  - "python clean architecture quality"
  - "audita arquitectura python"
  - "quality review python backend"
non_triggers:
  - "patron de diseno python"
  - "solo clean code naming"
  - "quality android"
---

# Devkit Python Clean Architecture Quality

## Purpose
Auditar arquitectura y calidad tecnica en codigo Python con reglas por severidad y evidencia verificable.

## When to use
- Auditoria de arquitectura y deuda tecnica en backend Python.
- Revisiones pre-merge o pre-release con foco en riesgo tecnico.
- Necesidad de informe accionable con quick wins y plan 7/30 dias.

## When NOT to use
- Seleccíon de patrones de diseno (usar `devkit-python-patterns`).
- Refactor de estilo o naming sin foco arquitectonico (usar `devkit-clean-code-guardian`).
- Codigo no Python.

## Inputs
- Scope: repo completo o rutas Python concretas.
- Focus opcional: arquitectura, typing, testing, seguridad, concurrencia.
- Constraints: incluir/excluir modulos.

## Steps
1. Definir scope y focus.
2. Validar reglas obligatorias de `references/`.
3. Cargar reglas y analizar codigo Python.
4. Registrar hallazgos con evidencia.
5. Priorizar por severidad e impacto.
6. Proponer quick wins y plan 7/30 dias.

## Required rules
- `references/python-rules-critical.md`
- `references/python-rules-high.md`
- `references/python-rules-medium.md`
- `references/python-rules-low.md`

Si falta alguna regla, detener y reportar la ausente.

## Expected outputs
- Resumen ejecutivo.
- Estado de reglas: `ok|missing`.
- Hallazgos priorizados con evidencia e impacto.
- Recomendaciones accionables.

## Validation
- Reglas presentes y cargadas.
- Hallazgos verificables y trazables en codigo.
- Severidad consistente con impacto.

## Examples
- "Audita clean architecture de `services/payments` en backend Python."
