---
applyTo: "**/*.swift"
---

# iOS SwiftUI Instructions

## Objetivo
Implementar features iOS con SwiftUI siguiendo prácticas modernas de arquitectura, concurrencia, navegación y testing.

## Reglas obligatorias
1. Arquitectura:
- Usar MVVM con `@Observable` (preferido cuando esté disponible) o `ObservableObject`.
- Mantener separación entre vista, estado y lógica de negocio.

2. Estado y datos:
- `@State` para estado local de vista.
- `@Binding` para sincronización padre-hijo.
- `@StateObject` para ownership de view model en la raíz de pantalla.
- `@ObservedObject` para dependencias inyectadas.

3. Concurrencia:
- Priorizar `async/await`.
- Usar `.task {}` para cargas de datos ligadas al ciclo de vida de la vista.
- Mantener mutaciones de UI bajo `@MainActor`.
- Usar Combine solo cuando exista dependencia previa o caso de streaming claramente justificado.

4. Navegación:
- Usar `NavigationStack` para nuevas implementaciones.
- No introducir `NavigationView` en código nuevo.

5. Listados y rendimiento:
- Usar `List` para listas con comportamiento estándar del sistema.
- Usar `ScrollView` + `LazyVStack` para composiciones personalizadas.

6. Testing:
- Escribir tests con XCTest para view models y lógica de dominio.
- Añadir pruebas asíncronas para flujos async/await.
- Añadir UI tests para journeys críticos.

7. Patrones de diseño (obligatorio):
- Identificar patrón aplicable antes de implementar (idealmente comparando candidatos con trade-offs).
- Declarar qué patrón quedó aplicado en la solución final.
- Detectar antipatrones y proponer remediación priorizada cuando aparezcan.
- Usar la skill `ios-patterns` para diagnóstico de patrón/antipatrón.

## Referencias oficiales
- SwiftUI: https://developer.apple.com/documentation/swiftui
- Swift Concurrency: https://developer.apple.com/documentation/swift/concurrency
- XCTest: https://developer.apple.com/documentation/xctest

## Referencias complementarias
- swift-patterns-skill: https://github.com/efremidze/swift-patterns-skill
- ios-patterns (repo actual): skills/ios/swiftui/ios-patterns/
