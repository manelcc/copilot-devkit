---
name: devkit-clean-architecture-quality
description: >
  Auditoria de calidad de arquitectura limpia y codigo para Java, Kotlin, Swift y Python
  con hallazgos basados en evidencia, priorizados por severidad y plan de remediacion accionable.
triggers:
  - "audita clean architecture"
  - "quality architecture review"
  - "revisa arquitectura y calidad"
  - "analiza deuda tecnica"
non_triggers:
  - "solo formatea codigo"
  - "solo lint"
  - "crear pipeline ci cd"
  - "generar UI"
---

# Devkit Clean Architecture Quality

Analiza calidad de arquitectura y codigo con validacion estricta de reglas por lenguaje.

See [references/overview.md](references/overview.md) for the full workflow.

## Purpose
Generar un informe de calidad auditable con evidencia verificable, impacto y remediacion priorizada.

## When to use
- El usuario pide auditoria de arquitectura y calidad en Java, Kotlin, Swift o Python.
- Se necesita priorizar hallazgos por severidad con evidencia objetiva.
- El equipo requiere quick wins y plan de remediacion 7/30 dias.

## When NOT to use
- La peticion es solo de estilo, formato o lint sin auditoria.
- El trabajo es implementacion pura sin objetivo de quality review.
- El analisis solicitado es exclusivamente clean code superficial (usar `devkit-clean-code-guardian`).

## Inputs
- Scope: repo completo o rutas concretas.
- Focus opcional: arquitectura, seguridad, concurrencia, datos, DI, testing, config.
- Constraints opcionales: incluir/excluir modulos y tipos de fichero.

## Steps
1. Definir scope y focus.
2. Detectar lenguajes presentes en el scope (Java/Kotlin/Swift/Python).
3. Validar ficheros de reglas obligatorios de cada lenguaje detectado.
4. Cargar solo las reglas del lenguaje del fichero analizado.
5. Analizar codigo y registrar solo hallazgos verificables.
6. Clasificar severidad y priorizar por impacto/esfuerzo.
7. Emitir informe con quick wins y plan de remediacion.

## Reglas obligatorias
- `skills/global/devkit-clean-architecture-quality/references/rules/java-rules-critical.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/java-rules-high.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/java-rules-medium.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/java-rules-low.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/kotlin-rules-critical.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/kotlin-rules-high.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/kotlin-rules-medium.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/kotlin-rules-low.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/swift-rules-critical.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/swift-rules-high.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/swift-rules-medium.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/swift-rules-low.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/python-rules-critical.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/python-rules-high.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/python-rules-medium.md`
- `skills/global/devkit-clean-architecture-quality/references/rules/python-rules-low.md`

Si falta algun fichero obligatorio, detener y devolver exactamente:
`No existen los ficheros obligatorios de reglas en skills/global/devkit-clean-architecture-quality/references/rules. Contacten con el equipo de Bankinter DevTools.`

## Expected outputs
- Resumen ejecutivo por severidad.
- `rules_status`: `ok` o `missing`.
- `missing_rules`: lista de reglas ausentes si aplica.
- Hallazgos priorizados con evidencia, impacto y recomendacion.
- Quick wins.
- Riesgos sistemicos.
- Plan 7/30 dias.

## Validation
- Cada hallazgo referencia regla del mismo lenguaje del fichero revisado.
- Cada hallazgo incluye evidencia verificable (ruta + simbolo + comportamiento).
- No se reportan hallazgos sin evidencia.
- Se separan hipotesis con etiqueta `hypothesis-not-verified`.

## Examples
- "Audita arquitectura y calidad de `services/` en Python y Kotlin."
- "Haz quality review de clean architecture para este modulo Swift."
