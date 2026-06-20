---
applyTo: "**/*.swift"
---

# Devkit iOS SwiftUI Instructions

## Objetivo
Implementar features iOS con SwiftUI usando arquitectura clara, concurrencia moderna y testing automatizado.

## Reglas obligatorias
1. Arquitectura:
- Usar MVVM con `@Observable` (preferido si el target lo permite) o `ObservableObject`.
- Mantener separación entre vista, estado y lógica de negocio.

2. Estado y datos:
- `@State` para estado local de vista.
- `@Binding` para sincronización padre-hijo.
- `@StateObject` para ownership de view model en raíz de pantalla.
- `@ObservedObject` para dependencias inyectadas.

3. Concurrencia:
- Priorizar `async/await`.
- Usar `.task {}` para cargas ligadas al ciclo de vida de la vista.
- Mantener mutaciones de UI bajo `@MainActor`.
- Usar Combine solo cuando haya dependencia previa o stream continuo justificado.

4. Navegación:
- Usar `NavigationStack` para código nuevo.
- No introducir `NavigationView` en implementaciones nuevas.

5. Testing:
- Escribir unit tests con XCTest para view models y lógica de dominio.
- Añadir pruebas asíncronas para flujos async/await.
- Añadir UI tests para journeys críticos.

7. Patrones de diseño (obligatorio en planning/implementación):
- Antes de implementar, identificar patrón candidato aplicable (mínimo 1, ideal 2 candidatos con trade-off).
- Durante revisión de implementación, indicar explícitamente qué patrón quedó aplicado.
- Si no hay evidencia suficiente del patrón aplicado, marcar el diagnóstico como hipótesis-no-verificada (no bloqueante).
- Detectar y reportar antipatrones potenciales (si existen) con severidad y remediación.
- Usar la skill `ios-patterns` para esta evaluación cuando la tarea lo requiera.

## Matriz de herramientas Swift/iOS a considerar
- `MCP de Xcode (mcpbridge)`: preferido para operaciones de archivos Xcode, diagnósticos y documentación si el entorno dispone de Xcode 26.3+.
- `XcodeBuildMCP`: preferido para build/test en simulador con salida estructurada si se dispone de Xcode 16+ y macOS 14.5+.
- `Foundation Models framework`: aplicar solo en features de IA on-device y en targets compatibles (iOS/iPadOS/macOS/visionOS 26+).
- `GitHub Copilot for Xcode`: usar como asistente principal en editor Xcode cuando el flujo de desarrollo sea local en macOS.
- `swiftui-expert-skill` y `swift-patterns-skill`: usar como referencia complementaria de patrones cuando sea necesario reforzar calidad de diseño.
- `MLX`: usar solo para casos que requieran inferencia local de LLMs en Apple Silicon.
- `SwiftMCP`: considerar para integración de agentes por protocolo MCP cuando haya necesidad real de interoperabilidad agente-herramienta.

## Criterios de decisión
- Si hay dos opciones válidas, priorizar la nativa de Apple o la más mantenible en el stack actual.
- No introducir dependencias de tooling que no puedan ejecutarse en CI o por el equipo.
- Documentar en la US cualquier excepción de compatibilidad por versión de Xcode/SO.

## Referencias oficiales
- SwiftUI: https://developer.apple.com/documentation/swiftui
- Swift Concurrency: https://developer.apple.com/documentation/swift/concurrency
- XCTest: https://developer.apple.com/documentation/xctest
- Foundation Models: https://developer.apple.com/documentation/foundationmodels

## Referencia complementaria de skill
- swift-patterns-skill: https://github.com/efremidze/swift-patterns-skill
- ios-patterns (repo actual): skills/ios/swiftui/ios-patterns/
