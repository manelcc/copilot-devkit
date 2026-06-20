---
name: ios-quality
description: >
  Skill de auditoría de calidad iOS/Swift con hallazgos basados en evidencia,
  priorizados por severidad CRITICAL/HIGH/MEDIUM/LOW y plan de remediación accionable.
triggers:
  - "audita calidad ios"
  - "revisa codigo swift"
  - "quality review ios"
  - "encuentra problemas en este modulo ios"
non_triggers:
  - "android quality"
  - "python quality"
  - "patrones de diseño swift"
---

# iOS Quality

## Purpose
Auditar código iOS/Swift produciendo hallazgos verificables, priorizados por severidad con plan de remediación concreto.

## When to use
- Auditar repositorio iOS antes de merge o release.
- Revisar módulo por deuda técnica o regresión de calidad.
- Diagnosticar problemas de arquitectura, concurrencia, seguridad o testing.

## When NOT to use
- Selección de patrón de diseño (usar `ios-patterns`).
- Código no iOS/Swift.
- Revisión puramente estética.

## Inputs
- Scope: repositorio completo o paths específicos (`Sources/`, `Features/`, `Services/`).
- Focus opcional: arquitectura, concurrencia, seguridad, testing, SwiftUI patterns.
- Constraints: ignorar módulos, solo Swift, incluir/excluir config files.

## Required rules
Usar solo estos ficheros de reglas (no inferir baseline):
- `references/ios-rules-critical.md`
- `references/ios-rules-high.md`
- `references/ios-rules-medium.md`
- `references/ios-rules-low.md`

Si algún fichero falta, detener la auditoría e indicar qué regla falta.

## Steps
1. Definir scope de análisis.
2. Validar que los ficheros de reglas existen en `references/`.
3. Cargar solo esos ficheros de reglas.
4. Inspeccionar código: arquitectura, ViewModel/Observable, concurrencia, seguridad, tests.
5. Registrar solo hallazgos verificables.
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
- [ ] Todos los ficheros de reglas están presentes.
- [ ] Cada hallazgo tiene evidencia trazable en código Swift.
- [ ] Severidad e impacto priorizados.
- [ ] Informe accionable para equipo iOS.
- [ ] `references/overview.md` con diagrama Mermaid.

## Examples

### Example - Hallazgo HIGH

```swift
class LoginViewModel: ObservableObject {
    func login() {
        DispatchQueue.global().async {
            let result = self.authService.login()
            self.isLoading = false  // ⚠️ mutación UI fuera de main thread
        }
    }
}
```

```text
ID: Q-001
Severity: HIGH
Rule: Mutación de estado UI fuera de @MainActor
Evidence: LoginViewModel.swift - isLoading asignado desde global queue
Impact: Race condition, posible crash en actualización de UI
Recommendation: Marcar ViewModel con @MainActor o usar await MainActor.run {}
```

## Sources
- Source origin: /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/skills/ios-quality-skill/
- Quality rules origin: /Users/manelcc/Library/CloudStorage/OneDrive-SopraSteria/mac/KMP_APPS/PRUEBA-TECNICA/ANDROID/.github/ios-quality-rules/
