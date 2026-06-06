# US-045 — Instrucciones iOS SwiftUI

**Como** desarrollador iOS SwiftUI,
**quiero** reglas Copilot claras para Swift + SwiftUI,
**para** generar código consistente con las mejores prácticas del stack.

---

## Criterios de aceptación

1. El archivo `instructions/ios-swiftui.instructions.md` existe y se aplica a `**/*.swift`.
2. Contiene reglas sobre MVVM, Combine, NavigationStack, async/await y SPM.
3. Describe convenciones de UI, estados de vista y pruebas SwiftUI.
4. Referencia las skills de iOS migradas en `skills/ios/`.
5. El documento es parseable por el sistema de instrucciones del repositorio.

---

## Referencias

- `US-040` — Skills iOS migradas
- Guía de instrucciones y `DoD`

---

## Validación INVEST

| Criterio | ✅ / ⚠️ | Observación |
|---|---|---|
| Independiente | ✅ | Documentación de instrucciones centrada en SwiftUI |
| Negociable | ✅ | Las reglas pueden ajustarse según los patrones adoptados |
| Valiosa | ✅ | Asegura generación de código SwiftUI coherente |
| Estimable | ✅ | Alcance de un archivo de instrucciones |
| Small | ✅ | Tarea bien acotada |
| Testeable | ✅ | CA verificables con parseo y revisión de contenido |
