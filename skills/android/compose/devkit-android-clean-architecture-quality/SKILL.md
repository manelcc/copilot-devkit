---
name: devkit-android-clean-architecture-quality
description: >
  Auditoria de clean-architecture-quality para Android/Kotlin basada en evidencia,
  con severidad CRITICAL/HIGH/MEDIUM/LOW y plan de remediacion accionable.
triggers:
  - "android clean architecture quality"
  - "audita arquitectura android"
  - "quality review android"
non_triggers:
  - "patron de diseno android"
  - "solo clean code naming"
  - "quality ios"
---

# Devkit Android Clean Architecture Quality

## Purpose
Auditar arquitectura y calidad tecnica en codigo Android/Kotlin con reglas por severidad y evidencia verificable.

## When to use
- Auditoria de arquitectura y deuda tecnica en Android.
- Revisiones pre-merge o pre-release con foco en riesgo tecnico.
- Necesidad de informe accionable con quick wins y plan 7/30 dias.

## When NOT to use
- Seleccion de patrones de diseno (usar `android-patterns`).
- Refactor de estilo o naming sin foco arquitectonico (usar `devkit-clean-code-guardian`).
- Codigo no Android/Kotlin.

## Inputs
- Scope: repo completo o rutas Android concretas.
- Focus opcional: arquitectura de capas, concurrencia, seguridad, testing.
- Constraints: incluir/excluir modulos.

## Steps
1. Definir scope y focus.
2. Validar reglas obligatorias de `references/`.
3. Cargar reglas y analizar codigo Kotlin/Android.
4. Registrar hallazgos con evidencia (ruta, simbolo, comportamiento).
5. Priorizar por severidad e impacto.
6. Proponer quick wins y plan 7/30 dias.

## Required rules
- `references/android-rules-critical.md`
- `references/android-rules-high.md`
- `references/android-rules-medium.md`
- `references/android-rules-low.md`

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
- "Audita clean architecture del modulo `feature/profile` en Android."
