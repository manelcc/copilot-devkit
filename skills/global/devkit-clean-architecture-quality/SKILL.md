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

## Scope policy (obligatorio)
- Alcance por defecto: solo diff de la branch actual contra `origin/develop`.
- Orden de inspeccion obligatorio:
  1. cambios sin commit (working tree de la rama),
  2. commits exclusivos de la rama (`origin/develop..HEAD`).
- No analizar repo completo salvo peticion explicita del usuario.
- Si no existe o no es accesible `origin/develop`, detener y pedir confirmacion de rama base.

## Template source of truth (obligatorio)
- Ruta template arquitectura:
  - `/Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/onedrive-IA/COPILOT/docs/quality/_TEMPLATE-architecture-report.md`
- Regla obligatoria:
  - El informe final DEBE usar exactamente este template como estructura base.
  - No se permite inventar secciones ni reordenar bloques fuera del template.
  - Si el template no existe o no es legible, detener y devolver exactamente:
    - `No existe o no es legible el template de arquitectura en COPILOT: /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/onedrive-IA/COPILOT/docs/quality/_TEMPLATE-architecture-report.md`

## Steps
1. Definir scope y focus.
2. Detectar lenguajes presentes en el scope (Java/Kotlin/Swift/Python).
3. Validar ficheros de reglas obligatorios de cada lenguaje detectado.
4. Cargar solo las reglas del lenguaje del fichero analizado.
5. Delimitar alcance obligatorio al diff de branch contra `origin/develop` (working tree + commits de rama).
6. Cargar template obligatorio de arquitectura desde COPILOT.
7. Analizar codigo y registrar solo hallazgos verificables.
8. Clasificar severidad y priorizar por impacto/esfuerzo.
9. Rellenar el template sin alterar su estructura base.
10. Escribir el informe completo en el proyecto analizado:
   - Ruta: `docs/quality/clean-architecture-<YYYY-MM-DD>.md` (fecha de ejecucion real).
   - Crear el directorio `docs/quality/` si no existe.
  - El fichero debe respetar al 100% la estructura del template oficial.
   - Si ya existe un fichero del mismo dia, sobreescribir.

## Preflight gate (obligatorio, fail-fast)
- Antes de redactar cualquier informe, validar y registrar internamente:
  1. Existe y es legible `origin/develop`.
  2. Existe y es legible el template oficial de arquitectura.
  3. Existen reglas obligatorias del lenguaje detectado.
  4. Scope efectivo limitado a:
     - working tree de la rama,
     - commits `origin/develop..HEAD`.
- Si falla cualquiera, detener y no generar informe.

## Definition of Done (obligatorio)
- Un informe de arquitectura solo se considera valido si cumple TODOS los puntos:
  1. Estructura exacta del template oficial (secciones y orden sin invencion ad-hoc).
  2. Scope explicitado como branch diff contra `origin/develop`.
  3. Hallazgos con evidencia verificable (ruta + simbolo + comportamiento).
  4. Cada hallazgo incluye recomendacion accionable.
  5. Incluye referencia externa verificable (libro o web tecnica oficial) por severidad reportada.
  6. Incluye un "good example" aplicable por severidad reportada.
  7. Quality Gate coherente con el contenido del propio informe.

## Errores contractuales (respuesta exacta)
- Si falla el template: `No existe o no es legible el template de arquitectura en COPILOT: /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/onedrive-IA/COPILOT/docs/quality/_TEMPLATE-architecture-report.md`
- Si falla rama base: `No se puede resolver origin/develop. Confirma rama base para continuar el analisis de quality.`
- Si faltan reglas: `No existen los ficheros obligatorios de reglas en skills/global/devkit-clean-architecture-quality/references/rules. Contacten con el equipo de Bankinter DevTools.`

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
- Fichero `docs/quality/clean-architecture-<YYYY-MM-DD>.md` escrito en el proyecto analizado.

## Validation
- Cada hallazgo referencia regla del mismo lenguaje del fichero revisado.
- Cada hallazgo incluye evidencia verificable (ruta + simbolo + comportamiento).
- No se reportan hallazgos sin evidencia.
- Se separan hipotesis con etiqueta `hypothesis-not-verified`.

## Examples
- "Audita arquitectura y calidad de `services/` en Python y Kotlin."
- "Haz quality review de clean architecture para este modulo Swift."
