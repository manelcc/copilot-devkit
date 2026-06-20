---
name: android-quality
description: >
  Skill de auditoría de calidad Android/Kotlin con hallazgos basados en evidencia,
  priorizados por severidad CRITICAL/HIGH/MEDIUM/LOW y plan de remediación accionable.
triggers:
  - "audita calidad android"
  - "revisa codigo kotlin android"
  - "quality review android"
  - "encuentra problemas en este modulo android"
non_triggers:
  - "ios quality"
  - "python quality"
  - "patrones de diseño"
---

# Android Quality

## Purpose
Auditar código Android/Kotlin produciendo hallazgos verificables, priorizados por severidad con plan de remediación concreto.

## When to use
- Auditar un repositorio Android antes de merge o release.
- Revisar módulo específico por deuda técnica.
- Diagnosticar problemas de arquitectura, concurrencia o seguridad.

## When NOT to use
- Selección de patrón de diseño (usar `android-patterns`).
- Código no Android/Kotlin.
- Revisión puramente estética sin impacto en calidad.

## Inputs
- Scope: repositorio completo o paths específicos (`app/`, `feature/*`, `data/*`).
- Focus opcional: arquitectura, concurrencia, testing, seguridad, performance.
- Constraints: ignorar módulos, solo Kotlin, incluir/excluir Gradle.

## Required rules
Usar solo estas reglas base (no inferir, no usar baseline propio):
- `references/android-rules-critical.md`
- `references/android-rules-high.md`
- `references/android-rules-medium.md`
- `references/android-rules-low.md`

Si algún fichero falta, detener la auditoría e indicar qué regla falta.

## Steps
1. Definir scope de análisis.
2. Validar que los ficheros de reglas existen en `references/`.
3. Cargar solo esos ficheros de reglas.
4. Inspeccionar código: arquitectura de capas, ViewModel, coroutines, seguridad, tests.
5. Registrar solo hallazgos verificables con: path, símbolo, comportamiento observado, regla violada.
6. Clasificar severidad (CRITICAL/HIGH/MEDIUM/LOW).
7. Priorizar por impacto y esfuerzo de remediación.
8. Proponer plan incremental 7/30 días.

## Expected outputs
- Resumen ejecutivo.
- Estado de validación de reglas: `rules_status: ok|missing`.
- Tabla priorizada de hallazgos con: id, severity, rule_reference, evidence, impact, recommendation.
- Quick wins.
- Riesgos sistémicos.
- Plan de remediación sugerido.

## Validation
- [ ] Todos los ficheros de reglas están presentes.
- [ ] Cada hallazgo tiene evidencia trazable en código.
- [ ] Severidad e impacto priorizados.
- [ ] Informe accionable para equipo Android.
- [ ] `references/overview.md` con diagrama Mermaid.

## Examples

### Example - Hallazgo CRITICAL

```kotlin
object UserSession {
    var token: String = ""
    var userId: Int = -1
}
```

```text
ID: Q-001
Severity: CRITICAL
Rule: ARCH_001 (Singleton con estado global mutable)
Evidence: UserSession.kt - estado mutable accesible globalmente sin control de scope
Impact: Testabilidad nula, race conditions en acceso concurrente
Recommendation: Inyectar SessionRepository con Hilt; exponer estado como Flow inmutable
```

## Sources
- Source origin: /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/skills/android-quality-skill/
- Quality rules origin: /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/android-quality-rules/
