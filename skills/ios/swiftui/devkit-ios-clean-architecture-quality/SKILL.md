---
name: devkit-ios-clean-architecture-quality
description: >
  Auditoria de clean-architecture-quality para iOS/Swift basada en evidencia,
  con severidad CRITICAL/HIGH/MEDIUM/LOW y plan de remediacion accionable.
triggers:
  - "ios clean architecture quality"
  - "audita arquitectura ios"
  - "quality review swift"
non_triggers:
  - "patron de diseno ios"
  - "solo clean code naming"
  - "quality android"
---

# Devkit iOS Clean Architecture Quality

## Purpose
Auditar arquitectura y calidad tecnica en codigo iOS/Swift con reglas por severidad y evidencia verificable.

## When to use
- Auditoria de arquitectura y deuda tecnica en iOS.
- Revisiones pre-merge o pre-release con foco en riesgo tecnico.
- Necesidad de informe accionable con quick wins y plan 7/30 dias.

## When NOT to use
- Seleccion de patrones de diseno (usar `ios-patterns`).
- Refactor de estilo o naming sin foco arquitectonico (usar `devkit-clean-code-guardian`).
- Codigo no iOS/Swift.

## Inputs
- Scope: repo completo o rutas iOS concretas.
- Focus opcional: arquitectura, concurrencia, seguridad, testing.
- Constraints: incluir/excluir modulos.

## Steps
1. Definir scope y focus.
2. Validar reglas obligatorias de `references/`.
3. Cargar reglas y analizar codigo Swift.
4. Registrar hallazgos con evidencia.
5. Priorizar por severidad e impacto.
6. Proponer quick wins y plan 7/30 dias.

## Required rules
- `references/ios-rules-critical.md`
- `references/ios-rules-high.md`
- `references/ios-rules-medium.md`
- `references/ios-rules-low.md`

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
- "Audita clean architecture del modulo `Login` en iOS."
